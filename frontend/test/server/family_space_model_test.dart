import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:moby_demo/core/config/space_content.dart';
import 'package:moby_demo/data/server/family_api.dart';
import 'package:moby_demo/data/server/family_space.dart';

JsonMap spaceFixture() =>
    jsonDecode(
          jsonEncode({
            'adultWallet': {
              'availableMinor': 97000,
              'reservedMinor': 3000,
              'currency': 'BYN',
            },
            'goals': [
              {
                'id': 'goal',
                'childId': 'a',
                'title': 'Велосипед',
                'targetMinor': 40000,
                'savedMinor': 1200,
                'matchedMinor': 200,
                'netDepositsMinor': 1000,
                'matchedBasisMinor': 400,
                'matchingAvailableMinor': 300,
                'matchingStatus': 'available',
              },
              {
                'id': 'sibling-goal',
                'childId': 'b',
                'title': 'Наушники',
                'targetMinor': 10000,
                'savedMinor': 0,
                'matchedMinor': 0,
              },
            ],
            'tasks': [
              {
                'id': 'task',
                'childId': 'a',
                'title': 'Разобрать книги',
                'rewardMinor': 200,
                'status': 'accepted',
                'cancelRequested': false,
              },
            ],
            'errands': [
              {
                'id': 'errand',
                'childId': 'a',
                'title': 'Продукты',
                'budgetMinor': 2000,
                'rewardMinor': 100,
                'actualMinor': 1700,
                'returnedMinor': 300,
                'funding': 'funded',
                'status': 'submitted',
                'ownMoneyConsent': false,
                'cancelRequested': false,
                'returnConfirmed': true,
              },
            ],
            'allowances': [
              {
                'id': 'allowance',
                'childId': 'a',
                'title': 'На неделю',
                'amountMinor': 1000,
                'frequency': 'weekly',
                'weekdays': [1, 4],
                'monthDay': 0,
                'nextDate': '2026-10-22',
                'retryLimit': 1,
                'active': true,
              },
            ],
            'installments': [
              {
                'id': 'installment',
                'childId': 'a',
                'allowanceId': 'allowance',
                'dueDate': '2026-10-22',
                'amountMinor': 1000,
                'status': 'insufficient',
                'attempts': 1,
              },
            ],
            'requests': [
              {
                'id': 'request',
                'childId': 'a',
                'title': 'Поднять лимит',
                'kind': 'policy',
                'status': 'pending',
                'policy': {
                  'payments': true,
                  'transfers': false,
                  'internet': true,
                  'dailyLimit': 2000,
                  'monthlyLimit': 10000,
                  'approvalThreshold': 1000,
                  'categories': {'food': true},
                },
              },
            ],
            'settings': {
              'a': {
                'matchingEnabled': true,
                'matchingPercent': 50,
                'matchingCapMinor': 2000,
                'notifications': true,
                'tasksEnabled': true,
                'errandsEnabled': true,
                'learningEnabled': true,
              },
            },
            'learning': [
              {'childId': 'a', 'lessonId': 'budget', 'completedAt': 1792454400},
            ],
            'lessons': [
              {
                'id': 'budget',
                'title': 'План расходов',
                'body': 'Текст урока с сервера',
                'skill': 'budgeting',
              },
            ],
            'weekly': [
              {
                'childId': 'a',
                'since': '2026-10-14',
                'incomingMinor': 2000,
                'spentMinor': 500,
                'savedMinor': -100,
                'tasksCompleted': 1,
                'lessonsCompleted': 1,
              },
            ],
          }),
        )
        as JsonMap;

FamilySpace parse(JsonMap space) =>
    FamilySpace.fromSnapshot({'familySpace': space});

void main() {
  test('absent v2 is unavailable, distinct from valid empty workspace', () {
    for (final snapshot in <JsonMap?>[
      null,
      {},
      {'familySpace': null},
    ]) {
      final space = FamilySpace.fromSnapshot(snapshot);
      expect(space.availability, SpaceAvailability.unavailable);
      expect(space.isAvailable, isFalse);
      expect(space.adultWallet, isNull);
      expect(space.errorCode, 'space_unavailable');
    }
    final empty = parse({
      'goals': [],
      'tasks': [],
      'errands': [],
      'allowances': [],
      'installments': [],
      'requests': [],
      'settings': {},
      'learning': [],
      'lessons': [],
      'weekly': [],
    });
    expect(empty.isAvailable, isTrue);
    expect(empty.adultWallet, isNull);
    expect(empty.settingsFor('a'), isNull);
    expect(empty.errorCode, isNull);
  });

  test('parses each entity, integer money, server copy and child helpers', () {
    final space = parse(spaceFixture());
    expect(space.isAvailable, isTrue);
    expect(space.adultWallet!.availableMinor, 97000);
    expect(space.adultWallet!.reservedMinor, 3000);
    expect(space.goal('goal')!.title, 'Велосипед');
    expect(space.goal('goal')!.matchingAvailableMinor, 300);
    expect(space.goal('sibling-goal')!.matchingAvailableMinor, isNull);
    expect(space.goalsFor('a').map((v) => v.id), ['goal']);
    expect(space.goalsFor('b').single.id, 'sibling-goal');
    expect(space.tasksFor('a').single.rewardMinor, 200);
    expect(space.task('task')!.status, 'accepted');
    expect(space.errand('errand')!.returnConfirmed, isTrue);
    expect(space.errandsFor('a').single.returnedMinor, 300);
    expect(space.allowance('allowance')!.weekdays, [1, 4]);
    expect(space.allowancesFor('a').single.nextDate, '2026-10-22');
    expect(space.installment('installment')!.lastAttemptDate, isNull);
    expect(space.installmentsFor('a').single.attempts, 1);
    expect(space.request('request')!.policy!.dailyLimit, 2000);
    expect(space.requestsFor('a').single.kind, 'policy');
    expect(space.settingsFor('a')!.matchingPercent, 50);
    expect(space.settingsFor('a')!.toJson()['matchingCapMinor'], 2000);
    expect(space.learningFor('a').single.completedAt, 1792454400);
    expect(space.lesson('budget')!.body, 'Текст урока с сервера');
    expect(space.lessonCompleted('a', 'budget'), isTrue);
    expect(space.lessonCompleted('b', 'budget'), isFalse);
    expect(space.weeklyFor('a')!.savedMinor, -100);
    expect(space.weeklyFor('b'), isNull);
    expect(space.goal('missing'), isNull);
  });

  test('retains supplied server scope without inventing actor permissions', () {
    final data = spaceFixture()..remove('adultWallet');
    data['goals'] = [data['goals'][0]];
    final space = FamilySpace.fromSnapshot({
      'actor': {'role': 'child', 'childId': 'a'},
      'familySpace': data,
    });
    expect(space.isAvailable, isTrue);
    expect(space.adultWallet, isNull);
    expect(space.goalsFor('b'), isEmpty);
    // Learning is completion data only and creates no synthetic policy grants.
    expect(space.lessonCompleted('a', 'budget'), isTrue);
    expect(space.request('request')!.policy!.transfers, isFalse);
  });

  test('all collections are immutable snapshots detached from raw JSON', () {
    final data = spaceFixture();
    final space = parse(data);
    data['goals'][0]['savedMinor'] = 99999;
    data['allowances'][0]['weekdays'].add(6);
    data['requests'][0]['policy']['categories']['food'] = false;
    data['settings']['a']['matchingPercent'] = 100;
    expect(space.goal('goal')!.savedMinor, 1200);
    expect(space.allowances.single.weekdays, [1, 4]);
    expect(space.requests.single.policy!.categories['food'], isTrue);
    expect(space.settingsFor('a')!.matchingPercent, 50);
    expect(() => space.goals.clear(), throwsUnsupportedError);
    expect(() => space.goalsFor('a').clear(), throwsUnsupportedError);
    expect(
      () => space.allowances.single.weekdays.add(2),
      throwsUnsupportedError,
    );
    expect(() => space.settings.clear(), throwsUnsupportedError);
    expect(
      () => space.requests.single.policy!.categories.clear(),
      throwsUnsupportedError,
    );
    final settingsJson = space.settingsFor('a')!.toJson();
    settingsJson['matchingPercent'] = 99;
    expect(space.settingsFor('a')!.matchingPercent, 50);
  });

  test(
    'money never coerces strings, doubles, booleans, null or unsafe integers',
    () {
      for (final bad in <Object?>[
        '97000',
        97000.0,
        1.2,
        true,
        null,
        9007199254740992,
      ]) {
        final data = spaceFixture();
        data['adultWallet']['availableMinor'] = bad;
        final space = parse(data);
        expect(space.availability, SpaceAvailability.malformed, reason: '$bad');
        expect(space.adultWallet, isNull);
        expect(space.goals, isEmpty);
        expect(space.errorCode, 'invalid_space_response');
      }
      for (final key in [
        'targetMinor',
        'savedMinor',
        'matchedMinor',
        'matchingAvailableMinor',
      ]) {
        final data = spaceFixture();
        data['goals'][0][key] = '100';
        expect(
          parse(data).availability,
          SpaceAvailability.malformed,
          reason: key,
        );
      }
      final wrongCurrency = spaceFixture();
      wrongCurrency['adultWallet']['currency'] = 'USD';
      expect(parse(wrongCurrency).isAvailable, isFalse);
    },
  );

  test(
    'partial and structurally malformed v2 never appear as zero balances',
    () {
      for (final bad in <Object?>[
        [],
        1,
        'space',
        {},
        {'goals': []},
      ]) {
        expect(
          FamilySpace.fromSnapshot({'familySpace': bad}).availability,
          SpaceAvailability.malformed,
        );
      }
      for (final key in [
        'tasks',
        'errands',
        'allowances',
        'installments',
        'requests',
        'settings',
        'learning',
        'lessons',
        'weekly',
      ]) {
        final data = spaceFixture()..remove(key);
        expect(parse(data).isAvailable, isFalse, reason: key);
      }
      final badPolicy = spaceFixture();
      badPolicy['requests'][0]['policy']['dailyLimit'] = '2000';
      expect(parse(badPolicy).isAvailable, isFalse);
      final badSettings = spaceFixture();
      badSettings['settings']['a']['matchingCapMinor'] = null;
      expect(parse(badSettings).isAvailable, isFalse);
      final badCount = spaceFixture();
      badCount['weekly'][0]['tasksCompleted'] = 1.5;
      expect(parse(badCount).isAvailable, isFalse);
    },
  );

  test(
    'accepts unused nil weekdays from Go and optional last-attempt dates',
    () {
      final data = spaceFixture();
      data['allowances'][0]['weekdays'] = null;
      data['allowances'][0]['frequency'] = 'daily';
      data['installments'][0]['lastAttemptDate'] = '2026-10-20';
      final space = parse(data);
      expect(space.isAvailable, isTrue);
      expect(space.allowances.single.weekdays, isEmpty);
      expect(space.installments.single.lastAttemptDate, '2026-10-20');
    },
  );

  test(
    'new money requests and server lesson questions stay immutable and strict',
    () {
      final data = spaceFixture();
      data['capabilities'] = <String, dynamic>{
        'synthetic': true,
        'currency': 'BYN',
        'timeZone': 'Europe/Minsk',
        'maxAmountMinor': 10000000,
        'matchingCapPeriod': 'goal_lifetime',
        'lessonsGrantPermissions': false,
      };
      data['requests'][0]['kind'] = 'money';
      data['requests'][0]['amountMinor'] = 2500;
      data['lessons'][0]['question'] = 'Как сохранить запас?';
      data['lessons'][0]['options'] = ['Оставить часть денег', 'Потратить всё'];
      final space = parse(data);
      expect(space.isAvailable, isTrue);
      expect(space.capabilities!.maxAmountMinor, 10000000);
      expect(space.capabilities!.lessonsGrantPermissions, isFalse);
      expect(space.requests.single.amountMinor, 2500);
      expect(space.lessons.single.question, 'Как сохранить запас?');
      expect(space.lessons.single.options.length, 2);
      expect(
        () => space.lessons.single.options.clear(),
        throwsUnsupportedError,
      );
      data['lessons'][0]['options'][0] = 'Подмена';
      expect(space.lessons.single.options.first, 'Оставить часть денег');
      expect(parse(spaceFixture()).requests.single.amountMinor, 0);
      data['requests'][0]['amountMinor'] = '2500';
      expect(parse(data).isAvailable, isFalse);
    },
  );

  test('unknown protocol statuses never leak as public copy', () {
    expect(SpaceContent.childNav, [
      'Moby',
      'Деньги',
      'Дела',
      'Цели',
      'Учиться',
    ]);
    expect(
      SpaceContent.statusLabel('future_server_state'),
      SpaceContent.unknownStatus,
    );
    expect(
      SpaceContent.errorMessage('raw_internal_code'),
      isNot(contains('raw_internal_code')),
    );
  });
}
