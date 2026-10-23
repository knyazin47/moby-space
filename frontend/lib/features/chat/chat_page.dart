import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/config/app_copy.dart';
import '../../core/config/chat_content.dart';
import '../../core/config/source_emoji_catalog.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/source_assets.dart';
import '../../core/ui/native_progress.dart';
import '../../core/config/demo_motion.dart';

// This page is the only writer of its local store. Reopening the route retains
// it; restarting the demo replaces the store and the keyed editing surface.
final _chatSessionProvider = Provider<_ChatSession>((ref) {
  ref.watch(demoSessionProvider);
  return _ChatSession();
});

class _ChatSession {
  final messages = <String>[];
  final recent = <SourceEmoji>[];
  final preferredVariants = <String, SourceEmoji>{};
  TextEditingValue draft = TextEditingValue.empty;
}

/// Local conversation only; no transport or bank session is created.
class ChatPage extends ConsumerWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(_chatSessionProvider);
    return _ChatSurface(key: ObjectKey(session), session: session);
  }
}

class _ChatSurface extends StatefulWidget {
  const _ChatSurface({super.key, required this.session});
  final _ChatSession session;

  @override
  State<_ChatSurface> createState() => _ChatPageState();
}

class _ChatPageState extends State<_ChatSurface> with WidgetsBindingObserver {
  final _input = TextEditingController();
  final _query = TextEditingController();
  final _inputFocus = FocusNode();
  final _searchFocus = FocusNode();
  final _scroll = ScrollController();
  final _messageKeys = <GlobalKey>[];
  List<String> get _messages => widget.session.messages;
  List<SourceEmoji> get _recent => widget.session.recent;
  bool _searching = false;
  bool _emojiVisible = false;
  int _category = 0;
  int _match = 0;
  double _keyboardHeight = ChatContent.initialEmojiPanelHeight;
  double _lastKeyboardInset = 0;
  Timer? _historyTimer;
  bool _historyLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _input.value = widget.session.draft;
    _messageKeys.addAll(List.generate(_messages.length, (_) => GlobalKey()));
    _input.addListener(_refresh);
    _inputFocus.addListener(_refresh);
    _searchFocus.addListener(_refresh);
    _query.addListener(_searchChanged);
    _historyTimer = Timer(DemoMotion.bodyLoad, () {
      if (mounted) setState(() => _historyLoading = false);
    });
  }

  void _refresh() {
    widget.session.draft = _input.value;
    if (mounted) setState(() {});
  }

  void _searchChanged() {
    setState(() => _match = 0);
    _revealMatch();
  }

  @override
  void dispose() {
    _historyTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _input.removeListener(_refresh);
    _inputFocus.removeListener(_refresh);
    _searchFocus.removeListener(_refresh);
    _query.removeListener(_searchChanged);
    _input.dispose();
    _query.dispose();
    _inputFocus.dispose();
    _searchFocus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final view = View.of(context);
      final inset = view.viewInsets.bottom / view.devicePixelRatio;
      // Android can consume Back to hide IME without clearing text focus.
      // Clear that stale focus so the next Back leaves the route normally.
      if (_lastKeyboardInset > 0 &&
          inset == 0 &&
          !_emojiVisible &&
          !_searching) {
        _inputFocus.unfocus();
      }
      _lastKeyboardInset = inset;
    });
  }

  List<int> get _matches {
    final term = _query.text.trim().toLowerCase();
    if (term.isEmpty) return const [];
    return [
      for (var i = 0; i < _messages.length; i++)
        if (_messages[i].toLowerCase().contains(term)) i,
    ];
  }

  bool get _canSend => _input.text.trim().isNotEmpty;

  bool get _ownsBack =>
      _searching ||
      _emojiVisible ||
      _inputFocus.hasFocus ||
      _searchFocus.hasFocus;

  void _back() {
    if (_searching) {
      _closeSearch();
    } else if (_emojiVisible) {
      setState(() => _emojiVisible = false);
      _inputFocus.unfocus();
    } else if (_inputFocus.hasFocus || _searchFocus.hasFocus) {
      _inputFocus.unfocus();
      _searchFocus.unfocus();
    } else if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  void _openSearch() {
    _inputFocus.unfocus();
    setState(() {
      _emojiVisible = false;
      _searching = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _searching) _searchFocus.requestFocus();
    });
  }

  void _closeSearch() {
    _searchFocus.unfocus();
    _query.clear();
    setState(() => _searching = false);
  }

  void _toggleEmoji() {
    if (_emojiVisible) {
      setState(() => _emojiVisible = false);
      _inputFocus.requestFocus();
    } else {
      setState(() => _emojiVisible = true);
      // Keep a caret/selection for the custom keyboard, without asking the
      // platform IME to open. The rebuilt field is read-only in this mode.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _emojiVisible) _inputFocus.requestFocus();
      });
    }
  }

  void _send() {
    final message = _input.text.trim();
    if (message.isEmpty) return;
    setState(() {
      _messages.add(message);
      _messageKeys.add(GlobalKey());
      _input.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scroll.hasClients) {
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    });
  }

  void _insertEmoji(SourceEmoji emoji) {
    final value = _input.value;
    final selection = value.selection;
    final start = selection.isValid ? selection.start : value.text.length;
    final end = selection.isValid ? selection.end : value.text.length;
    final text = value.text.replaceRange(start, end, emoji.text);
    if (text.characters.length > ChatContent.maxMessageLength) return;
    _input.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: start + emoji.text.length),
    );
    setState(() {
      _recent.removeWhere((item) => item.text == emoji.text);
      _recent.insert(0, emoji);
      if (_recent.length > ChatContent.maxRecentEmoji) _recent.removeLast();
    });
  }

  void _deleteGrapheme() {
    final value = _input.value;
    final selection = value.selection;
    final start = selection.isValid ? selection.start : value.text.length;
    final end = selection.isValid ? selection.end : value.text.length;
    if (start != end) {
      _input.value = TextEditingValue(
        text: value.text.replaceRange(start, end, ''),
        selection: TextSelection.collapsed(offset: start),
      );
    } else if (start > 0) {
      var offset = 0;
      for (final grapheme in value.text.characters) {
        final next = offset + grapheme.length;
        if (start <= next) {
          _input.value = TextEditingValue(
            text: value.text.replaceRange(offset, next, ''),
            selection: TextSelection.collapsed(offset: offset),
          );
          break;
        }
        offset = next;
      }
    }
  }

  void _moveMatch(int direction) {
    final next = _match + direction;
    if (next < 0 || next >= _matches.length) return;
    setState(() => _match = next);
    _revealMatch();
  }

  void _revealMatch() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final matches = _matches;
      if (matches.isEmpty || _match >= matches.length) return;
      final target = _messageKeys[matches[_match]].currentContext;
      if (target != null) {
        Scrollable.ensureVisible(target, alignment: 0.5);
      }
    });
  }

  Future<void> _showAttachments() async {
    _inputFocus.unfocus();
    setState(() => _emojiVisible = false);
    final action = await showModalBottomSheet<ChatAttachmentAction>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SourceIcon('ic_attach', size: 32),
                const SizedBox(height: 16),
                const Text(
                  ChatContent.attachmentTitle,
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    for (final item in ChatContent.attachments)
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: item == ChatContent.attachments.last ? 0 : 6,
                          ),
                          child: InkWell(
                            key: ValueKey('chat-attachment-${item.id}'),
                            onTap: () => Navigator.pop(context, item),
                            child: Column(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: MobyColors.rowBorder,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: SourceIcon(
                                    item.icon,
                                    width: item.iconWidth,
                                    height: item.iconHeight,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item.label,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton(
                    key: const ValueKey('chat-attachment-cancel'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: MobyColors.brand,
                      side: const BorderSide(color: MobyColors.brand),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(ChatContent.cancel),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (!mounted || action == null) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(action.label),
        content: const Text(ChatContent.attachmentDemo),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(ChatContent.close),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.viewInsetsOf(context).bottom;
    if (inset > 0) _keyboardHeight = inset;
    return PopScope(
      canPop: !_ownsBack && context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _back();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          title: AnimatedSwitcher(
            duration: ChatContent.searchFade,
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeIn,
            child: _searching ? _searchToolbar() : _toolbar(),
          ),
        ),
        body: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // One bottom surface: system IME or the app's source emoji grid.
              final panelHeight = math.min(
                _emojiVisible ? _keyboardHeight : inset,
                math.max(0.0, constraints.maxHeight - 110),
              );
              return Column(
                children: [
                  Expanded(child: _conversation()),
                  if (_searching)
                    _searchNavigation()
                  else
                    _composer(
                      maxHeight: math.max(
                        44,
                        constraints.maxHeight - panelHeight - 16,
                      ),
                    ),
                  if (_emojiVisible)
                    SizedBox(height: panelHeight, child: _emojiPanel())
                  else
                    SizedBox(height: panelHeight),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _toolbar() => Row(
    key: const ValueKey('chat-toolbar'),
    children: [
      _iconButton('ic_app_bar_arrow', AppCopy.back, _back, width: 56),
      const Expanded(child: Text(ChatContent.title)),
      _iconButton(
        'ic_search',
        ChatContent.search,
        _openSearch,
        width: 36,
        iconSize: 18,
      ),
      const SizedBox(width: 16),
    ],
  );

  Widget _searchToolbar() => Padding(
    key: const ValueKey('chat-search-toolbar'),
    padding: const EdgeInsets.only(left: 16),
    child: Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 44,
            child: TextField(
              key: const ValueKey('chat-search-input'),
              controller: _query,
              focusNode: _searchFocus,
              maxLength: ChatContent.maxSearchLength,
              style: const TextStyle(fontSize: 15),
              decoration: InputDecoration(
                hintText: ChatContent.search,
                counterText: '',
                filled: true,
                fillColor: const Color(0xFFEFF5FB),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                prefixIconConstraints: const BoxConstraints.tightFor(width: 47),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 16, right: 13),
                  child: SourceIcon('ic_search', size: 18),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: MobyColors.brand),
                ),
                suffixIconConstraints: const BoxConstraints.tightFor(width: 34),
                suffixIcon: _query.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: ChatContent.clearSearch,
                        padding: const EdgeInsets.only(right: 8),
                        icon: const SourceIcon('ic_input_remove', size: 10),
                        onPressed: _query.clear,
                      ),
              ),
            ),
          ),
        ),
        TextButton(
          onPressed: _closeSearch,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          child: const Text(ChatContent.cancel, style: TextStyle(fontSize: 13)),
        ),
      ],
    ),
  );

  Widget _conversation() {
    if (_historyLoading) {
      return const Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.only(top: 12),
          child: NativeProgress(size: 24),
        ),
      );
    }
    if (_messages.isEmpty) {
      return const Center(
        child: Text(
          ChatContent.empty,
          style: TextStyle(fontSize: 15, color: MobyColors.legacySecondary),
        ),
      );
    }
    final matches = _matches;
    final selected = _searching && matches.isNotEmpty ? matches[_match] : -1;
    return SingleChildScrollView(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < _messages.length; i++)
            Align(
              key: _messageKeys[i],
              alignment: Alignment.centerRight,
              child: Container(
                margin: const EdgeInsets.only(bottom: 12, left: 48),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: i == selected
                      ? const Color(0xFFE1EDFF)
                      : MobyColors.productsBackground,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(_messages[i], style: const TextStyle(fontSize: 15)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _composer({required double maxHeight}) => Padding(
    padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _iconButton(
          'ic_attach',
          ChatContent.attach,
          _showAttachments,
          width: 36,
          key: const ValueKey('chat-attach'),
        ),
        const SizedBox(width: 2),
        Expanded(
          child: Container(
            constraints: BoxConstraints(minHeight: 44, maxHeight: maxHeight),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF5FB),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                TextField(
                  key: const ValueKey('chat-input'),
                  controller: _input,
                  focusNode: _inputFocus,
                  readOnly: _emojiVisible,
                  showCursor: true,
                  minLines: 1,
                  maxLines: 9,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(
                      ChatContent.maxMessageLength,
                    ),
                  ],
                  onTap: () {
                    if (_emojiVisible) setState(() => _emojiVisible = false);
                  },
                  style: const TextStyle(
                    fontSize: 15,
                    color: MobyColors.legacyText,
                  ),
                  decoration: InputDecoration(
                    hintText: _emojiVisible ? null : ChatContent.messageHint,
                    hintStyle: const TextStyle(
                      fontSize: 15,
                      color: MobyColors.legacySecondary,
                    ),
                    filled: false,
                    isDense: true,
                    contentPadding: const EdgeInsets.fromLTRB(16, 12, 40, 12),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 1),
                  child: _iconButton(
                    _emojiVisible ? 'ic_keyboard' : 'ic_emoji',
                    _emojiVisible ? ChatContent.keyboard : ChatContent.emoji,
                    _toggleEmoji,
                    iconHeight: _emojiVisible ? 19 : 24,
                    key: const ValueKey('chat-emoji-toggle'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 44,
          height: 44,
          child: IconButton(
            key: const ValueKey('chat-send'),
            tooltip: AppCopy.send,
            onPressed: _canSend ? _send : null,
            style: IconButton.styleFrom(
              padding: const EdgeInsets.only(left: 2),
              backgroundColor: _canSend
                  ? MobyColors.brand
                  : const Color(0xFFDFE3EC),
              disabledBackgroundColor: const Color(0xFFDFE3EC),
            ),
            icon: const RotatedBox(
              quarterTurns: 2,
              child: SourceIcon('ic_app_bar_arrow', color: Colors.white),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _searchNavigation() {
    final count = _matches.length;
    return Container(
      key: const ValueKey('chat-search-panel'),
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0x1F0A2847))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              ChatContent.matchCount(count == 0 ? 0 : _match + 1, count),
              key: const ValueKey('chat-search-count'),
              style: const TextStyle(fontSize: 15),
            ),
          ),
          _iconButton(
            'ic_arrow_down',
            ChatContent.previousMatch,
            _match > 0 ? () => _moveMatch(-1) : null,
            width: 36,
            rotation: 2,
          ),
          const SizedBox(width: 16),
          _iconButton(
            'ic_arrow_down',
            ChatContent.nextMatch,
            _match + 1 < count ? () => _moveMatch(1) : null,
            width: 36,
          ),
        ],
      ),
    );
  }

  Widget _emojiPanel() {
    final categories = SourceEmojiCatalog.categories;
    final emojis = _category == -1 ? _recent : categories[_category].emojis;
    return Column(
      key: const ValueKey('chat-emoji-panel'),
      children: [
        SizedBox(
          height: 36,
          child: Row(
            children: [
              _emojiTab(
                SourceEmojiCatalog.recentAssetPath,
                ChatContent.recent,
                -1,
              ),
              for (var i = 0; i < categories.length; i++)
                _emojiTab(
                  categories[i].tabAssetPath,
                  ChatContent.categoryLabels[i],
                  i,
                ),
              Expanded(
                child: IconButton(
                  key: const ValueKey('chat-emoji-backspace'),
                  tooltip: ChatContent.backspace,
                  padding: const EdgeInsets.all(4),
                  onPressed: _deleteGrapheme,
                  icon: Image.asset(SourceEmojiCatalog.backspaceAssetPath),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: Color(0xFFCCCCCC)),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final columns = math.max(
                1,
                ((constraints.maxWidth - 12 + 6) / 42).floor(),
              );
              return GridView.builder(
                key: ValueKey('chat-emoji-grid-$_category'),
                padding: const EdgeInsets.all(6),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                ),
                itemCount: emojis.length,
                itemBuilder: (context, index) {
                  final emoji = emojis[index];
                  final chosen =
                      widget.session.preferredVariants[emoji.text] ?? emoji;
                  return Builder(
                    builder: (cellContext) => InkWell(
                      key: ValueKey('chat-emoji-$_category-$index'),
                      onTap: () => _insertEmoji(chosen),
                      onLongPress: emoji.variants.isEmpty
                          ? null
                          : () => _showVariants(cellContext, emoji),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Image.asset(
                          chosen.assetPath,
                          semanticLabel: chosen.text,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _showVariants(BuildContext cellContext, SourceEmoji base) async {
    final box = cellContext.findRenderObject()! as RenderBox;
    final origin = box.localToGlobal(Offset.zero);
    final screen = MediaQuery.sizeOf(context);
    final width = box.size.width;
    final variants = [base, ...base.variants];
    final popupWidth = math.min(
      screen.width - 8,
      variants.length * (width + 4) + 8,
    );
    final left = (origin.dx + width / 2 - popupWidth / 2).clamp(
      4.0,
      math.max(4.0, screen.width - popupWidth - 4),
    );
    final top = math.max(
      MediaQuery.paddingOf(context).top,
      origin.dy - width - 16,
    );
    final selected = await showGeneralDialog<SourceEmoji>(
      context: context,
      barrierDismissible: true,
      barrierLabel: ChatContent.close,
      barrierColor: Colors.transparent,
      transitionDuration: Duration.zero,
      pageBuilder: (popupContext, _, _) => Stack(
        children: [
          Positioned(
            left: left.toDouble(),
            top: top,
            width: popupWidth.toDouble(),
            child: Material(
              key: const ValueKey('chat-emoji-variants'),
              color: Colors.white,
              elevation: 2,
              borderRadius: BorderRadius.circular(1),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < variants.length; i++)
                      Padding(
                        padding: const EdgeInsets.all(2),
                        child: InkWell(
                          key: ValueKey('chat-emoji-variant-$i'),
                          onTap: () => Navigator.pop(popupContext, variants[i]),
                          child: SizedBox(
                            width: width,
                            height: width,
                            child: Padding(
                              padding: const EdgeInsets.all(2),
                              child: Image.asset(
                                variants[i].assetPath,
                                semanticLabel: variants[i].text,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
    if (mounted && selected != null) {
      widget.session.preferredVariants[base.text] = selected;
      _insertEmoji(selected);
    }
  }

  Widget _emojiTab(String path, String label, int index) => Expanded(
    child: Semantics(
      selected: _category == index,
      child: IconButton(
        key: ValueKey('chat-emoji-category-$index'),
        tooltip: label,
        padding: const EdgeInsets.all(4),
        onPressed: () => setState(() => _category = index),
        icon: Image.asset(
          path,
          color: _category == index ? MobyColors.brand : null,
        ),
      ),
    ),
  );

  Widget _iconButton(
    String icon,
    String label,
    VoidCallback? onPressed, {
    Key? key,
    double width = 44,
    double iconSize = 24,
    double? iconHeight,
    int rotation = 0,
  }) => SizedBox(
    width: width,
    height: 44,
    child: IconButton(
      key: key,
      tooltip: label,
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      icon: Opacity(
        opacity: onPressed == null ? 0.5 : 1,
        child: RotatedBox(
          quarterTurns: rotation,
          child: SourceIcon(
            icon,
            size: iconSize,
            height: iconHeight,
            color: MobyColors.brand,
          ),
        ),
      ),
    ),
  );
}
