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

import 'package:protobuf/protobuf.dart' as $pb;

/// Foundation only. No registration/delivery RPC, provider or OS permission flow
/// exists yet. These messages never authorize access to a family or an account.
class NotificationCategory extends $pb.ProtobufEnum {
  static const NotificationCategory NOTIFICATION_CATEGORY_UNSPECIFIED =
      NotificationCategory._(
          0, _omitEnumNames ? '' : 'NOTIFICATION_CATEGORY_UNSPECIFIED');
  static const NotificationCategory NOTIFICATION_CATEGORY_MONEY =
      NotificationCategory._(
          1, _omitEnumNames ? '' : 'NOTIFICATION_CATEGORY_MONEY');
  static const NotificationCategory NOTIFICATION_CATEGORY_WORK =
      NotificationCategory._(
          2, _omitEnumNames ? '' : 'NOTIFICATION_CATEGORY_WORK');
  static const NotificationCategory NOTIFICATION_CATEGORY_GOALS =
      NotificationCategory._(
          3, _omitEnumNames ? '' : 'NOTIFICATION_CATEGORY_GOALS');
  static const NotificationCategory NOTIFICATION_CATEGORY_LEARNING =
      NotificationCategory._(
          4, _omitEnumNames ? '' : 'NOTIFICATION_CATEGORY_LEARNING');
  static const NotificationCategory NOTIFICATION_CATEGORY_SECURITY =
      NotificationCategory._(
          5, _omitEnumNames ? '' : 'NOTIFICATION_CATEGORY_SECURITY');

  static const $core.List<NotificationCategory> values = <NotificationCategory>[
    NOTIFICATION_CATEGORY_UNSPECIFIED,
    NOTIFICATION_CATEGORY_MONEY,
    NOTIFICATION_CATEGORY_WORK,
    NOTIFICATION_CATEGORY_GOALS,
    NOTIFICATION_CATEGORY_LEARNING,
    NOTIFICATION_CATEGORY_SECURITY,
  ];

  static final $core.List<NotificationCategory?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static NotificationCategory? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const NotificationCategory._(super.value, super.name);
}

class NotificationKind extends $pb.ProtobufEnum {
  static const NotificationKind NOTIFICATION_KIND_UNSPECIFIED =
      NotificationKind._(
          0, _omitEnumNames ? '' : 'NOTIFICATION_KIND_UNSPECIFIED');
  static const NotificationKind NOTIFICATION_KIND_DECISION_REQUIRED =
      NotificationKind._(
          1, _omitEnumNames ? '' : 'NOTIFICATION_KIND_DECISION_REQUIRED');
  static const NotificationKind NOTIFICATION_KIND_STATE_CHANGED =
      NotificationKind._(
          2, _omitEnumNames ? '' : 'NOTIFICATION_KIND_STATE_CHANGED');
  static const NotificationKind NOTIFICATION_KIND_SECURITY_ALERT =
      NotificationKind._(
          3, _omitEnumNames ? '' : 'NOTIFICATION_KIND_SECURITY_ALERT');

  static const $core.List<NotificationKind> values = <NotificationKind>[
    NOTIFICATION_KIND_UNSPECIFIED,
    NOTIFICATION_KIND_DECISION_REQUIRED,
    NOTIFICATION_KIND_STATE_CHANGED,
    NOTIFICATION_KIND_SECURITY_ALERT,
  ];

  static final $core.List<NotificationKind?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static NotificationKind? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const NotificationKind._(super.value, super.name);
}

/// Navigation is an allowlist. Never replace it with a provider-controlled URL.
class NotificationTarget extends $pb.ProtobufEnum {
  static const NotificationTarget NOTIFICATION_TARGET_UNSPECIFIED =
      NotificationTarget._(
          0, _omitEnumNames ? '' : 'NOTIFICATION_TARGET_UNSPECIFIED');
  static const NotificationTarget NOTIFICATION_TARGET_FAMILY_OVERVIEW =
      NotificationTarget._(
          1, _omitEnumNames ? '' : 'NOTIFICATION_TARGET_FAMILY_OVERVIEW');
  static const NotificationTarget NOTIFICATION_TARGET_CHILD_MONEY =
      NotificationTarget._(
          2, _omitEnumNames ? '' : 'NOTIFICATION_TARGET_CHILD_MONEY');
  static const NotificationTarget NOTIFICATION_TARGET_CHILD_GOALS =
      NotificationTarget._(
          3, _omitEnumNames ? '' : 'NOTIFICATION_TARGET_CHILD_GOALS');
  static const NotificationTarget NOTIFICATION_TARGET_CHILD_WORK =
      NotificationTarget._(
          4, _omitEnumNames ? '' : 'NOTIFICATION_TARGET_CHILD_WORK');
  static const NotificationTarget NOTIFICATION_TARGET_CHILD_RULES =
      NotificationTarget._(
          5, _omitEnumNames ? '' : 'NOTIFICATION_TARGET_CHILD_RULES');
  static const NotificationTarget NOTIFICATION_TARGET_CHILD_LEARNING =
      NotificationTarget._(
          6, _omitEnumNames ? '' : 'NOTIFICATION_TARGET_CHILD_LEARNING');

  static const $core.List<NotificationTarget> values = <NotificationTarget>[
    NOTIFICATION_TARGET_UNSPECIFIED,
    NOTIFICATION_TARGET_FAMILY_OVERVIEW,
    NOTIFICATION_TARGET_CHILD_MONEY,
    NOTIFICATION_TARGET_CHILD_GOALS,
    NOTIFICATION_TARGET_CHILD_WORK,
    NOTIFICATION_TARGET_CHILD_RULES,
    NOTIFICATION_TARGET_CHILD_LEARNING,
  ];

  static final $core.List<NotificationTarget?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 6);
  static NotificationTarget? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const NotificationTarget._(super.value, super.name);
}

class NotificationDeliveryStatus extends $pb.ProtobufEnum {
  static const NotificationDeliveryStatus
      NOTIFICATION_DELIVERY_STATUS_UNSPECIFIED = NotificationDeliveryStatus._(
          0, _omitEnumNames ? '' : 'NOTIFICATION_DELIVERY_STATUS_UNSPECIFIED');
  static const NotificationDeliveryStatus
      NOTIFICATION_DELIVERY_STATUS_NOT_CONFIGURED =
      NotificationDeliveryStatus._(1,
          _omitEnumNames ? '' : 'NOTIFICATION_DELIVERY_STATUS_NOT_CONFIGURED');
  static const NotificationDeliveryStatus NOTIFICATION_DELIVERY_STATUS_PENDING =
      NotificationDeliveryStatus._(
          2, _omitEnumNames ? '' : 'NOTIFICATION_DELIVERY_STATUS_PENDING');

  /// Acceptance by a provider confirms neither device delivery nor reading.
  static const NotificationDeliveryStatus
      NOTIFICATION_DELIVERY_STATUS_PROVIDER_ACCEPTED =
      NotificationDeliveryStatus._(
          3,
          _omitEnumNames
              ? ''
              : 'NOTIFICATION_DELIVERY_STATUS_PROVIDER_ACCEPTED');
  static const NotificationDeliveryStatus NOTIFICATION_DELIVERY_STATUS_FAILED =
      NotificationDeliveryStatus._(
          4, _omitEnumNames ? '' : 'NOTIFICATION_DELIVERY_STATUS_FAILED');
  static const NotificationDeliveryStatus NOTIFICATION_DELIVERY_STATUS_EXPIRED =
      NotificationDeliveryStatus._(
          5, _omitEnumNames ? '' : 'NOTIFICATION_DELIVERY_STATUS_EXPIRED');

  static const $core.List<NotificationDeliveryStatus> values =
      <NotificationDeliveryStatus>[
    NOTIFICATION_DELIVERY_STATUS_UNSPECIFIED,
    NOTIFICATION_DELIVERY_STATUS_NOT_CONFIGURED,
    NOTIFICATION_DELIVERY_STATUS_PENDING,
    NOTIFICATION_DELIVERY_STATUS_PROVIDER_ACCEPTED,
    NOTIFICATION_DELIVERY_STATUS_FAILED,
    NOTIFICATION_DELIVERY_STATUS_EXPIRED,
  ];

  static final $core.List<NotificationDeliveryStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static NotificationDeliveryStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const NotificationDeliveryStatus._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
