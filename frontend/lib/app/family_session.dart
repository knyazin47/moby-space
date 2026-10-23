import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/server/family_api.dart';
import '../data/server/family_space.dart';
import '../data/server/session_vault.dart';
import '../data/server/money_intent.dart';

const familyApiUrl = String.fromEnvironment('MOBY_API_URL');
const familyApiEnabled = familyApiUrl != '';

final familySessionProvider = Provider<FamilySession>((ref) {
  final session = FamilySession(
    api: familyApiEnabled ? FamilyApi(Uri.parse(familyApiUrl)) : null,
    vault: const SecureSessionVault(namespace: familyApiUrl),
  );
  ref.onDispose(session.dispose);
  unawaited(session.restore());
  return session;
});

/// Watch this provider for live UI updates; use familySessionProvider for commands.
final familySessionStateProvider = StreamProvider<FamilySession>((ref) async* {
  final session = ref.watch(familySessionProvider);
  yield session;
  yield* session.changes;
});

enum FamilySessionPhase { restoring, signedOut, signedIn }

class FamilySession extends ChangeNotifier {
  FamilySession({required this.api, required this.vault, this.intentVault});
  final MoneyIntentVault? intentVault;
  final FamilyApi? api;
  final SessionVault vault;
  final _changes = StreamController<FamilySession>.broadcast();
  Stream<FamilySession> get changes => _changes.stream;
  FamilySessionPhase phase = FamilySessionPhase.restoring;
  JsonMap? snapshot;
  bool connected = false;
  bool busy = false;
  String? error;
  MoneyIntentStore? _moneyIntents;
  MoneyIntentStore get moneyIntents {
    final actorId = (snapshot?['actor'] as JsonMap?)?['id'];
    if (actorId is! String) {
      throw StateError('An authenticated actor is required');
    }
    final generation = _generation;
    return _moneyIntents ??= MoneyIntentStore(
      api: api!,
      actorId: actorId,
      vault: intentVault,
      validateAcknowledgement: (pending, result) {
        if (pending.kind == MoneyIntentKind.familySpace ||
            pending.kind == MoneyIntentKind.cardBlock) {
          _validateSpaceResult(result, generation, actorId);
        }
      },
      onAcknowledged: _refreshAcknowledged,
      isActorCurrent: () =>
          !_disposed &&
          generation == _generation &&
          (snapshot?['actor'] as JsonMap?)?['id'] == actorId,
    );
  }

  /// One actor-scoped frozen v2 command may be unresolved at a time. A new
  /// action must never replace an uncertain transfer or accepted obligation.
  Future<PendingMoneyIntent?> pendingSpaceCommand() => moneyIntents.load(
    childId: 'family-space',
    kind: MoneyIntentKind.familySpace,
  );

  Future<void> submitSpaceCommand(JsonMap command) async {
    final generation = _generation;
    final actorId = (snapshot?['actor'] as JsonMap?)?['id'];
    final store = moneyIntents;
    final result = await store.submit(
      childId: 'family-space',
      kind: MoneyIntentKind.familySpace,
      payload: command,
    );
    _acceptSpaceResult(result, generation, actorId);
  }

  /// Protective action has its own durable lane: an uncertain money command
  /// must never prevent blocking a card or get discarded to make room for it.
  Future<void> blockCard(String childId) async {
    final generation = _generation;
    final actorId = (snapshot?['actor'] as JsonMap?)?['id'];
    final store = moneyIntents;
    final pending = await store.load(
      childId: childId,
      kind: MoneyIntentKind.cardBlock,
    );
    final result = pending == null
        ? await store.submit(
            childId: childId,
            kind: MoneyIntentKind.cardBlock,
            payload: {'type': 'card.block', 'childId': childId},
          )
        : await store.retry(childId: childId, kind: MoneyIntentKind.cardBlock);
    _validateSpaceResult(result, generation, actorId);
    // A replay acknowledges the old intention. If someone has unblocked since
    // that intention committed, this new explicit press must block again.
    if (pending != null &&
        (result['children'] as List).whereType<JsonMap>().any(
          (c) => c['id'] == childId && c['cardStatus'] == 'active',
        )) {
      final blocked = await store.submit(
        childId: childId,
        kind: MoneyIntentKind.cardBlock,
        payload: {'type': 'card.block', 'childId': childId},
      );
      _acceptSpaceResult(blocked, generation, actorId);
    } else {
      _acceptSpaceResult(result, generation, actorId);
    }
  }

  Future<void> retrySpaceCommand() async {
    final generation = _generation;
    final actorId = (snapshot?['actor'] as JsonMap?)?['id'];
    final result = await moneyIntents.retry(
      childId: 'family-space',
      kind: MoneyIntentKind.familySpace,
    );
    _acceptSpaceResult(result, generation, actorId);
  }

  void _validateSpaceResult(JsonMap result, int generation, Object? actorId) {
    if (_disposed || generation != _generation) {
      throw const FamilyApiException(401, 'session_changed');
    }
    final actor = result['actor'];
    if (actor is! JsonMap ||
        actor['id'] != actorId ||
        !{'adult', 'child'}.contains(actor['role']) ||
        actor['role'] != role ||
        result['children'] is! List ||
        result['revision'] is! int ||
        !FamilySpace.fromSnapshot(result).isAvailable) {
      throw const FamilyApiException(502, 'invalid_snapshot');
    }
  }

  void _acceptSpaceResult(JsonMap result, int generation, Object? actorId) {
    _validateSpaceResult(result, generation, actorId);
    _applySnapshot(result);
    connected = true;
    error = null;
    _notify();
  }

  Future<void> _refreshAcknowledged() async {
    final generation = _generation;
    try {
      await refresh();
    } catch (e) {
      if (_disposed || generation != _generation) return;
      if (e is FamilyApiException && (e.status == 401 || e.status == 403)) {
        await _clear();
      } else {
        connected = false;
        error = 'Действие выполнено. Обновляем данные…';
        _notify();
      }
    }
  }

  bool _disposed = false;
  int _generation = 0;
  Future<void> _vaultQueue = Future<void>.value();

  Future<void> _vaultWrite(Future<void> Function() action) {
    final operation = _vaultQueue.then((_) => action());
    _vaultQueue = operation.catchError((Object _) {});
    return operation;
  }

  StreamSubscription<JsonMap>? _events;
  Timer? _retry;
  int _retryAttempt = 0;

  bool get enabled => api != null;
  String? get role => (snapshot?['actor'] as JsonMap?)?['role'] as String?;
  List<JsonMap> get children => (snapshot?['children'] as List? ?? [])
      .whereType<JsonMap>()
      .toList(growable: false);
  JsonMap? get child => children.isEmpty ? null : children.first;
  int get revision => snapshot?['revision'] as int? ?? 0;

  bool get familyPreferencesAvailable =>
      role == 'adult' &&
      snapshot?['preferences'] is JsonMap &&
      (snapshot!['preferences'] as JsonMap)['familyIntroSeen'] is bool;
  bool get familyIntroSeen =>
      familyPreferencesAvailable &&
      (snapshot!['preferences'] as JsonMap)['familyIntroSeen'] == true;

  Future<void> completeFamilyIntro() async {
    if (role != 'adult' || !familyPreferencesAvailable) {
      throw const FamilyApiException(403, 'adult_preferences_required');
    }
    final generation = _generation;
    final actorId = (snapshot!['actor'] as JsonMap)['id'];
    final JsonMap result;
    try {
      result = await api!.request(
        'POST',
        '/v1/preferences/family-intro/complete',
        <String, dynamic>{},
      );
    } on FamilyApiException catch (e) {
      if (e.status == 401 && !_disposed && generation == _generation) {
        await _clear();
      }
      rethrow;
    }
    if (_disposed || generation != _generation) {
      throw const FamilyApiException(401, 'session_changed');
    }
    final actor = result['actor'];
    final preferences = result['preferences'];
    if (actor is! JsonMap ||
        actor['id'] != actorId ||
        actor['role'] != 'adult' ||
        preferences is! JsonMap ||
        preferences['familyIntroSeen'] != true) {
      throw const FamilyApiException(502, 'invalid_preferences');
    }
    // The completion response IS the snapshot; a second GET must not turn a
    // committed action into an error or restore an older intro state.
    _applySnapshot(result);
    connected = true;
    error = null;
    _notify();
  }

  void _notify() {
    if (_disposed) return;
    notifyListeners();
    _changes.add(this);
  }

  Future<void> restore() async {
    if (!enabled) {
      phase = FamilySessionPhase.signedOut;
      _notify();
      return;
    }
    final generation = _generation;
    try {
      final saved = await vault.read();
      if (_disposed || generation != _generation) return;
      api!.token = saved;
      if (saved == null) {
        phase = FamilySessionPhase.signedOut;
      } else {
        if (!await refresh() || generation != _generation) return;
        phase = FamilySessionPhase.signedIn;
        _listen();
      }
    } on FamilyApiException catch (e) {
      if (_disposed || generation != _generation) return;
      if (e.status == 401 || e.status == 403) {
        await _clear();
      } else {
        error = 'Не удалось подключиться. Проверьте интернет и повторите.';
      }
    } catch (_) {
      if (_disposed || generation != _generation) return;
      error = 'Не удалось восстановить вход. Попробуйте ещё раз.';
    }
    _notify();
  }

  Future<bool> refresh() async {
    final generation = _generation;
    final data = await api!.request('GET', '/v1/snapshot');
    if (_disposed || generation != _generation) return false;
    _applySnapshot(data);
    connected = true;
    error = null;
    _notify();
    return true;
  }

  void _applySnapshot(JsonMap data) {
    final actor = data['actor'];
    if (actor is! JsonMap ||
        !{'adult', 'child'}.contains(actor['role']) ||
        data['children'] is! List ||
        data['revision'] is! int) {
      throw const FamilyApiException(502, 'invalid_snapshot');
    }
    if ((data['revision'] as int) >= revision) snapshot = data;
  }

  Future<void> loginAdult(String bootstrapSecret) async {
    final generation = _generation;
    final result = await api!.request('POST', '/v1/auth/adult', {
      'bootstrapSecret': bootstrapSecret,
      'deviceName': 'Телефон взрослого',
    });
    if (_disposed || generation != _generation) return;
    await _accept(result);
  }

  Future<void> acceptPairSession(JsonMap session) => _accept(session);

  Future<void> _accept(JsonMap data) async {
    final token = data['token'];
    if (token is! String || token.isEmpty) {
      throw const FamilyApiException(502, 'invalid_session');
    }
    final generation = ++_generation;
    api!.cancelEvents();
    snapshot = null;
    _moneyIntents = null;
    api!.token = token;
    try {
      await _vaultWrite(() => vault.write(token));
      if (_disposed || generation != _generation) return;
      if (!await refresh() || generation != _generation) return;
      phase = FamilySessionPhase.signedIn;
      _listen();
      _notify();
    } catch (_) {
      // A failed persisted login must never leave a usable client identity.
      if (!_disposed && generation == _generation) await _clear();
      rethrow;
    }
  }

  /// Inbox acknowledgement is independent of every durable monetary lane.
  /// It neither clears nor retries an uncertain payment or transfer.
  Future<void> markNoticeRead({
    required String childId,
    required String noticeId,
  }) async {
    final actor = snapshot?['actor'] as JsonMap?;
    final noticeIsVisible = FamilySpace.fromSnapshot(snapshot).notices.any(
      (notice) => notice.id == noticeId && notice.childId == childId,
    );
    if (phase != FamilySessionPhase.signedIn ||
        !{'adult', 'child'}.contains(role) ||
        !noticeIsVisible ||
        (role == 'child' && actor?['childId'] != childId)) {
      throw const FamilyApiException(403, 'forbidden');
    }
    final random = Random.secure();
    final key = List.generate(
      16,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    await command('POST', '/v1/family-space/commands', {
      'type': 'notice.read',
      'childId': childId,
      'entityId': noticeId,
      'idempotencyKey': 'notice-read-$key',
    });
  }

  Future<JsonMap> command(String method, String path, [JsonMap? body]) async {
    final generation = _generation;
    final JsonMap result;
    try {
      result = await api!.request(method, path, body);
    } on FamilyApiException catch (e) {
      if (e.status == 401 && !_disposed && generation == _generation) {
        await _clear();
      }
      rethrow;
    }
    if (_disposed || generation != _generation) {
      throw const FamilyApiException(401, 'session_changed');
    }
    await _refreshAcknowledged();
    return result;
  }

  void _listen() {
    _retry?.cancel();
    api?.cancelEvents();
    unawaited(_events?.cancel());
    final generation = _generation;
    _events = api!.events().listen(
      (data) {
        if (_disposed || generation != _generation) return;
        // A server filtered complete snapshot is the only event payload used.
        if (data['actor'] is JsonMap &&
            data['children'] is List &&
            data['revision'] is int &&
            {'adult', 'child'}.contains((data['actor'] as JsonMap)['role'])) {
          _applySnapshot(data);
          connected = true;
          _retryAttempt = 0;
          error = null;
          _notify();
        }
      },
      onError: (Object e) {
        if (generation != _generation || _disposed) return;
        if (e is FamilyApiException && (e.status == 401 || e.status == 403)) {
          unawaited(_clear());
        } else {
          _reconnect(generation);
        }
      },
      onDone: () {
        if (generation == _generation && !_disposed) _reconnect(generation);
      },
    );
  }

  void _reconnect(int generation) {
    if (phase != FamilySessionPhase.signedIn) return;
    connected = false;
    _notify();
    _retry?.cancel();
    final seconds = 1 << (_retryAttempt++).clamp(0, 5);
    _retry = Timer(Duration(seconds: seconds), () {
      if (_disposed || generation != _generation) return;
      _listen(); // Every SSE connection starts with a fresh scoped snapshot.
    });
  }

  Future<void> logout() async {
    // Keep the credential if revocation failed, so it can be retried explicitly.
    final generation = _generation;
    try {
      await api!.request('POST', '/v1/auth/logout');
    } on FamilyApiException catch (e) {
      if (e.status != 401 && e.status != 403) rethrow;
    }
    if (!_disposed && generation == _generation) await _clear();
  }

  Future<void> _clear() async {
    _generation++;
    _retry?.cancel();
    api?.cancelEvents();
    final events = _events;
    _events = null;
    api?.token = null;
    snapshot = null;
    _moneyIntents = null;
    connected = false;
    phase = FamilySessionPhase.signedOut;
    _notify();
    final clearing = _vaultWrite(vault.clear);
    await events?.cancel();
    await clearing;
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    _retry?.cancel();
    api?.cancelEvents();
    unawaited(_events?.cancel());
    api?.close();
    unawaited(_changes.close());
    super.dispose();
  }
}

/// Central guard: unauthenticated deep links never expose family or replica data.
String? familyRouteRedirect(FamilySession session, String path) {
  if (!session.enabled) return null;
  if (session.phase == FamilySessionPhase.restoring) {
    return path == '/welcome' ? null : '/welcome';
  }
  const entry = {'/welcome', '/adult/phone', '/adult/code', '/child/pair'};
  if (session.phase == FamilySessionPhase.signedOut) {
    return entry.contains(path) ? null : '/welcome';
  }
  if (session.role == 'child') {
    return path == '/child/home' ? null : '/child/home';
  }
  if (session.role == 'adult') {
    return entry.contains(path) || path.startsWith('/child/') ? '/home' : null;
  }
  return '/welcome';
}
