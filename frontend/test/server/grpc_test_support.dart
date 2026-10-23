import 'dart:async';
import 'dart:io';

import 'package:grpc/grpc.dart' as grpc;
import 'package:protobuf/protobuf.dart';
import 'package:moby_demo/data/server/family_api.dart';
import 'package:moby_demo/data/server/family_grpc_codec.dart';
import 'package:moby_demo/data/server/generated/moby/family/v1/family.pbgrpc.dart'
    as pb;

import '../support/space_fixture.dart';

typedef GrpcScript =
    Future<GeneratedMessage> Function(
      String method,
      grpc.ServiceCall call,
      GeneratedMessage request,
    );

class ScriptFamilyService extends pb.FamilyServiceBase {
  ScriptFamilyService(this.run, {this.watch});
  final GrpcScript run;
  final Stream<pb.Snapshot> Function(grpc.ServiceCall, pb.Empty)? watch;
  Future<T> _call<T extends GeneratedMessage>(
    String method,
    grpc.ServiceCall call,
    GeneratedMessage request,
  ) async => await run(method, call, request) as T;
  @override
  Stream<pb.Snapshot> watchSnapshots(grpc.ServiceCall call, pb.Empty request) =>
      watch?.call(call, request) ?? const Stream.empty();
  @override
  Future<pb.SessionGrant> loginAdult(
    grpc.ServiceCall call,
    pb.LoginAdultRequest request,
  ) => _call<pb.SessionGrant>('LoginAdult', call, request);
  @override
  Future<pb.Empty> logout(grpc.ServiceCall call, pb.Empty request) =>
      _call<pb.Empty>('Logout', call, request);
  @override
  Future<pb.Snapshot> getSnapshot(grpc.ServiceCall call, pb.Empty request) =>
      _call<pb.Snapshot>('GetSnapshot', call, request);
  @override
  Future<pb.Snapshot> completeFamilyIntro(
    grpc.ServiceCall call,
    pb.Empty request,
  ) => _call<pb.Snapshot>('CompleteFamilyIntro', call, request);
  @override
  Future<pb.ChildrenList> listChildren(
    grpc.ServiceCall call,
    pb.Empty request,
  ) => _call<pb.ChildrenList>('ListChildren', call, request);
  @override
  Future<pb.Child> getChild(grpc.ServiceCall call, pb.ChildRef request) =>
      _call<pb.Child>('GetChild', call, request);
  @override
  Future<pb.Child> createChild(
    grpc.ServiceCall call,
    pb.CreateChildRequest request,
  ) => _call<pb.Child>('CreateChild', call, request);
  @override
  Future<pb.Child> updateChild(
    grpc.ServiceCall call,
    pb.UpdateChildRequest request,
  ) => _call<pb.Child>('UpdateChild', call, request);
  @override
  Future<pb.Child> updatePolicy(
    grpc.ServiceCall call,
    pb.UpdatePolicyRequest request,
  ) => _call<pb.Child>('UpdatePolicy', call, request);
  @override
  Future<pb.Child> archiveChild(grpc.ServiceCall call, pb.ChildRef request) =>
      _call<pb.Child>('ArchiveChild', call, request);
  @override
  Future<pb.Child> verifyChild(
    grpc.ServiceCall call,
    pb.VerifyChildRequest request,
  ) => _call<pb.Child>('VerifyChild', call, request);
  @override
  Future<pb.Child> openProduct(
    grpc.ServiceCall call,
    pb.OpenProductRequest request,
  ) => _call<pb.Child>('OpenProduct', call, request);
  @override
  Future<pb.Operation> purchase(
    grpc.ServiceCall call,
    pb.ChildMoneyRequest request,
  ) => _call<pb.Operation>('Purchase', call, request);
  @override
  Future<pb.Operation> topUp(
    grpc.ServiceCall call,
    pb.ChildMoneyRequest request,
  ) => _call<pb.Operation>('TopUp', call, request);
  @override
  Future<pb.Operation> decideOperation(
    grpc.ServiceCall call,
    pb.DecideOperationRequest request,
  ) => _call<pb.Operation>('DecideOperation', call, request);
  @override
  Future<pb.PairingCreated> createPairing(
    grpc.ServiceCall call,
    pb.CreatePairingRequest request,
  ) => _call<pb.PairingCreated>('CreatePairing', call, request);
  @override
  Future<pb.PairingResult> consumePairing(
    grpc.ServiceCall call,
    pb.ConsumePairingRequest request,
  ) => _call<pb.PairingResult>('ConsumePairing', call, request);
  @override
  Future<pb.PairingPoll> pollPairing(
    grpc.ServiceCall call,
    pb.PairingSecretRequest request,
  ) => _call<pb.PairingPoll>('PollPairing', call, request);
  @override
  Future<pb.PairingResult> cancelPairing(
    grpc.ServiceCall call,
    pb.PairingSecretRequest request,
  ) => _call<pb.PairingResult>('CancelPairing', call, request);
  @override
  Future<pb.SessionsList> listSessions(
    grpc.ServiceCall call,
    pb.Empty request,
  ) => _call<pb.SessionsList>('ListSessions', call, request);
  @override
  Future<pb.Empty> revokeSession(
    grpc.ServiceCall call,
    pb.SessionRef request,
  ) => _call<pb.Empty>('RevokeSession', call, request);
  @override
  Future<pb.Snapshot> executeFamilySpaceCommand(
    grpc.ServiceCall call,
    pb.SpaceCommand request,
  ) => _call<pb.Snapshot>('ExecuteFamilySpaceCommand', call, request);
}

class GrpcHarness {
  GrpcHarness._(this.server, this.api);
  final grpc.Server server;
  final FamilyApi api;
  static Future<GrpcHarness> start(
    ScriptFamilyService service, {
    Duration requestTimeout = const Duration(seconds: 20),
    Duration streamIdleTimeout = const Duration(seconds: 35),
  }) async {
    final server = grpc.Server.create(services: [service]);
    await server.serve(address: InternetAddress.loopbackIPv4, port: 0);
    final api = FamilyApi(
      Uri.parse('http://127.0.0.1:${server.port}'),
      requestTimeout: requestTimeout,
      streamIdleTimeout: streamIdleTimeout,
    );
    return GrpcHarness._(server, api);
  }

  Future<void> close() async {
    api.close();
    await server.shutdown();
  }
}

pb.Snapshot grpcSnapshot({String? childId, int revision = 1}) => familyMessage(
  pb.Snapshot(),
  spacePreviewSnapshot(childId: childId)..['revision'] = revision,
);

Never domainFailure(grpc.ServiceCall call, int status, String code) {
  call.trailers!['moby-semantic-status'] = '$status';
  call.trailers!['moby-error-code'] = code;
  throw grpc.GrpcError.custom(
    domainGrpcStatus(status),
    'private diagnostic must not escape',
  );
}

int domainGrpcStatus(int status) => switch (status) {
  400 || 422 => grpc.StatusCode.invalidArgument,
  401 => grpc.StatusCode.unauthenticated,
  403 => grpc.StatusCode.permissionDenied,
  404 => grpc.StatusCode.notFound,
  409 || 410 => grpc.StatusCode.failedPrecondition,
  429 => grpc.StatusCode.resourceExhausted,
  499 => grpc.StatusCode.cancelled,
  503 => grpc.StatusCode.unavailable,
  _ => grpc.StatusCode.internal,
};
