import 'dart:async';

import 'package:grpc/grpc.dart' as grpc;
import 'package:protobuf/protobuf.dart';

import 'family_api_contract.dart';
import 'family_grpc_codec.dart';
import 'generated/moby/family/v1/family.pbgrpc.dart' as pb;

/// Native typed RPC dispatch. HTTP-style paths exist only in the local facade;
/// no method/path, JSON or untyped command envelope is sent over the network.
class FamilyGrpcTransport {
  FamilyGrpcTransport(
    Uri endpoint, {
    grpc.ClientChannel? channel,
    this.requestTimeout = const Duration(seconds: 20),
    this.streamIdleTimeout = const Duration(seconds: 35),
  }) : _channel =
           channel ??
           grpc.ClientChannel(
             endpoint.host,
             port: endpoint.hasPort
                 ? endpoint.port
                 : endpoint.scheme == 'https'
                 ? 443
                 : 80,
             options: grpc.ChannelOptions(
               credentials: endpoint.scheme == 'https'
                   ? const grpc.ChannelCredentials.secure()
                   : const grpc.ChannelCredentials.insecure(),
               connectTimeout: const Duration(seconds: 15),
             ),
           ) {
    _client = pb.FamilyServiceClient(_channel);
  }

  final grpc.ClientChannel _channel;
  late final pb.FamilyServiceClient _client;
  final Duration requestTimeout, streamIdleTimeout;
  final Set<grpc.ResponseStream<pb.Snapshot>> _streams = {};
  int _streamEpoch = 0;
  bool _closed = false;

  grpc.CallOptions _options(String? token, {bool streaming = false}) =>
      grpc.CallOptions(
        timeout: streaming ? null : requestTimeout,
        metadata: {if (token != null) 'authorization': 'Bearer $token'},
      );

  Future<JsonMap> request(
    String method,
    String path,
    JsonMap? body,
    String? authorization,
  ) async {
    if (_closed) throw const FamilyApiException(503, 'transport_closed');
    final options = _options(authorization);
    final values = body ?? <String, dynamic>{};
    final segments = Uri.parse(path).pathSegments;
    try {
      final GeneratedMessage response;
      switch ((method, segments)) {
        case ('POST', ['v1', 'auth', 'adult']):
          response = await _client.loginAdult(
            familyMessage(pb.LoginAdultRequest(), values),
            options: options,
          );
        case ('POST', ['v1', 'auth', 'logout']):
          response = await _client.logout(pb.Empty(), options: options);
        case ('GET', ['v1', 'snapshot']):
          response = await _client.getSnapshot(pb.Empty(), options: options);
        case ('POST', ['v1', 'preferences', 'family-intro', 'complete']):
          response = await _client.completeFamilyIntro(
            pb.Empty(),
            options: options,
          );
        case ('POST', ['v1', 'family-space', 'commands']):
          response = await _client.executeFamilySpaceCommand(
            familyMessage(pb.SpaceCommand(), values),
            options: options,
          );
        case ('GET', ['v1', 'children']):
          response = await _client.listChildren(pb.Empty(), options: options);
          return {
            'items': (response as pb.ChildrenList).children
                .map(_child)
                .toList(),
          };
        case ('POST', ['v1', 'children']):
          response = await _client.createChild(
            familyMessage(pb.CreateChildRequest(), values),
            options: options,
          );
        case ('GET', ['v1', 'children', final id]):
          response = await _client.getChild(
            pb.ChildRef(childId: id),
            options: options,
          );
        case ('PATCH', ['v1', 'children', final id]):
          response = await _client.updateChild(
            pb.UpdateChildRequest(
              childId: id,
              patch: familyMessage(pb.ChildPatch(), values),
            ),
            options: options,
          );
        case ('PATCH', ['v1', 'children', final id, 'policy']):
          response = await _client.updatePolicy(
            pb.UpdatePolicyRequest(
              childId: id,
              policy: familyMessage(pb.Policy(), values),
            ),
            options: options,
          );
        case ('POST', ['v1', 'children', final id, 'archive']):
          response = await _client.archiveChild(
            pb.ChildRef(childId: id),
            options: options,
          );
        case ('POST', ['v1', 'children', final id, 'verification']):
          response = await _client.verifyChild(
            familyMessage(pb.VerifyChildRequest(), {...values, 'childId': id}),
            options: options,
          );
        case ('POST', ['v1', 'children', final id, 'product']):
          response = await _client.openProduct(
            familyMessage(pb.OpenProductRequest(), {...values, 'childId': id}),
            options: options,
          );
        case ('POST', ['v1', 'children', final id, 'operations']):
          response = await _client.purchase(
            pb.ChildMoneyRequest(
              childId: id,
              input: familyMessage(pb.MoneyInput(), values),
            ),
            options: options,
          );
        case ('POST', ['v1', 'children', final id, 'topups']):
          response = await _client.topUp(
            pb.ChildMoneyRequest(
              childId: id,
              input: familyMessage(pb.MoneyInput(), values),
            ),
            options: options,
          );
        case ('POST', ['v1', 'operations', final id, 'decision']):
          response = await _client.decideOperation(
            familyMessage(pb.DecideOperationRequest(), {
              ...values,
              'operationId': id,
            }),
            options: options,
          );
        case ('POST', ['v1', 'pairings']):
          response = await _client.createPairing(
            familyMessage(pb.CreatePairingRequest(), values),
            options: options,
          );
        case ('POST', ['v1', 'pairings', 'consume']):
          response = await _client.consumePairing(
            familyMessage(pb.ConsumePairingRequest(), values),
            options: options,
          );
        case ('POST', ['v1', 'pairings', final id, 'poll']):
          response = await _client.pollPairing(
            familyMessage(pb.PairingSecretRequest(), {
              ...values,
              'pairingId': id,
            }),
            options: options,
          );
        case ('POST', ['v1', 'pairings', final id, 'cancel']):
          response = await _client.cancelPairing(
            familyMessage(pb.PairingSecretRequest(), {
              ...values,
              'pairingId': id,
            }),
            options: options,
          );
        case ('GET', ['v1', 'sessions']):
          response = await _client.listSessions(pb.Empty(), options: options);
          return {
            'items': (response as pb.SessionsList).sessions
                .map(familyMessageMap)
                .toList(),
          };
        case ('POST', ['v1', 'sessions', final id, 'revoke']):
          response = await _client.revokeSession(
            pb.SessionRef(sessionId: id),
            options: options,
          );
        default:
          throw const FamilyApiException(404, 'endpoint_not_found');
      }
      if (response is pb.Snapshot) return familySnapshotMap(response);
      if (response is pb.Child) return _child(response);
      if (response is pb.Operation) return _operation(response);
      if (response is pb.Empty) return {'ok': true};
      final result = familyMessageMap(response);
      if (response is pb.SessionGrant) _validateGrant(result);
      if (response is pb.PairingPoll) {
        final grant = result['session'];
        if (grant is JsonMap) _validateGrant(grant);
      }
      return result;
    } on grpc.GrpcError catch (error) {
      throw familyGrpcException(error);
    }
  }

  Stream<JsonMap> events(String? authorization) {
    final epoch = _streamEpoch;
    return _watch(authorization, epoch);
  }

  Stream<JsonMap> _watch(String? authorization, int epoch) async* {
    if (epoch != _streamEpoch) return;
    if (_closed) throw const FamilyApiException(503, 'transport_closed');
    final response = _client.watchSnapshots(
      pb.Empty(),
      options: _options(authorization, streaming: true),
    );
    _streams.add(response);
    try {
      await for (final snapshot in response.timeout(streamIdleTimeout)) {
        if (epoch != _streamEpoch) break;
        yield familySnapshotMap(snapshot);
      }
    } on grpc.GrpcError catch (error) {
      if (epoch == _streamEpoch) throw familyGrpcException(error);
    } catch (_) {
      if (epoch == _streamEpoch) rethrow;
    } finally {
      _streams.remove(response);
      await _cancelStream(response);
    }
  }

  void cancelEvents() {
    _streamEpoch++;
    for (final response in _streams.toList()) {
      unawaited(_cancelStream(response));
    }
  }

  void close() {
    _closed = true;
    cancelEvents();
    unawaited(_channel.terminate());
  }
}

Future<void> _cancelStream(grpc.ResponseStream<pb.Snapshot> response) async {
  try {
    await response.cancel();
  } catch (_) {
    // Cancellation cannot replace the original transport/domain failure.
  }
}

JsonMap _child(pb.Child child) {
  final result = familyMessageMap(child);
  if (result['id'] is! String ||
      (result['id'] as String).isEmpty ||
      result['balanceMinor'] is! int ||
      (result['balanceMinor'] as int) < 0 ||
      result['currency'] != 'BYN') {
    throw const FamilyApiException(502, 'invalid_response');
  }
  return result;
}

JsonMap _operation(pb.Operation operation) {
  final result = familyMessageMap(operation);
  if (result['id'] is! String ||
      (result['id'] as String).isEmpty ||
      result['amountMinor'] is! int ||
      (result['amountMinor'] as int) < 0 ||
      result['currency'] != 'BYN') {
    throw const FamilyApiException(502, 'invalid_response');
  }
  return result;
}

void _validateGrant(JsonMap grant) {
  if (grant['token'] is! String || (grant['token'] as String).isEmpty) {
    throw const FamilyApiException(502, 'invalid_session');
  }
}

/// Preserve domain rejection semantics for the durable money outbox. Transport
/// failures never masquerade as definitive business rejections.
FamilyApiException familyGrpcException(grpc.GrpcError error) {
  final trailerStatus = error.trailers?['moby-semantic-status'];
  var semantic = int.tryParse(trailerStatus ?? '');
  var code = error.trailers?['moby-error-code'];
  final hasDomainTrailers = trailerStatus != null || code != null;
  if (hasDomainTrailers && !_validDomain(semantic, code)) {
    return const FamilyApiException(502, 'invalid_error_details');
  }
  for (final detail in error.details ?? <GeneratedMessage>[]) {
    var matchingDomain = false;
    try {
      if (detail.info_.qualifiedMessageName != 'google.protobuf.Any') continue;
      matchingDomain = (detail.getField(1) as String).endsWith(
        '/moby.family.v1.DomainErrorDetail',
      );
      if (!matchingDomain) continue;
      final domain = pb.DomainErrorDetail.fromBuffer(
        detail.getField(2) as List<int>,
      );
      if (!_validDomain(domain.semanticStatus, domain.code) ||
          (semantic != null && semantic != domain.semanticStatus) ||
          (code != null && code != domain.code)) {
        return const FamilyApiException(502, 'invalid_error_details');
      }
      semantic = domain.semanticStatus;
      code = domain.code;
    } catch (_) {
      if (matchingDomain) {
        return const FamilyApiException(502, 'invalid_error_details');
      }
    }
  }
  if (semantic != null && code != null) {
    if (_domainGrpcStatus(semantic) != error.code) {
      return const FamilyApiException(502, 'invalid_error_details');
    }
    return FamilyApiException(semantic, code);
  }
  return switch (error.code) {
    grpc.StatusCode.unauthenticated => const FamilyApiException(
      401,
      'unauthorized',
    ),
    grpc.StatusCode.permissionDenied => const FamilyApiException(
      403,
      'forbidden',
    ),
    grpc.StatusCode.deadlineExceeded => const FamilyApiException(
      408,
      'deadline_exceeded',
    ),
    grpc.StatusCode.resourceExhausted => const FamilyApiException(
      429,
      'rate_limited',
    ),
    grpc.StatusCode.cancelled => const FamilyApiException(
      499,
      'request_cancelled',
    ),
    grpc.StatusCode.unavailable => const FamilyApiException(503, 'unavailable'),
    _ => const FamilyApiException(502, 'request_failed'),
  };
}

// Must agree with the server's typed domain-error contract. In particular,
// transport Unavailable/DeadlineExceeded cannot acknowledge a business rejection.
int? _domainGrpcStatus(int status) => switch (status) {
  400 || 422 => grpc.StatusCode.invalidArgument,
  401 => grpc.StatusCode.unauthenticated,
  403 => grpc.StatusCode.permissionDenied,
  404 => grpc.StatusCode.notFound,
  409 || 410 => grpc.StatusCode.failedPrecondition,
  429 => grpc.StatusCode.resourceExhausted,
  499 => grpc.StatusCode.cancelled,
  503 => grpc.StatusCode.unavailable,
  >= 500 && <= 599 => grpc.StatusCode.internal,
  _ => null,
};

bool _validDomain(int? status, String? code) =>
    status != null &&
    _domainGrpcStatus(status) != null &&
    code != null &&
    RegExp(r'^[a-z][a-z0-9_]{0,79}$').hasMatch(code);
