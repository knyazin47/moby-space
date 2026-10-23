import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../app/family_session.dart';
import '../../core/theme/mt_brand_theme.dart';
import '../../core/theme/app_theme.dart';
import '../../core/config/children_form_content.dart';
import '../../core/config/space_content.dart';
import '../../core/config/space_ui_content.dart';
import '../space/space_components.dart';
import '../../data/server/family_api.dart';
import '../../data/server/family_space.dart';
import '../../data/server/money_intent.dart';
import '../../data/server/family_ui_contract.dart';
import 'family_widgets.dart';
import 'children_tab_page.dart';

String familyMoney(Object? minor) => formatFamilyMoney(minor);
String familyServerError(Object e) {
  final code = e is FamilyApiException ? e.code : '';
  return switch (code) {
    'pending_family_obligations' => SpaceContent.errorMessage(
      'pending_family_obligations',
    ),
    'invalid_child' => 'Проверьте имя и дату рождения.',
    'invalid_policy' =>
      'Проверьте лимиты: месячный должен быть не меньше дневного.',
    'verification_required' => 'Сначала завершите проверку данных.',
    'invalid_money_command' => 'Введите положительную сумму в BYN.',
    'insufficient_funds' ||
    'insufficient_balance' => 'На счёте недостаточно средств.',
    'limit_exceeded' => 'Превышен установленный лимит. Проверьте настройки.',
    'permission_denied' => 'Эта возможность отключена в настройках.',
    'category_disabled' ||
    'category_forbidden' => 'Покупки этой категории недоступны.',
    'pairing_expired' || 'pairing_unavailable' || 'invalid_pairing' =>
      'Код недоступен. Откройте новый QR-код на телефоне ребёнка.',
    'card_unavailable' ||
    'product_unavailable' => 'Сначала завершите оформление карты.',
    'unauthorized' => 'Сеанс завершён. Войдите снова.',
    _ => 'Не удалось выполнить действие. Обновите данные и повторите.',
  };
}

/// Human-readable UI mapping, independent of the server's lifecycle identifiers.
String familyStatus(Object? status) => switch (status) {
  'draft' => 'Данные заполнены',
  'pending' => 'На проверке',
  'verified' => 'Данные проверены',
  'needs_correction' => 'Нужно уточнение',
  'rejected' => 'Проверка не пройдена',
  'active' => 'Активна',
  'blocked' => 'Заблокирована',
  'none' => 'Карта не выпущена',
  'paired' => 'Телефон подключён',
  'unpaired' => 'Телефон не подключён',
  'revoked' => 'Доступ отключён',
  'archived' => 'Связь с семьёй отключена',
  _ => 'Оформляется',
};

class _LiveFamily extends ConsumerWidget {
  const _LiveFamily({required this.builder});
  final Widget Function(BuildContext, FamilySession) builder;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(familySessionProvider);
    return ListenableBuilder(
      listenable: session,
      builder: (context, _) => builder(context, session),
    );
  }
}

/// Kept as a source-compatible entry for existing previews; one real hub UI.
class ServerFamilyPage extends StatelessWidget {
  const ServerFamilyPage({super.key});
  @override
  Widget build(BuildContext context) => const ChildrenTabPage();
}

class _Connection extends StatelessWidget {
  const _Connection({required this.session});
  final FamilySession session;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(
        session.connected
            ? Icons.cloud_done_outlined
            : Icons.cloud_off_outlined,
        color: MtBrandColors.blue,
        size: 18,
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          session.connected
              ? 'Данные обновляются на всех телефонах'
              : 'Соединение прервано. Восстанавливаем…',
          style: const TextStyle(fontSize: 12, color: MtBrandColors.secondary),
        ),
      ),
    ],
  );
}

class ServerAddChildPage extends ConsumerStatefulWidget {
  const ServerAddChildPage({super.key});
  @override
  ConsumerState<ServerAddChildPage> createState() => _ServerAddChildPageState();
}

class _ServerAddChildPageState extends ConsumerState<ServerAddChildPage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  DateTime? _dob;
  PendingMoneyIntent? _pending;
  bool _intentReady = false;
  @override
  void initState() {
    super.initState();
    _restoreIntent();
  }

  Future<void> _restoreIntent() async {
    try {
      final intent = await ref
          .read(familySessionProvider)
          .moneyIntents
          .load(childId: 'new', kind: MoneyIntentKind.createChild);
      if (mounted) {
        setState(() {
          _pending = intent;
          _intentReady = true;
          _error = null;
          if (intent != null) {
            _name.text = intent.payload['displayName'] as String;
            _dob = DateTime.tryParse(intent.payload['dateOfBirth'] as String);
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = ChildrenFormContent.restoreError);
      }
    }
  }

  bool _busy = false;
  String? _error;
  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FamilyPage(
    title: ChildrenFormContent.title,
    showAppBar: false,
    child: FamilyMaxWidth(
      child: LayoutBuilder(
        builder: (context, constraints) => Form(
          key: _form,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              24,
              32,
              24,
              MobyMetrics.contentBottomPadding,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    (constraints.maxHeight -
                            32 -
                            MobyMetrics.contentBottomPadding)
                        .clamp(0, double.infinity),
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      ChildrenFormContent.title,
                      style: buildMtBrandTheme().textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      ChildrenFormContent.description,
                      style: buildMtBrandTheme().textTheme.bodyLarge?.copyWith(
                        color: MtBrandColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const FamilyFieldLabel(ChildrenFormContent.name),
                    TextFormField(
                      key: const ValueKey('child-name'),
                      controller: _name,
                      enabled: _intentReady && _pending == null && !_busy,
                      maxLength: 50,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(counterText: ''),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? ChildrenFormContent.invalidName
                          : null,
                    ),
                    const SizedBox(height: 24),
                    const FamilyFieldLabel(ChildrenFormContent.birthDate),
                    OutlinedButton(
                      key: const ValueKey('child-birth-date'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        side: const BorderSide(color: MtBrandColors.border),
                      ),
                      onPressed: !_intentReady || _pending != null || _busy
                          ? null
                          : _pickBirthDate,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _dob == null
                                  ? ChildrenFormContent.birthDatePlaceholder
                                  : '${_dob!.day.toString().padLeft(2, '0')}.${_dob!.month.toString().padLeft(2, '0')}.${_dob!.year}',
                              style: TextStyle(
                                color: _dob == null
                                    ? MtBrandColors.secondary
                                    : MtBrandColors.ink,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const Icon(Icons.calendar_month_outlined, size: 24),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      ChildrenFormContent.documentHint,
                      style: buildMtBrandTheme().textTheme.bodyMedium?.copyWith(
                        color: MtBrandColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Spacer(),
                    if (_pending != null) ...[
                      const Text(ChildrenFormContent.pending),
                      const SizedBox(height: 16),
                    ],
                    if (_error != null) ...[
                      Text(
                        _error!,
                        style: const TextStyle(color: MtBrandColors.red),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (!_intentReady && _error != null)
                      TextButton(
                        onPressed: _restoreIntent,
                        child: const Text(ChildrenFormContent.restoreRetry),
                      ),
                    FilledButton(
                      onPressed: _busy || !_intentReady ? null : _submit,
                      child: Text(
                        _busy
                            ? ChildrenFormContent.creating
                            : _pending != null
                            ? ChildrenFormContent.retry
                            : ChildrenFormContent.create,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _busy ? null : () => context.go('/family'),
                      child: const Text(ChildrenFormContent.cancel),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Future<void> _pickBirthDate() async {
    FocusScope.of(context).unfocus();
    final date =
        ref.read(familySessionProvider).snapshot?['businessDate'] as String?;
    final today = DateTime.tryParse(date ?? '') ?? DateTime.now();
    final value = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(today.year - 10, today.month, today.day),
      firstDate: DateTime(
        today.year - 18,
        today.month,
        today.day,
      ).add(const Duration(days: 1)),
      lastDate: DateTime(today.year - 7, today.month, today.day),
      builder: (context, child) =>
          Theme(data: buildMtBrandTheme(), child: child!),
    );
    if (value != null && mounted) setState(() => _dob = value);
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    if (_dob == null) {
      setState(() => _error = ChildrenFormContent.invalidDate);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final store = ref.read(familySessionProvider).moneyIntents;
      if (_pending != null) {
        await store.retry(childId: 'new', kind: MoneyIntentKind.createChild);
      } else {
        await store.submit(
          childId: 'new',
          kind: MoneyIntentKind.createChild,
          payload: {
            'displayName': _name.text.trim(),
            'dateOfBirth':
                '${_dob!.year}-${_dob!.month.toString().padLeft(2, '0')}-${_dob!.day.toString().padLeft(2, '0')}',
          },
        );
      }
      if (mounted) context.go('/family');
    } catch (e) {
      await _restoreIntent();
      if (mounted) setState(() => _error = familyServerError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class ServerChildManagePage extends ConsumerStatefulWidget {
  const ServerChildManagePage({required this.childId, super.key});
  final String childId;
  @override
  ConsumerState<ServerChildManagePage> createState() =>
      _ServerChildManagePageState();
}

class _ServerChildManagePageState extends ConsumerState<ServerChildManagePage> {
  bool _busy = false;
  String? _error;
  Future<bool> _command(String method, String suffix, [JsonMap? body]) async {
    if (_busy) return false;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(familySessionProvider)
          .command(method, '/v1/children/${widget.childId}$suffix', body);
      return true;
    } catch (e) {
      if (mounted) setState(() => _error = familyServerError(e));
      return false;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verify(JsonMap child) async {
    if ((child['legalName'] as String? ?? '').trim().isEmpty) {
      final legal = await showDialog<String>(
        context: context,
        builder: (context) => const _LegalNameDialog(),
      );
      if (!mounted || legal == null) return;
      if (!await _command('PATCH', '', {'legalName': legal})) return;
    }
    await _command('POST', '/verification', {'outcome': 'verified'});
  }

  @override
  Widget build(BuildContext context) => _LiveFamily(
    builder: (context, session) {
      final children = session.children.where((c) => c['id'] == widget.childId);
      if (children.isEmpty) {
        return const FamilyPage(
          title: 'Профиль ребёнка',
          child: Center(child: Text('Профиль недоступен')),
        );
      }
      final child = children.first;
      final spaceEnabled = FamilySpace.fromSnapshot(
        session.snapshot,
      ).isAvailable;
      final policy = Map<String, dynamic>.from(child['policy'] as JsonMap);
      final active = child['membershipStatus'] == 'active';
      final operations =
          (session.snapshot?['operations'] as List? ?? [])
              .whereType<JsonMap>()
              .where((o) => o['childId'] == widget.childId)
              .toList()
            ..sort(
              (a, b) =>
                  (b['createdAt'] as num).compareTo(a['createdAt'] as num),
            );
      return FamilyPage(
        title: child['displayName'] as String,
        child: FamilyMaxWidth(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              24,
              24,
              24,
              MobyMetrics.contentBottomPadding,
            ),
            children: [
              _Connection(session: session),
              const SizedBox(height: 24),
              if (!spaceEnabled)
                SpaceHero(
                  title: SpaceUiCopy.childMoney,
                  amount: familyMoney(child['balanceMinor']),
                  details: [
                    (SpaceContent.account, familyStatus(child['cardStatus'])),
                  ],
                ),
              const SizedBox(height: 24),
              if (!active)
                const FamilyInfoCard(
                  text:
                      'Связь с семьёй отключена. История и принадлежность счёта сохранены.',
                ),
              if (active && child['accountStatus'] != 'synthetic_open') ...[
                Text(
                  'Оформление',
                  style: buildMtBrandTheme().textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Text(familyStatus(child['identityStatus'])),
                const SizedBox(height: 16),
                const FamilyInfoCard(
                  text:
                      'На показе используются вымышленные данные. Проверка документов и подписание выполняются демонстрационным сервисом; реальный банковский счёт не открывается.',
                ),
                const SizedBox(height: 16),
                if (child['identityStatus'] != 'verified')
                  FilledButton(
                    onPressed: _busy ? null : () => _verify(child),
                    child: const Text('Пройти проверку данных'),
                  ),
                if (child['identityStatus'] == 'verified')
                  FilledButton(
                    onPressed: _busy
                        ? null
                        : () async {
                            final yes = await _confirm(
                              context,
                              'Оформить карту?',
                              'Подтверждаю оформление демонстрационного продукта для этого ребёнка как его законный представитель.',
                            );
                            if (yes) {
                              await _command('POST', '/product', {
                                'agreementVersion': 'synthetic-v1',
                                'signerConsent': true,
                              });
                            }
                          },
                    child: const Text('Подтвердить оформление'),
                  ),
                const SizedBox(height: 24),
              ],
              if (active) ...[
                Text(
                  'Телефон и карта',
                  style: buildMtBrandTheme().textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(familyStatus(child['deviceAccessStatus'])),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _busy
                      ? null
                      : () => context.push(
                          '/family/child/${widget.childId}/access',
                        ),
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Подключить телефон'),
                ),
                if (!spaceEnabled &&
                    child['accountStatus'] == 'synthetic_open') ...[
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _busy
                        ? null
                        : () => _command('PATCH', '', {
                            'cardStatus': child['cardStatus'] == 'blocked'
                                ? 'active'
                                : 'blocked',
                          }),
                    child: Text(
                      child['cardStatus'] == 'blocked'
                          ? 'Разблокировать карту'
                          : 'Заблокировать карту',
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonal(
                    onPressed: _busy ? null : _topup,
                    child: const Text('Пополнить счёт'),
                  ),
                ],
                const SizedBox(height: 24),
                if (!spaceEnabled) ...[
                  Text(
                    'Возможности',
                    style: buildMtBrandTheme().textTheme.titleLarge,
                  ),
                  for (final item in const [
                    ('payments', 'Покупки'),
                    ('internet', 'Покупки в интернете'),
                  ])
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(item.$2),
                      value: policy[item.$1] == true,
                      onChanged: _busy || !session.connected
                          ? null
                          : (v) => _command('PATCH', '/policy', {
                              ...policy,
                              item.$1: v,
                            }),
                    ),
                  const SizedBox(height: 24),
                  Text(
                    'Лимиты',
                    style: buildMtBrandTheme().textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  for (final item in const [
                    ('dailyLimit', 'В день'),
                    ('monthlyLimit', 'В месяц'),
                    ('approvalThreshold', 'Без подтверждения'),
                  ])
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(item.$2),
                      trailing: Text(familyMoney(policy[item.$1])),
                      onTap: _busy
                          ? null
                          : () async {
                              final amount = await _amountDialog(
                                context,
                                item.$2,
                                initial: policy[item.$1] as int,
                                allowZero: true,
                              );
                              if (amount != null) {
                                await _command('PATCH', '/policy', {
                                  ...policy,
                                  item.$1: amount,
                                });
                              }
                            },
                    ),
                ],
              ],
              const SizedBox(height: 24),
              if (active && !spaceEnabled) ...[
                const SizedBox(height: 24),
                Text(
                  'Категории покупок',
                  style: buildMtBrandTheme().textTheme.titleLarge,
                ),
                for (final item in familyCategoryLabels.entries)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(item.value),
                    value:
                        (policy['categories'] as JsonMap?)?[item.key] != false,
                    onChanged: _busy || !session.connected
                        ? null
                        : (value) => _command('PATCH', '/policy', {
                            ...policy,
                            'categories': {
                              ...?policy['categories'] as JsonMap?,
                              item.key: value,
                            },
                          }),
                  ),
                const SizedBox(height: 24),
              ],
              if (!spaceEnabled) ...[
                Text(
                  'История',
                  style: buildMtBrandTheme().textTheme.titleLarge,
                ),
                if (operations.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('Здесь появятся пополнения и покупки.'),
                  ),
                for (final op in operations) ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      op['kind'] == 'topup'
                          ? 'Пополнение'
                          : op['merchant'] as String? ?? 'Покупка',
                    ),
                    subtitle: Text(
                      op['status'] == 'pending'
                          ? 'Нужно ваше решение'
                          : op['status'] == 'done'
                          ? 'Выполнено'
                          : 'Отклонено',
                    ),
                    trailing: Text(
                      '${op['kind'] == 'topup' ? '+' : '−'}${familyMoney(op['amountMinor'])}',
                    ),
                  ),
                  if (op['status'] == 'pending' && active)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _busy ? null : () => _decide(op, false),
                            child: const Text('Отклонить'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: _busy ? null : () => _decide(op, true),
                            child: const Text('Разрешить'),
                          ),
                        ),
                      ],
                    ),
                ],
              ],
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: MtBrandColors.red),
                  ),
                ),
              if (active) ...[
                const SizedBox(height: 32),
                TextButton(
                  onPressed: _busy
                      ? null
                      : () async {
                          if (await _confirm(
                            context,
                            'Отключить связь с семьёй?',
                            'Доступ ребёнка с подключённых телефонов будет отозван. Счёт, его принадлежность и история сохранятся.',
                          )) {
                            if (await _command('POST', '/archive') &&
                                context.mounted) {
                              context.go('/family');
                            }
                          }
                        },
                  child: const Text(
                    'Отключить связь с семьёй',
                    style: TextStyle(color: MtBrandColors.red),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
  Future<void> _topup() async {
    final store = ref.read(familySessionProvider).moneyIntents;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final pending = await store.load(
        childId: widget.childId,
        kind: MoneyIntentKind.topup,
      );
      if (!mounted) return;
      if (pending != null) {
        if (await _confirm(
          context,
          'Проверить предыдущее пополнение?',
          'Ответ на пополнение ${familyMoney(pending.payload['amountMinor'])} не получен. Повтор проверит ту же команду без повторного зачисления.',
        )) {
          await store.retry(
            childId: widget.childId,
            kind: MoneyIntentKind.topup,
          );
        }
      } else {
        final amount = await _amountDialog(context, 'Пополнить счёт');
        if (amount != null) {
          await store.submit(
            childId: widget.childId,
            kind: MoneyIntentKind.topup,
            payload: {'amountMinor': amount, 'currency': 'BYN'},
          );
        }
      }
    } catch (e) {
      if (mounted) setState(() => _error = familyServerError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _decide(JsonMap op, bool approve) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(familySessionProvider).command(
        'POST',
        '/v1/operations/${op['id']}/decision',
        {'approve': approve},
      );
    } catch (e) {
      if (mounted) setState(() => _error = familyServerError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class ServerPairChildPage extends ConsumerStatefulWidget {
  const ServerPairChildPage({required this.childId, super.key});
  final String childId;
  @override
  ConsumerState<ServerPairChildPage> createState() =>
      _ServerPairChildPageState();
}

class _ServerPairChildPageState extends ConsumerState<ServerPairChildPage> {
  final _code = TextEditingController();
  final _scanner = MobileScannerController(
    autoStart: true,
    formats: [BarcodeFormat.qrCode],
  );
  bool _camera = false, _busy = false;
  String? _error;
  @override
  void dispose() {
    _code.dispose();
    _scanner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FamilyPage(
    title: 'Подключить телефон',
    child: FamilyMaxWidth(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MobyMetrics.contentBottomPadding,
        ),
        children: [
          Text(
            'Отсканируйте QR-код ребёнка',
            style: buildMtBrandTheme().textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          const Text(
            'На его телефоне выберите «Я ребёнок». Код подключает только этот телефон к выбранному вами профилю.',
          ),
          const SizedBox(height: 24),
          if (_camera)
            SizedBox(
              height: 260,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: MobileScanner(
                  controller: _scanner,
                  onDetect: (capture) {
                    if (_busy) return;
                    for (final barcode in capture.barcodes) {
                      final value = barcode.rawValue;
                      if (value != null &&
                          value.startsWith('moby-family:pair:')) {
                        _code.text = value.substring(
                          'moby-family:pair:'.length,
                        );
                        _consume();
                        break;
                      }
                    }
                  },
                  errorBuilder: (context, error) => const Center(
                    child: Text('Камера недоступна. Введите код вручную.'),
                  ),
                ),
              ),
            ),
          if (!_camera)
            OutlinedButton.icon(
              onPressed: () => setState(() => _camera = true),
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Открыть камеру'),
            ),
          const SizedBox(height: 24),
          TextField(
            controller: _code,
            decoration: const InputDecoration(
              labelText: 'Код с телефона ребёнка',
            ),
            autocorrect: false,
            enableSuggestions: false,
          ),
          const SizedBox(height: 16),
          if (_error != null) ...[
            Text(_error!, style: const TextStyle(color: MtBrandColors.red)),
            const SizedBox(height: 16),
          ],
          FilledButton(
            onPressed: _busy ? null : _consume,
            child: Text(_busy ? 'Подключаем…' : 'Подключить этот телефон'),
          ),
        ],
      ),
    ),
  );
  Future<void> _consume() async {
    if (_busy || _code.text.trim().isEmpty) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    if (_camera) {
      try {
        await _scanner.stop();
      } catch (_) {
        /* Manual code entry remains available. */
      }
      if (!mounted) return;
      setState(() => _camera = false);
    }
    if (!mounted) return;
    final children = ref
        .read(familySessionProvider)
        .children
        .where((c) => c['id'] == widget.childId);
    if (children.isEmpty ||
        !await _confirm(
          context,
          'Подключить телефон?',
          'Этот телефон получит доступ к профилю ${children.first['displayName']}. Проверьте имя ребёнка перед подтверждением.',
        )) {
      if (mounted) setState(() => _busy = false);
      return;
    }
    try {
      await ref.read(familySessionProvider).command(
        'POST',
        '/v1/pairings/consume',
        {'code': _code.text.trim(), 'childId': widget.childId},
      );
      if (mounted) {
        _message(
          context,
          'Телефон подключён. Дождитесь входа на телефоне ребёнка.',
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) setState(() => _error = familyServerError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

void _message(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
Future<bool> _confirm(BuildContext context, String title, String text) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Подтвердить'),
          ),
        ],
      ),
    ) ??
    false;

Future<int?> _amountDialog(
  BuildContext context,
  String title, {
  int? initial,
  bool allowZero = false,
}) async {
  final controller = TextEditingController(
    text: initial == null ? '' : (initial / 100).toStringAsFixed(2),
  );
  String? error;
  final result = await showDialog<int>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
          ],
          decoration: InputDecoration(
            labelText: 'Сумма, BYN',
            errorText: error,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              final input = controller.text.replaceAll(',', '.');
              if (!RegExp(r'^\d{1,7}(\.\d{1,2})?$').hasMatch(input)) {
                setState(() => error = 'До двух знаков после запятой');
                return;
              }
              final parts = input.split('.');
              final amount =
                  int.parse(parts[0]) * 100 +
                  (parts.length == 2
                      ? int.parse(parts[1].padRight(2, '0'))
                      : 0);
              if (amount < (allowZero ? 0 : 1) || amount > 10000000) {
                setState(() => error = 'Проверьте сумму');
                return;
              }
              Navigator.pop(context, amount);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    ),
  );
  // Dialog route may still animate out with its TextField attached.
  Future<void>.delayed(const Duration(seconds: 1), controller.dispose);
  return result;
}

class _LegalNameDialog extends StatefulWidget {
  const _LegalNameDialog();
  @override
  State<_LegalNameDialog> createState() => _LegalNameDialogState();
}

class _LegalNameDialogState extends State<_LegalNameDialog> {
  final _controller = TextEditingController();
  final _form = GlobalKey<FormState>();
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Theme(
    data: buildMtBrandTheme(),
    child: AlertDialog(
      title: const Text(ChildrenFormContent.legalTitle),
      content: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(ChildrenFormContent.legalHint),
              const SizedBox(height: 16),
              TextFormField(
                controller: _controller,
                maxLength: 100,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: ChildrenFormContent.legalName,
                  alignLabelWithHint: true,
                ),
                validator: (v) =>
                    v == null || v.trim().split(RegExp(r'\s+')).length < 2
                    ? ChildrenFormContent.legalInvalid
                    : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(ChildrenFormContent.cancel),
        ),
        FilledButton(
          onPressed: () {
            if (_form.currentState!.validate()) {
              Navigator.pop(context, _controller.text.trim());
            }
          },
          child: const Text(ChildrenFormContent.legalConfirm),
        ),
      ],
    ),
  );
}
