import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'family_api.dart';

enum MoneyIntentKind { purchase, topup, createChild, familySpace, cardBlock }

abstract interface class MoneyIntentVault {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class SecureMoneyIntentVault implements MoneyIntentVault {
  const SecureMoneyIntentVault();
  static const _storage = FlutterSecureStorage();
  @override
  Future<String?> read(String key) => _storage.read(key: key);
  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);
  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

class PendingMoneyIntent {
  PendingMoneyIntent({
    required this.kind,
    required this.childId,
    required JsonMap payload,
  }) : payload = Map<String, dynamic>.unmodifiable(payload);
  final MoneyIntentKind kind;
  final String childId;
  final JsonMap payload;
}

class PendingMoneyIntentException implements Exception {
  const PendingMoneyIntentException();
  @override
  String toString() =>
      'An unresolved action must be retried before creating another';
}

/// One durable, frozen command per actor/child/kind. An uncertain response can
/// only replay the same payload/key, including after navigation or app restart.
class MoneyIntentStore {
  MoneyIntentStore({
    required this.api,
    required this.actorId,
    MoneyIntentVault? vault,
    this.onAcknowledged,
    this.isActorCurrent,
    this.validateAcknowledgement,
  }) : vault = vault ?? const SecureMoneyIntentVault();
  final FamilyApi api;
  final String actorId;
  final MoneyIntentVault vault;
  final Future<void> Function()? onAcknowledged;
  final bool Function()? isActorCurrent;
  final void Function(PendingMoneyIntent pending, JsonMap result)?
  validateAcknowledgement;
  final _locks = <String, Future<void>>{};

  String _key(String childId, MoneyIntentKind kind) =>
      'moby.intent.v1.${api.baseUri}.$actorId.$childId.${kind.name}';

  Future<T> _locked<T>(String key, Future<T> Function() action) {
    final next = (_locks[key] ?? Future<void>.value()).then((_) => action());
    _locks[key] = next.then<void>((_) {}).catchError((Object _) {});
    return next;
  }

  Future<PendingMoneyIntent?> load({
    required String childId,
    required MoneyIntentKind kind,
  }) {
    final key = _key(childId, kind);
    return _locked(key, () => _load(key, childId, kind));
  }

  Future<PendingMoneyIntent?> _load(
    String key,
    String childId,
    MoneyIntentKind kind,
  ) async {
    final raw = await vault.read(key);
    if (raw == null) return null;
    final decoded = jsonDecode(raw);
    if (decoded is! JsonMap ||
        decoded['payload'] is! JsonMap ||
        decoded['kind'] != kind.name ||
        decoded['childId'] != childId ||
        (decoded['payload'] as JsonMap)['idempotencyKey'] is! String) {
      // Fail closed: corrupt local state must never generate a replacement key.
      throw const PendingMoneyIntentException();
    }
    return PendingMoneyIntent(
      kind: kind,
      childId: childId,
      payload: decoded['payload'] as JsonMap,
    );
  }

  Future<JsonMap> submit({
    required String childId,
    required MoneyIntentKind kind,
    required JsonMap payload,
  }) {
    final key = _key(childId, kind);
    return _locked(key, () async {
      if (await _load(key, childId, kind) != null) {
        throw const PendingMoneyIntentException();
      }
      final frozen = jsonDecode(jsonEncode(payload)) as JsonMap;
      frozen['idempotencyKey'] = List.generate(
        32,
        (_) => Random.secure().nextInt(256).toRadixString(16).padLeft(2, '0'),
      ).join();
      final pending = PendingMoneyIntent(
        kind: kind,
        childId: childId,
        payload: frozen,
      );
      await vault.write(
        key,
        jsonEncode({
          'version': 1,
          'kind': kind.name,
          'childId': childId,
          'payload': frozen,
        }),
      );
      return _send(key, pending);
    });
  }

  Future<JsonMap> retry({
    required String childId,
    required MoneyIntentKind kind,
  }) {
    final key = _key(childId, kind);
    return _locked(key, () async {
      final pending = await _load(key, childId, kind);
      if (pending == null) throw const PendingMoneyIntentException();
      return _send(key, pending);
    });
  }

  Future<JsonMap> _send(String key, PendingMoneyIntent pending) async {
    final path = switch (pending.kind) {
      MoneyIntentKind.purchase =>
        '/v1/children/${Uri.encodeComponent(pending.childId)}/operations',
      MoneyIntentKind.topup =>
        '/v1/children/${Uri.encodeComponent(pending.childId)}/topups',
      MoneyIntentKind.createChild => '/v1/children',
      MoneyIntentKind.familySpace ||
      MoneyIntentKind.cardBlock => '/v1/family-space/commands',
    };
    if (isActorCurrent != null && !isActorCurrent!()) {
      throw const FamilyApiException(401, 'session_changed');
    }
    final JsonMap result;
    try {
      result = await api.request('POST', path, pending.payload);
    } on FamilyApiException catch (e) {
      // Authentication, rate limits, server errors and ambiguous conflicts keep
      // the original key. A new login can replay under the same stable actor.
      if ({400, 404, 409, 410, 422}.contains(e.status) &&
          e.code != 'idempotency_conflict') {
        await vault.delete(key);
      }
      rethrow;
    }
    validateAcknowledgement?.call(pending, result);
    await vault.delete(key);
    // Acknowledged mutation remains successful even if snapshot refresh fails.
    try {
      if (pending.kind != MoneyIntentKind.familySpace &&
          pending.kind != MoneyIntentKind.cardBlock) {
        await onAcknowledged?.call();
      }
    } catch (_) {
      /* SSE/reconnect refreshes later. */
    }
    return result;
  }
}
