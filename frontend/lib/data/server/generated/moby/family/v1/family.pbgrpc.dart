// This is a generated file - do not edit.
//
// Generated from moby/family/v1/family.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'family.pb.dart' as $0;

export 'family.pb.dart';

/// Native protobuf contract. Tokens, hashes, command fingerprints and storage
/// internals are deliberately absent from snapshots and session summaries.
@$pb.GrpcServiceName('moby.family.v1.FamilyService')
class FamilyServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  FamilyServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.SessionGrant> loginAdult(
    $0.LoginAdultRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$loginAdult, request, options: options);
  }

  $grpc.ResponseFuture<$0.Empty> logout(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$logout, request, options: options);
  }

  $grpc.ResponseFuture<$0.Snapshot> getSnapshot(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getSnapshot, request, options: options);
  }

  $grpc.ResponseStream<$0.Snapshot> watchSnapshots(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$watchSnapshots, $async.Stream.fromIterable([request]),
        options: options);
  }

  $grpc.ResponseFuture<$0.Snapshot> completeFamilyIntro(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$completeFamilyIntro, request, options: options);
  }

  $grpc.ResponseFuture<$0.ChildrenList> listChildren(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listChildren, request, options: options);
  }

  $grpc.ResponseFuture<$0.Child> getChild(
    $0.ChildRef request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getChild, request, options: options);
  }

  $grpc.ResponseFuture<$0.Child> createChild(
    $0.CreateChildRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$createChild, request, options: options);
  }

  $grpc.ResponseFuture<$0.Child> updateChild(
    $0.UpdateChildRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateChild, request, options: options);
  }

  $grpc.ResponseFuture<$0.Child> updatePolicy(
    $0.UpdatePolicyRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updatePolicy, request, options: options);
  }

  $grpc.ResponseFuture<$0.Child> archiveChild(
    $0.ChildRef request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$archiveChild, request, options: options);
  }

  $grpc.ResponseFuture<$0.Child> verifyChild(
    $0.VerifyChildRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$verifyChild, request, options: options);
  }

  $grpc.ResponseFuture<$0.Child> openProduct(
    $0.OpenProductRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$openProduct, request, options: options);
  }

  $grpc.ResponseFuture<$0.Operation> purchase(
    $0.ChildMoneyRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$purchase, request, options: options);
  }

  $grpc.ResponseFuture<$0.Operation> topUp(
    $0.ChildMoneyRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$topUp, request, options: options);
  }

  $grpc.ResponseFuture<$0.Operation> decideOperation(
    $0.DecideOperationRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$decideOperation, request, options: options);
  }

  $grpc.ResponseFuture<$0.PairingCreated> createPairing(
    $0.CreatePairingRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$createPairing, request, options: options);
  }

  $grpc.ResponseFuture<$0.PairingResult> consumePairing(
    $0.ConsumePairingRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$consumePairing, request, options: options);
  }

  $grpc.ResponseFuture<$0.PairingPoll> pollPairing(
    $0.PairingSecretRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$pollPairing, request, options: options);
  }

  $grpc.ResponseFuture<$0.PairingResult> cancelPairing(
    $0.PairingSecretRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$cancelPairing, request, options: options);
  }

  $grpc.ResponseFuture<$0.SessionsList> listSessions(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listSessions, request, options: options);
  }

  $grpc.ResponseFuture<$0.Empty> revokeSession(
    $0.SessionRef request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$revokeSession, request, options: options);
  }

  $grpc.ResponseFuture<$0.Snapshot> executeFamilySpaceCommand(
    $0.SpaceCommand request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$executeFamilySpaceCommand, request,
        options: options);
  }

  // method descriptors

  static final _$loginAdult =
      $grpc.ClientMethod<$0.LoginAdultRequest, $0.SessionGrant>(
          '/moby.family.v1.FamilyService/LoginAdult',
          ($0.LoginAdultRequest value) => value.writeToBuffer(),
          $0.SessionGrant.fromBuffer);
  static final _$logout = $grpc.ClientMethod<$0.Empty, $0.Empty>(
      '/moby.family.v1.FamilyService/Logout',
      ($0.Empty value) => value.writeToBuffer(),
      $0.Empty.fromBuffer);
  static final _$getSnapshot = $grpc.ClientMethod<$0.Empty, $0.Snapshot>(
      '/moby.family.v1.FamilyService/GetSnapshot',
      ($0.Empty value) => value.writeToBuffer(),
      $0.Snapshot.fromBuffer);
  static final _$watchSnapshots = $grpc.ClientMethod<$0.Empty, $0.Snapshot>(
      '/moby.family.v1.FamilyService/WatchSnapshots',
      ($0.Empty value) => value.writeToBuffer(),
      $0.Snapshot.fromBuffer);
  static final _$completeFamilyIntro =
      $grpc.ClientMethod<$0.Empty, $0.Snapshot>(
          '/moby.family.v1.FamilyService/CompleteFamilyIntro',
          ($0.Empty value) => value.writeToBuffer(),
          $0.Snapshot.fromBuffer);
  static final _$listChildren = $grpc.ClientMethod<$0.Empty, $0.ChildrenList>(
      '/moby.family.v1.FamilyService/ListChildren',
      ($0.Empty value) => value.writeToBuffer(),
      $0.ChildrenList.fromBuffer);
  static final _$getChild = $grpc.ClientMethod<$0.ChildRef, $0.Child>(
      '/moby.family.v1.FamilyService/GetChild',
      ($0.ChildRef value) => value.writeToBuffer(),
      $0.Child.fromBuffer);
  static final _$createChild =
      $grpc.ClientMethod<$0.CreateChildRequest, $0.Child>(
          '/moby.family.v1.FamilyService/CreateChild',
          ($0.CreateChildRequest value) => value.writeToBuffer(),
          $0.Child.fromBuffer);
  static final _$updateChild =
      $grpc.ClientMethod<$0.UpdateChildRequest, $0.Child>(
          '/moby.family.v1.FamilyService/UpdateChild',
          ($0.UpdateChildRequest value) => value.writeToBuffer(),
          $0.Child.fromBuffer);
  static final _$updatePolicy =
      $grpc.ClientMethod<$0.UpdatePolicyRequest, $0.Child>(
          '/moby.family.v1.FamilyService/UpdatePolicy',
          ($0.UpdatePolicyRequest value) => value.writeToBuffer(),
          $0.Child.fromBuffer);
  static final _$archiveChild = $grpc.ClientMethod<$0.ChildRef, $0.Child>(
      '/moby.family.v1.FamilyService/ArchiveChild',
      ($0.ChildRef value) => value.writeToBuffer(),
      $0.Child.fromBuffer);
  static final _$verifyChild =
      $grpc.ClientMethod<$0.VerifyChildRequest, $0.Child>(
          '/moby.family.v1.FamilyService/VerifyChild',
          ($0.VerifyChildRequest value) => value.writeToBuffer(),
          $0.Child.fromBuffer);
  static final _$openProduct =
      $grpc.ClientMethod<$0.OpenProductRequest, $0.Child>(
          '/moby.family.v1.FamilyService/OpenProduct',
          ($0.OpenProductRequest value) => value.writeToBuffer(),
          $0.Child.fromBuffer);
  static final _$purchase =
      $grpc.ClientMethod<$0.ChildMoneyRequest, $0.Operation>(
          '/moby.family.v1.FamilyService/Purchase',
          ($0.ChildMoneyRequest value) => value.writeToBuffer(),
          $0.Operation.fromBuffer);
  static final _$topUp = $grpc.ClientMethod<$0.ChildMoneyRequest, $0.Operation>(
      '/moby.family.v1.FamilyService/TopUp',
      ($0.ChildMoneyRequest value) => value.writeToBuffer(),
      $0.Operation.fromBuffer);
  static final _$decideOperation =
      $grpc.ClientMethod<$0.DecideOperationRequest, $0.Operation>(
          '/moby.family.v1.FamilyService/DecideOperation',
          ($0.DecideOperationRequest value) => value.writeToBuffer(),
          $0.Operation.fromBuffer);
  static final _$createPairing =
      $grpc.ClientMethod<$0.CreatePairingRequest, $0.PairingCreated>(
          '/moby.family.v1.FamilyService/CreatePairing',
          ($0.CreatePairingRequest value) => value.writeToBuffer(),
          $0.PairingCreated.fromBuffer);
  static final _$consumePairing =
      $grpc.ClientMethod<$0.ConsumePairingRequest, $0.PairingResult>(
          '/moby.family.v1.FamilyService/ConsumePairing',
          ($0.ConsumePairingRequest value) => value.writeToBuffer(),
          $0.PairingResult.fromBuffer);
  static final _$pollPairing =
      $grpc.ClientMethod<$0.PairingSecretRequest, $0.PairingPoll>(
          '/moby.family.v1.FamilyService/PollPairing',
          ($0.PairingSecretRequest value) => value.writeToBuffer(),
          $0.PairingPoll.fromBuffer);
  static final _$cancelPairing =
      $grpc.ClientMethod<$0.PairingSecretRequest, $0.PairingResult>(
          '/moby.family.v1.FamilyService/CancelPairing',
          ($0.PairingSecretRequest value) => value.writeToBuffer(),
          $0.PairingResult.fromBuffer);
  static final _$listSessions = $grpc.ClientMethod<$0.Empty, $0.SessionsList>(
      '/moby.family.v1.FamilyService/ListSessions',
      ($0.Empty value) => value.writeToBuffer(),
      $0.SessionsList.fromBuffer);
  static final _$revokeSession = $grpc.ClientMethod<$0.SessionRef, $0.Empty>(
      '/moby.family.v1.FamilyService/RevokeSession',
      ($0.SessionRef value) => value.writeToBuffer(),
      $0.Empty.fromBuffer);
  static final _$executeFamilySpaceCommand =
      $grpc.ClientMethod<$0.SpaceCommand, $0.Snapshot>(
          '/moby.family.v1.FamilyService/ExecuteFamilySpaceCommand',
          ($0.SpaceCommand value) => value.writeToBuffer(),
          $0.Snapshot.fromBuffer);
}

@$pb.GrpcServiceName('moby.family.v1.FamilyService')
abstract class FamilyServiceBase extends $grpc.Service {
  $core.String get $name => 'moby.family.v1.FamilyService';

  FamilyServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.LoginAdultRequest, $0.SessionGrant>(
        'LoginAdult',
        loginAdult_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.LoginAdultRequest.fromBuffer(value),
        ($0.SessionGrant value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.Empty>(
        'Logout',
        logout_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.Snapshot>(
        'GetSnapshot',
        getSnapshot_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.Snapshot value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.Snapshot>(
        'WatchSnapshots',
        watchSnapshots_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.Snapshot value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.Snapshot>(
        'CompleteFamilyIntro',
        completeFamilyIntro_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.Snapshot value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.ChildrenList>(
        'ListChildren',
        listChildren_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.ChildrenList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ChildRef, $0.Child>(
        'GetChild',
        getChild_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ChildRef.fromBuffer(value),
        ($0.Child value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CreateChildRequest, $0.Child>(
        'CreateChild',
        createChild_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.CreateChildRequest.fromBuffer(value),
        ($0.Child value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateChildRequest, $0.Child>(
        'UpdateChild',
        updateChild_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.UpdateChildRequest.fromBuffer(value),
        ($0.Child value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdatePolicyRequest, $0.Child>(
        'UpdatePolicy',
        updatePolicy_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.UpdatePolicyRequest.fromBuffer(value),
        ($0.Child value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ChildRef, $0.Child>(
        'ArchiveChild',
        archiveChild_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ChildRef.fromBuffer(value),
        ($0.Child value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.VerifyChildRequest, $0.Child>(
        'VerifyChild',
        verifyChild_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.VerifyChildRequest.fromBuffer(value),
        ($0.Child value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.OpenProductRequest, $0.Child>(
        'OpenProduct',
        openProduct_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.OpenProductRequest.fromBuffer(value),
        ($0.Child value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ChildMoneyRequest, $0.Operation>(
        'Purchase',
        purchase_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ChildMoneyRequest.fromBuffer(value),
        ($0.Operation value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ChildMoneyRequest, $0.Operation>(
        'TopUp',
        topUp_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ChildMoneyRequest.fromBuffer(value),
        ($0.Operation value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DecideOperationRequest, $0.Operation>(
        'DecideOperation',
        decideOperation_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.DecideOperationRequest.fromBuffer(value),
        ($0.Operation value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CreatePairingRequest, $0.PairingCreated>(
        'CreatePairing',
        createPairing_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.CreatePairingRequest.fromBuffer(value),
        ($0.PairingCreated value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ConsumePairingRequest, $0.PairingResult>(
        'ConsumePairing',
        consumePairing_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ConsumePairingRequest.fromBuffer(value),
        ($0.PairingResult value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.PairingSecretRequest, $0.PairingPoll>(
        'PollPairing',
        pollPairing_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.PairingSecretRequest.fromBuffer(value),
        ($0.PairingPoll value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.PairingSecretRequest, $0.PairingResult>(
        'CancelPairing',
        cancelPairing_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.PairingSecretRequest.fromBuffer(value),
        ($0.PairingResult value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.SessionsList>(
        'ListSessions',
        listSessions_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.SessionsList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SessionRef, $0.Empty>(
        'RevokeSession',
        revokeSession_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SessionRef.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SpaceCommand, $0.Snapshot>(
        'ExecuteFamilySpaceCommand',
        executeFamilySpaceCommand_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SpaceCommand.fromBuffer(value),
        ($0.Snapshot value) => value.writeToBuffer()));
  }

  $async.Future<$0.SessionGrant> loginAdult_Pre($grpc.ServiceCall $call,
      $async.Future<$0.LoginAdultRequest> $request) async {
    return loginAdult($call, await $request);
  }

  $async.Future<$0.SessionGrant> loginAdult(
      $grpc.ServiceCall call, $0.LoginAdultRequest request);

  $async.Future<$0.Empty> logout_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return logout($call, await $request);
  }

  $async.Future<$0.Empty> logout($grpc.ServiceCall call, $0.Empty request);

  $async.Future<$0.Snapshot> getSnapshot_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return getSnapshot($call, await $request);
  }

  $async.Future<$0.Snapshot> getSnapshot(
      $grpc.ServiceCall call, $0.Empty request);

  $async.Stream<$0.Snapshot> watchSnapshots_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async* {
    yield* watchSnapshots($call, await $request);
  }

  $async.Stream<$0.Snapshot> watchSnapshots(
      $grpc.ServiceCall call, $0.Empty request);

  $async.Future<$0.Snapshot> completeFamilyIntro_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return completeFamilyIntro($call, await $request);
  }

  $async.Future<$0.Snapshot> completeFamilyIntro(
      $grpc.ServiceCall call, $0.Empty request);

  $async.Future<$0.ChildrenList> listChildren_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return listChildren($call, await $request);
  }

  $async.Future<$0.ChildrenList> listChildren(
      $grpc.ServiceCall call, $0.Empty request);

  $async.Future<$0.Child> getChild_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.ChildRef> $request) async {
    return getChild($call, await $request);
  }

  $async.Future<$0.Child> getChild($grpc.ServiceCall call, $0.ChildRef request);

  $async.Future<$0.Child> createChild_Pre($grpc.ServiceCall $call,
      $async.Future<$0.CreateChildRequest> $request) async {
    return createChild($call, await $request);
  }

  $async.Future<$0.Child> createChild(
      $grpc.ServiceCall call, $0.CreateChildRequest request);

  $async.Future<$0.Child> updateChild_Pre($grpc.ServiceCall $call,
      $async.Future<$0.UpdateChildRequest> $request) async {
    return updateChild($call, await $request);
  }

  $async.Future<$0.Child> updateChild(
      $grpc.ServiceCall call, $0.UpdateChildRequest request);

  $async.Future<$0.Child> updatePolicy_Pre($grpc.ServiceCall $call,
      $async.Future<$0.UpdatePolicyRequest> $request) async {
    return updatePolicy($call, await $request);
  }

  $async.Future<$0.Child> updatePolicy(
      $grpc.ServiceCall call, $0.UpdatePolicyRequest request);

  $async.Future<$0.Child> archiveChild_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.ChildRef> $request) async {
    return archiveChild($call, await $request);
  }

  $async.Future<$0.Child> archiveChild(
      $grpc.ServiceCall call, $0.ChildRef request);

  $async.Future<$0.Child> verifyChild_Pre($grpc.ServiceCall $call,
      $async.Future<$0.VerifyChildRequest> $request) async {
    return verifyChild($call, await $request);
  }

  $async.Future<$0.Child> verifyChild(
      $grpc.ServiceCall call, $0.VerifyChildRequest request);

  $async.Future<$0.Child> openProduct_Pre($grpc.ServiceCall $call,
      $async.Future<$0.OpenProductRequest> $request) async {
    return openProduct($call, await $request);
  }

  $async.Future<$0.Child> openProduct(
      $grpc.ServiceCall call, $0.OpenProductRequest request);

  $async.Future<$0.Operation> purchase_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ChildMoneyRequest> $request) async {
    return purchase($call, await $request);
  }

  $async.Future<$0.Operation> purchase(
      $grpc.ServiceCall call, $0.ChildMoneyRequest request);

  $async.Future<$0.Operation> topUp_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ChildMoneyRequest> $request) async {
    return topUp($call, await $request);
  }

  $async.Future<$0.Operation> topUp(
      $grpc.ServiceCall call, $0.ChildMoneyRequest request);

  $async.Future<$0.Operation> decideOperation_Pre($grpc.ServiceCall $call,
      $async.Future<$0.DecideOperationRequest> $request) async {
    return decideOperation($call, await $request);
  }

  $async.Future<$0.Operation> decideOperation(
      $grpc.ServiceCall call, $0.DecideOperationRequest request);

  $async.Future<$0.PairingCreated> createPairing_Pre($grpc.ServiceCall $call,
      $async.Future<$0.CreatePairingRequest> $request) async {
    return createPairing($call, await $request);
  }

  $async.Future<$0.PairingCreated> createPairing(
      $grpc.ServiceCall call, $0.CreatePairingRequest request);

  $async.Future<$0.PairingResult> consumePairing_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ConsumePairingRequest> $request) async {
    return consumePairing($call, await $request);
  }

  $async.Future<$0.PairingResult> consumePairing(
      $grpc.ServiceCall call, $0.ConsumePairingRequest request);

  $async.Future<$0.PairingPoll> pollPairing_Pre($grpc.ServiceCall $call,
      $async.Future<$0.PairingSecretRequest> $request) async {
    return pollPairing($call, await $request);
  }

  $async.Future<$0.PairingPoll> pollPairing(
      $grpc.ServiceCall call, $0.PairingSecretRequest request);

  $async.Future<$0.PairingResult> cancelPairing_Pre($grpc.ServiceCall $call,
      $async.Future<$0.PairingSecretRequest> $request) async {
    return cancelPairing($call, await $request);
  }

  $async.Future<$0.PairingResult> cancelPairing(
      $grpc.ServiceCall call, $0.PairingSecretRequest request);

  $async.Future<$0.SessionsList> listSessions_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return listSessions($call, await $request);
  }

  $async.Future<$0.SessionsList> listSessions(
      $grpc.ServiceCall call, $0.Empty request);

  $async.Future<$0.Empty> revokeSession_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.SessionRef> $request) async {
    return revokeSession($call, await $request);
  }

  $async.Future<$0.Empty> revokeSession(
      $grpc.ServiceCall call, $0.SessionRef request);

  $async.Future<$0.Snapshot> executeFamilySpaceCommand_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.SpaceCommand> $request) async {
    return executeFamilySpaceCommand($call, await $request);
  }

  $async.Future<$0.Snapshot> executeFamilySpaceCommand(
      $grpc.ServiceCall call, $0.SpaceCommand request);
}
