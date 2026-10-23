// This is a generated file - do not edit.
//
// Generated from moby/family/v1/family.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class Empty extends $pb.GeneratedMessage {
  factory Empty() => Empty._();

  Empty._();

  factory Empty.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Empty()..mergeFromBuffer(data, registry);
  factory Empty.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Empty()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Empty',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'moby.family.v1'),
      createEmptyInstance: Empty.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Empty clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Empty copyWith(void Function(Empty) updates) =>
      super.copyWith((message) => updates(message as Empty)) as Empty;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Empty() / Empty.new instead')
  static Empty create() => Empty._();
  static $pb.GeneratedMessage $_createMessage() => Empty._();
  @$core.override
  Empty createEmptyInstance() => Empty._();
  @$core.pragma('dart2js:noInline')
  static Empty getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Empty>(Empty.$_createMessage);
  static Empty? _defaultInstance;
}

class DomainErrorDetail extends $pb.GeneratedMessage {
  factory DomainErrorDetail({
    $core.int? semanticStatus,
    $core.String? code,
  }) {
    final result = DomainErrorDetail._();
    if (semanticStatus != null) result.semanticStatus = semanticStatus;
    if (code != null) result.code = code;
    return result;
  }

  DomainErrorDetail._();

  factory DomainErrorDetail.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DomainErrorDetail()..mergeFromBuffer(data, registry);
  factory DomainErrorDetail.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DomainErrorDetail()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DomainErrorDetail',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'moby.family.v1'),
      createEmptyInstance: DomainErrorDetail.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'semanticStatus')
    ..aOS(2, _omitFieldNames ? '' : 'code')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DomainErrorDetail clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DomainErrorDetail copyWith(void Function(DomainErrorDetail) updates) =>
      super.copyWith((message) => updates(message as DomainErrorDetail))
          as DomainErrorDetail;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DomainErrorDetail() / DomainErrorDetail.new instead')
  static DomainErrorDetail create() => DomainErrorDetail._();
  static $pb.GeneratedMessage $_createMessage() => DomainErrorDetail._();
  @$core.override
  DomainErrorDetail createEmptyInstance() => DomainErrorDetail._();
  @$core.pragma('dart2js:noInline')
  static DomainErrorDetail getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DomainErrorDetail>(
          DomainErrorDetail.$_createMessage);
  static DomainErrorDetail? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get semanticStatus => $_getIZ(0);
  @$pb.TagNumber(1)
  set semanticStatus($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSemanticStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearSemanticStatus() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get code => $_getSZ(1);
  @$pb.TagNumber(2)
  set code($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCode() => $_has(1);
  @$pb.TagNumber(2)
  void clearCode() => $_clearField(2);
}

class LoginAdultRequest extends $pb.GeneratedMessage {
  factory LoginAdultRequest({
    $core.String? bootstrapSecret,
    $core.String? deviceName,
  }) {
    final result = LoginAdultRequest._();
    if (bootstrapSecret != null) result.bootstrapSecret = bootstrapSecret;
    if (deviceName != null) result.deviceName = deviceName;
    return result;
  }

  LoginAdultRequest._();

  factory LoginAdultRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoginAdultRequest()..mergeFromBuffer(data, registry);
  factory LoginAdultRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoginAdultRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoginAdultRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'moby.family.v1'),
      createEmptyInstance: LoginAdultRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'bootstrapSecret')
    ..aOS(2, _omitFieldNames ? '' : 'deviceName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoginAdultRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoginAdultRequest copyWith(void Function(LoginAdultRequest) updates) =>
      super.copyWith((message) => updates(message as LoginAdultRequest))
          as LoginAdultRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use LoginAdultRequest() / LoginAdultRequest.new instead')
  static LoginAdultRequest create() => LoginAdultRequest._();
  static $pb.GeneratedMessage $_createMessage() => LoginAdultRequest._();
  @$core.override
  LoginAdultRequest createEmptyInstance() => LoginAdultRequest._();
  @$core.pragma('dart2js:noInline')
  static LoginAdultRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoginAdultRequest>(
          LoginAdultRequest.$_createMessage);
  static LoginAdultRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get bootstrapSecret => $_getSZ(0);
  @$pb.TagNumber(1)
  set bootstrapSecret($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasBootstrapSecret() => $_has(0);
  @$pb.TagNumber(1)
  void clearBootstrapSecret() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get deviceName => $_getSZ(1);
  @$pb.TagNumber(2)
  set deviceName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDeviceName() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeviceName() => $_clearField(2);
}

class SessionGrant extends $pb.GeneratedMessage {
  factory SessionGrant({
    $core.String? token,
    Actor? actor,
    $fixnum.Int64? expiresAt,
  }) {
    final result = SessionGrant._();
    if (token != null) result.token = token;
    if (actor != null) result.actor = actor;
    if (expiresAt != null) result.expiresAt = expiresAt;
    return result;
  }

  SessionGrant._();

  factory SessionGrant.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SessionGrant()..mergeFromBuffer(data, registry);
  factory SessionGrant.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SessionGrant()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SessionGrant',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'moby.family.v1'),
      createEmptyInstance: SessionGrant.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'token')
    ..aOM<Actor>(2, _omitFieldNames ? '' : 'actor',
        subBuilder: Actor.$_createMessage)
    ..aInt64(3, _omitFieldNames ? '' : 'expiresAt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SessionGrant clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SessionGrant copyWith(void Function(SessionGrant) updates) =>
      super.copyWith((message) => updates(message as SessionGrant))
          as SessionGrant;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SessionGrant() / SessionGrant.new instead')
  static SessionGrant create() => SessionGrant._();
  static $pb.GeneratedMessage $_createMessage() => SessionGrant._();
  @$core.override
  SessionGrant createEmptyInstance() => SessionGrant._();
  @$core.pragma('dart2js:noInline')
  static SessionGrant getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SessionGrant>(
          SessionGrant.$_createMessage);
  static SessionGrant? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get token => $_getSZ(0);
  @$pb.TagNumber(1)
  set token($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearToken() => $_clearField(1);

  @$pb.TagNumber(2)
  Actor get actor => $_getN(1);
  @$pb.TagNumber(2)
  set actor(Actor value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasActor() => $_has(1);
  @$pb.TagNumber(2)
  void clearActor() => $_clearField(2);
  @$pb.TagNumber(2)
  Actor ensureActor() => $_ensure(1);

  @$pb.TagNumber(3)
  $fixnum.Int64 get expiresAt => $_getI64(2);
  @$pb.TagNumber(3)
  set expiresAt($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasExpiresAt() => $_has(2);
  @$pb.TagNumber(3)
  void clearExpiresAt() => $_clearField(3);
}

class ChildRef extends $pb.GeneratedMessage {
  factory ChildRef({
    $core.String? childId,
  }) {
    final result = ChildRef._();
    if (childId != null) result.childId = childId;
    return result;
  }

  ChildRef._();

  factory ChildRef.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChildRef()..mergeFromBuffer(data, registry);
  factory ChildRef.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChildRef()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChildRef',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'moby.family.v1'),
      createEmptyInstance: ChildRef.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'childId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChildRef clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChildRef copyWith(void Function(ChildRef) updates) =>
      super.copyWith((message) => updates(message as ChildRef)) as ChildRef;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ChildRef() / ChildRef.new instead')
  static ChildRef create() => ChildRef._();
  static $pb.GeneratedMessage $_createMessage() => ChildRef._();
  @$core.override
  ChildRef createEmptyInstance() => ChildRef._();
  @$core.pragma('dart2js:noInline')
  static ChildRef getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChildRef>(ChildRef.$_createMessage);
  static ChildRef? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get childId => $_getSZ(0);
  @$pb.TagNumber(1)
  set childId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChildId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChildId() => $_clearField(1);
}

class SessionRef extends $pb.GeneratedMessage {
  factory SessionRef({
    $core.String? sessionId,
  }) {
    final result = SessionRef._();
    if (sessionId != null) result.sessionId = sessionId;
    return result;
  }

  SessionRef._();

  factory SessionRef.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SessionRef()..mergeFromBuffer(data, registry);
  factory SessionRef.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SessionRef()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SessionRef',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'moby.family.v1'),
      createEmptyInstance: SessionRef.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'sessionId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SessionRef clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SessionRef copyWith(void Function(SessionRef) updates) =>
      super.copyWith((message) => updates(message as SessionRef)) as SessionRef;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SessionRef() / SessionRef.new instead')
  static SessionRef create() => SessionRef._();
  static $pb.GeneratedMessage $_createMessage() => SessionRef._();
  @$core.override
  SessionRef createEmptyInstance() => SessionRef._();
  @$core.pragma('dart2js:noInline')
  static SessionRef getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SessionRef>(SessionRef.$_createMessage);
  static SessionRef? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sessionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSessionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionId() => $_clearField(1);
}

class CreateChildRequest extends $pb.GeneratedMessage {
  factory CreateChildRequest({
    $core.String? displayName,
    $core.String? legalName,
    $core.String? dateOfBirth,
    $core.String? idempotencyKey,
  }) {
    final result = CreateChildRequest._();
    if (displayName != null) result.displayName = displayName;
    if (legalName != null) result.legalName = legalName;
    if (dateOfBirth != null) result.dateOfBirth = dateOfBirth;
    if (idempotencyKey != null) result.idempotencyKey = idempotencyKey;
    return result;
  }

  CreateChildRequest._();

  factory CreateChildRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateChildRequest()..mergeFromBuffer(data, registry);
  factory CreateChildRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateChildRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateChildRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'moby.family.v1'),
      createEmptyInstance: CreateChildRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'displayName')
    ..aOS(2, _omitFieldNames ? '' : 'legalName')
    ..aOS(3, _omitFieldNames ? '' : 'dateOfBirth')
    ..aOS(4, _omitFieldNames ? '' : 'idempotencyKey')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateChildRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateChildRequest copyWith(void Function(CreateChildRequest) updates) =>
      super.copyWith((message) => updates(message as CreateChildRequest))
          as CreateChildRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreateChildRequest() / CreateChildRequest.new instead')
  static CreateChildRequest create() => CreateChildRequest._();
  static $pb.GeneratedMessage $_createMessage() => CreateChildRequest._();
  @$core.override
  CreateChildRequest createEmptyInstance() => CreateChildRequest._();
  @$core.pragma('dart2js:noInline')
  static CreateChildRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateChildRequest>(
          CreateChildRequest.$_createMessage);
  static CreateChildRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get displayName => $_getSZ(0);
  @$pb.TagNumber(1)
  set displayName($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDisplayName() => $_has(0);
  @$pb.TagNumber(1)
  void clearDisplayName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get legalName => $_getSZ(1);
  @$pb.TagNumber(2)
  set legalName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLegalName() => $_has(1);
  @$pb.TagNumber(2)
  void clearLegalName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get dateOfBirth => $_getSZ(2);
  @$pb.TagNumber(3)
  set dateOfBirth($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDateOfBirth() => $_has(2);
  @$pb.TagNumber(3)
  void clearDateOfBirth() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get idempotencyKey => $_getSZ(3);
  @$pb.TagNumber(4)
  set idempotencyKey($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasIdempotencyKey() => $_has(3);
  @$pb.TagNumber(4)
  void clearIdempotencyKey() => $_clearField(4);
}

class ChildPatch extends $pb.GeneratedMessage {
  factory ChildPatch({
    $core.String? displayName,
    $core.String? legalName,
    $core.String? dateOfBirth,
    $core.String? cardStatus,
  }) {
    final result = ChildPatch._();
    if (displayName != null) result.displayName = displayName;
    if (legalName != null) result.legalName = legalName;
    if (dateOfBirth != null) result.dateOfBirth = dateOfBirth;
    if (cardStatus != null) result.cardStatus = cardStatus;
    return result;
  }

  ChildPatch._();

  factory ChildPatch.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChildPatch()..mergeFromBuffer(data, registry);
  factory ChildPatch.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChildPatch()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChildPatch',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'moby.family.v1'),
      createEmptyInstance: ChildPatch.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'displayName')
    ..aOS(2, _omitFieldNames ? '' : 'legalName')
    ..aOS(3, _omitFieldNames ? '' : 'dateOfBirth')
    ..aOS(4, _omitFieldNames ? '' : 'cardStatus')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChildPatch clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChildPatch copyWith(void Function(ChildPatch) updates) =>
      super.copyWith((message) => updates(message as ChildPatch)) as ChildPatch;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ChildPatch() / ChildPatch.new instead')
  static ChildPatch create() => ChildPatch._();
  static $pb.GeneratedMessage $_createMessage() => ChildPatch._();
  @$core.override
  ChildPatch createEmptyInstance() => ChildPatch._();
  @$core.pragma('dart2js:noInline')
  static ChildPatch getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChildPatch>(ChildPatch.$_createMessage);
  static ChildPatch? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get displayName => $_getSZ(0);
  @$pb.TagNumber(1)
  set displayName($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDisplayName() => $_has(0);
  @$pb.TagNumber(1)
  void clearDisplayName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get legalName => $_getSZ(1);
  @$pb.TagNumber(2)
  set legalName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLegalName() => $_has(1);
  @$pb.TagNumber(2)
  void clearLegalName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get dateOfBirth => $_getSZ(2);
  @$pb.TagNumber(3)
  set dateOfBirth($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDateOfBirth() => $_has(2);
  @$pb.TagNumber(3)
  void clearDateOfBirth() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get cardStatus => $_getSZ(3);
  @$pb.TagNumber(4)
  set cardStatus($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCardStatus() => $_has(3);
  @$pb.TagNumber(4)
  void clearCardStatus() => $_clearField(4);
}

class UpdateChildRequest extends $pb.GeneratedMessage {
  factory UpdateChildRequest({
    $core.String? childId,
    ChildPatch? patch,
  }) {
    final result = UpdateChildRequest._();
    if (childId != null) result.childId = childId;
    if (patch != null) result.patch = patch;
    return result;
  }

  UpdateChildRequest._();

  factory UpdateChildRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateChildRequest()..mergeFromBuffer(data, registry);
  factory UpdateChildRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateChildRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateChildRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'moby.family.v1'),
      createEmptyInstance: UpdateChildRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'childId')
    ..aOM<ChildPatch>(2, _omitFieldNames ? '' : 'patch',
        subBuilder: ChildPatch.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateChildRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateChildRequest copyWith(void Function(UpdateChildRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateChildRequest))
          as UpdateChildRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use UpdateChildRequest() / UpdateChildRequest.new instead')
  static UpdateChildRequest create() => UpdateChildRequest._();
  static $pb.GeneratedMessage $_createMessage() => UpdateChildRequest._();
  @$core.override
  UpdateChildRequest createEmptyInstance() => UpdateChildRequest._();
  @$core.pragma('dart2js:noInline')
  static UpdateChildRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateChildRequest>(
          UpdateChildRequest.$_createMessage);
  static UpdateChildRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get childId => $_getSZ(0);
  @$pb.TagNumber(1)
  set childId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChildId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChildId() => $_clearField(1);

  @$pb.TagNumber(2)
  ChildPatch get patch => $_getN(1);
  @$pb.TagNumber(2)
  set patch(ChildPatch value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasPatch() => $_has(1);
  @$pb.TagNumber(2)
  void clearPatch() => $_clearField(2);
  @$pb.TagNumber(2)
  ChildPatch ensurePatch() => $_ensure(1);
}

class UpdatePolicyRequest extends $pb.GeneratedMessage {
  factory UpdatePolicyRequest({
    $core.String? childId,
    Policy? policy,
  }) {
    final result = UpdatePolicyRequest._();
    if (childId != null) result.childId = childId;
    if (policy != null) result.policy = policy;
    return result;
  }

  UpdatePolicyRequest._();

  factory UpdatePolicyRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdatePolicyRequest()..mergeFromBuffer(data, registry);
  factory UpdatePolicyRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdatePolicyRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdatePolicyRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'moby.family.v1'),
      createEmptyInstance: UpdatePolicyRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'childId')
    ..aOM<Policy>(2, _omitFieldNames ? '' : 'policy',
        subBuilder: Policy.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdatePolicyRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdatePolicyRequest copyWith(void Function(UpdatePolicyRequest) updates) =>
      super.copyWith((message) => updates(message as UpdatePolicyRequest))
          as UpdatePolicyRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use UpdatePolicyRequest() / UpdatePolicyRequest.new instead')
  static UpdatePolicyRequest create() => UpdatePolicyRequest._();
  static $pb.GeneratedMessage $_createMessage() => UpdatePolicyRequest._();
  @$core.override
  UpdatePolicyRequest createEmptyInstance() => UpdatePolicyRequest._();
  @$core.pragma('dart2js:noInline')
  static UpdatePolicyRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdatePolicyRequest>(
          UpdatePolicyRequest.$_createMessage);
  static UpdatePolicyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get childId => $_getSZ(0);
  @$pb.TagNumber(1)
  set childId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChildId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChildId() => $_clearField(1);

  @$pb.TagNumber(2)
  Policy get policy => $_getN(1);
  @$pb.TagNumber(2)
  set policy(Policy value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasPolicy() => $_has(1);
  @$pb.TagNumber(2)
  void clearPolicy() => $_clearField(2);
  @$pb.TagNumber(2)
  Policy ensurePolicy() => $_ensure(1);
}

class VerifyChildRequest extends $pb.GeneratedMessage {
  factory VerifyChildRequest({
    $core.String? childId,
    $core.String? outcome,
  }) {
    final result = VerifyChildRequest._();
    if (childId != null) result.childId = childId;
    if (outcome != null) result.outcome = outcome;
    return result;
  }

  VerifyChildRequest._();

  factory VerifyChildRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      VerifyChildRequest()..mergeFromBuffer(data, registry);
  factory VerifyChildRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      VerifyChildRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'VerifyChildRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'moby.family.v1'),
      createEmptyInstance: VerifyChildRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'childId')
    ..aOS(2, _omitFieldNames ? '' : 'outcome')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VerifyChildRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VerifyChildRequest copyWith(void Function(VerifyChildRequest) updates) =>
      super.copyWith((message) => updates(message as VerifyChildRequest))
          as VerifyChildRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use VerifyChildRequest() / VerifyChildRequest.new instead')
  static VerifyChildRequest create() => VerifyChildRequest._();
  static $pb.GeneratedMessage $_createMessage() => VerifyChildRequest._();
  @$core.override
  VerifyChildRequest createEmptyInstance() => VerifyChildRequest._();
  @$core.pragma('dart2js:noInline')
  static VerifyChildRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<VerifyChildRequest>(
          VerifyChildRequest.$_createMessage);
  static VerifyChildRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get childId => $_getSZ(0);
  @$pb.TagNumber(1)
  set childId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChildId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChildId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get outcome => $_getSZ(1);
  @$pb.TagNumber(2)
  set outcome($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOutcome() => $_has(1);
  @$pb.TagNumber(2)
  void clearOutcome() => $_clearField(2);
}

class OpenProductRequest extends $pb.GeneratedMessage {
  factory OpenProductRequest({
    $core.String? childId,
    $core.String? agreementVersion,
    $core.bool? signerConsent,
  }) {
    final result = OpenProductRequest._();
    if (childId != null) result.childId = childId;
    if (agreementVersion != null) result.agreementVersion = agreementVersion;
    if (signerConsent != null) result.signerConsent = signerConsent;
    return result;
  }

  OpenProductRequest._();

  factory OpenProductRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OpenProductRequest()..mergeFromBuffer(data, registry);
  factory OpenProductRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OpenProductRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'OpenProductRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'moby.family.v1'),
      createEmptyInstance: OpenProductRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'childId')
    ..aOS(2, _omitFieldNames ? '' : 'agreementVersion')
    ..aOB(3, _omitFieldNames ? '' : 'signerConsent')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OpenProductRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OpenProductRequest copyWith(void Function(OpenProductRequest) updates) =>
      super.copyWith((message) => updates(message as OpenProductRequest))
          as OpenProductRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use OpenProductRequest() / OpenProductRequest.new instead')
  static OpenProductRequest create() => OpenProductRequest._();
  static $pb.GeneratedMessage $_createMessage() => OpenProductRequest._();
  @$core.override
  OpenProductRequest createEmptyInstance() => OpenProductRequest._();
  @$core.pragma('dart2js:noInline')
  static OpenProductRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<OpenProductRequest>(
          OpenProductRequest.$_createMessage);
  static OpenProductRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get childId => $_getSZ(0);
  @$pb.TagNumber(1)
  set childId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChildId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChildId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get agreementVersion => $_getSZ(1);
  @$pb.TagNumber(2)
  set agreementVersion($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAgreementVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearAgreementVersion() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get signerConsent => $_getBF(2);
  @$pb.TagNumber(3)
  set signerConsent($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSignerConsent() => $_has(2);
  @$pb.TagNumber(3)
  void clearSignerConsent() => $_clearField(3);
}

class MoneyInput extends $pb.GeneratedMessage {
  factory MoneyInput({
    $fixnum.Int64? amountMinor,
    $core.String? currency,
    $core.String? channel,
    $core.String? category,
    $core.String? merchant,
    $core.String? idempotencyKey,
  }) {
    final result = MoneyInput._();
    if (amountMinor != null) result.amountMinor = amountMinor;
    if (currency != null) result.currency = currency;
    if (channel != null) result.channel = channel;
    if (category != null) result.category = category;
    if (merchant != null) result.merchant = merchant;
    if (idempotencyKey != null) result.idempotencyKey = idempotencyKey;
    return result;
  }

  MoneyInput._();

  factory MoneyInput.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MoneyInput()..mergeFromBuffer(data, registry);
  factory MoneyInput.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MoneyInput()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MoneyInput',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'moby.family.v1'),
      createEmptyInstance: MoneyInput.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'amountMinor')
    ..aOS(2, _omitFieldNames ? '' : 'currency')
    ..aOS(3, _omitFieldNames ? '' : 'channel')
    ..aOS(4, _omitFieldNames ? '' : 'category')
    ..aOS(5, _omitFieldNames ? '' : 'merchant')
    ..aOS(6, _omitFieldNames ? '' : 'idempotencyKey')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MoneyInput clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MoneyInput copyWith(void Function(MoneyInput) updates) =>
      super.copyWith((message) => updates(message as MoneyInput)) as MoneyInput;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MoneyInput() / MoneyInput.new instead')
  static MoneyInput create() => MoneyInput._();
  static $pb.GeneratedMessage $_createMessage() => MoneyInput._();
  @$core.override
  MoneyInput createEmptyInstance() => MoneyInput._();
  @$core.pragma('dart2js:noInline')
  static MoneyInput getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MoneyInput>(MoneyInput.$_createMessage);
  static MoneyInput? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get amountMinor => $_getI64(0);
  @$pb.TagNumber(1)
  set amountMinor($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAmountMinor() => $_has(0);
  @$pb.TagNumber(1)
  void clearAmountMinor() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get currency => $_getSZ(1);
  @$pb.TagNumber(2)
  set currency($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCurrency() => $_has(1);
  @$pb.TagNumber(2)
  void clearCurrency() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get channel => $_getSZ(2);
  @$pb.TagNumber(3)
  set channel($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasChannel() => $_has(2);
  @$pb.TagNumber(3)
  void clearChannel() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get category => $_getSZ(3);
  @$pb.TagNumber(4)
  set category($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCategory() => $_has(3);
  @$pb.TagNumber(4)
  void clearCategory() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get merchant => $_getSZ(4);
  @$pb.TagNumber(5)
  set merchant($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMerchant() => $_has(4);
  @$pb.TagNumber(5)
  void clearMerchant() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get idempotencyKey => $_getSZ(5);
  @$pb.TagNumber(6)
  set idempotencyKey($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasIdempotencyKey() => $_has(5);
  @$pb.TagNumber(6)
  void clearIdempotencyKey() => $_clearField(6);
}

class ChildMoneyRequest extends $pb.GeneratedMessage {
  factory ChildMoneyRequest({
    $core.String? childId,
    MoneyInput? input,
  }) {
    final result = ChildMoneyRequest._();
    if (childId != null) result.childId = childId;
    if (input != null) result.input = input;
    return result;
  }

  ChildMoneyRequest._();

  factory ChildMoneyRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChildMoneyRequest()..mergeFromBuffer(data, registry);
  factory ChildMoneyRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChildMoneyRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChildMoneyRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'moby.family.v1'),
      createEmptyInstance: ChildMoneyRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'childId')
    ..aOM<MoneyInput>(2, _omitFieldNames ? '' : 'input',
        subBuilder: MoneyInput.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChildMoneyRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChildMoneyRequest copyWith(void Function(ChildMoneyRequest) updates) =>
      super.copyWith((message) => updates(message as ChildMoneyRequest))
          as ChildMoneyRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ChildMoneyRequest() / ChildMoneyRequest.new instead')
  static ChildMoneyRequest create() => ChildMoneyRequest._();
  static $pb.GeneratedMessage $_createMessage() => ChildMoneyRequest._();
  @$core.override
  ChildMoneyRequest createEmptyInstance() => ChildMoneyRequest._();
  @$core.pragma('dart2js:noInline')
  static ChildMoneyRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChildMoneyRequest>(
          ChildMoneyRequest.$_createMessage);
  static ChildMoneyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get childId => $_getSZ(0);
  @$pb.TagNumber(1)
  set childId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChildId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChildId() => $_clearField(1);

  @$pb.TagNumber(2)
  MoneyInput get input => $_getN(1);
  @$pb.TagNumber(2)
  set input(MoneyInput value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasInput() => $_has(1);
  @$pb.TagNumber(2)
  void clearInput() => $_clearField(2);
  @$pb.TagNumber(2)
  MoneyInput ensureInput() => $_ensure(1);
}

class DecideOperationRequest extends $pb.GeneratedMessage {
  factory DecideOperationRequest({
    $core.String? operationId,
    $core.bool? approve,
  }) {
    final result = DecideOperationRequest._();
    if (operationId != null) result.operationId = operationId;
    if (approve != null) result.approve = approve;
    return result;
  }

  DecideOperationRequest._();

  factory DecideOperationRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DecideOperationRequest()..mergeFromBuffer(data, registry);
  factory DecideOperationRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DecideOperationRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DecideOperationRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'moby.family.v1'),
      createEmptyInstance: DecideOperationRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'operationId')
    ..aOB(2, _omitFieldNames ? '' : 'approve')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DecideOperationRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DecideOperationRequest copyWith(
          void Function(DecideOperationRequest) updates) =>
      super.copyWith((message) => updates(message as DecideOperationRequest))
          as DecideOperationRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use DecideOperationRequest() / DecideOperationRequest.new instead')
  static DecideOperationRequest create() => DecideOperationRequest._();
  static $pb.GeneratedMessage $_createMessage() => DecideOperationRequest._();
  @$core.override
  DecideOperationRequest createEmptyInstance() => DecideOperationRequest._();
  @$core.pragma('dart2js:noInline')
  static DecideOperationRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DecideOperationRequest>(
          DecideOperationRequest.$_createMessage);
  static DecideOperationRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get operationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set operationId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOperationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearOperationId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get approve => $_getBF(1);
  @$pb.TagNumber(2)
  set approve($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasApprove() => $_has(1);
  @$pb.TagNumber(2)
  void clearApprove() => $_clearField(2);
}

class ChildrenList extends $pb.GeneratedMessage {
  factory ChildrenList({
    $core.Iterable<Child>? children,
  }) {
    final result = ChildrenList._();
    if (children != null) result.children.addAll(children);
    return result;
  }

  ChildrenList._();

  factory ChildrenList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChildrenList()..mergeFromBuffer(data, registry);
  factory ChildrenList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChildrenList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChildrenList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'moby.family.v1'),
      createEmptyInstance: ChildrenList.$_createMessage)
    ..pPM<Child>(1, _omitFieldNames ? '' : 'children',
        subBuilder: Child.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChildrenList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChildrenList copyWith(void Function(ChildrenList) updates) =>
      super.copyWith((message) => updates(message as ChildrenList))
          as ChildrenList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ChildrenList() / ChildrenList.new instead')
  static ChildrenList create() => ChildrenList._();
  static $pb.GeneratedMessage $_createMessage() => ChildrenList._();
  @$core.override
  ChildrenList createEmptyInstance() => ChildrenList._();
  @$core.pragma('dart2js:noInline')
  static ChildrenList getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChildrenList>(
          ChildrenList.$_createMessage);
  static ChildrenList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Child> get children => $_getList(0);
}

class CreatePairingRequest extends $pb.GeneratedMessage {
  factory CreatePairingRequest({
    $core.String? deviceName,
  }) {
    final result = CreatePairingRequest._();
    if (deviceName != null) result.deviceName = deviceName;
    return result;
  }

  CreatePairingRequest._();

  factory CreatePairingRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreatePairingRequest()..mergeFromBuffer(data, registry);
  factory CreatePairingRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreatePairingRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreatePairingRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'moby.family.v1'),
      createEmptyInstance: CreatePairingRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'deviceName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreatePairingRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreatePairingRequest copyWith(void Function(CreatePairingRequest) updates) =>
      super.copyWith((message) => updates(message as CreatePairingRequest))
          as CreatePairingRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CreatePairingRequest() / CreatePairingRequest.new instead')
  static CreatePairingRequest create() => CreatePairingRequest._();
  static $pb.GeneratedMessage $_createMessage() => CreatePairingRequest._();
  @$core.override
  CreatePairingRequest createEmptyInstance() => CreatePairingRequest._();
  @$core.pragma('dart2js:noInline')
  static CreatePairingRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreatePairingRequest>(
          CreatePairingRequest.$_createMessage);
  static CreatePairingRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get deviceName => $_getSZ(0);
  @$pb.TagNumber(1)
  set deviceName($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDeviceName() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeviceName() => $_clearField(1);
}

class ConsumePairingRequest extends $pb.GeneratedMessage {
  factory ConsumePairingRequest({
    $core.String? code,
    $core.String? childId,
  }) {
    final result = ConsumePairingRequest._();
    if (code != null) result.code = code;
    if (childId != null) result.childId = childId;
    return result;
  }

  ConsumePairingRequest._();

  factory ConsumePairingRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ConsumePairingRequest()..mergeFromBuffer(data, registry);
  factory ConsumePairingRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ConsumePairingRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConsumePairingRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'moby.family.v1'),
      createEmptyInstance: ConsumePairingRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'code')
    ..aOS(2, _omitFieldNames ? '' : 'childId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConsumePairingRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConsumePairingRequest copyWith(
          void Function(ConsumePairingRequest) updates) =>
      super.copyWith((message) => updates(message as ConsumePairingRequest))
          as ConsumePairingRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ConsumePairingRequest() / ConsumePairingRequest.new instead')
  static ConsumePairingRequest create() => ConsumePairingRequest._();
  static $pb.GeneratedMessage $_createMessage() => ConsumePairingRequest._();
  @$core.override
  ConsumePairingRequest createEmptyInstance() => ConsumePairingRequest._();
  @$core.pragma('dart2js:noInline')
  static ConsumePairingRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConsumePairingRequest>(
          ConsumePairingRequest.$_createMessage);
  static ConsumePairingRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get code => $_getSZ(0);
  @$pb.TagNumber(1)
  set code($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get childId => $_getSZ(1);
  @$pb.TagNumber(2)
  set childId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasChildId() => $_has(1);
  @$pb.TagNumber(2)
  void clearChildId() => $_clearField(2);
}

class PairingSecretRequest extends $pb.GeneratedMessage {
  factory PairingSecretRequest({
    $core.String? pairingId,
    $core.String? requestSecret,
  }) {
    final result = PairingSecretRequest._();
    if (pairingId != null) result.pairingId = pairingId;
    if (requestSecret != null) result.requestSecret = requestSecret;
    return result;
  }

  PairingSecretRequest._();

  factory PairingSecretRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PairingSecretRequest()..mergeFromBuffer(data, registry);
  factory PairingSecretRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PairingSecretRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PairingSecretRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'moby.family.v1'),
      createEmptyInstance: PairingSecretRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'pairingId')
    ..aOS(2, _omitFieldNames ? '' : 'requestSecret')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PairingSecretRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PairingSecretRequest copyWith(void Function(PairingSecretRequest) updates) =>
      super.copyWith((message) => updates(message as PairingSecretRequest))
          as PairingSecretRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PairingSecretRequest() / PairingSecretRequest.new instead')
  static PairingSecretRequest create() => PairingSecretRequest._();
  static $pb.GeneratedMessage $_createMessage() => PairingSecretRequest._();
  @$core.override
  PairingSecretRequest createEmptyInstance() => PairingSecretRequest._();
  @$core.pragma('dart2js:noInline')
  static PairingSecretRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PairingSecretRequest>(
          PairingSecretRequest.$_createMessage);
  static PairingSecretRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get pairingId => $_getSZ(0);
  @$pb.TagNumber(1)
  set pairingId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPairingId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPairingId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get requestSecret => $_getSZ(1);
  @$pb.TagNumber(2)
  set requestSecret($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRequestSecret() => $_has(1);
  @$pb.TagNumber(2)
  void clearRequestSecret() => $_clearField(2);
}

class PairingCreated extends $pb.GeneratedMessage {
  factory PairingCreated({
    $core.String? id,
    $core.String? code,
    $core.String? requestSecret,
    $fixnum.Int64? expiresAt,
    $core.String? status,
  }) {
    final result = PairingCreated._();
    if (id != null) result.id = id;
    if (code != null) result.code = code;
    if (requestSecret != null) result.requestSecret = requestSecret;
    if (expiresAt != null) result.expiresAt = expiresAt;
    if (status != null) result.status = status;
    return result;
  }

  PairingCreated._();

  factory PairingCreated.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PairingCreated()..mergeFromBuffer(data, registry);
  factory PairingCreated.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PairingCreated()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PairingCreated',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'moby.family.v1'),
      createEmptyInstance: PairingCreated.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'code')
    ..aOS(3, _omitFieldNames ? '' : 'requestSecret')
    ..aInt64(4, _omitFieldNames ? '' : 'expiresAt')
    ..aOS(5, _omitFieldNames ? '' : 'status')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PairingCreated clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PairingCreated copyWith(void Function(PairingCreated) updates) =>
      super.copyWith((message) => updates(message as PairingCreated))
          as PairingCreated;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PairingCreated() / PairingCreated.new instead')
  static PairingCreated create() => PairingCreated._();
  static $pb.GeneratedMessage $_createMessage() => PairingCreated._();
  @$core.override
  PairingCreated createEmptyInstance() => PairingCreated._();
  @$core.pragma('dart2js:noInline')
  static PairingCreated getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PairingCreated>(
          PairingCreated.$_createMessage);
  static PairingCreated? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get code => $_getSZ(1);
  @$pb.TagNumber(2)
  set code($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCode() => $_has(1);
  @$pb.TagNumber(2)
  void clearCode() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get requestSecret => $_getSZ(2);
  @$pb.TagNumber(3)
  set requestSecret($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRequestSecret() => $_has(2);
  @$pb.TagNumber(3)
  void clearRequestSecret() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get expiresAt => $_getI64(3);
  @$pb.TagNumber(4)
  set expiresAt($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasExpiresAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearExpiresAt() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get status => $_getSZ(4);
  @$pb.TagNumber(5)
  set status($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(4);
  @$pb.TagNumber(5)
  void clearStatus() => $_clearField(5);
}

class PairingResult extends $pb.GeneratedMessage {
  factory PairingResult({
    $core.String? id,
    $core.String? status,
    $core.String? childId,
  }) {
    final result = PairingResult._();
    if (id != null) result.id = id;
    if (status != null) result.status = status;
    if (childId != null) result.childId = childId;
    return result;
  }

  PairingResult._();

  factory PairingResult.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PairingResult()..mergeFromBuffer(data, registry);
  factory PairingResult.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PairingResult()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PairingResult',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'moby.family.v1'),
      createEmptyInstance: PairingResult.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'status')
    ..aOS(3, _omitFieldNames ? '' : 'childId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PairingResult clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PairingResult copyWith(void Function(PairingResult) updates) =>
      super.copyWith((message) => updates(message as PairingResult))
          as PairingResult;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PairingResult() / PairingResult.new instead')
  static PairingResult create() => PairingResult._();
  static $pb.GeneratedMessage $_createMessage() => PairingResult._();
  @$core.override
  PairingResult createEmptyInstance() => PairingResult._();
  @$core.pragma('dart2js:noInline')
  static PairingResult getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PairingResult>(
          PairingResult.$_createMessage);
  static PairingResult? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get status => $_getSZ(1);
  @$pb.TagNumber(2)
  set status($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get childId => $_getSZ(2);
  @$pb.TagNumber(3)
  set childId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasChildId() => $_has(2);
  @$pb.TagNumber(3)
  void clearChildId() => $_clearField(3);
}

class PairingPoll extends $pb.GeneratedMessage {
  factory PairingPoll({
    $core.String? status,
    SessionGrant? session,
  }) {
    final result = PairingPoll._();
    if (status != null) result.status = status;
    if (session != null) result.session = session;
    return result;
  }

  PairingPoll._();

  factory PairingPoll.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PairingPoll()..mergeFromBuffer(data, registry);
  factory PairingPoll.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PairingPoll()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PairingPoll',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'moby.family.v1'),
      createEmptyInstance: PairingPoll.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'status')
    ..aOM<SessionGrant>(2, _omitFieldNames ? '' : 'session',
        subBuilder: SessionGrant.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PairingPoll clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PairingPoll copyWith(void Function(PairingPoll) updates) =>
      super.copyWith((message) => updates(message as PairingPoll))
          as PairingPoll;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PairingPoll() / PairingPoll.new instead')
  static PairingPoll create() => PairingPoll._();
  static $pb.GeneratedMessage $_createMessage() => PairingPoll._();
  @$core.override
  PairingPoll createEmptyInstance() => PairingPoll._();
  @$core.pragma('dart2js:noInline')
  static PairingPoll getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PairingPoll>(
          PairingPoll.$_createMessage);
  static PairingPoll? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get status => $_getSZ(0);
  @$pb.TagNumber(1)
  set status($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => $_clearField(1);

  @$pb.TagNumber(2)
  SessionGrant get session => $_getN(1);
  @$pb.TagNumber(2)
  set session(SessionGrant value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasSession() => $_has(1);
  @$pb.TagNumber(2)
  void clearSession() => $_clearField(2);
  @$pb.TagNumber(2)
  SessionGrant ensureSession() => $_ensure(1);
}

class SessionSummary extends $pb.GeneratedMessage {
  factory SessionSummary({
    $core.String? id,
    $core.String? role,
    $core.String? childId,
    $core.String? deviceName,
    $fixnum.Int64? expiresAt,
    $core.bool? revoked,
  }) {
    final result = SessionSummary._();
    if (id != null) result.id = id;
    if (role != null) result.role = role;
    if (childId != null) result.childId = childId;
    if (deviceName != null) result.deviceName = deviceName;
    if (expiresAt != null) result.expiresAt = expiresAt;
    if (revoked != null) result.revoked = revoked;
    return result;
  }

  SessionSummary._();

  factory SessionSummary.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SessionSummary()..mergeFromBuffer(data, registry);
  factory SessionSummary.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SessionSummary()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SessionSummary',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'moby.family.v1'),
      createEmptyInstance: SessionSummary.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'role')
    ..aOS(3, _omitFieldNames ? '' : 'childId')
    ..aOS(4, _omitFieldNames ? '' : 'deviceName')
    ..aInt64(5, _omitFieldNames ? '' : 'expiresAt')
    ..aOB(6, _omitFieldNames ? '' : 'revoked')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SessionSummary clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SessionSummary copyWith(void Function(SessionSummary) updates) =>
      super.copyWith((message) => updates(message as SessionSummary))
          as SessionSummary;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SessionSummary() / SessionSummary.new instead')
  static SessionSummary create() => SessionSummary._();
  static $pb.GeneratedMessage $_createMessage() => SessionSummary._();
  @$core.override
  SessionSummary createEmptyInstance() => SessionSummary._();
  @$core.pragma('dart2js:noInline')
  static SessionSummary getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SessionSummary>(
          SessionSummary.$_createMessage);
  static SessionSummary? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get role => $_getSZ(1);
  @$pb.TagNumber(2)
  set role($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRole() => $_has(1);
  @$pb.TagNumber(2)
  void clearRole() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get childId => $_getSZ(2);
  @$pb.TagNumber(3)
  set childId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasChildId() => $_has(2);
  @$pb.TagNumber(3)
  void clearChildId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get deviceName => $_getSZ(3);
  @$pb.TagNumber(4)
  set deviceName($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDeviceName() => $_has(3);
  @$pb.TagNumber(4)
  void clearDeviceName() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get expiresAt => $_getI64(4);
  @$pb.TagNumber(5)
  set expiresAt($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasExpiresAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearExpiresAt() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get revoked => $_getBF(5);
  @$pb.TagNumber(6)
  set revoked($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasRevoked() => $_has(5);
  @$pb.TagNumber(6)
  void clearRevoked() => $_clearField(6);
}

class SessionsList extends $pb.GeneratedMessage {
  factory SessionsList({
    $core.Iterable<SessionSummary>? sessions,
  }) {
    final result = SessionsList._();
    if (sessions != null) result.sessions.addAll(sessions);
    return result;
  }

  SessionsList._();

  factory SessionsList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SessionsList()..mergeFromBuffer(data, registry);
  factory SessionsList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SessionsList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SessionsList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'moby.family.v1'),
      createEmptyInstance: SessionsList.$_createMessage)
    ..pPM<SessionSummary>(1, _omitFieldNames ? '' : 'sessions',
        subBuilder: SessionSummary.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SessionsList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SessionsList copyWith(void Function(SessionsList) updates) =>
      super.copyWith((message) => updates(message as SessionsList))
          as SessionsList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SessionsList() / SessionsList.new instead')
  static SessionsList create() => SessionsList._();
  static $pb.GeneratedMessage $_createMessage() => SessionsList._();
  @$core.override
  SessionsList createEmptyInstance() => SessionsList._();
  @$core.pragma('dart2js:noInline')
  static SessionsList getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SessionsList>(
          SessionsList.$_createMessage);
  static SessionsList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<SessionSummary> get sessions => $_getList(0);
}

/// Wrapper distinguishes an omitted category policy from an explicitly empty one.
class CategoryRules extends $pb.GeneratedMessage {
  factory CategoryRules({
    $core.Iterable<$core.MapEntry<$core.String, $core.bool>>? values,
  }) {
    final result = CategoryRules._();
    if (values != null) result.values.addEntries(values);
    return result;
  }

  CategoryRules._();

  factory CategoryRules.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CategoryRules()..mergeFromBuffer(data, registry);
  factory CategoryRules.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CategoryRules()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CategoryRules',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'moby.family.v1'),
      createEmptyInstance: CategoryRules.$_createMessage)
    ..m<$core.String, $core.bool>(1, _omitFieldNames ? '' : 'values',
        entryClassName: 'CategoryRules.ValuesEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OB,
        packageName: const $pb.PackageName('moby.family.v1'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CategoryRules clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CategoryRules copyWith(void Function(CategoryRules) updates) =>
      super.copyWith((message) => updates(message as CategoryRules))
          as CategoryRules;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CategoryRules() / CategoryRules.new instead')
  static CategoryRules create() => CategoryRules._();
  static $pb.GeneratedMessage $_createMessage() => CategoryRules._();
  @$core.override
  CategoryRules createEmptyInstance() => CategoryRules._();
  @$core.pragma('dart2js:noInline')
  static CategoryRules getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CategoryRules>(
          CategoryRules.$_createMessage);
  static CategoryRules? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbMap<$core.String, $core.bool> get values => $_getMap(0);
}

class Policy extends $pb.GeneratedMessage {
  factory Policy({
    CategoryRules? categories,
    $core.bool? payments,
    $core.bool? transfers,
    $core.bool? internet,
    $fixnum.Int64? dailyLimit,
    $fixnum.Int64? monthlyLimit,
    $fixnum.Int64? approvalThreshold,
  }) {
    final result = Policy._();
    if (categories != null) result.categories = categories;
    if (payments != null) result.payments = payments;
    if (transfers != null) result.transfers = transfers;
    if (internet != null) result.internet = internet;
    if (dailyLimit != null) result.dailyLimit = dailyLimit;
    if (monthlyLimit != null) result.monthlyLimit = monthlyLimit;
    if (approvalThreshold != null) result.approvalThreshold = approvalThreshold;
    return result;
  }

  Policy._();

  factory Policy.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Policy()..mergeFromBuffer(data, registry);
  factory Policy.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Policy()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Policy',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'moby.family.v1'),
      createEmptyInstance: Policy.$_createMessage)
    ..aOM<CategoryRules>(1, _omitFieldNames ? '' : 'categories',
        subBuilder: CategoryRules.$_createMessage)
    ..aOB(2, _omitFieldNames ? '' : 'payments')
    ..aOB(3, _omitFieldNames ? '' : 'transfers')
    ..aOB(4, _omitFieldNames ? '' : 'internet')
    ..aInt64(5, _omitFieldNames ? '' : 'dailyLimit')
    ..aInt64(6, _omitFieldNames ? '' : 'monthlyLimit')
    ..aInt64(7, _omitFieldNames ? '' : 'approvalThreshold')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Policy clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Policy copyWith(void Function(Policy) updates) =>
      super.copyWith((message) => updates(message as Policy)) as Policy;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Policy() / Policy.new instead')
  static Policy create() => Policy._();
  static $pb.GeneratedMessage $_createMessage() => Policy._();
  @$core.override
  Policy createEmptyInstance() => Policy._();
  @$core.pragma('dart2js:noInline')
  static Policy getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Policy>(Policy.$_createMessage);
  static Policy? _defaultInstance;

  @$pb.TagNumber(1)
  CategoryRules get categories => $_getN(0);
  @$pb.TagNumber(1)
  set categories(CategoryRules value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasCategories() => $_has(0);
  @$pb.TagNumber(1)
  void clearCategories() => $_clearField(1);
  @$pb.TagNumber(1)
  CategoryRules ensureCategories() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.bool get payments => $_getBF(1);
  @$pb.TagNumber(2)
  set payments($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPayments() => $_has(1);
  @$pb.TagNumber(2)
  void clearPayments() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get transfers => $_getBF(2);
  @$pb.TagNumber(3)
  set transfers($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTransfers() => $_has(2);
  @$pb.TagNumber(3)
  void clearTransfers() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get internet => $_getBF(3);
  @$pb.TagNumber(4)
  set internet($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasInternet() => $_has(3);
  @$pb.TagNumber(4)
  void clearInternet() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get dailyLimit => $_getI64(4);
  @$pb.TagNumber(5)
  set dailyLimit($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDailyLimit() => $_has(4);
  @$pb.TagNumber(5)
  void clearDailyLimit() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get monthlyLimit => $_getI64(5);
  @$pb.TagNumber(6)
  set monthlyLimit($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMonthlyLimit() => $_has(5);
  @$pb.TagNumber(6)
  void clearMonthlyLimit() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get approvalThreshold => $_getI64(6);
  @$pb.TagNumber(7)
  set approvalThreshold($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasApprovalThreshold() => $_has(6);
  @$pb.TagNumber(7)
  void clearApprovalThreshold() => $_clearField(7);
}

class Child extends $pb.GeneratedMessage {
  factory Child({
    $core.String? id,
    $core.String? displayName,
    $core.String? legalName,
    $core.String? dateOfBirth,
    $core.String? identityStatus,
    $core.String? representationStatus,
    $core.String? agreementStatus,
    $core.String? accountStatus,
    $core.String? cardStatus,
    $core.String? deviceAccessStatus,
    $core.String? membershipStatus,
    Policy? policy,
    $fixnum.Int64? balanceMinor,
    $core.String? currency,
    $core.String? agreementVersion,
    $core.String? signerId,
    $fixnum.Int64? signedAt,
    $fixnum.Int64? version,
  }) {
    final result = Child._();
    if (id != null) result.id = id;
    if (displayName != null) result.displayName = displayName;
    if (legalName != null) result.legalName = legalName;
    if (dateOfBirth != null) result.dateOfBirth = dateOfBirth;
    if (identityStatus != null) result.identityStatus = identityStatus;
    if (representationStatus != null)
      result.representationStatus = representationStatus;
    if (agreementStatus != null) result.agreementStatus = agreementStatus;
    if (accountStatus != null) result.accountStatus = accountStatus;
    if (cardStatus != null) result.cardStatus = cardStatus;
    if (deviceAccessStatus != null)
      result.deviceAccessStatus = deviceAccessStatus;
    if (membershipStatus != null) result.membershipStatus = membershipStatus;
    if (policy != null) result.policy = policy;
    if (balanceMinor != null) result.balanceMinor = balanceMinor;
    if (currency != null) result.currency = currency;
    if (agreementVersion != null) result.agreementVersion = agreementVersion;
    if (signerId != null) result.signerId = signerId;
    if (signedAt != null) result.signedAt = signedAt;
    if (version != null) result.version = version;
    return result;
  }

  Child._();

  factory Child.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Child()..mergeFromBuffer(data, registry);
  factory Child.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Child()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Child',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'moby.family.v1'),
      createEmptyInstance: Child.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'displayName')
    ..aOS(3, _omitFieldNames ? '' : 'legalName')
    ..aOS(4, _omitFieldNames ? '' : 'dateOfBirth')
    ..aOS(5, _omitFieldNames ? '' : 'identityStatus')
    ..aOS(6, _omitFieldNames ? '' : 'representationStatus')
    ..aOS(7, _omitFieldNames ? '' : 'agreementStatus')
    ..aOS(8, _omitFieldNames ? '' : 'accountStatus')
    ..aOS(9, _omitFieldNames ? '' : 'cardStatus')
    ..aOS(10, _omitFieldNames ? '' : 'deviceAccessStatus')
    ..aOS(11, _omitFieldNames ? '' : 'membershipStatus')
    ..aOM<Policy>(12, _omitFieldNames ? '' : 'policy',
        subBuilder: Policy.$_createMessage)
    ..aInt64(13, _omitFieldNames ? '' : 'balanceMinor')
    ..aOS(14, _omitFieldNames ? '' : 'currency')
    ..aOS(15, _omitFieldNames ? '' : 'agreementVersion')
    ..aOS(16, _omitFieldNames ? '' : 'signerId')
    ..aInt64(17, _omitFieldNames ? '' : 'signedAt')
    ..aInt64(18, _omitFieldNames ? '' : 'version')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Child clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Child copyWith(void Function(Child) updates) =>
      super.copyWith((message) => updates(message as Child)) as Child;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Child() / Child.new instead')
  static Child create() => Child._();
  static $pb.GeneratedMessage $_createMessage() => Child._();
  @$core.override
  Child createEmptyInstance() => Child._();
  @$core.pragma('dart2js:noInline')
  static Child getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Child>(Child.$_createMessage);
  static Child? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get displayName => $_getSZ(1);
  @$pb.TagNumber(2)
  set displayName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDisplayName() => $_has(1);
  @$pb.TagNumber(2)
  void clearDisplayName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get legalName => $_getSZ(2);
  @$pb.TagNumber(3)
  set legalName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLegalName() => $_has(2);
  @$pb.TagNumber(3)
  void clearLegalName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get dateOfBirth => $_getSZ(3);
  @$pb.TagNumber(4)
  set dateOfBirth($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDateOfBirth() => $_has(3);
  @$pb.TagNumber(4)
  void clearDateOfBirth() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get identityStatus => $_getSZ(4);
  @$pb.TagNumber(5)
  set identityStatus($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIdentityStatus() => $_has(4);
  @$pb.TagNumber(5)
  void clearIdentityStatus() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get representationStatus => $_getSZ(5);
  @$pb.TagNumber(6)
  set representationStatus($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasRepresentationStatus() => $_has(5);
  @$pb.TagNumber(6)
  void clearRepresentationStatus() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get agreementStatus => $_getSZ(6);
  @$pb.TagNumber(7)
  set agreementStatus($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasAgreementStatus() => $_has(6);
  @$pb.TagNumber(7)
  void clearAgreementStatus() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get accountStatus => $_getSZ(7);
  @$pb.TagNumber(8)
  set accountStatus($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasAccountStatus() => $_has(7);
  @$pb.TagNumber(8)
  void clearAccountStatus() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get cardStatus => $_getSZ(8);
  @$pb.TagNumber(9)
  set cardStatus($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasCardStatus() => $_has(8);
  @$pb.TagNumber(9)
  void clearCardStatus() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get deviceAccessStatus => $_getSZ(9);
  @$pb.TagNumber(10)
  set deviceAccessStatus($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasDeviceAccessStatus() => $_has(9);
  @$pb.TagNumber(10)
  void clearDeviceAccessStatus() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get membershipStatus => $_getSZ(10);
  @$pb.TagNumber(11)
  set membershipStatus($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasMembershipStatus() => $_has(10);
  @$pb.TagNumber(11)
  void clearMembershipStatus() => $_clearField(11);

  @$pb.TagNumber(12)
  Policy get policy => $_getN(11);
  @$pb.TagNumber(12)
  set policy(Policy value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasPolicy() => $_has(11);
  @$pb.TagNumber(12)
  void clearPolicy() => $_clearField(12);
  @$pb.TagNumber(12)
  Policy ensurePolicy() => $_ensure(11);

  @$pb.TagNumber(13)
  $fixnum.Int64 get balanceMinor => $_getI64(12);
  @$pb.TagNumber(13)
  set balanceMinor($fixnum.Int64 value) => $_setInt64(12, value);
  @$pb.TagNumber(13)
  $core.bool hasBalanceMinor() => $_has(12);
  @$pb.TagNumber(13)
  void clearBalanceMinor() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.String get currency => $_getSZ(13);
  @$pb.TagNumber(14)
  set currency($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasCurrency() => $_has(13);
  @$pb.TagNumber(14)
  void clearCurrency() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.String get agreementVersion => $_getSZ(14);
  @$pb.TagNumber(15)
  set agreementVersion($core.String value) => $_setString(14, value);
  @$pb.TagNumber(15)
  $core.bool hasAgreementVersion() => $_has(14);
  @$pb.TagNumber(15)
  void clearAgreementVersion() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.String get signerId => $_getSZ(15);
  @$pb.TagNumber(16)
  set signerId($core.String value) => $_setString(15, value);
  @$pb.TagNumber(16)
  $core.bool hasSignerId() => $_has(15);
  @$pb.TagNumber(16)
  void clearSignerId() => $_clearField(16);

  @$pb.TagNumber(17)
  $fixnum.Int64 get signedAt => $_getI64(16);
  @$pb.TagNumber(17)
  set signedAt($fixnum.Int64 value) => $_setInt64(16, value);
  @$pb.TagNumber(17)
  $core.bool hasSignedAt() => $_has(16);
  @$pb.TagNumber(17)
  void clearSignedAt() => $_clearField(17);

  @$pb.TagNumber(18)
  $fixnum.Int64 get version => $_getI64(17);
  @$pb.TagNumber(18)
  set version($fixnum.Int64 value) => $_setInt64(17, value);
  @$pb.TagNumber(18)
  $core.bool hasVersion() => $_has(17);
  @$pb.TagNumber(18)
  void clearVersion() => $_clearField(18);
}

class Actor extends $pb.GeneratedMessage {
  factory Actor({
    $core.String? id,
    $core.String? role,
    $core.String? childId,
    $core.String? sessionId,
  }) {
    final result = Actor._();
    if (id != null) result.id = id;
    if (role != null) result.role = role;
    if (childId != null) result.childId = childId;
    if (sessionId != null) result.sessionId = sessionId;
    return result;
  }

  Actor._();

  factory Actor.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Actor()..mergeFromBuffer(data, registry);
  factory Actor.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Actor()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Actor',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'moby.family.v1'),
      createEmptyInstance: Actor.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'role')
    ..aOS(3, _omitFieldNames ? '' : 'childId')
    ..aOS(4, _omitFieldNames ? '' : 'sessionId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Actor clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Actor copyWith(void Function(Actor) updates) =>
      super.copyWith((message) => updates(message as Actor)) as Actor;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Actor() / Actor.new instead')
  static Actor create() => Actor._();
  static $pb.GeneratedMessage $_createMessage() => Actor._();
  @$core.override
  Actor createEmptyInstance() => Actor._();
  @$core.pragma('dart2js:noInline')
  static Actor getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Actor>(Actor.$_createMessage);
  static Actor? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get role => $_getSZ(1);
  @$pb.TagNumber(2)
  set role($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRole() => $_has(1);
  @$pb.TagNumber(2)
  void clearRole() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get childId => $_getSZ(2);
  @$pb.TagNumber(3)
  set childId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasChildId() => $_has(2);
  @$pb.TagNumber(3)
  void clearChildId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get sessionId => $_getSZ(3);
  @$pb.TagNumber(4)
  set sessionId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSessionId() => $_has(3);
  @$pb.TagNumber(4)
  void clearSessionId() => $_clearField(4);
}

class AdultPreferences extends $pb.GeneratedMessage {
  factory AdultPreferences({
    $core.bool? familyIntroSeen,
  }) {
    final result = AdultPreferences._();
    if (familyIntroSeen != null) result.familyIntroSeen = familyIntroSeen;
    return result;
  }

  AdultPreferences._();

  factory AdultPreferences.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AdultPreferences()..mergeFromBuffer(data, registry);
  factory AdultPreferences.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AdultPreferences()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AdultPreferences',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'moby.family.v1'),
      createEmptyInstance: AdultPreferences.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'familyIntroSeen')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AdultPreferences clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AdultPreferences copyWith(void Function(AdultPreferences) updates) =>
      super.copyWith((message) => updates(message as AdultPreferences))
          as AdultPreferences;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AdultPreferences() / AdultPreferences.new instead')
  static AdultPreferences create() => AdultPreferences._();
  static $pb.GeneratedMessage $_createMessage() => AdultPreferences._();
  @$core.override
  AdultPreferences createEmptyInstance() => AdultPreferences._();
  @$core.pragma('dart2js:noInline')
  static AdultPreferences getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AdultPreferences>(
          AdultPreferences.$_createMessage);
  static AdultPreferences? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get familyIntroSeen => $_getBF(0);
  @$pb.TagNumber(1)
  set familyIntroSeen($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFamilyIntroSeen() => $_has(0);
  @$pb.TagNumber(1)
  void clearFamilyIntroSeen() => $_clearField(1);
}

class Snapshot extends $pb.GeneratedMessage {
  factory Snapshot({
    FamilySpaceSnapshot? familySpace,
    $fixnum.Int64? revision,
    Actor? actor,
    AdultPreferences? preferences,
    $core.Iterable<Child>? children,
    $core.Iterable<Operation>? operations,
    $core.bool? synthetic,
    $core.String? businessDate,
  }) {
    final result = Snapshot._();
    if (familySpace != null) result.familySpace = familySpace;
    if (revision != null) result.revision = revision;
    if (actor != null) result.actor = actor;
    if (preferences != null) result.preferences = preferences;
    if (children != null) result.children.addAll(children);
    if (operations != null) result.operations.addAll(operations);
    if (synthetic != null) result.synthetic = synthetic;
    if (businessDate != null) result.businessDate = businessDate;
    return result;
  }

  Snapshot._();

  factory Snapshot.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Snapshot()..mergeFromBuffer(data, registry);
  factory Snapshot.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Snapshot()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Snapshot',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'moby.family.v1'),
      createEmptyInstance: Snapshot.$_createMessage)
    ..aOM<FamilySpaceSnapshot>(1, _omitFieldNames ? '' : 'familySpace',
        subBuilder: FamilySpaceSnapshot.$_createMessage)
    ..aInt64(2, _omitFieldNames ? '' : 'revision')
    ..aOM<Actor>(3, _omitFieldNames ? '' : 'actor',
        subBuilder: Actor.$_createMessage)
    ..aOM<AdultPreferences>(4, _omitFieldNames ? '' : 'preferences',
        subBuilder: AdultPreferences.$_createMessage)
    ..pPM<Child>(5, _omitFieldNames ? '' : 'children',
        subBuilder: Child.$_createMessage)
    ..pPM<Operation>(6, _omitFieldNames ? '' : 'operations',
        subBuilder: Operation.$_createMessage)
    ..aOB(7, _omitFieldNames ? '' : 'synthetic')
    ..aOS(8, _omitFieldNames ? '' : 'businessDate')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Snapshot clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Snapshot copyWith(void Function(Snapshot) updates) =>
      super.copyWith((message) => updates(message as Snapshot)) as Snapshot;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Snapshot() / Snapshot.new instead')
  static Snapshot create() => Snapshot._();
  static $pb.GeneratedMessage $_createMessage() => Snapshot._();
  @$core.override
  Snapshot createEmptyInstance() => Snapshot._();
  @$core.pragma('dart2js:noInline')
  static Snapshot getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Snapshot>(Snapshot.$_createMessage);
  static Snapshot? _defaultInstance;

  @$pb.TagNumber(1)
  FamilySpaceSnapshot get familySpace => $_getN(0);
  @$pb.TagNumber(1)
  set familySpace(FamilySpaceSnapshot value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasFamilySpace() => $_has(0);
  @$pb.TagNumber(1)
  void clearFamilySpace() => $_clearField(1);
  @$pb.TagNumber(1)
  FamilySpaceSnapshot ensureFamilySpace() => $_ensure(0);

  @$pb.TagNumber(2)
  $fixnum.Int64 get revision => $_getI64(1);
  @$pb.TagNumber(2)
  set revision($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRevision() => $_has(1);
  @$pb.TagNumber(2)
  void clearRevision() => $_clearField(2);

  @$pb.TagNumber(3)
  Actor get actor => $_getN(2);
  @$pb.TagNumber(3)
  set actor(Actor value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasActor() => $_has(2);
  @$pb.TagNumber(3)
  void clearActor() => $_clearField(3);
  @$pb.TagNumber(3)
  Actor ensureActor() => $_ensure(2);

  @$pb.TagNumber(4)
  AdultPreferences get preferences => $_getN(3);
  @$pb.TagNumber(4)
  set preferences(AdultPreferences value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasPreferences() => $_has(3);
  @$pb.TagNumber(4)
  void clearPreferences() => $_clearField(4);
  @$pb.TagNumber(4)
  AdultPreferences ensurePreferences() => $_ensure(3);

  @$pb.TagNumber(5)
  $pb.PbList<Child> get children => $_getList(4);

  @$pb.TagNumber(6)
  $pb.PbList<Operation> get operations => $_getList(5);

  @$pb.TagNumber(7)
  $core.bool get synthetic => $_getBF(6);
  @$pb.TagNumber(7)
  set synthetic($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasSynthetic() => $_has(6);
  @$pb.TagNumber(7)
  void clearSynthetic() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get businessDate => $_getSZ(7);
  @$pb.TagNumber(8)
  set businessDate($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasBusinessDate() => $_has(7);
  @$pb.TagNumber(8)
  void clearBusinessDate() => $_clearField(8);
}

class Operation extends $pb.GeneratedMessage {
  factory Operation({
    $core.String? id,
    $core.String? childId,
    $core.String? kind,
    $fixnum.Int64? amountMinor,
    $core.String? currency,
    $core.String? channel,
    $core.String? category,
    $fixnum.Int64? completedAt,
    $core.String? merchant,
    $core.String? status,
    $fixnum.Int64? createdAt,
    $fixnum.Int64? version,
    $core.bool? decision,
  }) {
    final result = Operation._();
    if (id != null) result.id = id;
    if (childId != null) result.childId = childId;
    if (kind != null) result.kind = kind;
    if (amountMinor != null) result.amountMinor = amountMinor;
    if (currency != null) result.currency = currency;
    if (channel != null) result.channel = channel;
    if (category != null) result.category = category;
    if (completedAt != null) result.completedAt = completedAt;
    if (merchant != null) result.merchant = merchant;
    if (status != null) result.status = status;
    if (createdAt != null) result.createdAt = createdAt;
    if (version != null) result.version = version;
    if (decision != null) result.decision = decision;
    return result;
  }

  Operation._();

  factory Operation.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Operation()..mergeFromBuffer(data, registry);
  factory Operation.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Operation()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Operation',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'moby.family.v1'),
      createEmptyInstance: Operation.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'childId')
    ..aOS(3, _omitFieldNames ? '' : 'kind')
    ..aInt64(4, _omitFieldNames ? '' : 'amountMinor')
    ..aOS(5, _omitFieldNames ? '' : 'currency')
    ..aOS(6, _omitFieldNames ? '' : 'channel')
    ..aOS(7, _omitFieldNames ? '' : 'category')
    ..aInt64(8, _omitFieldNames ? '' : 'completedAt')
    ..aOS(9, _omitFieldNames ? '' : 'merchant')
    ..aOS(10, _omitFieldNames ? '' : 'status')
    ..aInt64(11, _omitFieldNames ? '' : 'createdAt')
    ..aInt64(12, _omitFieldNames ? '' : 'version')
    ..aOB(13, _omitFieldNames ? '' : 'decision')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Operation clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Operation copyWith(void Function(Operation) updates) =>
      super.copyWith((message) => updates(message as Operation)) as Operation;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Operation() / Operation.new instead')
  static Operation create() => Operation._();
  static $pb.GeneratedMessage $_createMessage() => Operation._();
  @$core.override
  Operation createEmptyInstance() => Operation._();
  @$core.pragma('dart2js:noInline')
  static Operation getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Operation>(Operation.$_createMessage);
  static Operation? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get childId => $_getSZ(1);
  @$pb.TagNumber(2)
  set childId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasChildId() => $_has(1);
  @$pb.TagNumber(2)
  void clearChildId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get kind => $_getSZ(2);
  @$pb.TagNumber(3)
  set kind($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasKind() => $_has(2);
  @$pb.TagNumber(3)
  void clearKind() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get amountMinor => $_getI64(3);
  @$pb.TagNumber(4)
  set amountMinor($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAmountMinor() => $_has(3);
  @$pb.TagNumber(4)
  void clearAmountMinor() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get currency => $_getSZ(4);
  @$pb.TagNumber(5)
  set currency($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCurrency() => $_has(4);
  @$pb.TagNumber(5)
  void clearCurrency() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get channel => $_getSZ(5);
  @$pb.TagNumber(6)
  set channel($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasChannel() => $_has(5);
  @$pb.TagNumber(6)
  void clearChannel() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get category => $_getSZ(6);
  @$pb.TagNumber(7)
  set category($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasCategory() => $_has(6);
  @$pb.TagNumber(7)
  void clearCategory() => $_clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get completedAt => $_getI64(7);
  @$pb.TagNumber(8)
  set completedAt($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasCompletedAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearCompletedAt() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get merchant => $_getSZ(8);
  @$pb.TagNumber(9)
  set merchant($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasMerchant() => $_has(8);
  @$pb.TagNumber(9)
  void clearMerchant() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get status => $_getSZ(9);
  @$pb.TagNumber(10)
  set status($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasStatus() => $_has(9);
  @$pb.TagNumber(10)
  void clearStatus() => $_clearField(10);

  @$pb.TagNumber(11)
  $fixnum.Int64 get createdAt => $_getI64(10);
  @$pb.TagNumber(11)
  set createdAt($fixnum.Int64 value) => $_setInt64(10, value);
  @$pb.TagNumber(11)
  $core.bool hasCreatedAt() => $_has(10);
  @$pb.TagNumber(11)
  void clearCreatedAt() => $_clearField(11);

  @$pb.TagNumber(12)
  $fixnum.Int64 get version => $_getI64(11);
  @$pb.TagNumber(12)
  set version($fixnum.Int64 value) => $_setInt64(11, value);
  @$pb.TagNumber(12)
  $core.bool hasVersion() => $_has(11);
  @$pb.TagNumber(12)
  void clearVersion() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.bool get decision => $_getBF(12);
  @$pb.TagNumber(13)
  set decision($core.bool value) => $_setBool(12, value);
  @$pb.TagNumber(13)
  $core.bool hasDecision() => $_has(12);
  @$pb.TagNumber(13)
  void clearDecision() => $_clearField(13);
}

class Wallet extends $pb.GeneratedMessage {
  factory Wallet({
    $fixnum.Int64? availableMinor,
    $fixnum.Int64? reservedMinor,
    $core.String? currency,
  }) {
    final result = Wallet._();
    if (availableMinor != null) result.availableMinor = availableMinor;
    if (reservedMinor != null) result.reservedMinor = reservedMinor;
    if (currency != null) result.currency = currency;
    return result;
  }

  Wallet._();

  factory Wallet.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Wallet()..mergeFromBuffer(data, registry);
  factory Wallet.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Wallet()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Wallet',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'moby.family.v1'),
      createEmptyInstance: Wallet.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'availableMinor')
    ..aInt64(2, _omitFieldNames ? '' : 'reservedMinor')
    ..aOS(3, _omitFieldNames ? '' : 'currency')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Wallet clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Wallet copyWith(void Function(Wallet) updates) =>
      super.copyWith((message) => updates(message as Wallet)) as Wallet;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Wallet() / Wallet.new instead')
  static Wallet create() => Wallet._();
  static $pb.GeneratedMessage $_createMessage() => Wallet._();
  @$core.override
  Wallet createEmptyInstance() => Wallet._();
  @$core.pragma('dart2js:noInline')
  static Wallet getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Wallet>(Wallet.$_createMessage);
  static Wallet? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get availableMinor => $_getI64(0);
  @$pb.TagNumber(1)
  set availableMinor($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAvailableMinor() => $_has(0);
  @$pb.TagNumber(1)
  void clearAvailableMinor() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get reservedMinor => $_getI64(1);
  @$pb.TagNumber(2)
  set reservedMinor($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasReservedMinor() => $_has(1);
  @$pb.TagNumber(2)
  void clearReservedMinor() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get currency => $_getSZ(2);
  @$pb.TagNumber(3)
  set currency($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCurrency() => $_has(2);
  @$pb.TagNumber(3)
  void clearCurrency() => $_clearField(3);
}

class Goal extends $pb.GeneratedMessage {
  factory Goal({
    $core.String? id,
    $core.String? childId,
    $core.String? title,
    $fixnum.Int64? targetMinor,
    $fixnum.Int64? savedMinor,
    $fixnum.Int64? matchedMinor,
    $fixnum.Int64? netDepositsMinor,
    $fixnum.Int64? matchedBasisMinor,
    $fixnum.Int64? matchingAvailableMinor,
    $core.String? matchingStatus,
  }) {
    final result = Goal._();
    if (id != null) result.id = id;
    if (childId != null) result.childId = childId;
    if (title != null) result.title = title;
    if (targetMinor != null) result.targetMinor = targetMinor;
    if (savedMinor != null) result.savedMinor = savedMinor;
    if (matchedMinor != null) result.matchedMinor = matchedMinor;
    if (netDepositsMinor != null) result.netDepositsMinor = netDepositsMinor;
    if (matchedBasisMinor != null) result.matchedBasisMinor = matchedBasisMinor;
    if (matchingAvailableMinor != null)
      result.matchingAvailableMinor = matchingAvailableMinor;
    if (matchingStatus != null) result.matchingStatus = matchingStatus;
    return result;
  }

  Goal._();

  factory Goal.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Goal()..mergeFromBuffer(data, registry);
  factory Goal.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Goal()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Goal',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'moby.family.v1'),
      createEmptyInstance: Goal.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'childId')
    ..aOS(3, _omitFieldNames ? '' : 'title')
    ..aInt64(4, _omitFieldNames ? '' : 'targetMinor')
    ..aInt64(5, _omitFieldNames ? '' : 'savedMinor')
    ..aInt64(6, _omitFieldNames ? '' : 'matchedMinor')
    ..aInt64(7, _omitFieldNames ? '' : 'netDepositsMinor')
    ..aInt64(8, _omitFieldNames ? '' : 'matchedBasisMinor')
    ..aInt64(9, _omitFieldNames ? '' : 'matchingAvailableMinor')
    ..aOS(10, _omitFieldNames ? '' : 'matchingStatus')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Goal clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Goal copyWith(void Function(Goal) updates) =>
      super.copyWith((message) => updates(message as Goal)) as Goal;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Goal() / Goal.new instead')
  static Goal create() => Goal._();
  static $pb.GeneratedMessage $_createMessage() => Goal._();
  @$core.override
  Goal createEmptyInstance() => Goal._();
  @$core.pragma('dart2js:noInline')
  static Goal getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Goal>(Goal.$_createMessage);
  static Goal? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get childId => $_getSZ(1);
  @$pb.TagNumber(2)
  set childId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasChildId() => $_has(1);
  @$pb.TagNumber(2)
  void clearChildId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get title => $_getSZ(2);
  @$pb.TagNumber(3)
  set title($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTitle() => $_has(2);
  @$pb.TagNumber(3)
  void clearTitle() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get targetMinor => $_getI64(3);
  @$pb.TagNumber(4)
  set targetMinor($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTargetMinor() => $_has(3);
  @$pb.TagNumber(4)
  void clearTargetMinor() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get savedMinor => $_getI64(4);
  @$pb.TagNumber(5)
  set savedMinor($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSavedMinor() => $_has(4);
  @$pb.TagNumber(5)
  void clearSavedMinor() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get matchedMinor => $_getI64(5);
  @$pb.TagNumber(6)
  set matchedMinor($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMatchedMinor() => $_has(5);
  @$pb.TagNumber(6)
  void clearMatchedMinor() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get netDepositsMinor => $_getI64(6);
  @$pb.TagNumber(7)
  set netDepositsMinor($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasNetDepositsMinor() => $_has(6);
  @$pb.TagNumber(7)
  void clearNetDepositsMinor() => $_clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get matchedBasisMinor => $_getI64(7);
  @$pb.TagNumber(8)
  set matchedBasisMinor($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasMatchedBasisMinor() => $_has(7);
  @$pb.TagNumber(8)
  void clearMatchedBasisMinor() => $_clearField(8);

  @$pb.TagNumber(9)
  $fixnum.Int64 get matchingAvailableMinor => $_getI64(8);
  @$pb.TagNumber(9)
  set matchingAvailableMinor($fixnum.Int64 value) => $_setInt64(8, value);
  @$pb.TagNumber(9)
  $core.bool hasMatchingAvailableMinor() => $_has(8);
  @$pb.TagNumber(9)
  void clearMatchingAvailableMinor() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get matchingStatus => $_getSZ(9);
  @$pb.TagNumber(10)
  set matchingStatus($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasMatchingStatus() => $_has(9);
  @$pb.TagNumber(10)
  void clearMatchingStatus() => $_clearField(10);
}

class FamilyTask extends $pb.GeneratedMessage {
  factory FamilyTask({
    $core.String? cancelReason,
    $core.String? id,
    $core.String? childId,
    $core.String? title,
    $fixnum.Int64? rewardMinor,
    $core.String? status,
    $core.bool? cancelRequested,
  }) {
    final result = FamilyTask._();
    if (cancelReason != null) result.cancelReason = cancelReason;
    if (id != null) result.id = id;
    if (childId != null) result.childId = childId;
    if (title != null) result.title = title;
    if (rewardMinor != null) result.rewardMinor = rewardMinor;
    if (status != null) result.status = status;
    if (cancelRequested != null) result.cancelRequested = cancelRequested;
    return result;
  }

  FamilyTask._();

  factory FamilyTask.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FamilyTask()..mergeFromBuffer(data, registry);
  factory FamilyTask.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FamilyTask()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FamilyTask',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'moby.family.v1'),
      createEmptyInstance: FamilyTask.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'cancelReason')
    ..aOS(2, _omitFieldNames ? '' : 'id')
    ..aOS(3, _omitFieldNames ? '' : 'childId')
    ..aOS(4, _omitFieldNames ? '' : 'title')
    ..aInt64(5, _omitFieldNames ? '' : 'rewardMinor')
    ..aOS(6, _omitFieldNames ? '' : 'status')
    ..aOB(7, _omitFieldNames ? '' : 'cancelRequested')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FamilyTask clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FamilyTask copyWith(void Function(FamilyTask) updates) =>
      super.copyWith((message) => updates(message as FamilyTask)) as FamilyTask;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use FamilyTask() / FamilyTask.new instead')
  static FamilyTask create() => FamilyTask._();
  static $pb.GeneratedMessage $_createMessage() => FamilyTask._();
  @$core.override
  FamilyTask createEmptyInstance() => FamilyTask._();
  @$core.pragma('dart2js:noInline')
  static FamilyTask getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FamilyTask>(FamilyTask.$_createMessage);
  static FamilyTask? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get cancelReason => $_getSZ(0);
  @$pb.TagNumber(1)
  set cancelReason($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCancelReason() => $_has(0);
  @$pb.TagNumber(1)
  void clearCancelReason() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get id => $_getSZ(1);
  @$pb.TagNumber(2)
  set id($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasId() => $_has(1);
  @$pb.TagNumber(2)
  void clearId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get childId => $_getSZ(2);
  @$pb.TagNumber(3)
  set childId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasChildId() => $_has(2);
  @$pb.TagNumber(3)
  void clearChildId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get title => $_getSZ(3);
  @$pb.TagNumber(4)
  set title($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTitle() => $_has(3);
  @$pb.TagNumber(4)
  void clearTitle() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get rewardMinor => $_getI64(4);
  @$pb.TagNumber(5)
  set rewardMinor($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRewardMinor() => $_has(4);
  @$pb.TagNumber(5)
  void clearRewardMinor() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get status => $_getSZ(5);
  @$pb.TagNumber(6)
  set status($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasStatus() => $_has(5);
  @$pb.TagNumber(6)
  void clearStatus() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get cancelRequested => $_getBF(6);
  @$pb.TagNumber(7)
  set cancelRequested($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasCancelRequested() => $_has(6);
  @$pb.TagNumber(7)
  void clearCancelRequested() => $_clearField(7);
}

class Errand extends $pb.GeneratedMessage {
  factory Errand({
    $core.String? cancelReason,
    $core.bool? rewardReserved,
    $core.bool? expenseRecorded,
    $core.String? id,
    $core.String? childId,
    $core.String? title,
    $fixnum.Int64? budgetMinor,
    $fixnum.Int64? rewardMinor,
    $fixnum.Int64? actualMinor,
    $fixnum.Int64? returnedMinor,
    $core.String? funding,
    $core.String? status,
    $core.bool? returnConfirmed,
    $core.bool? ownMoneyConsent,
    $core.bool? cancelRequested,
  }) {
    final result = Errand._();
    if (cancelReason != null) result.cancelReason = cancelReason;
    if (rewardReserved != null) result.rewardReserved = rewardReserved;
    if (expenseRecorded != null) result.expenseRecorded = expenseRecorded;
    if (id != null) result.id = id;
    if (childId != null) result.childId = childId;
    if (title != null) result.title = title;
    if (budgetMinor != null) result.budgetMinor = budgetMinor;
    if (rewardMinor != null) result.rewardMinor = rewardMinor;
    if (actualMinor != null) result.actualMinor = actualMinor;
    if (returnedMinor != null) result.returnedMinor = returnedMinor;
    if (funding != null) result.funding = funding;
    if (status != null) result.status = status;
    if (returnConfirmed != null) result.returnConfirmed = returnConfirmed;
    if (ownMoneyConsent != null) result.ownMoneyConsent = ownMoneyConsent;
    if (cancelRequested != null) result.cancelRequested = cancelRequested;
    return result;
  }

  Errand._();

  factory Errand.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Errand()..mergeFromBuffer(data, registry);
  factory Errand.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Errand()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Errand',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'moby.family.v1'),
      createEmptyInstance: Errand.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'cancelReason')
    ..aOB(2, _omitFieldNames ? '' : 'rewardReserved')
    ..aOB(3, _omitFieldNames ? '' : 'expenseRecorded')
    ..aOS(4, _omitFieldNames ? '' : 'id')
    ..aOS(5, _omitFieldNames ? '' : 'childId')
    ..aOS(6, _omitFieldNames ? '' : 'title')
    ..aInt64(7, _omitFieldNames ? '' : 'budgetMinor')
    ..aInt64(8, _omitFieldNames ? '' : 'rewardMinor')
    ..aInt64(9, _omitFieldNames ? '' : 'actualMinor')
    ..aInt64(10, _omitFieldNames ? '' : 'returnedMinor')
    ..aOS(11, _omitFieldNames ? '' : 'funding')
    ..aOS(12, _omitFieldNames ? '' : 'status')
    ..aOB(13, _omitFieldNames ? '' : 'returnConfirmed')
    ..aOB(14, _omitFieldNames ? '' : 'ownMoneyConsent')
    ..aOB(15, _omitFieldNames ? '' : 'cancelRequested')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Errand clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Errand copyWith(void Function(Errand) updates) =>
      super.copyWith((message) => updates(message as Errand)) as Errand;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Errand() / Errand.new instead')
  static Errand create() => Errand._();
  static $pb.GeneratedMessage $_createMessage() => Errand._();
  @$core.override
  Errand createEmptyInstance() => Errand._();
  @$core.pragma('dart2js:noInline')
  static Errand getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Errand>(Errand.$_createMessage);
  static Errand? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get cancelReason => $_getSZ(0);
  @$pb.TagNumber(1)
  set cancelReason($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCancelReason() => $_has(0);
  @$pb.TagNumber(1)
  void clearCancelReason() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get rewardReserved => $_getBF(1);
  @$pb.TagNumber(2)
  set rewardReserved($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRewardReserved() => $_has(1);
  @$pb.TagNumber(2)
  void clearRewardReserved() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get expenseRecorded => $_getBF(2);
  @$pb.TagNumber(3)
  set expenseRecorded($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasExpenseRecorded() => $_has(2);
  @$pb.TagNumber(3)
  void clearExpenseRecorded() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get id => $_getSZ(3);
  @$pb.TagNumber(4)
  set id($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasId() => $_has(3);
  @$pb.TagNumber(4)
  void clearId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get childId => $_getSZ(4);
  @$pb.TagNumber(5)
  set childId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasChildId() => $_has(4);
  @$pb.TagNumber(5)
  void clearChildId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get title => $_getSZ(5);
  @$pb.TagNumber(6)
  set title($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTitle() => $_has(5);
  @$pb.TagNumber(6)
  void clearTitle() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get budgetMinor => $_getI64(6);
  @$pb.TagNumber(7)
  set budgetMinor($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasBudgetMinor() => $_has(6);
  @$pb.TagNumber(7)
  void clearBudgetMinor() => $_clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get rewardMinor => $_getI64(7);
  @$pb.TagNumber(8)
  set rewardMinor($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasRewardMinor() => $_has(7);
  @$pb.TagNumber(8)
  void clearRewardMinor() => $_clearField(8);

  @$pb.TagNumber(9)
  $fixnum.Int64 get actualMinor => $_getI64(8);
  @$pb.TagNumber(9)
  set actualMinor($fixnum.Int64 value) => $_setInt64(8, value);
  @$pb.TagNumber(9)
  $core.bool hasActualMinor() => $_has(8);
  @$pb.TagNumber(9)
  void clearActualMinor() => $_clearField(9);

  @$pb.TagNumber(10)
  $fixnum.Int64 get returnedMinor => $_getI64(9);
  @$pb.TagNumber(10)
  set returnedMinor($fixnum.Int64 value) => $_setInt64(9, value);
  @$pb.TagNumber(10)
  $core.bool hasReturnedMinor() => $_has(9);
  @$pb.TagNumber(10)
  void clearReturnedMinor() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get funding => $_getSZ(10);
  @$pb.TagNumber(11)
  set funding($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasFunding() => $_has(10);
  @$pb.TagNumber(11)
  void clearFunding() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get status => $_getSZ(11);
  @$pb.TagNumber(12)
  set status($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasStatus() => $_has(11);
  @$pb.TagNumber(12)
  void clearStatus() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.bool get returnConfirmed => $_getBF(12);
  @$pb.TagNumber(13)
  set returnConfirmed($core.bool value) => $_setBool(12, value);
  @$pb.TagNumber(13)
  $core.bool hasReturnConfirmed() => $_has(12);
  @$pb.TagNumber(13)
  void clearReturnConfirmed() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.bool get ownMoneyConsent => $_getBF(13);
  @$pb.TagNumber(14)
  set ownMoneyConsent($core.bool value) => $_setBool(13, value);
  @$pb.TagNumber(14)
  $core.bool hasOwnMoneyConsent() => $_has(13);
  @$pb.TagNumber(14)
  void clearOwnMoneyConsent() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.bool get cancelRequested => $_getBF(14);
  @$pb.TagNumber(15)
  set cancelRequested($core.bool value) => $_setBool(14, value);
  @$pb.TagNumber(15)
  $core.bool hasCancelRequested() => $_has(14);
  @$pb.TagNumber(15)
  void clearCancelRequested() => $_clearField(15);
}

class Allowance extends $pb.GeneratedMessage {
  factory Allowance({
    $core.String? id,
    $core.String? childId,
    $core.String? title,
    $fixnum.Int64? amountMinor,
    $core.String? frequency,
    $core.Iterable<$core.int>? weekdays,
    $core.int? monthDay,
    $core.String? nextDate,
    $core.int? retryLimit,
    $core.bool? active,
  }) {
    final result = Allowance._();
    if (id != null) result.id = id;
    if (childId != null) result.childId = childId;
    if (title != null) result.title = title;
    if (amountMinor != null) result.amountMinor = amountMinor;
    if (frequency != null) result.frequency = frequency;
    if (weekdays != null) result.weekdays.addAll(weekdays);
    if (monthDay != null) result.monthDay = monthDay;
    if (nextDate != null) result.nextDate = nextDate;
    if (retryLimit != null) result.retryLimit = retryLimit;
    if (active != null) result.active = active;
    return result;
  }

  Allowance._();

  factory Allowance.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Allowance()..mergeFromBuffer(data, registry);
  factory Allowance.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Allowance()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Allowance',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'moby.family.v1'),
      createEmptyInstance: Allowance.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'childId')
    ..aOS(3, _omitFieldNames ? '' : 'title')
    ..aInt64(4, _omitFieldNames ? '' : 'amountMinor')
    ..aOS(5, _omitFieldNames ? '' : 'frequency')
    ..p<$core.int>(6, _omitFieldNames ? '' : 'weekdays', $pb.PbFieldType.K3)
    ..aI(7, _omitFieldNames ? '' : 'monthDay')
    ..aOS(8, _omitFieldNames ? '' : 'nextDate')
    ..aI(9, _omitFieldNames ? '' : 'retryLimit')
    ..aOB(10, _omitFieldNames ? '' : 'active')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Allowance clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Allowance copyWith(void Function(Allowance) updates) =>
      super.copyWith((message) => updates(message as Allowance)) as Allowance;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Allowance() / Allowance.new instead')
  static Allowance create() => Allowance._();
  static $pb.GeneratedMessage $_createMessage() => Allowance._();
  @$core.override
  Allowance createEmptyInstance() => Allowance._();
  @$core.pragma('dart2js:noInline')
  static Allowance getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Allowance>(Allowance.$_createMessage);
  static Allowance? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get childId => $_getSZ(1);
  @$pb.TagNumber(2)
  set childId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasChildId() => $_has(1);
  @$pb.TagNumber(2)
  void clearChildId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get title => $_getSZ(2);
  @$pb.TagNumber(3)
  set title($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTitle() => $_has(2);
  @$pb.TagNumber(3)
  void clearTitle() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get amountMinor => $_getI64(3);
  @$pb.TagNumber(4)
  set amountMinor($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAmountMinor() => $_has(3);
  @$pb.TagNumber(4)
  void clearAmountMinor() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get frequency => $_getSZ(4);
  @$pb.TagNumber(5)
  set frequency($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFrequency() => $_has(4);
  @$pb.TagNumber(5)
  void clearFrequency() => $_clearField(5);

  @$pb.TagNumber(6)
  $pb.PbList<$core.int> get weekdays => $_getList(5);

  @$pb.TagNumber(7)
  $core.int get monthDay => $_getIZ(6);
  @$pb.TagNumber(7)
  set monthDay($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasMonthDay() => $_has(6);
  @$pb.TagNumber(7)
  void clearMonthDay() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get nextDate => $_getSZ(7);
  @$pb.TagNumber(8)
  set nextDate($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasNextDate() => $_has(7);
  @$pb.TagNumber(8)
  void clearNextDate() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get retryLimit => $_getIZ(8);
  @$pb.TagNumber(9)
  set retryLimit($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasRetryLimit() => $_has(8);
  @$pb.TagNumber(9)
  void clearRetryLimit() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.bool get active => $_getBF(9);
  @$pb.TagNumber(10)
  set active($core.bool value) => $_setBool(9, value);
  @$pb.TagNumber(10)
  $core.bool hasActive() => $_has(9);
  @$pb.TagNumber(10)
  void clearActive() => $_clearField(10);
}

class Installment extends $pb.GeneratedMessage {
  factory Installment({
    $core.int? retryLimit,
    $core.String? id,
    $core.String? childId,
    $core.String? allowanceId,
    $core.String? dueDate,
    $fixnum.Int64? amountMinor,
    $core.String? status,
    $core.int? attempts,
    $core.String? lastAttemptDate,
  }) {
    final result = Installment._();
    if (retryLimit != null) result.retryLimit = retryLimit;
    if (id != null) result.id = id;
    if (childId != null) result.childId = childId;
    if (allowanceId != null) result.allowanceId = allowanceId;
    if (dueDate != null) result.dueDate = dueDate;
    if (amountMinor != null) result.amountMinor = amountMinor;
    if (status != null) result.status = status;
    if (attempts != null) result.attempts = attempts;
    if (lastAttemptDate != null) result.lastAttemptDate = lastAttemptDate;
    return result;
  }

  Installment._();

  factory Installment.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Installment()..mergeFromBuffer(data, registry);
  factory Installment.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Installment()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Installment',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'moby.family.v1'),
      createEmptyInstance: Installment.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'retryLimit')
    ..aOS(2, _omitFieldNames ? '' : 'id')
    ..aOS(3, _omitFieldNames ? '' : 'childId')
    ..aOS(4, _omitFieldNames ? '' : 'allowanceId')
    ..aOS(5, _omitFieldNames ? '' : 'dueDate')
    ..aInt64(6, _omitFieldNames ? '' : 'amountMinor')
    ..aOS(7, _omitFieldNames ? '' : 'status')
    ..aI(8, _omitFieldNames ? '' : 'attempts')
    ..aOS(9, _omitFieldNames ? '' : 'lastAttemptDate')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Installment clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Installment copyWith(void Function(Installment) updates) =>
      super.copyWith((message) => updates(message as Installment))
          as Installment;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Installment() / Installment.new instead')
  static Installment create() => Installment._();
  static $pb.GeneratedMessage $_createMessage() => Installment._();
  @$core.override
  Installment createEmptyInstance() => Installment._();
  @$core.pragma('dart2js:noInline')
  static Installment getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Installment>(
          Installment.$_createMessage);
  static Installment? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get retryLimit => $_getIZ(0);
  @$pb.TagNumber(1)
  set retryLimit($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRetryLimit() => $_has(0);
  @$pb.TagNumber(1)
  void clearRetryLimit() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get id => $_getSZ(1);
  @$pb.TagNumber(2)
  set id($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasId() => $_has(1);
  @$pb.TagNumber(2)
  void clearId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get childId => $_getSZ(2);
  @$pb.TagNumber(3)
  set childId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasChildId() => $_has(2);
  @$pb.TagNumber(3)
  void clearChildId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get allowanceId => $_getSZ(3);
  @$pb.TagNumber(4)
  set allowanceId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAllowanceId() => $_has(3);
  @$pb.TagNumber(4)
  void clearAllowanceId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get dueDate => $_getSZ(4);
  @$pb.TagNumber(5)
  set dueDate($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDueDate() => $_has(4);
  @$pb.TagNumber(5)
  void clearDueDate() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get amountMinor => $_getI64(5);
  @$pb.TagNumber(6)
  set amountMinor($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasAmountMinor() => $_has(5);
  @$pb.TagNumber(6)
  void clearAmountMinor() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get status => $_getSZ(6);
  @$pb.TagNumber(7)
  set status($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasStatus() => $_has(6);
  @$pb.TagNumber(7)
  void clearStatus() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get attempts => $_getIZ(7);
  @$pb.TagNumber(8)
  set attempts($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasAttempts() => $_has(7);
  @$pb.TagNumber(8)
  void clearAttempts() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get lastAttemptDate => $_getSZ(8);
  @$pb.TagNumber(9)
  set lastAttemptDate($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasLastAttemptDate() => $_has(8);
  @$pb.TagNumber(9)
  void clearLastAttemptDate() => $_clearField(9);
}

class SpaceSettings extends $pb.GeneratedMessage {
  factory SpaceSettings({
    $core.bool? matchingEnabled,
    $fixnum.Int64? matchingPercent,
    $fixnum.Int64? matchingCapMinor,
    $core.bool? notifications,
    $core.bool? tasksEnabled,
    $core.bool? errandsEnabled,
    $core.bool? learningEnabled,
  }) {
    final result = SpaceSettings._();
    if (matchingEnabled != null) result.matchingEnabled = matchingEnabled;
    if (matchingPercent != null) result.matchingPercent = matchingPercent;
    if (matchingCapMinor != null) result.matchingCapMinor = matchingCapMinor;
    if (notifications != null) result.notifications = notifications;
    if (tasksEnabled != null) result.tasksEnabled = tasksEnabled;
    if (errandsEnabled != null) result.errandsEnabled = errandsEnabled;
    if (learningEnabled != null) result.learningEnabled = learningEnabled;
    return result;
  }

  SpaceSettings._();

  factory SpaceSettings.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SpaceSettings()..mergeFromBuffer(data, registry);
  factory SpaceSettings.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SpaceSettings()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SpaceSettings',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'moby.family.v1'),
      createEmptyInstance: SpaceSettings.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'matchingEnabled')
    ..aInt64(2, _omitFieldNames ? '' : 'matchingPercent')
    ..aInt64(3, _omitFieldNames ? '' : 'matchingCapMinor')
    ..aOB(4, _omitFieldNames ? '' : 'notifications')
    ..aOB(5, _omitFieldNames ? '' : 'tasksEnabled')
    ..aOB(6, _omitFieldNames ? '' : 'errandsEnabled')
    ..aOB(7, _omitFieldNames ? '' : 'learningEnabled')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceSettings clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceSettings copyWith(void Function(SpaceSettings) updates) =>
      super.copyWith((message) => updates(message as SpaceSettings))
          as SpaceSettings;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SpaceSettings() / SpaceSettings.new instead')
  static SpaceSettings create() => SpaceSettings._();
  static $pb.GeneratedMessage $_createMessage() => SpaceSettings._();
  @$core.override
  SpaceSettings createEmptyInstance() => SpaceSettings._();
  @$core.pragma('dart2js:noInline')
  static SpaceSettings getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SpaceSettings>(
          SpaceSettings.$_createMessage);
  static SpaceSettings? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get matchingEnabled => $_getBF(0);
  @$pb.TagNumber(1)
  set matchingEnabled($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMatchingEnabled() => $_has(0);
  @$pb.TagNumber(1)
  void clearMatchingEnabled() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get matchingPercent => $_getI64(1);
  @$pb.TagNumber(2)
  set matchingPercent($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMatchingPercent() => $_has(1);
  @$pb.TagNumber(2)
  void clearMatchingPercent() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get matchingCapMinor => $_getI64(2);
  @$pb.TagNumber(3)
  set matchingCapMinor($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMatchingCapMinor() => $_has(2);
  @$pb.TagNumber(3)
  void clearMatchingCapMinor() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get notifications => $_getBF(3);
  @$pb.TagNumber(4)
  set notifications($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasNotifications() => $_has(3);
  @$pb.TagNumber(4)
  void clearNotifications() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get tasksEnabled => $_getBF(4);
  @$pb.TagNumber(5)
  set tasksEnabled($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTasksEnabled() => $_has(4);
  @$pb.TagNumber(5)
  void clearTasksEnabled() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get errandsEnabled => $_getBF(5);
  @$pb.TagNumber(6)
  set errandsEnabled($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasErrandsEnabled() => $_has(5);
  @$pb.TagNumber(6)
  void clearErrandsEnabled() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get learningEnabled => $_getBF(6);
  @$pb.TagNumber(7)
  set learningEnabled($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasLearningEnabled() => $_has(6);
  @$pb.TagNumber(7)
  void clearLearningEnabled() => $_clearField(7);
}

class FamilyRequest extends $pb.GeneratedMessage {
  factory FamilyRequest({
    $fixnum.Int64? amountMinor,
    $core.String? id,
    $core.String? childId,
    $core.String? kind,
    $core.String? title,
    Policy? policy,
    $core.String? status,
  }) {
    final result = FamilyRequest._();
    if (amountMinor != null) result.amountMinor = amountMinor;
    if (id != null) result.id = id;
    if (childId != null) result.childId = childId;
    if (kind != null) result.kind = kind;
    if (title != null) result.title = title;
    if (policy != null) result.policy = policy;
    if (status != null) result.status = status;
    return result;
  }

  FamilyRequest._();

  factory FamilyRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FamilyRequest()..mergeFromBuffer(data, registry);
  factory FamilyRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FamilyRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FamilyRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'moby.family.v1'),
      createEmptyInstance: FamilyRequest.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'amountMinor')
    ..aOS(2, _omitFieldNames ? '' : 'id')
    ..aOS(3, _omitFieldNames ? '' : 'childId')
    ..aOS(4, _omitFieldNames ? '' : 'kind')
    ..aOS(5, _omitFieldNames ? '' : 'title')
    ..aOM<Policy>(6, _omitFieldNames ? '' : 'policy',
        subBuilder: Policy.$_createMessage)
    ..aOS(7, _omitFieldNames ? '' : 'status')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FamilyRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FamilyRequest copyWith(void Function(FamilyRequest) updates) =>
      super.copyWith((message) => updates(message as FamilyRequest))
          as FamilyRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use FamilyRequest() / FamilyRequest.new instead')
  static FamilyRequest create() => FamilyRequest._();
  static $pb.GeneratedMessage $_createMessage() => FamilyRequest._();
  @$core.override
  FamilyRequest createEmptyInstance() => FamilyRequest._();
  @$core.pragma('dart2js:noInline')
  static FamilyRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FamilyRequest>(
          FamilyRequest.$_createMessage);
  static FamilyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get amountMinor => $_getI64(0);
  @$pb.TagNumber(1)
  set amountMinor($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAmountMinor() => $_has(0);
  @$pb.TagNumber(1)
  void clearAmountMinor() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get id => $_getSZ(1);
  @$pb.TagNumber(2)
  set id($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasId() => $_has(1);
  @$pb.TagNumber(2)
  void clearId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get childId => $_getSZ(2);
  @$pb.TagNumber(3)
  set childId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasChildId() => $_has(2);
  @$pb.TagNumber(3)
  void clearChildId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get kind => $_getSZ(3);
  @$pb.TagNumber(4)
  set kind($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasKind() => $_has(3);
  @$pb.TagNumber(4)
  void clearKind() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get title => $_getSZ(4);
  @$pb.TagNumber(5)
  set title($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTitle() => $_has(4);
  @$pb.TagNumber(5)
  void clearTitle() => $_clearField(5);

  @$pb.TagNumber(6)
  Policy get policy => $_getN(5);
  @$pb.TagNumber(6)
  set policy(Policy value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasPolicy() => $_has(5);
  @$pb.TagNumber(6)
  void clearPolicy() => $_clearField(6);
  @$pb.TagNumber(6)
  Policy ensurePolicy() => $_ensure(5);

  @$pb.TagNumber(7)
  $core.String get status => $_getSZ(6);
  @$pb.TagNumber(7)
  set status($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasStatus() => $_has(6);
  @$pb.TagNumber(7)
  void clearStatus() => $_clearField(7);
}

class Lesson extends $pb.GeneratedMessage {
  factory Lesson({
    $core.String? question,
    $core.Iterable<$core.String>? options,
    $core.String? id,
    $core.String? title,
    $core.String? body,
    $core.String? skill,
  }) {
    final result = Lesson._();
    if (question != null) result.question = question;
    if (options != null) result.options.addAll(options);
    if (id != null) result.id = id;
    if (title != null) result.title = title;
    if (body != null) result.body = body;
    if (skill != null) result.skill = skill;
    return result;
  }

  Lesson._();

  factory Lesson.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Lesson()..mergeFromBuffer(data, registry);
  factory Lesson.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Lesson()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Lesson',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'moby.family.v1'),
      createEmptyInstance: Lesson.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'question')
    ..pPS(2, _omitFieldNames ? '' : 'options')
    ..aOS(3, _omitFieldNames ? '' : 'id')
    ..aOS(4, _omitFieldNames ? '' : 'title')
    ..aOS(5, _omitFieldNames ? '' : 'body')
    ..aOS(6, _omitFieldNames ? '' : 'skill')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Lesson clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Lesson copyWith(void Function(Lesson) updates) =>
      super.copyWith((message) => updates(message as Lesson)) as Lesson;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Lesson() / Lesson.new instead')
  static Lesson create() => Lesson._();
  static $pb.GeneratedMessage $_createMessage() => Lesson._();
  @$core.override
  Lesson createEmptyInstance() => Lesson._();
  @$core.pragma('dart2js:noInline')
  static Lesson getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Lesson>(Lesson.$_createMessage);
  static Lesson? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get question => $_getSZ(0);
  @$pb.TagNumber(1)
  set question($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasQuestion() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuestion() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get options => $_getList(1);

  @$pb.TagNumber(3)
  $core.String get id => $_getSZ(2);
  @$pb.TagNumber(3)
  set id($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasId() => $_has(2);
  @$pb.TagNumber(3)
  void clearId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get title => $_getSZ(3);
  @$pb.TagNumber(4)
  set title($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTitle() => $_has(3);
  @$pb.TagNumber(4)
  void clearTitle() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get body => $_getSZ(4);
  @$pb.TagNumber(5)
  set body($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasBody() => $_has(4);
  @$pb.TagNumber(5)
  void clearBody() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get skill => $_getSZ(5);
  @$pb.TagNumber(6)
  set skill($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSkill() => $_has(5);
  @$pb.TagNumber(6)
  void clearSkill() => $_clearField(6);
}

class LessonCompletion extends $pb.GeneratedMessage {
  factory LessonCompletion({
    $core.String? childId,
    $core.String? lessonId,
    $fixnum.Int64? completedAt,
  }) {
    final result = LessonCompletion._();
    if (childId != null) result.childId = childId;
    if (lessonId != null) result.lessonId = lessonId;
    if (completedAt != null) result.completedAt = completedAt;
    return result;
  }

  LessonCompletion._();

  factory LessonCompletion.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LessonCompletion()..mergeFromBuffer(data, registry);
  factory LessonCompletion.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LessonCompletion()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LessonCompletion',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'moby.family.v1'),
      createEmptyInstance: LessonCompletion.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'childId')
    ..aOS(2, _omitFieldNames ? '' : 'lessonId')
    ..aInt64(3, _omitFieldNames ? '' : 'completedAt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LessonCompletion clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LessonCompletion copyWith(void Function(LessonCompletion) updates) =>
      super.copyWith((message) => updates(message as LessonCompletion))
          as LessonCompletion;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use LessonCompletion() / LessonCompletion.new instead')
  static LessonCompletion create() => LessonCompletion._();
  static $pb.GeneratedMessage $_createMessage() => LessonCompletion._();
  @$core.override
  LessonCompletion createEmptyInstance() => LessonCompletion._();
  @$core.pragma('dart2js:noInline')
  static LessonCompletion getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LessonCompletion>(
          LessonCompletion.$_createMessage);
  static LessonCompletion? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get childId => $_getSZ(0);
  @$pb.TagNumber(1)
  set childId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChildId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChildId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get lessonId => $_getSZ(1);
  @$pb.TagNumber(2)
  set lessonId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLessonId() => $_has(1);
  @$pb.TagNumber(2)
  void clearLessonId() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get completedAt => $_getI64(2);
  @$pb.TagNumber(3)
  set completedAt($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCompletedAt() => $_has(2);
  @$pb.TagNumber(3)
  void clearCompletedAt() => $_clearField(3);
}

class SpaceEntry extends $pb.GeneratedMessage {
  factory SpaceEntry({
    $core.String? id,
    $core.String? childId,
    $core.String? kind,
    $fixnum.Int64? amountMinor,
    $fixnum.Int64? at,
    $core.String? entityId,
  }) {
    final result = SpaceEntry._();
    if (id != null) result.id = id;
    if (childId != null) result.childId = childId;
    if (kind != null) result.kind = kind;
    if (amountMinor != null) result.amountMinor = amountMinor;
    if (at != null) result.at = at;
    if (entityId != null) result.entityId = entityId;
    return result;
  }

  SpaceEntry._();

  factory SpaceEntry.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SpaceEntry()..mergeFromBuffer(data, registry);
  factory SpaceEntry.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SpaceEntry()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SpaceEntry',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'moby.family.v1'),
      createEmptyInstance: SpaceEntry.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'childId')
    ..aOS(3, _omitFieldNames ? '' : 'kind')
    ..aInt64(4, _omitFieldNames ? '' : 'amountMinor')
    ..aInt64(5, _omitFieldNames ? '' : 'at')
    ..aOS(6, _omitFieldNames ? '' : 'entityId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceEntry clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceEntry copyWith(void Function(SpaceEntry) updates) =>
      super.copyWith((message) => updates(message as SpaceEntry)) as SpaceEntry;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SpaceEntry() / SpaceEntry.new instead')
  static SpaceEntry create() => SpaceEntry._();
  static $pb.GeneratedMessage $_createMessage() => SpaceEntry._();
  @$core.override
  SpaceEntry createEmptyInstance() => SpaceEntry._();
  @$core.pragma('dart2js:noInline')
  static SpaceEntry getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SpaceEntry>(SpaceEntry.$_createMessage);
  static SpaceEntry? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get childId => $_getSZ(1);
  @$pb.TagNumber(2)
  set childId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasChildId() => $_has(1);
  @$pb.TagNumber(2)
  void clearChildId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get kind => $_getSZ(2);
  @$pb.TagNumber(3)
  set kind($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasKind() => $_has(2);
  @$pb.TagNumber(3)
  void clearKind() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get amountMinor => $_getI64(3);
  @$pb.TagNumber(4)
  set amountMinor($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAmountMinor() => $_has(3);
  @$pb.TagNumber(4)
  void clearAmountMinor() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get at => $_getI64(4);
  @$pb.TagNumber(5)
  set at($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearAt() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get entityId => $_getSZ(5);
  @$pb.TagNumber(6)
  set entityId($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasEntityId() => $_has(5);
  @$pb.TagNumber(6)
  void clearEntityId() => $_clearField(6);
}

class WeeklyOverview extends $pb.GeneratedMessage {
  factory WeeklyOverview({
    $core.String? childId,
    $core.String? since,
    $fixnum.Int64? incomingMinor,
    $fixnum.Int64? spentMinor,
    $fixnum.Int64? savedMinor,
    $core.int? tasksCompleted,
    $core.int? lessonsCompleted,
  }) {
    final result = WeeklyOverview._();
    if (childId != null) result.childId = childId;
    if (since != null) result.since = since;
    if (incomingMinor != null) result.incomingMinor = incomingMinor;
    if (spentMinor != null) result.spentMinor = spentMinor;
    if (savedMinor != null) result.savedMinor = savedMinor;
    if (tasksCompleted != null) result.tasksCompleted = tasksCompleted;
    if (lessonsCompleted != null) result.lessonsCompleted = lessonsCompleted;
    return result;
  }

  WeeklyOverview._();

  factory WeeklyOverview.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WeeklyOverview()..mergeFromBuffer(data, registry);
  factory WeeklyOverview.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WeeklyOverview()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WeeklyOverview',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'moby.family.v1'),
      createEmptyInstance: WeeklyOverview.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'childId')
    ..aOS(2, _omitFieldNames ? '' : 'since')
    ..aInt64(3, _omitFieldNames ? '' : 'incomingMinor')
    ..aInt64(4, _omitFieldNames ? '' : 'spentMinor')
    ..aInt64(5, _omitFieldNames ? '' : 'savedMinor')
    ..aI(6, _omitFieldNames ? '' : 'tasksCompleted')
    ..aI(7, _omitFieldNames ? '' : 'lessonsCompleted')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WeeklyOverview clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WeeklyOverview copyWith(void Function(WeeklyOverview) updates) =>
      super.copyWith((message) => updates(message as WeeklyOverview))
          as WeeklyOverview;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WeeklyOverview() / WeeklyOverview.new instead')
  static WeeklyOverview create() => WeeklyOverview._();
  static $pb.GeneratedMessage $_createMessage() => WeeklyOverview._();
  @$core.override
  WeeklyOverview createEmptyInstance() => WeeklyOverview._();
  @$core.pragma('dart2js:noInline')
  static WeeklyOverview getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WeeklyOverview>(
          WeeklyOverview.$_createMessage);
  static WeeklyOverview? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get childId => $_getSZ(0);
  @$pb.TagNumber(1)
  set childId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChildId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChildId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get since => $_getSZ(1);
  @$pb.TagNumber(2)
  set since($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSince() => $_has(1);
  @$pb.TagNumber(2)
  void clearSince() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get incomingMinor => $_getI64(2);
  @$pb.TagNumber(3)
  set incomingMinor($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIncomingMinor() => $_has(2);
  @$pb.TagNumber(3)
  void clearIncomingMinor() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get spentMinor => $_getI64(3);
  @$pb.TagNumber(4)
  set spentMinor($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSpentMinor() => $_has(3);
  @$pb.TagNumber(4)
  void clearSpentMinor() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get savedMinor => $_getI64(4);
  @$pb.TagNumber(5)
  set savedMinor($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSavedMinor() => $_has(4);
  @$pb.TagNumber(5)
  void clearSavedMinor() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get tasksCompleted => $_getIZ(5);
  @$pb.TagNumber(6)
  set tasksCompleted($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTasksCompleted() => $_has(5);
  @$pb.TagNumber(6)
  void clearTasksCompleted() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get lessonsCompleted => $_getIZ(6);
  @$pb.TagNumber(7)
  set lessonsCompleted($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasLessonsCompleted() => $_has(6);
  @$pb.TagNumber(7)
  void clearLessonsCompleted() => $_clearField(7);
}

class FamilyCapabilities extends $pb.GeneratedMessage {
  factory FamilyCapabilities({
    $core.bool? synthetic,
    $core.String? currency,
    $core.String? timeZone,
    $fixnum.Int64? maxAmountMinor,
    $core.String? matchingCapPeriod,
    $core.bool? lessonsGrantPermissions,
  }) {
    final result = FamilyCapabilities._();
    if (synthetic != null) result.synthetic = synthetic;
    if (currency != null) result.currency = currency;
    if (timeZone != null) result.timeZone = timeZone;
    if (maxAmountMinor != null) result.maxAmountMinor = maxAmountMinor;
    if (matchingCapPeriod != null) result.matchingCapPeriod = matchingCapPeriod;
    if (lessonsGrantPermissions != null)
      result.lessonsGrantPermissions = lessonsGrantPermissions;
    return result;
  }

  FamilyCapabilities._();

  factory FamilyCapabilities.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FamilyCapabilities()..mergeFromBuffer(data, registry);
  factory FamilyCapabilities.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FamilyCapabilities()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FamilyCapabilities',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'moby.family.v1'),
      createEmptyInstance: FamilyCapabilities.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'synthetic')
    ..aOS(2, _omitFieldNames ? '' : 'currency')
    ..aOS(3, _omitFieldNames ? '' : 'timeZone')
    ..aInt64(4, _omitFieldNames ? '' : 'maxAmountMinor')
    ..aOS(5, _omitFieldNames ? '' : 'matchingCapPeriod')
    ..aOB(6, _omitFieldNames ? '' : 'lessonsGrantPermissions')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FamilyCapabilities clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FamilyCapabilities copyWith(void Function(FamilyCapabilities) updates) =>
      super.copyWith((message) => updates(message as FamilyCapabilities))
          as FamilyCapabilities;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use FamilyCapabilities() / FamilyCapabilities.new instead')
  static FamilyCapabilities create() => FamilyCapabilities._();
  static $pb.GeneratedMessage $_createMessage() => FamilyCapabilities._();
  @$core.override
  FamilyCapabilities createEmptyInstance() => FamilyCapabilities._();
  @$core.pragma('dart2js:noInline')
  static FamilyCapabilities getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FamilyCapabilities>(
          FamilyCapabilities.$_createMessage);
  static FamilyCapabilities? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get synthetic => $_getBF(0);
  @$pb.TagNumber(1)
  set synthetic($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSynthetic() => $_has(0);
  @$pb.TagNumber(1)
  void clearSynthetic() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get currency => $_getSZ(1);
  @$pb.TagNumber(2)
  set currency($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCurrency() => $_has(1);
  @$pb.TagNumber(2)
  void clearCurrency() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get timeZone => $_getSZ(2);
  @$pb.TagNumber(3)
  set timeZone($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTimeZone() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimeZone() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get maxAmountMinor => $_getI64(3);
  @$pb.TagNumber(4)
  set maxAmountMinor($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMaxAmountMinor() => $_has(3);
  @$pb.TagNumber(4)
  void clearMaxAmountMinor() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get matchingCapPeriod => $_getSZ(4);
  @$pb.TagNumber(5)
  set matchingCapPeriod($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMatchingCapPeriod() => $_has(4);
  @$pb.TagNumber(5)
  void clearMatchingCapPeriod() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get lessonsGrantPermissions => $_getBF(5);
  @$pb.TagNumber(6)
  set lessonsGrantPermissions($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasLessonsGrantPermissions() => $_has(5);
  @$pb.TagNumber(6)
  void clearLessonsGrantPermissions() => $_clearField(6);
}

class SpaceNotice extends $pb.GeneratedMessage {
  factory SpaceNotice({
    $core.String? id,
    $core.String? childId,
    $core.String? recipient,
    $core.String? title,
    $core.String? body,
    $core.String? kind,
    $fixnum.Int64? createdAt,
    $core.bool? read,
    $core.bool? mandatory,
  }) {
    final result = SpaceNotice._();
    if (id != null) result.id = id;
    if (childId != null) result.childId = childId;
    if (recipient != null) result.recipient = recipient;
    if (title != null) result.title = title;
    if (body != null) result.body = body;
    if (kind != null) result.kind = kind;
    if (createdAt != null) result.createdAt = createdAt;
    if (read != null) result.read = read;
    if (mandatory != null) result.mandatory = mandatory;
    return result;
  }

  SpaceNotice._();

  factory SpaceNotice.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SpaceNotice()..mergeFromBuffer(data, registry);
  factory SpaceNotice.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SpaceNotice()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SpaceNotice',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'moby.family.v1'),
      createEmptyInstance: SpaceNotice.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'childId')
    ..aOS(3, _omitFieldNames ? '' : 'recipient')
    ..aOS(4, _omitFieldNames ? '' : 'title')
    ..aOS(5, _omitFieldNames ? '' : 'body')
    ..aOS(6, _omitFieldNames ? '' : 'kind')
    ..aInt64(7, _omitFieldNames ? '' : 'createdAt')
    ..aOB(8, _omitFieldNames ? '' : 'read')
    ..aOB(9, _omitFieldNames ? '' : 'mandatory')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceNotice clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceNotice copyWith(void Function(SpaceNotice) updates) =>
      super.copyWith((message) => updates(message as SpaceNotice))
          as SpaceNotice;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SpaceNotice() / SpaceNotice.new instead')
  static SpaceNotice create() => SpaceNotice._();
  static $pb.GeneratedMessage $_createMessage() => SpaceNotice._();
  @$core.override
  SpaceNotice createEmptyInstance() => SpaceNotice._();
  @$core.pragma('dart2js:noInline')
  static SpaceNotice getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SpaceNotice>(
          SpaceNotice.$_createMessage);
  static SpaceNotice? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get childId => $_getSZ(1);
  @$pb.TagNumber(2)
  set childId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasChildId() => $_has(1);
  @$pb.TagNumber(2)
  void clearChildId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get recipient => $_getSZ(2);
  @$pb.TagNumber(3)
  set recipient($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRecipient() => $_has(2);
  @$pb.TagNumber(3)
  void clearRecipient() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get title => $_getSZ(3);
  @$pb.TagNumber(4)
  set title($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTitle() => $_has(3);
  @$pb.TagNumber(4)
  void clearTitle() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get body => $_getSZ(4);
  @$pb.TagNumber(5)
  set body($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasBody() => $_has(4);
  @$pb.TagNumber(5)
  void clearBody() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get kind => $_getSZ(5);
  @$pb.TagNumber(6)
  set kind($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasKind() => $_has(5);
  @$pb.TagNumber(6)
  void clearKind() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get createdAt => $_getI64(6);
  @$pb.TagNumber(7)
  set createdAt($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasCreatedAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearCreatedAt() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.bool get read => $_getBF(7);
  @$pb.TagNumber(8)
  set read($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasRead() => $_has(7);
  @$pb.TagNumber(8)
  void clearRead() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.bool get mandatory => $_getBF(8);
  @$pb.TagNumber(9)
  set mandatory($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasMandatory() => $_has(8);
  @$pb.TagNumber(9)
  void clearMandatory() => $_clearField(9);
}

class FamilySpaceSnapshot extends $pb.GeneratedMessage {
  factory FamilySpaceSnapshot({
    $core.Iterable<SpaceEntry>? activity,
    $core.Iterable<SpaceNotice>? notices,
    FamilyCapabilities? capabilities,
    Wallet? adultWallet,
    $core.Iterable<Goal>? goals,
    $core.Iterable<FamilyTask>? tasks,
    $core.Iterable<Errand>? errands,
    $core.Iterable<Allowance>? allowances,
    $core.Iterable<Installment>? installments,
    $core.Iterable<FamilyRequest>? requests,
    $core.Iterable<$core.MapEntry<$core.String, SpaceSettings>>? settings,
    $core.Iterable<LessonCompletion>? learning,
    $core.Iterable<Lesson>? lessons,
    $core.Iterable<WeeklyOverview>? weekly,
  }) {
    final result = FamilySpaceSnapshot._();
    if (activity != null) result.activity.addAll(activity);
    if (notices != null) result.notices.addAll(notices);
    if (capabilities != null) result.capabilities = capabilities;
    if (adultWallet != null) result.adultWallet = adultWallet;
    if (goals != null) result.goals.addAll(goals);
    if (tasks != null) result.tasks.addAll(tasks);
    if (errands != null) result.errands.addAll(errands);
    if (allowances != null) result.allowances.addAll(allowances);
    if (installments != null) result.installments.addAll(installments);
    if (requests != null) result.requests.addAll(requests);
    if (settings != null) result.settings.addEntries(settings);
    if (learning != null) result.learning.addAll(learning);
    if (lessons != null) result.lessons.addAll(lessons);
    if (weekly != null) result.weekly.addAll(weekly);
    return result;
  }

  FamilySpaceSnapshot._();

  factory FamilySpaceSnapshot.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FamilySpaceSnapshot()..mergeFromBuffer(data, registry);
  factory FamilySpaceSnapshot.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FamilySpaceSnapshot()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FamilySpaceSnapshot',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'moby.family.v1'),
      createEmptyInstance: FamilySpaceSnapshot.$_createMessage)
    ..pPM<SpaceEntry>(1, _omitFieldNames ? '' : 'activity',
        subBuilder: SpaceEntry.$_createMessage)
    ..pPM<SpaceNotice>(2, _omitFieldNames ? '' : 'notices',
        subBuilder: SpaceNotice.$_createMessage)
    ..aOM<FamilyCapabilities>(3, _omitFieldNames ? '' : 'capabilities',
        subBuilder: FamilyCapabilities.$_createMessage)
    ..aOM<Wallet>(4, _omitFieldNames ? '' : 'adultWallet',
        subBuilder: Wallet.$_createMessage)
    ..pPM<Goal>(5, _omitFieldNames ? '' : 'goals',
        subBuilder: Goal.$_createMessage)
    ..pPM<FamilyTask>(6, _omitFieldNames ? '' : 'tasks',
        subBuilder: FamilyTask.$_createMessage)
    ..pPM<Errand>(7, _omitFieldNames ? '' : 'errands',
        subBuilder: Errand.$_createMessage)
    ..pPM<Allowance>(8, _omitFieldNames ? '' : 'allowances',
        subBuilder: Allowance.$_createMessage)
    ..pPM<Installment>(9, _omitFieldNames ? '' : 'installments',
        subBuilder: Installment.$_createMessage)
    ..pPM<FamilyRequest>(10, _omitFieldNames ? '' : 'requests',
        subBuilder: FamilyRequest.$_createMessage)
    ..m<$core.String, SpaceSettings>(11, _omitFieldNames ? '' : 'settings',
        entryClassName: 'FamilySpaceSnapshot.SettingsEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: SpaceSettings.$_createMessage,
        valueDefaultOrMaker: SpaceSettings.getDefault,
        packageName: const $pb.PackageName('moby.family.v1'))
    ..pPM<LessonCompletion>(12, _omitFieldNames ? '' : 'learning',
        subBuilder: LessonCompletion.$_createMessage)
    ..pPM<Lesson>(13, _omitFieldNames ? '' : 'lessons',
        subBuilder: Lesson.$_createMessage)
    ..pPM<WeeklyOverview>(14, _omitFieldNames ? '' : 'weekly',
        subBuilder: WeeklyOverview.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FamilySpaceSnapshot clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FamilySpaceSnapshot copyWith(void Function(FamilySpaceSnapshot) updates) =>
      super.copyWith((message) => updates(message as FamilySpaceSnapshot))
          as FamilySpaceSnapshot;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use FamilySpaceSnapshot() / FamilySpaceSnapshot.new instead')
  static FamilySpaceSnapshot create() => FamilySpaceSnapshot._();
  static $pb.GeneratedMessage $_createMessage() => FamilySpaceSnapshot._();
  @$core.override
  FamilySpaceSnapshot createEmptyInstance() => FamilySpaceSnapshot._();
  @$core.pragma('dart2js:noInline')
  static FamilySpaceSnapshot getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FamilySpaceSnapshot>(
          FamilySpaceSnapshot.$_createMessage);
  static FamilySpaceSnapshot? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<SpaceEntry> get activity => $_getList(0);

  @$pb.TagNumber(2)
  $pb.PbList<SpaceNotice> get notices => $_getList(1);

  @$pb.TagNumber(3)
  FamilyCapabilities get capabilities => $_getN(2);
  @$pb.TagNumber(3)
  set capabilities(FamilyCapabilities value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasCapabilities() => $_has(2);
  @$pb.TagNumber(3)
  void clearCapabilities() => $_clearField(3);
  @$pb.TagNumber(3)
  FamilyCapabilities ensureCapabilities() => $_ensure(2);

  @$pb.TagNumber(4)
  Wallet get adultWallet => $_getN(3);
  @$pb.TagNumber(4)
  set adultWallet(Wallet value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasAdultWallet() => $_has(3);
  @$pb.TagNumber(4)
  void clearAdultWallet() => $_clearField(4);
  @$pb.TagNumber(4)
  Wallet ensureAdultWallet() => $_ensure(3);

  @$pb.TagNumber(5)
  $pb.PbList<Goal> get goals => $_getList(4);

  @$pb.TagNumber(6)
  $pb.PbList<FamilyTask> get tasks => $_getList(5);

  @$pb.TagNumber(7)
  $pb.PbList<Errand> get errands => $_getList(6);

  @$pb.TagNumber(8)
  $pb.PbList<Allowance> get allowances => $_getList(7);

  @$pb.TagNumber(9)
  $pb.PbList<Installment> get installments => $_getList(8);

  @$pb.TagNumber(10)
  $pb.PbList<FamilyRequest> get requests => $_getList(9);

  @$pb.TagNumber(11)
  $pb.PbMap<$core.String, SpaceSettings> get settings => $_getMap(10);

  @$pb.TagNumber(12)
  $pb.PbList<LessonCompletion> get learning => $_getList(11);

  @$pb.TagNumber(13)
  $pb.PbList<Lesson> get lessons => $_getList(12);

  @$pb.TagNumber(14)
  $pb.PbList<WeeklyOverview> get weekly => $_getList(13);
}

class SpaceCommand extends $pb.GeneratedMessage {
  factory SpaceCommand({
    $core.String? reason,
    $core.int? answerIndex,
    $core.String? type,
    $core.String? childId,
    $core.String? entityId,
    $core.String? title,
    $fixnum.Int64? amountMinor,
    $fixnum.Int64? budgetMinor,
    $fixnum.Int64? rewardMinor,
    $fixnum.Int64? targetMinor,
    $core.String? action,
    $core.String? idempotencyKey,
    $core.String? funding,
    $core.bool? ownMoneyConsent,
    $core.String? frequency,
    $core.Iterable<$core.int>? weekdays,
    $core.int? monthDay,
    $core.String? nextDate,
    $core.int? retryLimit,
    SpaceSettings? settings,
    Policy? policy,
    $core.String? kind,
    $core.bool? approve,
  }) {
    final result = SpaceCommand._();
    if (reason != null) result.reason = reason;
    if (answerIndex != null) result.answerIndex = answerIndex;
    if (type != null) result.type = type;
    if (childId != null) result.childId = childId;
    if (entityId != null) result.entityId = entityId;
    if (title != null) result.title = title;
    if (amountMinor != null) result.amountMinor = amountMinor;
    if (budgetMinor != null) result.budgetMinor = budgetMinor;
    if (rewardMinor != null) result.rewardMinor = rewardMinor;
    if (targetMinor != null) result.targetMinor = targetMinor;
    if (action != null) result.action = action;
    if (idempotencyKey != null) result.idempotencyKey = idempotencyKey;
    if (funding != null) result.funding = funding;
    if (ownMoneyConsent != null) result.ownMoneyConsent = ownMoneyConsent;
    if (frequency != null) result.frequency = frequency;
    if (weekdays != null) result.weekdays.addAll(weekdays);
    if (monthDay != null) result.monthDay = monthDay;
    if (nextDate != null) result.nextDate = nextDate;
    if (retryLimit != null) result.retryLimit = retryLimit;
    if (settings != null) result.settings = settings;
    if (policy != null) result.policy = policy;
    if (kind != null) result.kind = kind;
    if (approve != null) result.approve = approve;
    return result;
  }

  SpaceCommand._();

  factory SpaceCommand.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SpaceCommand()..mergeFromBuffer(data, registry);
  factory SpaceCommand.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SpaceCommand()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SpaceCommand',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'moby.family.v1'),
      createEmptyInstance: SpaceCommand.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'reason')
    ..aI(2, _omitFieldNames ? '' : 'answerIndex')
    ..aOS(3, _omitFieldNames ? '' : 'type')
    ..aOS(4, _omitFieldNames ? '' : 'childId')
    ..aOS(5, _omitFieldNames ? '' : 'entityId')
    ..aOS(6, _omitFieldNames ? '' : 'title')
    ..aInt64(7, _omitFieldNames ? '' : 'amountMinor')
    ..aInt64(8, _omitFieldNames ? '' : 'budgetMinor')
    ..aInt64(9, _omitFieldNames ? '' : 'rewardMinor')
    ..aInt64(10, _omitFieldNames ? '' : 'targetMinor')
    ..aOS(11, _omitFieldNames ? '' : 'action')
    ..aOS(12, _omitFieldNames ? '' : 'idempotencyKey')
    ..aOS(13, _omitFieldNames ? '' : 'funding')
    ..aOB(14, _omitFieldNames ? '' : 'ownMoneyConsent')
    ..aOS(15, _omitFieldNames ? '' : 'frequency')
    ..p<$core.int>(16, _omitFieldNames ? '' : 'weekdays', $pb.PbFieldType.K3)
    ..aI(17, _omitFieldNames ? '' : 'monthDay')
    ..aOS(18, _omitFieldNames ? '' : 'nextDate')
    ..aI(19, _omitFieldNames ? '' : 'retryLimit')
    ..aOM<SpaceSettings>(20, _omitFieldNames ? '' : 'settings',
        subBuilder: SpaceSettings.$_createMessage)
    ..aOM<Policy>(21, _omitFieldNames ? '' : 'policy',
        subBuilder: Policy.$_createMessage)
    ..aOS(22, _omitFieldNames ? '' : 'kind')
    ..aOB(23, _omitFieldNames ? '' : 'approve')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceCommand clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceCommand copyWith(void Function(SpaceCommand) updates) =>
      super.copyWith((message) => updates(message as SpaceCommand))
          as SpaceCommand;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SpaceCommand() / SpaceCommand.new instead')
  static SpaceCommand create() => SpaceCommand._();
  static $pb.GeneratedMessage $_createMessage() => SpaceCommand._();
  @$core.override
  SpaceCommand createEmptyInstance() => SpaceCommand._();
  @$core.pragma('dart2js:noInline')
  static SpaceCommand getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SpaceCommand>(
          SpaceCommand.$_createMessage);
  static SpaceCommand? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get reason => $_getSZ(0);
  @$pb.TagNumber(1)
  set reason($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasReason() => $_has(0);
  @$pb.TagNumber(1)
  void clearReason() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get answerIndex => $_getIZ(1);
  @$pb.TagNumber(2)
  set answerIndex($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAnswerIndex() => $_has(1);
  @$pb.TagNumber(2)
  void clearAnswerIndex() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get type => $_getSZ(2);
  @$pb.TagNumber(3)
  set type($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasType() => $_has(2);
  @$pb.TagNumber(3)
  void clearType() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get childId => $_getSZ(3);
  @$pb.TagNumber(4)
  set childId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasChildId() => $_has(3);
  @$pb.TagNumber(4)
  void clearChildId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get entityId => $_getSZ(4);
  @$pb.TagNumber(5)
  set entityId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasEntityId() => $_has(4);
  @$pb.TagNumber(5)
  void clearEntityId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get title => $_getSZ(5);
  @$pb.TagNumber(6)
  set title($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTitle() => $_has(5);
  @$pb.TagNumber(6)
  void clearTitle() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get amountMinor => $_getI64(6);
  @$pb.TagNumber(7)
  set amountMinor($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasAmountMinor() => $_has(6);
  @$pb.TagNumber(7)
  void clearAmountMinor() => $_clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get budgetMinor => $_getI64(7);
  @$pb.TagNumber(8)
  set budgetMinor($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasBudgetMinor() => $_has(7);
  @$pb.TagNumber(8)
  void clearBudgetMinor() => $_clearField(8);

  @$pb.TagNumber(9)
  $fixnum.Int64 get rewardMinor => $_getI64(8);
  @$pb.TagNumber(9)
  set rewardMinor($fixnum.Int64 value) => $_setInt64(8, value);
  @$pb.TagNumber(9)
  $core.bool hasRewardMinor() => $_has(8);
  @$pb.TagNumber(9)
  void clearRewardMinor() => $_clearField(9);

  @$pb.TagNumber(10)
  $fixnum.Int64 get targetMinor => $_getI64(9);
  @$pb.TagNumber(10)
  set targetMinor($fixnum.Int64 value) => $_setInt64(9, value);
  @$pb.TagNumber(10)
  $core.bool hasTargetMinor() => $_has(9);
  @$pb.TagNumber(10)
  void clearTargetMinor() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get action => $_getSZ(10);
  @$pb.TagNumber(11)
  set action($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasAction() => $_has(10);
  @$pb.TagNumber(11)
  void clearAction() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get idempotencyKey => $_getSZ(11);
  @$pb.TagNumber(12)
  set idempotencyKey($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasIdempotencyKey() => $_has(11);
  @$pb.TagNumber(12)
  void clearIdempotencyKey() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get funding => $_getSZ(12);
  @$pb.TagNumber(13)
  set funding($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasFunding() => $_has(12);
  @$pb.TagNumber(13)
  void clearFunding() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.bool get ownMoneyConsent => $_getBF(13);
  @$pb.TagNumber(14)
  set ownMoneyConsent($core.bool value) => $_setBool(13, value);
  @$pb.TagNumber(14)
  $core.bool hasOwnMoneyConsent() => $_has(13);
  @$pb.TagNumber(14)
  void clearOwnMoneyConsent() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.String get frequency => $_getSZ(14);
  @$pb.TagNumber(15)
  set frequency($core.String value) => $_setString(14, value);
  @$pb.TagNumber(15)
  $core.bool hasFrequency() => $_has(14);
  @$pb.TagNumber(15)
  void clearFrequency() => $_clearField(15);

  @$pb.TagNumber(16)
  $pb.PbList<$core.int> get weekdays => $_getList(15);

  @$pb.TagNumber(17)
  $core.int get monthDay => $_getIZ(16);
  @$pb.TagNumber(17)
  set monthDay($core.int value) => $_setSignedInt32(16, value);
  @$pb.TagNumber(17)
  $core.bool hasMonthDay() => $_has(16);
  @$pb.TagNumber(17)
  void clearMonthDay() => $_clearField(17);

  @$pb.TagNumber(18)
  $core.String get nextDate => $_getSZ(17);
  @$pb.TagNumber(18)
  set nextDate($core.String value) => $_setString(17, value);
  @$pb.TagNumber(18)
  $core.bool hasNextDate() => $_has(17);
  @$pb.TagNumber(18)
  void clearNextDate() => $_clearField(18);

  @$pb.TagNumber(19)
  $core.int get retryLimit => $_getIZ(18);
  @$pb.TagNumber(19)
  set retryLimit($core.int value) => $_setSignedInt32(18, value);
  @$pb.TagNumber(19)
  $core.bool hasRetryLimit() => $_has(18);
  @$pb.TagNumber(19)
  void clearRetryLimit() => $_clearField(19);

  @$pb.TagNumber(20)
  SpaceSettings get settings => $_getN(19);
  @$pb.TagNumber(20)
  set settings(SpaceSettings value) => $_setField(20, value);
  @$pb.TagNumber(20)
  $core.bool hasSettings() => $_has(19);
  @$pb.TagNumber(20)
  void clearSettings() => $_clearField(20);
  @$pb.TagNumber(20)
  SpaceSettings ensureSettings() => $_ensure(19);

  @$pb.TagNumber(21)
  Policy get policy => $_getN(20);
  @$pb.TagNumber(21)
  set policy(Policy value) => $_setField(21, value);
  @$pb.TagNumber(21)
  $core.bool hasPolicy() => $_has(20);
  @$pb.TagNumber(21)
  void clearPolicy() => $_clearField(21);
  @$pb.TagNumber(21)
  Policy ensurePolicy() => $_ensure(20);

  @$pb.TagNumber(22)
  $core.String get kind => $_getSZ(21);
  @$pb.TagNumber(22)
  set kind($core.String value) => $_setString(21, value);
  @$pb.TagNumber(22)
  $core.bool hasKind() => $_has(21);
  @$pb.TagNumber(22)
  void clearKind() => $_clearField(22);

  @$pb.TagNumber(23)
  $core.bool get approve => $_getBF(22);
  @$pb.TagNumber(23)
  set approve($core.bool value) => $_setBool(22, value);
  @$pb.TagNumber(23)
  $core.bool hasApprove() => $_has(22);
  @$pb.TagNumber(23)
  void clearApprove() => $_clearField(23);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
