// This is a generated file - do not edit.
//
// Generated from moby/notifications/v1/notifications.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use notificationCategoryDescriptor instead')
const NotificationCategory$json = {
  '1': 'NotificationCategory',
  '2': [
    {'1': 'NOTIFICATION_CATEGORY_UNSPECIFIED', '2': 0},
    {'1': 'NOTIFICATION_CATEGORY_MONEY', '2': 1},
    {'1': 'NOTIFICATION_CATEGORY_WORK', '2': 2},
    {'1': 'NOTIFICATION_CATEGORY_GOALS', '2': 3},
    {'1': 'NOTIFICATION_CATEGORY_LEARNING', '2': 4},
    {'1': 'NOTIFICATION_CATEGORY_SECURITY', '2': 5},
  ],
};

/// Descriptor for `NotificationCategory`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List notificationCategoryDescriptor = $convert.base64Decode(
    'ChROb3RpZmljYXRpb25DYXRlZ29yeRIlCiFOT1RJRklDQVRJT05fQ0FURUdPUllfVU5TUEVDSU'
    'ZJRUQQABIfChtOT1RJRklDQVRJT05fQ0FURUdPUllfTU9ORVkQARIeChpOT1RJRklDQVRJT05f'
    'Q0FURUdPUllfV09SSxACEh8KG05PVElGSUNBVElPTl9DQVRFR09SWV9HT0FMUxADEiIKHk5PVE'
    'lGSUNBVElPTl9DQVRFR09SWV9MRUFSTklORxAEEiIKHk5PVElGSUNBVElPTl9DQVRFR09SWV9T'
    'RUNVUklUWRAF');

@$core.Deprecated('Use notificationKindDescriptor instead')
const NotificationKind$json = {
  '1': 'NotificationKind',
  '2': [
    {'1': 'NOTIFICATION_KIND_UNSPECIFIED', '2': 0},
    {'1': 'NOTIFICATION_KIND_DECISION_REQUIRED', '2': 1},
    {'1': 'NOTIFICATION_KIND_STATE_CHANGED', '2': 2},
    {'1': 'NOTIFICATION_KIND_SECURITY_ALERT', '2': 3},
  ],
};

/// Descriptor for `NotificationKind`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List notificationKindDescriptor = $convert.base64Decode(
    'ChBOb3RpZmljYXRpb25LaW5kEiEKHU5PVElGSUNBVElPTl9LSU5EX1VOU1BFQ0lGSUVEEAASJw'
    'ojTk9USUZJQ0FUSU9OX0tJTkRfREVDSVNJT05fUkVRVUlSRUQQARIjCh9OT1RJRklDQVRJT05f'
    'S0lORF9TVEFURV9DSEFOR0VEEAISJAogTk9USUZJQ0FUSU9OX0tJTkRfU0VDVVJJVFlfQUxFUl'
    'QQAw==');

@$core.Deprecated('Use notificationTargetDescriptor instead')
const NotificationTarget$json = {
  '1': 'NotificationTarget',
  '2': [
    {'1': 'NOTIFICATION_TARGET_UNSPECIFIED', '2': 0},
    {'1': 'NOTIFICATION_TARGET_FAMILY_OVERVIEW', '2': 1},
    {'1': 'NOTIFICATION_TARGET_CHILD_MONEY', '2': 2},
    {'1': 'NOTIFICATION_TARGET_CHILD_GOALS', '2': 3},
    {'1': 'NOTIFICATION_TARGET_CHILD_WORK', '2': 4},
    {'1': 'NOTIFICATION_TARGET_CHILD_RULES', '2': 5},
    {'1': 'NOTIFICATION_TARGET_CHILD_LEARNING', '2': 6},
  ],
};

/// Descriptor for `NotificationTarget`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List notificationTargetDescriptor = $convert.base64Decode(
    'ChJOb3RpZmljYXRpb25UYXJnZXQSIwofTk9USUZJQ0FUSU9OX1RBUkdFVF9VTlNQRUNJRklFRB'
    'AAEicKI05PVElGSUNBVElPTl9UQVJHRVRfRkFNSUxZX09WRVJWSUVXEAESIwofTk9USUZJQ0FU'
    'SU9OX1RBUkdFVF9DSElMRF9NT05FWRACEiMKH05PVElGSUNBVElPTl9UQVJHRVRfQ0hJTERfR0'
    '9BTFMQAxIiCh5OT1RJRklDQVRJT05fVEFSR0VUX0NISUxEX1dPUksQBBIjCh9OT1RJRklDQVRJ'
    'T05fVEFSR0VUX0NISUxEX1JVTEVTEAUSJgoiTk9USUZJQ0FUSU9OX1RBUkdFVF9DSElMRF9MRU'
    'FSTklORxAG');

@$core.Deprecated('Use notificationDeliveryStatusDescriptor instead')
const NotificationDeliveryStatus$json = {
  '1': 'NotificationDeliveryStatus',
  '2': [
    {'1': 'NOTIFICATION_DELIVERY_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'NOTIFICATION_DELIVERY_STATUS_NOT_CONFIGURED', '2': 1},
    {'1': 'NOTIFICATION_DELIVERY_STATUS_PENDING', '2': 2},
    {'1': 'NOTIFICATION_DELIVERY_STATUS_PROVIDER_ACCEPTED', '2': 3},
    {'1': 'NOTIFICATION_DELIVERY_STATUS_FAILED', '2': 4},
    {'1': 'NOTIFICATION_DELIVERY_STATUS_EXPIRED', '2': 5},
  ],
};

/// Descriptor for `NotificationDeliveryStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List notificationDeliveryStatusDescriptor = $convert.base64Decode(
    'ChpOb3RpZmljYXRpb25EZWxpdmVyeVN0YXR1cxIsCihOT1RJRklDQVRJT05fREVMSVZFUllfU1'
    'RBVFVTX1VOU1BFQ0lGSUVEEAASLworTk9USUZJQ0FUSU9OX0RFTElWRVJZX1NUQVRVU19OT1Rf'
    'Q09ORklHVVJFRBABEigKJE5PVElGSUNBVElPTl9ERUxJVkVSWV9TVEFUVVNfUEVORElORxACEj'
    'IKLk5PVElGSUNBVElPTl9ERUxJVkVSWV9TVEFUVVNfUFJPVklERVJfQUNDRVBURUQQAxInCiNO'
    'T1RJRklDQVRJT05fREVMSVZFUllfU1RBVFVTX0ZBSUxFRBAEEigKJE5PVElGSUNBVElPTl9ERU'
    'xJVkVSWV9TVEFUVVNfRVhQSVJFRBAF');

@$core.Deprecated('Use notificationEventDescriptor instead')
const NotificationEvent$json = {
  '1': 'NotificationEvent',
  '2': [
    {
      '1': 'event_id',
      '3': 1,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'eventId',
      '17': true
    },
    {
      '1': 'recipient_actor_id',
      '3': 2,
      '4': 1,
      '5': 9,
      '9': 1,
      '10': 'recipientActorId',
      '17': true
    },
    {
      '1': 'child_id',
      '3': 3,
      '4': 1,
      '5': 9,
      '9': 2,
      '10': 'childId',
      '17': true
    },
    {
      '1': 'sequence',
      '3': 4,
      '4': 1,
      '5': 3,
      '9': 3,
      '10': 'sequence',
      '17': true
    },
    {
      '1': 'kind',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.moby.notifications.v1.NotificationKind',
      '9': 4,
      '10': 'kind',
      '17': true
    },
    {
      '1': 'category',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.moby.notifications.v1.NotificationCategory',
      '9': 5,
      '10': 'category',
      '17': true
    },
    {
      '1': 'target',
      '3': 7,
      '4': 1,
      '5': 14,
      '6': '.moby.notifications.v1.NotificationTarget',
      '9': 6,
      '10': 'target',
      '17': true
    },
    {
      '1': 'entity_id',
      '3': 8,
      '4': 1,
      '5': 9,
      '9': 7,
      '10': 'entityId',
      '17': true
    },
    {
      '1': 'created_at',
      '3': 9,
      '4': 1,
      '5': 3,
      '9': 8,
      '10': 'createdAt',
      '17': true
    },
    {
      '1': 'expires_at',
      '3': 10,
      '4': 1,
      '5': 3,
      '9': 9,
      '10': 'expiresAt',
      '17': true
    },
    {
      '1': 'mandatory',
      '3': 11,
      '4': 1,
      '5': 8,
      '9': 10,
      '10': 'mandatory',
      '17': true
    },
  ],
  '8': [
    {'1': '_event_id'},
    {'1': '_recipient_actor_id'},
    {'1': '_child_id'},
    {'1': '_sequence'},
    {'1': '_kind'},
    {'1': '_category'},
    {'1': '_target'},
    {'1': '_entity_id'},
    {'1': '_created_at'},
    {'1': '_expires_at'},
    {'1': '_mandatory'},
  ],
};

/// Descriptor for `NotificationEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List notificationEventDescriptor = $convert.base64Decode(
    'ChFOb3RpZmljYXRpb25FdmVudBIeCghldmVudF9pZBgBIAEoCUgAUgdldmVudElkiAEBEjEKEn'
    'JlY2lwaWVudF9hY3Rvcl9pZBgCIAEoCUgBUhByZWNpcGllbnRBY3RvcklkiAEBEh4KCGNoaWxk'
    'X2lkGAMgASgJSAJSB2NoaWxkSWSIAQESHwoIc2VxdWVuY2UYBCABKANIA1IIc2VxdWVuY2WIAQ'
    'ESQAoEa2luZBgFIAEoDjInLm1vYnkubm90aWZpY2F0aW9ucy52MS5Ob3RpZmljYXRpb25LaW5k'
    'SARSBGtpbmSIAQESTAoIY2F0ZWdvcnkYBiABKA4yKy5tb2J5Lm5vdGlmaWNhdGlvbnMudjEuTm'
    '90aWZpY2F0aW9uQ2F0ZWdvcnlIBVIIY2F0ZWdvcnmIAQESRgoGdGFyZ2V0GAcgASgOMikubW9i'
    'eS5ub3RpZmljYXRpb25zLnYxLk5vdGlmaWNhdGlvblRhcmdldEgGUgZ0YXJnZXSIAQESIAoJZW'
    '50aXR5X2lkGAggASgJSAdSCGVudGl0eUlkiAEBEiIKCmNyZWF0ZWRfYXQYCSABKANICFIJY3Jl'
    'YXRlZEF0iAEBEiIKCmV4cGlyZXNfYXQYCiABKANICVIJZXhwaXJlc0F0iAEBEiEKCW1hbmRhdG'
    '9yeRgLIAEoCEgKUgltYW5kYXRvcnmIAQFCCwoJX2V2ZW50X2lkQhUKE19yZWNpcGllbnRfYWN0'
    'b3JfaWRCCwoJX2NoaWxkX2lkQgsKCV9zZXF1ZW5jZUIHCgVfa2luZEILCglfY2F0ZWdvcnlCCQ'
    'oHX3RhcmdldEIMCgpfZW50aXR5X2lkQg0KC19jcmVhdGVkX2F0Qg0KC19leHBpcmVzX2F0QgwK'
    'Cl9tYW5kYXRvcnk=');

@$core.Deprecated('Use notificationPreferencesDescriptor instead')
const NotificationPreferences$json = {
  '1': 'NotificationPreferences',
  '2': [
    {
      '1': 'actor_id',
      '3': 1,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'actorId',
      '17': true
    },
    {
      '1': 'version',
      '3': 2,
      '4': 1,
      '5': 3,
      '9': 1,
      '10': 'version',
      '17': true
    },
    {
      '1': 'enabled',
      '3': 3,
      '4': 1,
      '5': 8,
      '9': 2,
      '10': 'enabled',
      '17': true
    },
    {
      '1': 'enabled_categories',
      '3': 4,
      '4': 3,
      '5': 14,
      '6': '.moby.notifications.v1.NotificationCategory',
      '10': 'enabledCategories'
    },
  ],
  '8': [
    {'1': '_actor_id'},
    {'1': '_version'},
    {'1': '_enabled'},
  ],
};

/// Descriptor for `NotificationPreferences`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List notificationPreferencesDescriptor = $convert.base64Decode(
    'ChdOb3RpZmljYXRpb25QcmVmZXJlbmNlcxIeCghhY3Rvcl9pZBgBIAEoCUgAUgdhY3RvcklkiA'
    'EBEh0KB3ZlcnNpb24YAiABKANIAVIHdmVyc2lvbogBARIdCgdlbmFibGVkGAMgASgISAJSB2Vu'
    'YWJsZWSIAQESWgoSZW5hYmxlZF9jYXRlZ29yaWVzGAQgAygOMisubW9ieS5ub3RpZmljYXRpb2'
    '5zLnYxLk5vdGlmaWNhdGlvbkNhdGVnb3J5UhFlbmFibGVkQ2F0ZWdvcmllc0ILCglfYWN0b3Jf'
    'aWRCCgoIX3ZlcnNpb25CCgoIX2VuYWJsZWQ=');

@$core.Deprecated('Use notificationInstallationRefDescriptor instead')
const NotificationInstallationRef$json = {
  '1': 'NotificationInstallationRef',
  '2': [
    {
      '1': 'installation_id',
      '3': 1,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'installationId',
      '17': true
    },
    {
      '1': 'actor_id',
      '3': 2,
      '4': 1,
      '5': 9,
      '9': 1,
      '10': 'actorId',
      '17': true
    },
  ],
  '8': [
    {'1': '_installation_id'},
    {'1': '_actor_id'},
  ],
};

/// Descriptor for `NotificationInstallationRef`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List notificationInstallationRefDescriptor =
    $convert.base64Decode(
        'ChtOb3RpZmljYXRpb25JbnN0YWxsYXRpb25SZWYSLAoPaW5zdGFsbGF0aW9uX2lkGAEgASgJSA'
        'BSDmluc3RhbGxhdGlvbklkiAEBEh4KCGFjdG9yX2lkGAIgASgJSAFSB2FjdG9ySWSIAQFCEgoQ'
        'X2luc3RhbGxhdGlvbl9pZEILCglfYWN0b3JfaWQ=');

@$core.Deprecated('Use notificationDeliveryEnvelopeDescriptor instead')
const NotificationDeliveryEnvelope$json = {
  '1': 'NotificationDeliveryEnvelope',
  '2': [
    {
      '1': 'event_id',
      '3': 1,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'eventId',
      '17': true
    },
    {
      '1': 'recipient_actor_id',
      '3': 2,
      '4': 1,
      '5': 9,
      '9': 1,
      '10': 'recipientActorId',
      '17': true
    },
    {
      '1': 'installation',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.moby.notifications.v1.NotificationInstallationRef',
      '10': 'installation'
    },
  ],
  '8': [
    {'1': '_event_id'},
    {'1': '_recipient_actor_id'},
  ],
};

/// Descriptor for `NotificationDeliveryEnvelope`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List notificationDeliveryEnvelopeDescriptor = $convert.base64Decode(
    'ChxOb3RpZmljYXRpb25EZWxpdmVyeUVudmVsb3BlEh4KCGV2ZW50X2lkGAEgASgJSABSB2V2ZW'
    '50SWSIAQESMQoScmVjaXBpZW50X2FjdG9yX2lkGAIgASgJSAFSEHJlY2lwaWVudEFjdG9ySWSI'
    'AQESVgoMaW5zdGFsbGF0aW9uGAMgASgLMjIubW9ieS5ub3RpZmljYXRpb25zLnYxLk5vdGlmaW'
    'NhdGlvbkluc3RhbGxhdGlvblJlZlIMaW5zdGFsbGF0aW9uQgsKCV9ldmVudF9pZEIVChNfcmVj'
    'aXBpZW50X2FjdG9yX2lk');

@$core.Deprecated('Use notificationDeliveryReceiptDescriptor instead')
const NotificationDeliveryReceipt$json = {
  '1': 'NotificationDeliveryReceipt',
  '2': [
    {
      '1': 'event_id',
      '3': 1,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'eventId',
      '17': true
    },
    {
      '1': 'installation_id',
      '3': 2,
      '4': 1,
      '5': 9,
      '9': 1,
      '10': 'installationId',
      '17': true
    },
    {
      '1': 'status',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.moby.notifications.v1.NotificationDeliveryStatus',
      '9': 2,
      '10': 'status',
      '17': true
    },
  ],
  '8': [
    {'1': '_event_id'},
    {'1': '_installation_id'},
    {'1': '_status'},
  ],
};

/// Descriptor for `NotificationDeliveryReceipt`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List notificationDeliveryReceiptDescriptor = $convert.base64Decode(
    'ChtOb3RpZmljYXRpb25EZWxpdmVyeVJlY2VpcHQSHgoIZXZlbnRfaWQYASABKAlIAFIHZXZlbn'
    'RJZIgBARIsCg9pbnN0YWxsYXRpb25faWQYAiABKAlIAVIOaW5zdGFsbGF0aW9uSWSIAQESTgoG'
    'c3RhdHVzGAMgASgOMjEubW9ieS5ub3RpZmljYXRpb25zLnYxLk5vdGlmaWNhdGlvbkRlbGl2ZX'
    'J5U3RhdHVzSAJSBnN0YXR1c4gBAUILCglfZXZlbnRfaWRCEgoQX2luc3RhbGxhdGlvbl9pZEIJ'
    'Cgdfc3RhdHVz');
