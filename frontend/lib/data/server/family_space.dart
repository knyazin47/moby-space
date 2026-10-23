import 'family_api_contract.dart';

/// Availability is distinct from an empty, valid workspace.
enum SpaceAvailability { available, unavailable, malformed }

/// Immutable, server-scoped data. This parser grants no permissions and never
/// replaces missing or malformed money with a zero balance.
final class FamilySpace {
  const FamilySpace._({
    required this.availability,
    this.adultWallet,
    this.capabilities,
    this.goals = const [],
    this.tasks = const [],
    this.errands = const [],
    this.allowances = const [],
    this.installments = const [],
    this.requests = const [],
    this.settings = const {},
    this.learning = const [],
    this.lessons = const [],
    this.weekly = const [],
    this.notices = const [],
    this.activity = const [],
  });

  factory FamilySpace.fromSnapshot(JsonMap? snapshot) {
    if (snapshot == null ||
        !snapshot.containsKey('familySpace') ||
        snapshot['familySpace'] == null) {
      return const FamilySpace._(availability: SpaceAvailability.unavailable);
    }
    try {
      final data = _map(snapshot['familySpace']);
      return FamilySpace._(
        availability: SpaceAvailability.available,
        adultWallet: data['adultWallet'] == null
            ? null
            : SpaceWallet._parse(_map(data['adultWallet'])),
        capabilities: data['capabilities'] == null
            ? null
            : SpaceCapabilities._parse(_map(data['capabilities'])),
        goals: _items(data, 'goals', SpaceGoal._parse),
        tasks: _items(data, 'tasks', SpaceTask._parse),
        errands: _items(data, 'errands', SpaceErrand._parse),
        allowances: _items(data, 'allowances', SpaceAllowance._parse),
        installments: _items(data, 'installments', SpaceInstallment._parse),
        requests: _items(data, 'requests', SpaceRequest._parse),
        settings: Map.unmodifiable(
          _map(data['settings']).map(
            (key, value) => MapEntry(key, SpaceSettings._parse(_map(value))),
          ),
        ),
        learning: _items(data, 'learning', SpaceLessonCompletion._parse),
        lessons: _items(data, 'lessons', SpaceLesson._parse),
        weekly: _items(data, 'weekly', SpaceWeekly._parse),
        activity: data['activity'] == null
            ? const []
            : _items(data, 'activity', SpaceActivity._parse),
        notices: data['notices'] == null
            ? const []
            : _items(data, 'notices', SpaceNotice._parse),
      );
    } on FormatException {
      return const FamilySpace._(availability: SpaceAvailability.malformed);
    }
  }

  final SpaceAvailability availability;
  bool get isAvailable => availability == SpaceAvailability.available;
  String? get errorCode => switch (availability) {
    SpaceAvailability.available => null,
    SpaceAvailability.unavailable => 'space_unavailable',
    SpaceAvailability.malformed => 'invalid_space_response',
  };
  final SpaceWallet? adultWallet;
  final SpaceCapabilities? capabilities;
  final List<SpaceGoal> goals;
  final List<SpaceTask> tasks;
  final List<SpaceErrand> errands;
  final List<SpaceAllowance> allowances;
  final List<SpaceInstallment> installments;
  final List<SpaceRequest> requests;
  final Map<String, SpaceSettings> settings;
  final List<SpaceLessonCompletion> learning;
  final List<SpaceLesson> lessons;
  final List<SpaceWeekly> weekly;
  final List<SpaceNotice> notices;
  final List<SpaceActivity> activity;

  List<SpaceGoal> goalsFor(String childId) =>
      _forChild(goals, childId, (v) => v.childId);
  List<SpaceTask> tasksFor(String childId) =>
      _forChild(tasks, childId, (v) => v.childId);
  List<SpaceErrand> errandsFor(String childId) =>
      _forChild(errands, childId, (v) => v.childId);
  List<SpaceAllowance> allowancesFor(String childId) =>
      _forChild(allowances, childId, (v) => v.childId);
  List<SpaceInstallment> installmentsFor(String childId) =>
      _forChild(installments, childId, (v) => v.childId);
  List<SpaceRequest> requestsFor(String childId) =>
      _forChild(requests, childId, (v) => v.childId);
  List<SpaceLessonCompletion> learningFor(String childId) =>
      _forChild(learning, childId, (v) => v.childId);
  SpaceSettings? settingsFor(String childId) => settings[childId];
  SpaceWeekly? weeklyFor(String childId) =>
      _find(weekly, (v) => v.childId == childId);
  SpaceGoal? goal(String id) => _find(goals, (v) => v.id == id);
  SpaceTask? task(String id) => _find(tasks, (v) => v.id == id);
  SpaceErrand? errand(String id) => _find(errands, (v) => v.id == id);
  SpaceAllowance? allowance(String id) => _find(allowances, (v) => v.id == id);
  SpaceInstallment? installment(String id) =>
      _find(installments, (v) => v.id == id);
  SpaceRequest? request(String id) => _find(requests, (v) => v.id == id);
  SpaceLesson? lesson(String id) => _find(lessons, (v) => v.id == id);
  bool lessonCompleted(String childId, String lessonId) =>
      learning.any((v) => v.childId == childId && v.lessonId == lessonId);
}

final class SpaceWallet {
  const SpaceWallet._({
    required this.availableMinor,
    required this.reservedMinor,
    required this.currency,
  });
  factory SpaceWallet._parse(JsonMap data) => SpaceWallet._(
    availableMinor: _integer(data['availableMinor']),
    reservedMinor: _integer(data['reservedMinor']),
    currency: _currency(data['currency']),
  );
  final int availableMinor;
  final int reservedMinor;
  final String currency;
}

final class SpaceGoal {
  const SpaceGoal._({
    required this.id,
    required this.childId,
    required this.title,
    required this.targetMinor,
    required this.savedMinor,
    required this.matchedMinor,
    required this.netDepositsMinor,
    required this.matchedBasisMinor,
    required this.matchingAvailableMinor,
    required this.matchingStatus,
  });
  factory SpaceGoal._parse(JsonMap data) => SpaceGoal._(
    id: _string(data['id']),
    childId: _string(data['childId']),
    title: _string(data['title']),
    targetMinor: _integer(data['targetMinor']),
    savedMinor: _integer(data['savedMinor']),
    matchedMinor: _integer(data['matchedMinor']),
    netDepositsMinor: data['netDepositsMinor'] == null
        ? null
        : _integer(data['netDepositsMinor']),
    matchedBasisMinor: data['matchedBasisMinor'] == null
        ? null
        : _integer(data['matchedBasisMinor']),
    matchingAvailableMinor: data['matchingAvailableMinor'] == null
        ? null
        : _integer(data['matchingAvailableMinor']),
    matchingStatus: data['matchingStatus'] == null
        ? null
        : _string(data['matchingStatus']),
  );
  final String id;
  final String childId;
  final String title;
  final int targetMinor;
  final int savedMinor;
  final int matchedMinor;
  final int? netDepositsMinor;
  final int? matchedBasisMinor;
  final int? matchingAvailableMinor;
  final String? matchingStatus;
}

final class SpaceTask {
  const SpaceTask._({
    required this.id,
    required this.childId,
    required this.title,
    required this.rewardMinor,
    required this.status,
    required this.cancelRequested,
    this.cancelReason,
  });
  factory SpaceTask._parse(JsonMap data) => SpaceTask._(
    id: _string(data['id']),
    childId: _string(data['childId']),
    title: _string(data['title']),
    rewardMinor: _integer(data['rewardMinor']),
    status: _string(data['status']),
    cancelRequested: _boolean(data['cancelRequested']),
    cancelReason: data['cancelReason'] == null
        ? null
        : _string(data['cancelReason']),
  );
  final String id;
  final String childId;
  final String title;
  final int rewardMinor;
  final String status;
  final bool cancelRequested;
  final String? cancelReason;
}

final class SpaceErrand {
  const SpaceErrand._({
    required this.id,
    required this.childId,
    required this.title,
    required this.budgetMinor,
    required this.rewardMinor,
    required this.actualMinor,
    required this.returnedMinor,
    required this.funding,
    required this.status,
    required this.ownMoneyConsent,
    required this.cancelRequested,
    this.cancelReason,
    required this.returnConfirmed,
    this.expenseRecorded = false,
  });
  factory SpaceErrand._parse(JsonMap data) => SpaceErrand._(
    id: _string(data['id']),
    childId: _string(data['childId']),
    title: _string(data['title']),
    budgetMinor: _integer(data['budgetMinor']),
    rewardMinor: _integer(data['rewardMinor']),
    actualMinor: _integer(data['actualMinor']),
    returnedMinor: _integer(data['returnedMinor']),
    funding: _string(data['funding']),
    status: _string(data['status']),
    ownMoneyConsent: _boolean(data['ownMoneyConsent']),
    cancelRequested: _boolean(data['cancelRequested']),
    cancelReason: data['cancelReason'] == null
        ? null
        : _string(data['cancelReason']),
    returnConfirmed: _boolean(data['returnConfirmed']),
    expenseRecorded: data['expenseRecorded'] == null
        ? false
        : _boolean(data['expenseRecorded']),
  );
  final String id;
  final String childId;
  final String title;
  final int budgetMinor;
  final int rewardMinor;
  final int actualMinor;
  final int returnedMinor;
  final String funding;
  final String status;
  final bool ownMoneyConsent;
  final bool cancelRequested;
  final String? cancelReason;
  final bool returnConfirmed;
  final bool expenseRecorded;
}

final class SpaceAllowance {
  const SpaceAllowance._({
    required this.id,
    required this.childId,
    required this.title,
    required this.amountMinor,
    required this.frequency,
    required this.weekdays,
    required this.monthDay,
    required this.nextDate,
    required this.retryLimit,
    required this.active,
  });
  factory SpaceAllowance._parse(JsonMap data) => SpaceAllowance._(
    id: _string(data['id']),
    childId: _string(data['childId']),
    title: _string(data['title']),
    amountMinor: _integer(data['amountMinor']),
    frequency: _string(data['frequency']),
    weekdays: _intList(data['weekdays']),
    monthDay: _integer(data['monthDay']),
    nextDate: _string(data['nextDate']),
    retryLimit: _integer(data['retryLimit']),
    active: _boolean(data['active']),
  );
  final String id;
  final String childId;
  final String title;
  final int amountMinor;
  final String frequency;
  final List<int> weekdays;
  final int monthDay;
  final String nextDate;
  final int retryLimit;
  final bool active;
}

final class SpaceInstallment {
  const SpaceInstallment._({
    required this.id,
    required this.childId,
    required this.allowanceId,
    required this.dueDate,
    required this.amountMinor,
    required this.status,
    required this.attempts,
    required this.lastAttemptDate,
  });
  factory SpaceInstallment._parse(JsonMap data) => SpaceInstallment._(
    id: _string(data['id']),
    childId: _string(data['childId']),
    allowanceId: _string(data['allowanceId']),
    dueDate: _string(data['dueDate']),
    amountMinor: _integer(data['amountMinor']),
    status: _string(data['status']),
    attempts: _integer(data['attempts']),
    lastAttemptDate: data['lastAttemptDate'] == null
        ? null
        : _string(data['lastAttemptDate']),
  );
  final String id;
  final String childId;
  final String allowanceId;
  final String dueDate;
  final int amountMinor;
  final String status;
  final int attempts;
  final String? lastAttemptDate;
}

final class SpaceRequest {
  const SpaceRequest._({
    required this.id,
    required this.amountMinor,
    required this.childId,
    required this.title,
    required this.kind,
    required this.policy,
    required this.status,
  });
  factory SpaceRequest._parse(JsonMap data) => SpaceRequest._(
    id: _string(data['id']),
    amountMinor: data.containsKey('amountMinor')
        ? _integer(data['amountMinor'])
        : 0,
    childId: _string(data['childId']),
    title: _string(data['title']),
    kind: _string(data['kind']),
    policy: data['policy'] == null
        ? null
        : SpacePolicy._parse(_map(data['policy'])),
    status: _string(data['status']),
  );
  final String id;
  final int amountMinor;
  final String childId;
  final String title;
  final String kind;
  final SpacePolicy? policy;
  final String status;
}

final class SpaceSettings {
  const SpaceSettings._({
    required this.matchingEnabled,
    required this.matchingPercent,
    required this.matchingCapMinor,
    required this.notifications,
    required this.tasksEnabled,
    required this.errandsEnabled,
    required this.learningEnabled,
  });
  factory SpaceSettings._parse(JsonMap data) => SpaceSettings._(
    matchingEnabled: _boolean(data['matchingEnabled']),
    matchingPercent: _integer(data['matchingPercent']),
    matchingCapMinor: _integer(data['matchingCapMinor']),
    notifications: _boolean(data['notifications']),
    tasksEnabled: _boolean(data['tasksEnabled']),
    errandsEnabled: _boolean(data['errandsEnabled']),
    learningEnabled: _boolean(data['learningEnabled']),
  );
  final bool matchingEnabled;
  final int matchingPercent;
  final int matchingCapMinor;
  final bool notifications;
  final bool tasksEnabled;
  final bool errandsEnabled;
  final bool learningEnabled;
  JsonMap toJson() => {
    'matchingEnabled': matchingEnabled,
    'matchingPercent': matchingPercent,
    'matchingCapMinor': matchingCapMinor,
    'notifications': notifications,
    'tasksEnabled': tasksEnabled,
    'errandsEnabled': errandsEnabled,
    'learningEnabled': learningEnabled,
  };
}

final class SpacePolicy {
  const SpacePolicy._({
    required this.payments,
    required this.transfers,
    required this.internet,
    required this.dailyLimit,
    required this.monthlyLimit,
    required this.approvalThreshold,
    required this.categories,
  });
  factory SpacePolicy._parse(JsonMap data) => SpacePolicy._(
    payments: _boolean(data['payments']),
    transfers: _boolean(data['transfers']),
    internet: _boolean(data['internet']),
    dailyLimit: _integer(data['dailyLimit']),
    monthlyLimit: _integer(data['monthlyLimit']),
    approvalThreshold: _integer(data['approvalThreshold']),
    categories: _boolMap(data['categories']),
  );
  final bool payments;
  final bool transfers;
  final bool internet;
  final int dailyLimit;
  final int monthlyLimit;
  final int approvalThreshold;
  final Map<String, bool> categories;
  JsonMap toJson() => {
    'payments': payments,
    'transfers': transfers,
    'internet': internet,
    'dailyLimit': dailyLimit,
    'monthlyLimit': monthlyLimit,
    'approvalThreshold': approvalThreshold,
    'categories': categories,
  };
}

final class SpaceLesson {
  const SpaceLesson._({
    required this.id,
    required this.question,
    required this.options,
    required this.title,
    required this.body,
    required this.skill,
  });
  factory SpaceLesson._parse(JsonMap data) => SpaceLesson._(
    id: _string(data['id']),
    question: data['question'] == null ? null : _string(data['question']),
    options: data.containsKey('options')
        ? _stringList(data['options'])
        : const [],
    title: _string(data['title']),
    body: _string(data['body']),
    skill: _string(data['skill']),
  );
  final String id;
  final String? question;
  final List<String> options;
  final String title;
  final String body;
  final String skill;
}

final class SpaceLessonCompletion {
  const SpaceLessonCompletion._({
    required this.childId,
    required this.lessonId,
    required this.completedAt,
  });
  factory SpaceLessonCompletion._parse(JsonMap data) => SpaceLessonCompletion._(
    childId: _string(data['childId']),
    lessonId: _string(data['lessonId']),
    completedAt: _integer(data['completedAt']),
  );
  final String childId;
  final String lessonId;
  final int completedAt;
}

final class SpaceWeekly {
  const SpaceWeekly._({
    required this.childId,
    required this.since,
    required this.incomingMinor,
    required this.spentMinor,
    required this.savedMinor,
    required this.tasksCompleted,
    required this.lessonsCompleted,
  });
  factory SpaceWeekly._parse(JsonMap data) => SpaceWeekly._(
    childId: _string(data['childId']),
    since: _string(data['since']),
    incomingMinor: _integer(data['incomingMinor']),
    spentMinor: _integer(data['spentMinor']),
    savedMinor: _integer(data['savedMinor']),
    tasksCompleted: _integer(data['tasksCompleted']),
    lessonsCompleted: _integer(data['lessonsCompleted']),
  );
  final String childId;
  final String since;
  final int incomingMinor;
  final int spentMinor;
  final int savedMinor;
  final int tasksCompleted;
  final int lessonsCompleted;
}

JsonMap _map(Object? value) {
  if (value is! Map || value.keys.any((key) => key is! String)) {
    throw const FormatException('invalid_object');
  }
  return Map<String, dynamic>.from(value);
}

String _string(Object? value) {
  if (value is! String) throw const FormatException('invalid_string');
  return value;
}

int _integer(Object? value) {
  // Keep exact integer money on both the Dart VM and JavaScript clients.
  if (value is! int || value.abs() > 9007199254740991) {
    throw const FormatException('invalid_integer');
  }
  return value;
}

bool _boolean(Object? value) {
  if (value is! bool) throw const FormatException('invalid_boolean');
  return value;
}

List<T> _items<T>(JsonMap data, String key, T Function(JsonMap) parse) {
  final value = data[key];
  if (value is! List) throw const FormatException('invalid_array');
  return List.unmodifiable(value.map((item) => parse(_map(item))));
}

List<int> _intList(Object? value) {
  // Go encodes a nil, unused weekdays slice as null for daily/monthly schedules.
  if (value == null) return const [];
  if (value is! List) throw const FormatException('invalid_integer_array');
  return List.unmodifiable(value.map(_integer));
}

Map<String, bool> _boolMap(Object? value) {
  if (value == null) return const {};
  return Map.unmodifiable(
    _map(value).map((key, v) => MapEntry(key, _boolean(v))),
  );
}

List<T> _forChild<T>(List<T> items, String childId, String Function(T) id) =>
    List.unmodifiable(items.where((item) => id(item) == childId));
T? _find<T>(List<T> items, bool Function(T) matches) {
  for (final item in items) {
    if (matches(item)) return item;
  }
  return null;
}

String _currency(Object? value) {
  if (value != 'BYN') throw const FormatException('invalid_currency');
  return 'BYN';
}

/// Informational server capabilities, never a local authorization policy.
final class SpaceCapabilities {
  const SpaceCapabilities._({
    required this.synthetic,
    required this.currency,
    required this.timeZone,
    required this.maxAmountMinor,
    required this.matchingCapPeriod,
    required this.lessonsGrantPermissions,
  });
  factory SpaceCapabilities._parse(JsonMap data) => SpaceCapabilities._(
    synthetic: _boolean(data['synthetic']),
    currency: _currency(data['currency']),
    timeZone: _string(data['timeZone']),
    maxAmountMinor: _integer(data['maxAmountMinor']),
    matchingCapPeriod: _string(data['matchingCapPeriod']),
    lessonsGrantPermissions: _boolean(data['lessonsGrantPermissions']),
  );
  final bool synthetic;
  final String currency;
  final String timeZone;
  final int maxAmountMinor;
  final String matchingCapPeriod;
  final bool lessonsGrantPermissions;
}

List<String> _stringList(Object? value) {
  if (value is! List) throw const FormatException('invalid_string_array');
  return List.unmodifiable(value.map(_string));
}

final class SpaceNotice {
  const SpaceNotice._({
    required this.id,
    required this.childId,
    required this.title,
    required this.body,
    required this.kind,
    required this.createdAt,
    required this.read,
    required this.mandatory,
  });
  factory SpaceNotice._parse(JsonMap data) => SpaceNotice._(
    id: _string(data['id']),
    childId: _string(data['childId']),
    title: _string(data['title']),
    body: _string(data['body']),
    kind: _string(data['kind']),
    createdAt: _integer(data['createdAt']),
    read: _boolean(data['read']),
    mandatory: _boolean(data['mandatory']),
  );
  final String id, childId, title, body, kind;
  final int createdAt;
  final bool read, mandatory;
}

final class SpaceActivity {
  const SpaceActivity._({
    required this.id,
    required this.childId,
    required this.kind,
    required this.amountMinor,
    required this.at,
  });
  factory SpaceActivity._parse(JsonMap data) => SpaceActivity._(
    id: _string(data['id']),
    childId: data['childId'] == null ? '' : _string(data['childId']),
    kind: _string(data['kind']),
    amountMinor: _integer(data['amountMinor']),
    at: _integer(data['at']),
  );
  final String id, childId, kind;
  final int amountMinor, at;
}
