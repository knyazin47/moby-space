import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/config/app_copy.dart';
import '../../core/config/observed_web_content.dart';
import '../../core/config/source_public_content.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/common.dart';
import '../../core/ui/source_assets.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = watchBankSnapshot(ref).profile;
    return MobyPage(
      title: AppCopy.profile,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: MobyColors.brand,
            foregroundColor: Colors.white,
            child: Text(profile.initials, style: const TextStyle(fontSize: 26)),
          ),
          const SizedBox(height: 24),
          for (final field in [
            (AppCopy.firstName, profile.firstName),
            (AppCopy.lastName, profile.lastName),
            (AppCopy.phone, profile.phone),
          ])
            ListTile(title: Text(field.$1), subtitle: Text(field.$2)),
        ],
      ),
    );
  }
}

class InfoPage extends StatelessWidget {
  const InfoPage({super.key, required this.content});
  final InfoPageContent content;
  @override
  Widget build(BuildContext context) => MobyPage(
    title: content.title,
    replayLoad: content.replayLoad,
    child: content.empty
        ? Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SourceIcon(
                        content.assetName ?? 'ic_empty_list',
                        width: content.iconWidth,
                        height: content.iconHeight,
                      ),
                      SizedBox(
                        height: content.assetName == 'ic_empty_requests'
                            ? 16
                            : 12,
                      ),
                      Text(
                        content.description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: MobyColors.legacySecondary,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (content.actionLabel != null)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 24,
                  child: Material(
                    color: Colors.white,
                    elevation: 4,
                    shadowColor: const Color(0x26000000),
                    borderRadius: BorderRadius.circular(32),
                    child: InkWell(
                      key: const ValueKey('empty-product-action'),
                      borderRadius: BorderRadius.circular(32),
                      onTap: () => content.actionRoute != null
                          ? context.push(content.actionRoute!)
                          : showDialog<void>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text(
                                  SourceSafetyContent.depositUnavailable,
                                ),
                                content: const Text(
                                  SourceSafetyContent.depositDescription,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text(
                                      SourceSafetyContent.close,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 56),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (content.actionAsset != null) ...[
                              SourceIcon(
                                content.actionAsset!,
                                size: 30,
                                color: MobyColors.brand,
                              ),
                              const SizedBox(width: 8),
                            ],
                            Flexible(
                              child: Text(
                                content.actionLabel!,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Text(
              content.description,
              style: const TextStyle(fontSize: 15),
            ),
          ),
  );
}

class SourceSafetyPage extends StatefulWidget {
  const SourceSafetyPage({super.key});
  @override
  State<SourceSafetyPage> createState() => _SourceSafetyPageState();
}

class _SourceSafetyPageState extends State<SourceSafetyPage> {
  final _links = <TapGestureRecognizer>[];

  @override
  void initState() {
    super.initState();
    for (final paragraph in SourceSafetyContent.paragraphs) {
      for (final run in paragraph.where((run) => run.link)) {
        _links.add(TapGestureRecognizer()..onTap = () => _openLink(run.text));
      }
    }
  }

  void _openLink(String label) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        label == 'mtbank.by' ? label : SourceSafetyContent.previewTitle,
      ),
      content: Text(
        label == 'mtbank.by'
            ? SourceSafetyContent.siteDescription
            : SourceSafetyContent.previewDescription,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(SourceSafetyContent.close),
        ),
      ],
    ),
  );

  @override
  void dispose() {
    for (final link in _links) {
      link.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var linkIndex = 0;
    return MobyPage(
      title: SourceSafetyContent.title,
      replayLoad: true,
      child: ListView(
        key: const ValueKey('safety-article'),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          const Text(
            SourceSafetyContent.heading,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              height: 1.18,
            ),
          ),
          const SizedBox(height: 20),
          for (final paragraph in SourceSafetyContent.paragraphs) ...[
            Text.rich(
              TextSpan(
                children: [
                  for (final run in paragraph)
                    TextSpan(
                      text: run.text,
                      recognizer: run.link ? _links[linkIndex++] : null,
                      style: run.link
                          ? const TextStyle(
                              color: MobyColors.brand,
                              decoration: TextDecoration.underline,
                              decorationColor: MobyColors.brand,
                            )
                          : null,
                    ),
                ],
              ),
              style: const TextStyle(
                fontSize: 15,
                height: 1.22,
                color: MobyColors.legacyText,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }
}

class DemoControlsPage extends ConsumerWidget {
  const DemoControlsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => MobyPage(
    title: AppCopy.demoControls,
    child: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(AppCopy.demoDescription),
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: () => context.push('/reference/web'),
          child: const Text(ObservedWebContent.operatorLabel),
        ),
        const SizedBox(height: 24),
        FilledButton(
          key: const ValueKey('reset-demo'),
          onPressed: () {
            ref.read(bankRepositoryProvider).reset();
            ref.read(demoSessionProvider.notifier).restart();
            context.go('/home');
          },
          child: const Text(AppCopy.reset),
        ),
      ],
    ),
  );
}
