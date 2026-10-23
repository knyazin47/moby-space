import 'dart:convert';

import 'package:moby_demo/app/family_session.dart';
import 'package:moby_demo/data/server/family_api.dart';
import 'package:moby_demo/data/server/money_intent.dart';
import 'package:moby_demo/data/server/session_vault.dart';

const spaceJuniorId = 'space-mikhail';
const spaceTeenId = 'space-alexandra';

JsonMap _copy(JsonMap value) => jsonDecode(jsonEncode(value)) as JsonMap;

/// Synthetic display fixtures only. They never seed an installed or live server.
JsonMap spacePreviewSnapshot({String? childId}) {
  final data = _copy({
    'revision': 1,
    'businessDate': '2026-10-21',
    'synthetic': true,
    'actor': {
      'id': childId == null ? 'preview-adult' : 'actor-$childId',
      'role': childId == null ? 'adult' : 'child',
      'sessionId': 'preview-session',
      'childId': ?childId,
    },
    if (childId == null) 'preferences': {'familyIntroSeen': true},
    'children': [
      _child(spaceJuniorId, 'Михаил', '2016-03-12', 5000),
      _child(spaceTeenId, 'Александра', '2010-05-23', 12000),
    ],
    'operations': [
      for (final id in [spaceJuniorId, spaceTeenId])
        {
          'id': 'topup-$id',
          'childId': id,
          'kind': 'topup',
          'amountMinor': 2000,
          'currency': 'BYN',
          'channel': 'internal',
          'category': 'other',
          'merchant': 'Карманные деньги',
          'status': 'completed',
          'createdAt': 1792454400,
          'completedAt': 1792454400,
          'version': 1,
        },
    ],
    'familySpace': {
      'capabilities': {
        'synthetic': true,
        'currency': 'BYN',
        'timeZone': 'Europe/Minsk',
        'maxAmountMinor': 10000000,
        'matchingCapPeriod': 'goal_lifetime',
        'lessonsGrantPermissions': false,
      },
      if (childId == null)
        'adultWallet': {
          'availableMinor': 54000,
          'reservedMinor': 12000,
          'currency': 'BYN',
        },
      'goals': [
        _goal(spaceJuniorId, 'Наушники', 5000, 2000),
        _goal(spaceTeenId, 'На поездку', 20000, 8000),
      ],
      'tasks': [
        for (final id in [spaceJuniorId, spaceTeenId])
          {
            'id': 'task-$id',
            'childId': id,
            'title': 'Помочь с покупками',
            'rewardMinor': id == spaceJuniorId ? 500 : 1500,
            'status': 'offered',
            'cancelRequested': false,
          },
      ],
      'errands': [
        for (final id in [spaceJuniorId, spaceTeenId])
          {
            'id': 'errand-$id',
            'childId': id,
            'title': 'Купить продукты к ужину',
            'budgetMinor': 2500,
            'rewardMinor': 300,
            'actualMinor': 0,
            'returnedMinor': 0,
            'funding': 'funded',
            'status': 'offered',
            'ownMoneyConsent': false,
            'cancelRequested': false,
            'returnConfirmed': false,
            'expenseRecorded': false,
            'rewardReserved': true,
          },
      ],
      'allowances': [
        for (final id in [spaceJuniorId, spaceTeenId])
          {
            'id': 'allowance-$id',
            'childId': id,
            'title': 'Карманные на неделю',
            'amountMinor': 2000,
            'frequency': 'weekly',
            'weekdays': [5],
            'monthDay': 0,
            'nextDate': '2026-10-23',
            'retryLimit': 0,
            'active': true,
          },
      ],
      'installments': [
        for (final id in [spaceJuniorId, spaceTeenId])
          {
            'id': 'installment-$id',
            'childId': id,
            'allowanceId': 'allowance-$id',
            'dueDate': '2026-10-16',
            'amountMinor': 2000,
            'status': 'paid',
            'attempts': 1,
            'lastAttemptDate': '2026-10-16',
          },
      ],
      'requests': [
        {
          'id': 'request-help',
          'childId': spaceJuniorId,
          'title': 'Помоги выбрать наушники',
          'kind': 'help',
          'status': 'pending',
        },
      ],
      'settings': {
        for (final id in [spaceJuniorId, spaceTeenId])
          id: {
            'matchingEnabled': true,
            'matchingPercent': 50,
            'matchingCapMinor': 5000,
            'notifications': true,
            'tasksEnabled': true,
            'errandsEnabled': true,
            'learningEnabled': true,
          },
      },
      'learning': [
        {
          'childId': spaceTeenId,
          'lessonId': 'needs-wants',
          'completedAt': 1792454400,
        },
      ],
      'lessons': [
        {
          'id': 'needs-wants',
          'title': 'Нужды и желания',
          'body':
              'Перед покупкой подумай: это необходимо сейчас или можно отложить?',
          'skill': 'planning',
          'question': 'Что лучше сделать перед необязательной покупкой?',
          'options': [
            'Сравнить её с важными расходами',
            'Купить сразу, не считая деньги',
          ],
        },
        {
          'id': 'saving-goal',
          'title': 'Как копить на цель',
          'body':
              'Раздели стоимость цели на небольшие части. Деньги в цели хранятся отдельно от доступных для покупок.',
          'skill': 'saving',
          'question': 'Где хранится сумма, отложенная на цель?',
          'options': [
            'В общем доступном остатке',
            'Отдельно от денег для покупок',
          ],
        },
        {
          'id': 'safe-payment',
          'title': 'Безопасная оплата',
          'body':
              'Не сообщай коды, пароли и данные карты. Если сомневаешься, обратись к взрослому.',
          'skill': 'safety',
          'question': 'Незнакомец просит код из сообщения. Что делать?',
          'options': [
            'Не сообщать код и обратиться к взрослому',
            'Продиктовать код',
          ],
        },
        {
          'id': 'budget',
          'title': 'План расходов',
          'body':
              'Сравни доступные деньги и будущие траты. Оставь запас на необходимое.',
          'skill': 'budgeting',
          'question': 'Что нужно учесть в плане расходов?',
          'options': [
            'Только желаемые покупки',
            'Доступные деньги и будущие необходимые траты',
          ],
        },
      ],
      'weekly': [
        for (final id in [spaceJuniorId, spaceTeenId])
          {
            'childId': id,
            'since': '2026-10-15',
            'incomingMinor': 2000,
            'spentMinor': 1250,
            'savedMinor': 500,
            'tasksCompleted': 0,
            'lessonsCompleted': id == spaceTeenId ? 1 : 0,
          },
      ],
      'notices': [
        for (final id in [spaceJuniorId, spaceTeenId])
          {
            'id': 'notice-$id',
            'childId': id,
            'recipient': childId == null ? 'adult' : 'child',
            'title': 'Карманные деньги переведены',
            'body': '20,00 BYN доступны для покупок.',
            'kind': 'allowance_paid',
            'createdAt': 1792454400,
            'read': false,
            'mandatory': true,
          },
      ],
    },
  });
  if (childId != null) {
    for (final key in ['children', 'operations']) {
      data[key] = (data[key] as List)
          .where((v) => v[key == 'children' ? 'id' : 'childId'] == childId)
          .toList();
    }
    final space = data['familySpace'] as JsonMap;
    for (final key in [
      'goals',
      'tasks',
      'errands',
      'allowances',
      'installments',
      'requests',
      'learning',
      'weekly',
      'notices',
    ]) {
      space[key] = (space[key] as List)
          .where((v) => v['childId'] == childId)
          .toList();
    }
    space['settings'] = {childId: space['settings'][childId]};
  }
  return data;
}

JsonMap _child(String id, String name, String birthDate, int balance) => {
  'id': id,
  'displayName': name,
  'legalName': name,
  'dateOfBirth': birthDate,
  'identityStatus': 'verified',
  'representationStatus': 'verified',
  'agreementStatus': 'signed',
  'accountStatus': 'synthetic_open',
  'cardStatus': 'active',
  'deviceAccessStatus': 'paired',
  'membershipStatus': 'active',
  'balanceMinor': balance,
  'currency': 'BYN',
  'agreementVersion': 'synthetic-v1',
  'signerId': 'preview-adult',
  'signedAt': 1792454400,
  'version': 1,
  'policy': {
    'payments': true,
    'transfers': false,
    'internet': false,
    'dailyLimit': 5000,
    'monthlyLimit': 20000,
    'approvalThreshold': 2000,
    'categories': {
      'food': true,
      'transport': true,
      'entertainment': true,
      'other': true,
    },
  },
};
JsonMap _goal(String childId, String title, int target, int saved) => {
  'id': 'goal-$childId',
  'childId': childId,
  'title': title,
  'targetMinor': target,
  'savedMinor': saved,
  'matchedMinor': 0,
  'netDepositsMinor': saved,
  'matchedBasisMinor': saved,
  'matchingAvailableMinor': saved ~/ 2,
  'matchingStatus': 'available',
};

class SpacePreviewSessionVault implements SessionVault {
  String? value;
  @override
  Future<void> clear() async {
    value = null;
  }

  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String token) async {
    value = token;
  }
}

class SpacePreviewIntentVault implements MoneyIntentVault {
  final values = <String, String>{};
  @override
  Future<void> delete(String key) async {
    values.remove(key);
  }

  @override
  Future<String?> read(String key) async => values[key];
  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
  }
}

/// This adapter overrides every I/O entry point. Unexpected calls fail the test.
/// It deliberately tests client wiring, never claims backend-domain acceptance.
class SpacePreviewApi extends FamilyApi {
  SpacePreviewApi({String? childId})
    : data = spacePreviewSnapshot(childId: childId),
      super(Uri.parse('http://127.0.0.1:1'));
  JsonMap data;
  final commands = <JsonMap>[];
  Future<void> Function(JsonMap)? beforeCommand;
  final _acknowledged = <String, JsonMap>{};
  @override
  Stream<JsonMap> events() => const Stream.empty();
  @override
  Future<JsonMap> request(String method, String path, [JsonMap? body]) async {
    if (method == 'GET' && path == '/v1/snapshot') return _copy(data);
    if (method == 'POST' && path == '/v1/auth/logout') return {};
    if (method != 'POST' ||
        path != '/v1/family-space/commands' ||
        body == null) {
      throw StateError('Unexpected in-memory preview request: $method $path');
    }
    final command = _copy(body);
    await beforeCommand?.call(command);
    final key = command['idempotencyKey'] as String;
    if (_acknowledged.containsKey(key)) return _copy(_acknowledged[key]!);
    final space = data['familySpace'] as JsonMap;
    final childId = command['childId'] as String;
    if ((data['actor'] as JsonMap)['role'] == 'child' &&
        (data['actor'] as JsonMap)['childId'] != childId) {
      throw const FamilyApiException(403, 'forbidden');
    }
    switch (command['type']) {
      case 'card.block':
        (data['children'] as List).singleWhere(
          (c) => c['id'] == childId,
        )['cardStatus'] = 'blocked';
      case 'wallet.transfer':
        final wallet = space['adultWallet'] as JsonMap;
        final amount = command['amountMinor'] as int;
        if (amount <= 0 || amount > (wallet['availableMinor'] as int)) {
          throw const FamilyApiException(400, 'insufficient_funds');
        }
        final child = (data['children'] as List).singleWhere(
          (c) => c['id'] == childId,
        );
        wallet['availableMinor'] = (wallet['availableMinor'] as int) - amount;
        child['balanceMinor'] = (child['balanceMinor'] as int) + amount;

      case 'goal.create':
        (space['goals'] as List).add({
          'id': 'created-goal',
          'childId': childId,
          'title': command['title'],
          'targetMinor': command['targetMinor'],
          'savedMinor': 0,
          'matchedMinor': 0,
          'netDepositsMinor': 0,
          'matchedBasisMinor': 0,
          'matchingAvailableMinor': 0,
          'matchingStatus': 'not_eligible',
        });
      case 'request.create':
        (space['requests'] as List).add({
          'id': 'created-request',
          'childId': childId,
          'title': command['title'],
          'kind': command['kind'],
          'status': 'pending',
          if (command.containsKey('amountMinor'))
            'amountMinor': command['amountMinor'],
          if (command.containsKey('policy'))
            'policy': _copy(command['policy'] as JsonMap),
        });
      case 'lesson.complete':
        final id = command['entityId'];
        final expected = {
          'needs-wants': 0,
          'saving-goal': 1,
          'safe-payment': 0,
          'budget': 1,
        }[id];
        if (command['answerIndex'] != expected) {
          throw const FamilyApiException(400, 'wrong_answer');
        }
        if (!(space['learning'] as List).any(
          (v) => v['childId'] == childId && v['lessonId'] == id,
        )) {
          (space['learning'] as List).add({
            'childId': childId,
            'lessonId': id,
            'completedAt': 1792540800,
          });
        }
      case 'notice.read':
        for (final notice in space['notices'] as List) {
          if (notice['id'] == command['entityId']) notice['read'] = true;
        }
      default:
        throw StateError('Unexpected preview command: ${command['type']}');
    }
    commands.add(command);
    data['revision'] = (data['revision'] as int) + 1;
    _acknowledged[key] = _copy(data);
    return _copy(data);
  }
}

class SpacePreviewSession extends FamilySession {
  SpacePreviewSession(SpacePreviewApi preview)
    : super(api: preview, vault: SpacePreviewSessionVault()) {
    phase = FamilySessionPhase.signedIn;
    connected = true;
    snapshot = _copy(preview.data);
    _outbox = MoneyIntentStore(
      api: preview,
      actorId: snapshot!['actor']['id'] as String,
      vault: SpacePreviewIntentVault(),
      onAcknowledged: refresh,
    );
  }
  late final MoneyIntentStore _outbox;
  @override
  MoneyIntentStore get moneyIntents => _outbox;
}
