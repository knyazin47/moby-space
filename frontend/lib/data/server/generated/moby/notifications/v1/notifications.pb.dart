// This is a generated file - do not edit.
//
// Generated from moby/notifications/v1/notifications.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'notifications.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'notifications.pbenum.dart';

/// A future authenticated, actor-scoped source owns the monotonic sequence.
/// No financial amount, account/card details, body, title or credential belongs
/// in this event metadata. Opening it must re-fetch authorized application data.
class NotificationEvent extends $pb.GeneratedMessage {
  factory NotificationEvent({
    $core.String? eventId,
    $core.String? recipientActorId,
    $core.String? childId,
    $fixnum.Int64? sequence,
    NotificationKind? kind,
    NotificationCategory? category,
    NotificationTarget? target,
    $core.String? entityId,
    $fixnum.Int64? createdAt,
    $fixnum.Int64? expiresAt,
    $core.bool? mandatory,
  }) {
    final result = NotificationEvent._();
    if (eventId != null) result.eventId = eventId;
    if (recipientActorId != null) result.recipientActorId = recipientActorId;
    if (childId != null) result.childId = childId;
    if (sequence != null) result.sequence = sequence;
    if (kind != null) result.kind = kind;
    if (category != null) result.category = category;
    if (target != null) result.target = target;
    if (entityId != null) result.entityId = entityId;
    if (createdAt != null) result.createdAt = createdAt;
    if (expiresAt != null) result.expiresAt = expiresAt;
    if (mandatory != null) result.mandatory = mandatory;
    return result;
  }

  NotificationEvent._();

  factory NotificationEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      NotificationEvent()..mergeFromBuffer(data, registry);
  factory NotificationEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      NotificationEvent()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NotificationEvent',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'moby.notifications.v1'),
      createEmptyInstance: NotificationEvent.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'eventId')
    ..aOS(2, _omitFieldNames ? '' : 'recipientActorId')
    ..aOS(3, _omitFieldNames ? '' : 'childId')
    ..aInt64(4, _omitFieldNames ? '' : 'sequence')
    ..aE<NotificationKind>(5, _omitFieldNames ? '' : 'kind',
        enumValues: NotificationKind.values)
    ..aE<NotificationCategory>(6, _omitFieldNames ? '' : 'category',
        enumValues: NotificationCategory.values)
    ..aE<NotificationTarget>(7, _omitFieldNames ? '' : 'target',
        enumValues: NotificationTarget.values)
    ..aOS(8, _omitFieldNames ? '' : 'entityId')
    ..aInt64(9, _omitFieldNames ? '' : 'createdAt')
    ..aInt64(10, _omitFieldNames ? '' : 'expiresAt')
    ..aOB(11, _omitFieldNames ? '' : 'mandatory')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NotificationEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NotificationEvent copyWith(void Function(NotificationEvent) updates) =>
      super.copyWith((message) => updates(message as NotificationEvent))
          as NotificationEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use NotificationEvent() / NotificationEvent.new instead')
  static NotificationEvent create() => NotificationEvent._();
  static $pb.GeneratedMessage $_createMessage() => NotificationEvent._();
  @$core.override
  NotificationEvent createEmptyInstance() => NotificationEvent._();
  @$core.pragma('dart2js:noInline')
  static NotificationEvent getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<NotificationEvent>(
          NotificationEvent.$_createMessage);
  static NotificationEvent? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get eventId => $_getSZ(0);
  @$pb.TagNumber(1)
  set eventId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEventId() => $_has(0);
  @$pb.TagNumber(1)
  void clearEventId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get recipientActorId => $_getSZ(1);
  @$pb.TagNumber(2)
  set recipientActorId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRecipientActorId() => $_has(1);
  @$pb.TagNumber(2)
  void clearRecipientActorId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get childId => $_getSZ(2);
  @$pb.TagNumber(3)
  set childId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasChildId() => $_has(2);
  @$pb.TagNumber(3)
  void clearChildId() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get sequence => $_getI64(3);
  @$pb.TagNumber(4)
  set sequence($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSequence() => $_has(3);
  @$pb.TagNumber(4)
  void clearSequence() => $_clearField(4);

  @$pb.TagNumber(5)
  NotificationKind get kind => $_getN(4);
  @$pb.TagNumber(5)
  set kind(NotificationKind value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasKind() => $_has(4);
  @$pb.TagNumber(5)
  void clearKind() => $_clearField(5);

  @$pb.TagNumber(6)
  NotificationCategory get category => $_getN(5);
  @$pb.TagNumber(6)
  set category(NotificationCategory value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasCategory() => $_has(5);
  @$pb.TagNumber(6)
  void clearCategory() => $_clearField(6);

  @$pb.TagNumber(7)
  NotificationTarget get target => $_getN(6);
  @$pb.TagNumber(7)
  set target(NotificationTarget value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasTarget() => $_has(6);
  @$pb.TagNumber(7)
  void clearTarget() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get entityId => $_getSZ(7);
  @$pb.TagNumber(8)
  set entityId($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasEntityId() => $_has(7);
  @$pb.TagNumber(8)
  void clearEntityId() => $_clearField(8);

  @$pb.TagNumber(9)
  $fixnum.Int64 get createdAt => $_getI64(8);
  @$pb.TagNumber(9)
  set createdAt($fixnum.Int64 value) => $_setInt64(8, value);
  @$pb.TagNumber(9)
  $core.bool hasCreatedAt() => $_has(8);
  @$pb.TagNumber(9)
  void clearCreatedAt() => $_clearField(9);

  @$pb.TagNumber(10)
  $fixnum.Int64 get expiresAt => $_getI64(9);
  @$pb.TagNumber(10)
  set expiresAt($fixnum.Int64 value) => $_setInt64(9, value);
  @$pb.TagNumber(10)
  $core.bool hasExpiresAt() => $_has(9);
  @$pb.TagNumber(10)
  void clearExpiresAt() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.bool get mandatory => $_getBF(10);
  @$pb.TagNumber(11)
  set mandatory($core.bool value) => $_setBool(10, value);
  @$pb.TagNumber(11)
  $core.bool hasMandatory() => $_has(10);
  @$pb.TagNumber(11)
  void clearMandatory() => $_clearField(11);
}

class NotificationPreferences extends $pb.GeneratedMessage {
  factory NotificationPreferences({
    $core.String? actorId,
    $fixnum.Int64? version,
    $core.bool? enabled,
    $core.Iterable<NotificationCategory>? enabledCategories,
  }) {
    final result = NotificationPreferences._();
    if (actorId != null) result.actorId = actorId;
    if (version != null) result.version = version;
    if (enabled != null) result.enabled = enabled;
    if (enabledCategories != null)
      result.enabledCategories.addAll(enabledCategories);
    return result;
  }

  NotificationPreferences._();

  factory NotificationPreferences.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      NotificationPreferences()..mergeFromBuffer(data, registry);
  factory NotificationPreferences.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      NotificationPreferences()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NotificationPreferences',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'moby.notifications.v1'),
      createEmptyInstance: NotificationPreferences.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'actorId')
    ..aInt64(2, _omitFieldNames ? '' : 'version')
    ..aOB(3, _omitFieldNames ? '' : 'enabled')
    ..pc<NotificationCategory>(
        4, _omitFieldNames ? '' : 'enabledCategories', $pb.PbFieldType.KE,
        valueOf: NotificationCategory.valueOf,
        enumValues: NotificationCategory.values,
        defaultEnumValue:
            NotificationCategory.NOTIFICATION_CATEGORY_UNSPECIFIED)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NotificationPreferences clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NotificationPreferences copyWith(
          void Function(NotificationPreferences) updates) =>
      super.copyWith((message) => updates(message as NotificationPreferences))
          as NotificationPreferences;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use NotificationPreferences() / NotificationPreferences.new instead')
  static NotificationPreferences create() => NotificationPreferences._();
  static $pb.GeneratedMessage $_createMessage() => NotificationPreferences._();
  @$core.override
  NotificationPreferences createEmptyInstance() => NotificationPreferences._();
  @$core.pragma('dart2js:noInline')
  static NotificationPreferences getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NotificationPreferences>(
          NotificationPreferences.$_createMessage);
  static NotificationPreferences? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get actorId => $_getSZ(0);
  @$pb.TagNumber(1)
  set actorId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasActorId() => $_has(0);
  @$pb.TagNumber(1)
  void clearActorId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get version => $_getI64(1);
  @$pb.TagNumber(2)
  set version($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearVersion() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get enabled => $_getBF(2);
  @$pb.TagNumber(3)
  set enabled($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEnabled() => $_has(2);
  @$pb.TagNumber(3)
  void clearEnabled() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<NotificationCategory> get enabledCategories => $_getList(3);
}

/// Opaque server references only. Token registration and platform/provider
/// credentials have no wire field and no persistence contract in this milestone.
class NotificationInstallationRef extends $pb.GeneratedMessage {
  factory NotificationInstallationRef({
    $core.String? installationId,
    $core.String? actorId,
  }) {
    final result = NotificationInstallationRef._();
    if (installationId != null) result.installationId = installationId;
    if (actorId != null) result.actorId = actorId;
    return result;
  }

  NotificationInstallationRef._();

  factory NotificationInstallationRef.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      NotificationInstallationRef()..mergeFromBuffer(data, registry);
  factory NotificationInstallationRef.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      NotificationInstallationRef()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NotificationInstallationRef',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'moby.notifications.v1'),
      createEmptyInstance: NotificationInstallationRef.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'installationId')
    ..aOS(2, _omitFieldNames ? '' : 'actorId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NotificationInstallationRef clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NotificationInstallationRef copyWith(
          void Function(NotificationInstallationRef) updates) =>
      super.copyWith(
              (message) => updates(message as NotificationInstallationRef))
          as NotificationInstallationRef;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use NotificationInstallationRef() / NotificationInstallationRef.new instead')
  static NotificationInstallationRef create() =>
      NotificationInstallationRef._();
  static $pb.GeneratedMessage $_createMessage() =>
      NotificationInstallationRef._();
  @$core.override
  NotificationInstallationRef createEmptyInstance() =>
      NotificationInstallationRef._();
  @$core.pragma('dart2js:noInline')
  static NotificationInstallationRef getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NotificationInstallationRef>(
          NotificationInstallationRef.$_createMessage);
  static NotificationInstallationRef? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get installationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set installationId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasInstallationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearInstallationId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get actorId => $_getSZ(1);
  @$pb.TagNumber(2)
  set actorId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasActorId() => $_has(1);
  @$pb.TagNumber(2)
  void clearActorId() => $_clearField(2);
}

class NotificationDeliveryEnvelope extends $pb.GeneratedMessage {
  factory NotificationDeliveryEnvelope({
    $core.String? eventId,
    $core.String? recipientActorId,
    NotificationInstallationRef? installation,
  }) {
    final result = NotificationDeliveryEnvelope._();
    if (eventId != null) result.eventId = eventId;
    if (recipientActorId != null) result.recipientActorId = recipientActorId;
    if (installation != null) result.installation = installation;
    return result;
  }

  NotificationDeliveryEnvelope._();

  factory NotificationDeliveryEnvelope.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      NotificationDeliveryEnvelope()..mergeFromBuffer(data, registry);
  factory NotificationDeliveryEnvelope.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      NotificationDeliveryEnvelope()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NotificationDeliveryEnvelope',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'moby.notifications.v1'),
      createEmptyInstance: NotificationDeliveryEnvelope.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'eventId')
    ..aOS(2, _omitFieldNames ? '' : 'recipientActorId')
    ..aOM<NotificationInstallationRef>(3, _omitFieldNames ? '' : 'installation',
        subBuilder: NotificationInstallationRef.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NotificationDeliveryEnvelope clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NotificationDeliveryEnvelope copyWith(
          void Function(NotificationDeliveryEnvelope) updates) =>
      super.copyWith(
              (message) => updates(message as NotificationDeliveryEnvelope))
          as NotificationDeliveryEnvelope;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use NotificationDeliveryEnvelope() / NotificationDeliveryEnvelope.new instead')
  static NotificationDeliveryEnvelope create() =>
      NotificationDeliveryEnvelope._();
  static $pb.GeneratedMessage $_createMessage() =>
      NotificationDeliveryEnvelope._();
  @$core.override
  NotificationDeliveryEnvelope createEmptyInstance() =>
      NotificationDeliveryEnvelope._();
  @$core.pragma('dart2js:noInline')
  static NotificationDeliveryEnvelope getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NotificationDeliveryEnvelope>(
          NotificationDeliveryEnvelope.$_createMessage);
  static NotificationDeliveryEnvelope? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get eventId => $_getSZ(0);
  @$pb.TagNumber(1)
  set eventId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEventId() => $_has(0);
  @$pb.TagNumber(1)
  void clearEventId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get recipientActorId => $_getSZ(1);
  @$pb.TagNumber(2)
  set recipientActorId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRecipientActorId() => $_has(1);
  @$pb.TagNumber(2)
  void clearRecipientActorId() => $_clearField(2);

  @$pb.TagNumber(3)
  NotificationInstallationRef get installation => $_getN(2);
  @$pb.TagNumber(3)
  set installation(NotificationInstallationRef value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasInstallation() => $_has(2);
  @$pb.TagNumber(3)
  void clearInstallation() => $_clearField(3);
  @$pb.TagNumber(3)
  NotificationInstallationRef ensureInstallation() => $_ensure(2);
}

class NotificationDeliveryReceipt extends $pb.GeneratedMessage {
  factory NotificationDeliveryReceipt({
    $core.String? eventId,
    $core.String? installationId,
    NotificationDeliveryStatus? status,
  }) {
    final result = NotificationDeliveryReceipt._();
    if (eventId != null) result.eventId = eventId;
    if (installationId != null) result.installationId = installationId;
    if (status != null) result.status = status;
    return result;
  }

  NotificationDeliveryReceipt._();

  factory NotificationDeliveryReceipt.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      NotificationDeliveryReceipt()..mergeFromBuffer(data, registry);
  factory NotificationDeliveryReceipt.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      NotificationDeliveryReceipt()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NotificationDeliveryReceipt',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'moby.notifications.v1'),
      createEmptyInstance: NotificationDeliveryReceipt.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'eventId')
    ..aOS(2, _omitFieldNames ? '' : 'installationId')
    ..aE<NotificationDeliveryStatus>(3, _omitFieldNames ? '' : 'status',
        enumValues: NotificationDeliveryStatus.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NotificationDeliveryReceipt clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NotificationDeliveryReceipt copyWith(
          void Function(NotificationDeliveryReceipt) updates) =>
      super.copyWith(
              (message) => updates(message as NotificationDeliveryReceipt))
          as NotificationDeliveryReceipt;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use NotificationDeliveryReceipt() / NotificationDeliveryReceipt.new instead')
  static NotificationDeliveryReceipt create() =>
      NotificationDeliveryReceipt._();
  static $pb.GeneratedMessage $_createMessage() =>
      NotificationDeliveryReceipt._();
  @$core.override
  NotificationDeliveryReceipt createEmptyInstance() =>
      NotificationDeliveryReceipt._();
  @$core.pragma('dart2js:noInline')
  static NotificationDeliveryReceipt getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NotificationDeliveryReceipt>(
          NotificationDeliveryReceipt.$_createMessage);
  static NotificationDeliveryReceipt? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get eventId => $_getSZ(0);
  @$pb.TagNumber(1)
  set eventId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEventId() => $_has(0);
  @$pb.TagNumber(1)
  void clearEventId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get installationId => $_getSZ(1);
  @$pb.TagNumber(2)
  set installationId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasInstallationId() => $_has(1);
  @$pb.TagNumber(2)
  void clearInstallationId() => $_clearField(2);

  @$pb.TagNumber(3)
  NotificationDeliveryStatus get status => $_getN(2);
  @$pb.TagNumber(3)
  set status(NotificationDeliveryStatus value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearStatus() => $_clearField(3);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
