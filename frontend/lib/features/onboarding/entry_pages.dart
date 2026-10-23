import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../app/family_session.dart';
import '../../core/theme/mt_brand_theme.dart';
import '../../data/server/family_api.dart';

class FamilyEntryFrame extends StatelessWidget {
  const FamilyEntryFrame({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
    this.back = true,
  });
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final bool back;
  @override
  Widget build(BuildContext context) => Theme(
    data: buildMtBrandTheme(),
    child: Builder(
      builder: (context) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: back,
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: MtBrandMetrics.maxContentWidth,
              ),
              child: ListView(
                padding: const EdgeInsets.all(MtBrandMetrics.pagePadding),
                children: [
                  Text(title, style: Theme.of(context).textTheme.headlineLarge),
                  if (subtitle != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                  const SizedBox(height: 32),
                  ...children,
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class FamilyWelcomePage extends ConsumerWidget {
  const FamilyWelcomePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(familySessionProvider);
    return ListenableBuilder(
      listenable: session,
      builder: (context, _) {
        if (session.phase == FamilySessionPhase.restoring) {
          return FamilyEntryFrame(
            title: 'С возвращением',
            back: false,
            subtitle: session.error ?? 'Восстанавливаем безопасный вход',
            children: [
              if (session.error == null)
                const Center(child: CircularProgressIndicator())
              else
                FilledButton(
                  onPressed: session.restore,
                  child: const Text('Повторить'),
                ),
            ],
          );
        }
        return FamilyEntryFrame(
          title: 'Деньги — часть взросления',
          back: false,
          subtitle: 'У каждого свой доступ. У семьи общие возможности.',
          children: [
            const Icon(
              Icons.people_alt_outlined,
              size: 100,
              color: MtBrandColors.blue,
            ),
            const SizedBox(height: 40),
            FilledButton(
              onPressed: () => context.go('/adult/phone'),
              child: const Text('Я взрослый'),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => context.go('/child/pair'),
              child: const Text('Я ребёнок'),
            ),
          ],
        );
      },
    );
  }
}

class AdultPhonePage extends StatefulWidget {
  const AdultPhonePage({super.key});
  @override
  State<AdultPhonePage> createState() => _AdultPhonePageState();
}

class _AdultPhonePageState extends State<AdultPhonePage> {
  final _phone = TextEditingController();
  String? _error;
  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FamilyEntryFrame(
    title: 'Вход для взрослого',
    subtitle: 'Укажите условный номер телефона для этого показа.',
    children: [
      TextField(
        controller: _phone,
        keyboardType: TextInputType.phone,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(9),
        ],
        decoration: InputDecoration(
          labelText: 'Телефон',
          prefixText: '+375 ',
          hintText: '29 123 45 67',
          errorText: _error,
        ),
      ),
      const SizedBox(height: 24),
      FilledButton(
        onPressed: () {
          if (_phone.text.length != 9) {
            setState(() => _error = 'Введите 9 цифр после +375');
            return;
          }
          // Only the last two digits cross into the next page; no identity claim.
          context.push('/adult/code', extra: _phone.text.substring(7));
        },
        child: const Text('Продолжить'),
      ),
    ],
  );
}

class AdultCodePage extends ConsumerStatefulWidget {
  const AdultCodePage({super.key, this.phoneSuffix});
  final String? phoneSuffix;
  @override
  ConsumerState<AdultCodePage> createState() => _AdultCodePageState();
}

class _AdultCodePageState extends ConsumerState<AdultCodePage> {
  final _code = TextEditingController();
  final _secret = TextEditingController();
  bool _busy = false;
  String? _error;
  @override
  void dispose() {
    _code.dispose();
    _secret.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_code.text.length != 4 || _secret.text.isEmpty) {
      setState(() => _error = 'Введите 4 цифры и ключ доступа взрослого.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(familySessionProvider).loginAdult(_secret.text);
      _secret.clear();
      if (mounted) context.go('/home');
    } catch (_) {
      if (mounted) {
        setState(
          () =>
              _error = 'Не удалось войти. Проверьте ключ доступа и соединение.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => FamilyEntryFrame(
    title: 'Подтвердите вход',
    subtitle:
        '+375 •• ••• •• ${widget.phoneSuffix ?? '••'}\nУсловный код для показа. SMS не отправляется.',
    children: [
      TextField(
        controller: _code,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(4),
        ],
        decoration: const InputDecoration(labelText: 'Любые 4 цифры'),
      ),
      const SizedBox(height: 24),
      TextField(
        controller: _secret,
        obscureText: true,
        enableSuggestions: false,
        autocorrect: false,
        decoration: const InputDecoration(
          labelText: 'Ключ доступа взрослого',
          helperText: 'Получите ключ у организатора показа.',
          helperMaxLines: 2,
        ),
      ),
      if (_error != null) ...[
        const SizedBox(height: 16),
        Text(_error!, style: const TextStyle(color: MtBrandColors.red)),
      ],
      const SizedBox(height: 24),
      FilledButton(
        onPressed: _busy ? null : _login,
        child: Text(_busy ? 'Входим…' : 'Войти'),
      ),
    ],
  );
}

class ServerChildPairPage extends ConsumerStatefulWidget {
  const ServerChildPairPage({super.key});
  @override
  ConsumerState<ServerChildPairPage> createState() =>
      _ServerChildPairPageState();
}

class _ServerChildPairPageState extends ConsumerState<ServerChildPairPage> {
  JsonMap? _pair;
  Timer? _timer;
  bool _busy = false;
  String? _error;
  String? _terminal;
  int _generation = 0;
  @override
  void initState() {
    super.initState();
    unawaited(_create());
  }

  FamilyApi get _api => ref.read(familySessionProvider).api!;
  Future<void> _create() async {
    final generation = ++_generation;
    _timer?.cancel();
    setState(() {
      _busy = true;
      _error = null;
      _terminal = null;
      _pair = null;
    });
    try {
      final pair = await _api.request('POST', '/v1/pairings', {
        'deviceName': 'Телефон ребёнка',
      });
      if (!mounted || generation != _generation) return;
      setState(() => _pair = pair);
      _schedule(generation);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Не удалось создать код. Проверьте соединение.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _schedule(int generation) {
    _timer = Timer(const Duration(seconds: 2), () => _poll(generation));
  }

  Future<void> _poll(int generation) async {
    if (!mounted || generation != _generation || _pair == null) return;
    try {
      final result = await _api.request(
        'POST',
        '/v1/pairings/${_pair!['id']}/poll',
        {'requestSecret': _pair!['requestSecret']},
      );
      if (!mounted || generation != _generation) return;
      if (result['session'] is JsonMap) {
        await ref
            .read(familySessionProvider)
            .acceptPairSession(result['session'] as JsonMap);
        if (mounted) context.go('/child/home');
        return;
      }
      if (result['status'] != 'waiting' && result['status'] != 'approved') {
        setState(
          () => _terminal = 'Этот код больше не действует. Создайте новый.',
        );
        return;
      }
      if (_error != null) setState(() => _error = null);
    } on FamilyApiException catch (e) {
      if (!mounted) return;
      if (e.status == 404 || e.status == 409 || e.status == 410) {
        setState(() => _terminal = 'Время кода истекло. Создайте новый.');
        return;
      }
      setState(() => _error = 'Связь прервалась. Пробуем подключиться снова…');
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Связь прервалась. Пробуем подключиться снова…',
        );
      }
    }
    if (mounted && generation == _generation) _schedule(generation);
  }

  Future<void> _cancel() async {
    _timer?.cancel();
    _generation++;
    final pair = _pair;
    if (pair != null) {
      try {
        await _api.request('POST', '/v1/pairings/${pair['id']}/cancel', {
          'requestSecret': pair['requestSecret'],
        });
      } catch (_) {
        if (mounted) {
          setState(
            () => _error = 'Не удалось отменить код. Попробуйте ещё раз.',
          );
          return;
        }
      }
    }
    if (mounted) context.go('/welcome');
  }

  @override
  void dispose() {
    _generation++;
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) unawaited(_cancel());
    },
    child: FamilyEntryFrame(
      title: 'Подключим твой телефон',
      back: false,
      subtitle:
          'Покажи QR взрослому. Он выберет твой профиль и подтвердит доступ.',
      children: [
        if (_busy) const Center(child: CircularProgressIndicator()),
        if (_pair != null && _terminal == null) ...[
          Center(
            child: QrImageView(
              data: 'moby-family:pair:${_pair!['code']}',
              size: 240,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Если камера недоступна, взрослый может ввести этот код вручную.',
          ),
          const SizedBox(height: 12),
          SelectableText(
            '${_pair!['code']}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Ждём подтверждения взрослого',
            textAlign: TextAlign.center,
          ),
        ],
        if (_error != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(_error!),
          ),
        if (_terminal != null) Text(_terminal!),
        if (!_busy && (_pair == null || _terminal != null))
          FilledButton(
            onPressed: _create,
            child: const Text('Создать новый код'),
          ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: _cancel,
          child: const Text('Отменить подключение'),
        ),
      ],
    ),
  );
}
