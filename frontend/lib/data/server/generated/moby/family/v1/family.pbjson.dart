// This is a generated file - do not edit.
//
// Generated from moby/family/v1/family.proto.

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

@$core.Deprecated('Use emptyDescriptor instead')
const Empty$json = {
  '1': 'Empty',
};

/// Descriptor for `Empty`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List emptyDescriptor =
    $convert.base64Decode('CgVFbXB0eQ==');

@$core.Deprecated('Use domainErrorDetailDescriptor instead')
const DomainErrorDetail$json = {
  '1': 'DomainErrorDetail',
  '2': [
    {'1': 'semantic_status', '3': 1, '4': 1, '5': 5, '10': 'semanticStatus'},
    {'1': 'code', '3': 2, '4': 1, '5': 9, '10': 'code'},
  ],
};

/// Descriptor for `DomainErrorDetail`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List domainErrorDetailDescriptor = $convert.base64Decode(
    'ChFEb21haW5FcnJvckRldGFpbBInCg9zZW1hbnRpY19zdGF0dXMYASABKAVSDnNlbWFudGljU3'
    'RhdHVzEhIKBGNvZGUYAiABKAlSBGNvZGU=');

@$core.Deprecated('Use loginAdultRequestDescriptor instead')
const LoginAdultRequest$json = {
  '1': 'LoginAdultRequest',
  '2': [
    {
      '1': 'bootstrap_secret',
      '3': 1,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'bootstrapSecret',
      '17': true
    },
    {
      '1': 'device_name',
      '3': 2,
      '4': 1,
      '5': 9,
      '9': 1,
      '10': 'deviceName',
      '17': true
    },
  ],
  '8': [
    {'1': '_bootstrap_secret'},
    {'1': '_device_name'},
  ],
};

/// Descriptor for `LoginAdultRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loginAdultRequestDescriptor = $convert.base64Decode(
    'ChFMb2dpbkFkdWx0UmVxdWVzdBIuChBib290c3RyYXBfc2VjcmV0GAEgASgJSABSD2Jvb3RzdH'
    'JhcFNlY3JldIgBARIkCgtkZXZpY2VfbmFtZRgCIAEoCUgBUgpkZXZpY2VOYW1liAEBQhMKEV9i'
    'b290c3RyYXBfc2VjcmV0Qg4KDF9kZXZpY2VfbmFtZQ==');

@$core.Deprecated('Use sessionGrantDescriptor instead')
const SessionGrant$json = {
  '1': 'SessionGrant',
  '2': [
    {'1': 'token', '3': 1, '4': 1, '5': 9, '9': 0, '10': 'token', '17': true},
    {
      '1': 'actor',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.moby.family.v1.Actor',
      '10': 'actor'
    },
    {
      '1': 'expires_at',
      '3': 3,
      '4': 1,
      '5': 3,
      '9': 1,
      '10': 'expiresAt',
      '17': true
    },
  ],
  '8': [
    {'1': '_token'},
    {'1': '_expires_at'},
  ],
};

/// Descriptor for `SessionGrant`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sessionGrantDescriptor = $convert.base64Decode(
    'CgxTZXNzaW9uR3JhbnQSGQoFdG9rZW4YASABKAlIAFIFdG9rZW6IAQESKwoFYWN0b3IYAiABKA'
    'syFS5tb2J5LmZhbWlseS52MS5BY3RvclIFYWN0b3ISIgoKZXhwaXJlc19hdBgDIAEoA0gBUgll'
    'eHBpcmVzQXSIAQFCCAoGX3Rva2VuQg0KC19leHBpcmVzX2F0');

@$core.Deprecated('Use childRefDescriptor instead')
const ChildRef$json = {
  '1': 'ChildRef',
  '2': [
    {
      '1': 'child_id',
      '3': 1,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'childId',
      '17': true
    },
  ],
  '8': [
    {'1': '_child_id'},
  ],
};

/// Descriptor for `ChildRef`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List childRefDescriptor = $convert.base64Decode(
    'CghDaGlsZFJlZhIeCghjaGlsZF9pZBgBIAEoCUgAUgdjaGlsZElkiAEBQgsKCV9jaGlsZF9pZA'
    '==');

@$core.Deprecated('Use sessionRefDescriptor instead')
const SessionRef$json = {
  '1': 'SessionRef',
  '2': [
    {
      '1': 'session_id',
      '3': 1,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'sessionId',
      '17': true
    },
  ],
  '8': [
    {'1': '_session_id'},
  ],
};

/// Descriptor for `SessionRef`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sessionRefDescriptor = $convert.base64Decode(
    'CgpTZXNzaW9uUmVmEiIKCnNlc3Npb25faWQYASABKAlIAFIJc2Vzc2lvbklkiAEBQg0KC19zZX'
    'NzaW9uX2lk');

@$core.Deprecated('Use createChildRequestDescriptor instead')
const CreateChildRequest$json = {
  '1': 'CreateChildRequest',
  '2': [
    {
      '1': 'display_name',
      '3': 1,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'displayName',
      '17': true
    },
    {
      '1': 'legal_name',
      '3': 2,
      '4': 1,
      '5': 9,
      '9': 1,
      '10': 'legalName',
      '17': true
    },
    {
      '1': 'date_of_birth',
      '3': 3,
      '4': 1,
      '5': 9,
      '9': 2,
      '10': 'dateOfBirth',
      '17': true
    },
    {
      '1': 'idempotency_key',
      '3': 4,
      '4': 1,
      '5': 9,
      '9': 3,
      '10': 'idempotencyKey',
      '17': true
    },
  ],
  '8': [
    {'1': '_display_name'},
    {'1': '_legal_name'},
    {'1': '_date_of_birth'},
    {'1': '_idempotency_key'},
  ],
};

/// Descriptor for `CreateChildRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createChildRequestDescriptor = $convert.base64Decode(
    'ChJDcmVhdGVDaGlsZFJlcXVlc3QSJgoMZGlzcGxheV9uYW1lGAEgASgJSABSC2Rpc3BsYXlOYW'
    '1liAEBEiIKCmxlZ2FsX25hbWUYAiABKAlIAVIJbGVnYWxOYW1liAEBEicKDWRhdGVfb2ZfYmly'
    'dGgYAyABKAlIAlILZGF0ZU9mQmlydGiIAQESLAoPaWRlbXBvdGVuY3lfa2V5GAQgASgJSANSDm'
    'lkZW1wb3RlbmN5S2V5iAEBQg8KDV9kaXNwbGF5X25hbWVCDQoLX2xlZ2FsX25hbWVCEAoOX2Rh'
    'dGVfb2ZfYmlydGhCEgoQX2lkZW1wb3RlbmN5X2tleQ==');

@$core.Deprecated('Use childPatchDescriptor instead')
const ChildPatch$json = {
  '1': 'ChildPatch',
  '2': [
    {
      '1': 'display_name',
      '3': 1,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'displayName',
      '17': true
    },
    {
      '1': 'legal_name',
      '3': 2,
      '4': 1,
      '5': 9,
      '9': 1,
      '10': 'legalName',
      '17': true
    },
    {
      '1': 'date_of_birth',
      '3': 3,
      '4': 1,
      '5': 9,
      '9': 2,
      '10': 'dateOfBirth',
      '17': true
    },
    {
      '1': 'card_status',
      '3': 4,
      '4': 1,
      '5': 9,
      '9': 3,
      '10': 'cardStatus',
      '17': true
    },
  ],
  '8': [
    {'1': '_display_name'},
    {'1': '_legal_name'},
    {'1': '_date_of_birth'},
    {'1': '_card_status'},
  ],
};

/// Descriptor for `ChildPatch`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List childPatchDescriptor = $convert.base64Decode(
    'CgpDaGlsZFBhdGNoEiYKDGRpc3BsYXlfbmFtZRgBIAEoCUgAUgtkaXNwbGF5TmFtZYgBARIiCg'
    'psZWdhbF9uYW1lGAIgASgJSAFSCWxlZ2FsTmFtZYgBARInCg1kYXRlX29mX2JpcnRoGAMgASgJ'
    'SAJSC2RhdGVPZkJpcnRoiAEBEiQKC2NhcmRfc3RhdHVzGAQgASgJSANSCmNhcmRTdGF0dXOIAQ'
    'FCDwoNX2Rpc3BsYXlfbmFtZUINCgtfbGVnYWxfbmFtZUIQCg5fZGF0ZV9vZl9iaXJ0aEIOCgxf'
    'Y2FyZF9zdGF0dXM=');

@$core.Deprecated('Use updateChildRequestDescriptor instead')
const UpdateChildRequest$json = {
  '1': 'UpdateChildRequest',
  '2': [
    {
      '1': 'child_id',
      '3': 1,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'childId',
      '17': true
    },
    {
      '1': 'patch',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.moby.family.v1.ChildPatch',
      '10': 'patch'
    },
  ],
  '8': [
    {'1': '_child_id'},
  ],
};

/// Descriptor for `UpdateChildRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateChildRequestDescriptor = $convert.base64Decode(
    'ChJVcGRhdGVDaGlsZFJlcXVlc3QSHgoIY2hpbGRfaWQYASABKAlIAFIHY2hpbGRJZIgBARIwCg'
    'VwYXRjaBgCIAEoCzIaLm1vYnkuZmFtaWx5LnYxLkNoaWxkUGF0Y2hSBXBhdGNoQgsKCV9jaGls'
    'ZF9pZA==');

@$core.Deprecated('Use updatePolicyRequestDescriptor instead')
const UpdatePolicyRequest$json = {
  '1': 'UpdatePolicyRequest',
  '2': [
    {
      '1': 'child_id',
      '3': 1,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'childId',
      '17': true
    },
    {
      '1': 'policy',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.moby.family.v1.Policy',
      '10': 'policy'
    },
  ],
  '8': [
    {'1': '_child_id'},
  ],
};

/// Descriptor for `UpdatePolicyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updatePolicyRequestDescriptor = $convert.base64Decode(
    'ChNVcGRhdGVQb2xpY3lSZXF1ZXN0Eh4KCGNoaWxkX2lkGAEgASgJSABSB2NoaWxkSWSIAQESLg'
    'oGcG9saWN5GAIgASgLMhYubW9ieS5mYW1pbHkudjEuUG9saWN5UgZwb2xpY3lCCwoJX2NoaWxk'
    'X2lk');

@$core.Deprecated('Use verifyChildRequestDescriptor instead')
const VerifyChildRequest$json = {
  '1': 'VerifyChildRequest',
  '2': [
    {
      '1': 'child_id',
      '3': 1,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'childId',
      '17': true
    },
    {
      '1': 'outcome',
      '3': 2,
      '4': 1,
      '5': 9,
      '9': 1,
      '10': 'outcome',
      '17': true
    },
  ],
  '8': [
    {'1': '_child_id'},
    {'1': '_outcome'},
  ],
};

/// Descriptor for `VerifyChildRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List verifyChildRequestDescriptor = $convert.base64Decode(
    'ChJWZXJpZnlDaGlsZFJlcXVlc3QSHgoIY2hpbGRfaWQYASABKAlIAFIHY2hpbGRJZIgBARIdCg'
    'dvdXRjb21lGAIgASgJSAFSB291dGNvbWWIAQFCCwoJX2NoaWxkX2lkQgoKCF9vdXRjb21l');

@$core.Deprecated('Use openProductRequestDescriptor instead')
const OpenProductRequest$json = {
  '1': 'OpenProductRequest',
  '2': [
    {
      '1': 'child_id',
      '3': 1,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'childId',
      '17': true
    },
    {
      '1': 'agreement_version',
      '3': 2,
      '4': 1,
      '5': 9,
      '9': 1,
      '10': 'agreementVersion',
      '17': true
    },
    {
      '1': 'signer_consent',
      '3': 3,
      '4': 1,
      '5': 8,
      '9': 2,
      '10': 'signerConsent',
      '17': true
    },
  ],
  '8': [
    {'1': '_child_id'},
    {'1': '_agreement_version'},
    {'1': '_signer_consent'},
  ],
};

/// Descriptor for `OpenProductRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List openProductRequestDescriptor = $convert.base64Decode(
    'ChJPcGVuUHJvZHVjdFJlcXVlc3QSHgoIY2hpbGRfaWQYASABKAlIAFIHY2hpbGRJZIgBARIwCh'
    'FhZ3JlZW1lbnRfdmVyc2lvbhgCIAEoCUgBUhBhZ3JlZW1lbnRWZXJzaW9uiAEBEioKDnNpZ25l'
    'cl9jb25zZW50GAMgASgISAJSDXNpZ25lckNvbnNlbnSIAQFCCwoJX2NoaWxkX2lkQhQKEl9hZ3'
    'JlZW1lbnRfdmVyc2lvbkIRCg9fc2lnbmVyX2NvbnNlbnQ=');

@$core.Deprecated('Use moneyInputDescriptor instead')
const MoneyInput$json = {
  '1': 'MoneyInput',
  '2': [
    {
      '1': 'amount_minor',
      '3': 1,
      '4': 1,
      '5': 3,
      '9': 0,
      '10': 'amountMinor',
      '17': true
    },
    {
      '1': 'currency',
      '3': 2,
      '4': 1,
      '5': 9,
      '9': 1,
      '10': 'currency',
      '17': true
    },
    {
      '1': 'channel',
      '3': 3,
      '4': 1,
      '5': 9,
      '9': 2,
      '10': 'channel',
      '17': true
    },
    {
      '1': 'category',
      '3': 4,
      '4': 1,
      '5': 9,
      '9': 3,
      '10': 'category',
      '17': true
    },
    {
      '1': 'merchant',
      '3': 5,
      '4': 1,
      '5': 9,
      '9': 4,
      '10': 'merchant',
      '17': true
    },
    {
      '1': 'idempotency_key',
      '3': 6,
      '4': 1,
      '5': 9,
      '9': 5,
      '10': 'idempotencyKey',
      '17': true
    },
  ],
  '8': [
    {'1': '_amount_minor'},
    {'1': '_currency'},
    {'1': '_channel'},
    {'1': '_category'},
    {'1': '_merchant'},
    {'1': '_idempotency_key'},
  ],
};

/// Descriptor for `MoneyInput`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List moneyInputDescriptor = $convert.base64Decode(
    'CgpNb25leUlucHV0EiYKDGFtb3VudF9taW5vchgBIAEoA0gAUgthbW91bnRNaW5vcogBARIfCg'
    'hjdXJyZW5jeRgCIAEoCUgBUghjdXJyZW5jeYgBARIdCgdjaGFubmVsGAMgASgJSAJSB2NoYW5u'
    'ZWyIAQESHwoIY2F0ZWdvcnkYBCABKAlIA1IIY2F0ZWdvcnmIAQESHwoIbWVyY2hhbnQYBSABKA'
    'lIBFIIbWVyY2hhbnSIAQESLAoPaWRlbXBvdGVuY3lfa2V5GAYgASgJSAVSDmlkZW1wb3RlbmN5'
    'S2V5iAEBQg8KDV9hbW91bnRfbWlub3JCCwoJX2N1cnJlbmN5QgoKCF9jaGFubmVsQgsKCV9jYX'
    'RlZ29yeUILCglfbWVyY2hhbnRCEgoQX2lkZW1wb3RlbmN5X2tleQ==');

@$core.Deprecated('Use childMoneyRequestDescriptor instead')
const ChildMoneyRequest$json = {
  '1': 'ChildMoneyRequest',
  '2': [
    {
      '1': 'child_id',
      '3': 1,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'childId',
      '17': true
    },
    {
      '1': 'input',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.moby.family.v1.MoneyInput',
      '10': 'input'
    },
  ],
  '8': [
    {'1': '_child_id'},
  ],
};

/// Descriptor for `ChildMoneyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List childMoneyRequestDescriptor = $convert.base64Decode(
    'ChFDaGlsZE1vbmV5UmVxdWVzdBIeCghjaGlsZF9pZBgBIAEoCUgAUgdjaGlsZElkiAEBEjAKBW'
    'lucHV0GAIgASgLMhoubW9ieS5mYW1pbHkudjEuTW9uZXlJbnB1dFIFaW5wdXRCCwoJX2NoaWxk'
    'X2lk');

@$core.Deprecated('Use decideOperationRequestDescriptor instead')
const DecideOperationRequest$json = {
  '1': 'DecideOperationRequest',
  '2': [
    {
      '1': 'operation_id',
      '3': 1,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'operationId',
      '17': true
    },
    {
      '1': 'approve',
      '3': 2,
      '4': 1,
      '5': 8,
      '9': 1,
      '10': 'approve',
      '17': true
    },
  ],
  '8': [
    {'1': '_operation_id'},
    {'1': '_approve'},
  ],
};

/// Descriptor for `DecideOperationRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List decideOperationRequestDescriptor = $convert.base64Decode(
    'ChZEZWNpZGVPcGVyYXRpb25SZXF1ZXN0EiYKDG9wZXJhdGlvbl9pZBgBIAEoCUgAUgtvcGVyYX'
    'Rpb25JZIgBARIdCgdhcHByb3ZlGAIgASgISAFSB2FwcHJvdmWIAQFCDwoNX29wZXJhdGlvbl9p'
    'ZEIKCghfYXBwcm92ZQ==');

@$core.Deprecated('Use childrenListDescriptor instead')
const ChildrenList$json = {
  '1': 'ChildrenList',
  '2': [
    {
      '1': 'children',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.moby.family.v1.Child',
      '10': 'children'
    },
  ],
};

/// Descriptor for `ChildrenList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List childrenListDescriptor = $convert.base64Decode(
    'CgxDaGlsZHJlbkxpc3QSMQoIY2hpbGRyZW4YASADKAsyFS5tb2J5LmZhbWlseS52MS5DaGlsZF'
    'IIY2hpbGRyZW4=');

@$core.Deprecated('Use createPairingRequestDescriptor instead')
const CreatePairingRequest$json = {
  '1': 'CreatePairingRequest',
  '2': [
    {
      '1': 'device_name',
      '3': 1,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'deviceName',
      '17': true
    },
  ],
  '8': [
    {'1': '_device_name'},
  ],
};

/// Descriptor for `CreatePairingRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createPairingRequestDescriptor = $convert.base64Decode(
    'ChRDcmVhdGVQYWlyaW5nUmVxdWVzdBIkCgtkZXZpY2VfbmFtZRgBIAEoCUgAUgpkZXZpY2VOYW'
    '1liAEBQg4KDF9kZXZpY2VfbmFtZQ==');

@$core.Deprecated('Use consumePairingRequestDescriptor instead')
const ConsumePairingRequest$json = {
  '1': 'ConsumePairingRequest',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 9, '9': 0, '10': 'code', '17': true},
    {
      '1': 'child_id',
      '3': 2,
      '4': 1,
      '5': 9,
      '9': 1,
      '10': 'childId',
      '17': true
    },
  ],
  '8': [
    {'1': '_code'},
    {'1': '_child_id'},
  ],
};

/// Descriptor for `ConsumePairingRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List consumePairingRequestDescriptor = $convert.base64Decode(
    'ChVDb25zdW1lUGFpcmluZ1JlcXVlc3QSFwoEY29kZRgBIAEoCUgAUgRjb2RliAEBEh4KCGNoaW'
    'xkX2lkGAIgASgJSAFSB2NoaWxkSWSIAQFCBwoFX2NvZGVCCwoJX2NoaWxkX2lk');

@$core.Deprecated('Use pairingSecretRequestDescriptor instead')
const PairingSecretRequest$json = {
  '1': 'PairingSecretRequest',
  '2': [
    {
      '1': 'pairing_id',
      '3': 1,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'pairingId',
      '17': true
    },
    {
      '1': 'request_secret',
      '3': 2,
      '4': 1,
      '5': 9,
      '9': 1,
      '10': 'requestSecret',
      '17': true
    },
  ],
  '8': [
    {'1': '_pairing_id'},
    {'1': '_request_secret'},
  ],
};

/// Descriptor for `PairingSecretRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pairingSecretRequestDescriptor = $convert.base64Decode(
    'ChRQYWlyaW5nU2VjcmV0UmVxdWVzdBIiCgpwYWlyaW5nX2lkGAEgASgJSABSCXBhaXJpbmdJZI'
    'gBARIqCg5yZXF1ZXN0X3NlY3JldBgCIAEoCUgBUg1yZXF1ZXN0U2VjcmV0iAEBQg0KC19wYWly'
    'aW5nX2lkQhEKD19yZXF1ZXN0X3NlY3JldA==');

@$core.Deprecated('Use pairingCreatedDescriptor instead')
const PairingCreated$json = {
  '1': 'PairingCreated',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '9': 0, '10': 'id', '17': true},
    {'1': 'code', '3': 2, '4': 1, '5': 9, '9': 1, '10': 'code', '17': true},
    {
      '1': 'request_secret',
      '3': 3,
      '4': 1,
      '5': 9,
      '9': 2,
      '10': 'requestSecret',
      '17': true
    },
    {
      '1': 'expires_at',
      '3': 4,
      '4': 1,
      '5': 3,
      '9': 3,
      '10': 'expiresAt',
      '17': true
    },
    {'1': 'status', '3': 5, '4': 1, '5': 9, '9': 4, '10': 'status', '17': true},
  ],
  '8': [
    {'1': '_id'},
    {'1': '_code'},
    {'1': '_request_secret'},
    {'1': '_expires_at'},
    {'1': '_status'},
  ],
};

/// Descriptor for `PairingCreated`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pairingCreatedDescriptor = $convert.base64Decode(
    'Cg5QYWlyaW5nQ3JlYXRlZBITCgJpZBgBIAEoCUgAUgJpZIgBARIXCgRjb2RlGAIgASgJSAFSBG'
    'NvZGWIAQESKgoOcmVxdWVzdF9zZWNyZXQYAyABKAlIAlINcmVxdWVzdFNlY3JldIgBARIiCgpl'
    'eHBpcmVzX2F0GAQgASgDSANSCWV4cGlyZXNBdIgBARIbCgZzdGF0dXMYBSABKAlIBFIGc3RhdH'
    'VziAEBQgUKA19pZEIHCgVfY29kZUIRCg9fcmVxdWVzdF9zZWNyZXRCDQoLX2V4cGlyZXNfYXRC'
    'CQoHX3N0YXR1cw==');

@$core.Deprecated('Use pairingResultDescriptor instead')
const PairingResult$json = {
  '1': 'PairingResult',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '9': 0, '10': 'id', '17': true},
    {'1': 'status', '3': 2, '4': 1, '5': 9, '9': 1, '10': 'status', '17': true},
    {
      '1': 'child_id',
      '3': 3,
      '4': 1,
      '5': 9,
      '9': 2,
      '10': 'childId',
      '17': true
    },
  ],
  '8': [
    {'1': '_id'},
    {'1': '_status'},
    {'1': '_child_id'},
  ],
};

/// Descriptor for `PairingResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pairingResultDescriptor = $convert.base64Decode(
    'Cg1QYWlyaW5nUmVzdWx0EhMKAmlkGAEgASgJSABSAmlkiAEBEhsKBnN0YXR1cxgCIAEoCUgBUg'
    'ZzdGF0dXOIAQESHgoIY2hpbGRfaWQYAyABKAlIAlIHY2hpbGRJZIgBAUIFCgNfaWRCCQoHX3N0'
    'YXR1c0ILCglfY2hpbGRfaWQ=');

@$core.Deprecated('Use pairingPollDescriptor instead')
const PairingPoll$json = {
  '1': 'PairingPoll',
  '2': [
    {'1': 'status', '3': 1, '4': 1, '5': 9, '9': 0, '10': 'status', '17': true},
    {
      '1': 'session',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.moby.family.v1.SessionGrant',
      '10': 'session'
    },
  ],
  '8': [
    {'1': '_status'},
  ],
};

/// Descriptor for `PairingPoll`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pairingPollDescriptor = $convert.base64Decode(
    'CgtQYWlyaW5nUG9sbBIbCgZzdGF0dXMYASABKAlIAFIGc3RhdHVziAEBEjYKB3Nlc3Npb24YAi'
    'ABKAsyHC5tb2J5LmZhbWlseS52MS5TZXNzaW9uR3JhbnRSB3Nlc3Npb25CCQoHX3N0YXR1cw==');

@$core.Deprecated('Use sessionSummaryDescriptor instead')
const SessionSummary$json = {
  '1': 'SessionSummary',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '9': 0, '10': 'id', '17': true},
    {'1': 'role', '3': 2, '4': 1, '5': 9, '9': 1, '10': 'role', '17': true},
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
      '1': 'device_name',
      '3': 4,
      '4': 1,
      '5': 9,
      '9': 3,
      '10': 'deviceName',
      '17': true
    },
    {
      '1': 'expires_at',
      '3': 5,
      '4': 1,
      '5': 3,
      '9': 4,
      '10': 'expiresAt',
      '17': true
    },
    {
      '1': 'revoked',
      '3': 6,
      '4': 1,
      '5': 8,
      '9': 5,
      '10': 'revoked',
      '17': true
    },
  ],
  '8': [
    {'1': '_id'},
    {'1': '_role'},
    {'1': '_child_id'},
    {'1': '_device_name'},
    {'1': '_expires_at'},
    {'1': '_revoked'},
  ],
};

/// Descriptor for `SessionSummary`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sessionSummaryDescriptor = $convert.base64Decode(
    'Cg5TZXNzaW9uU3VtbWFyeRITCgJpZBgBIAEoCUgAUgJpZIgBARIXCgRyb2xlGAIgASgJSAFSBH'
    'JvbGWIAQESHgoIY2hpbGRfaWQYAyABKAlIAlIHY2hpbGRJZIgBARIkCgtkZXZpY2VfbmFtZRgE'
    'IAEoCUgDUgpkZXZpY2VOYW1liAEBEiIKCmV4cGlyZXNfYXQYBSABKANIBFIJZXhwaXJlc0F0iA'
    'EBEh0KB3Jldm9rZWQYBiABKAhIBVIHcmV2b2tlZIgBAUIFCgNfaWRCBwoFX3JvbGVCCwoJX2No'
    'aWxkX2lkQg4KDF9kZXZpY2VfbmFtZUINCgtfZXhwaXJlc19hdEIKCghfcmV2b2tlZA==');

@$core.Deprecated('Use sessionsListDescriptor instead')
const SessionsList$json = {
  '1': 'SessionsList',
  '2': [
    {
      '1': 'sessions',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.moby.family.v1.SessionSummary',
      '10': 'sessions'
    },
  ],
};

/// Descriptor for `SessionsList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sessionsListDescriptor = $convert.base64Decode(
    'CgxTZXNzaW9uc0xpc3QSOgoIc2Vzc2lvbnMYASADKAsyHi5tb2J5LmZhbWlseS52MS5TZXNzaW'
    '9uU3VtbWFyeVIIc2Vzc2lvbnM=');

@$core.Deprecated('Use categoryRulesDescriptor instead')
const CategoryRules$json = {
  '1': 'CategoryRules',
  '2': [
    {
      '1': 'values',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.moby.family.v1.CategoryRules.ValuesEntry',
      '10': 'values'
    },
  ],
  '3': [CategoryRules_ValuesEntry$json],
};

@$core.Deprecated('Use categoryRulesDescriptor instead')
const CategoryRules_ValuesEntry$json = {
  '1': 'ValuesEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 8, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `CategoryRules`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List categoryRulesDescriptor = $convert.base64Decode(
    'Cg1DYXRlZ29yeVJ1bGVzEkEKBnZhbHVlcxgBIAMoCzIpLm1vYnkuZmFtaWx5LnYxLkNhdGVnb3'
    'J5UnVsZXMuVmFsdWVzRW50cnlSBnZhbHVlcxo5CgtWYWx1ZXNFbnRyeRIQCgNrZXkYASABKAlS'
    'A2tleRIUCgV2YWx1ZRgCIAEoCFIFdmFsdWU6AjgB');

@$core.Deprecated('Use policyDescriptor instead')
const Policy$json = {
  '1': 'Policy',
  '2': [
    {
      '1': 'categories',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.moby.family.v1.CategoryRules',
      '10': 'categories'
    },
    {
      '1': 'payments',
      '3': 2,
      '4': 1,
      '5': 8,
      '9': 0,
      '10': 'payments',
      '17': true
    },
    {
      '1': 'transfers',
      '3': 3,
      '4': 1,
      '5': 8,
      '9': 1,
      '10': 'transfers',
      '17': true
    },
    {
      '1': 'internet',
      '3': 4,
      '4': 1,
      '5': 8,
      '9': 2,
      '10': 'internet',
      '17': true
    },
    {
      '1': 'daily_limit',
      '3': 5,
      '4': 1,
      '5': 3,
      '9': 3,
      '10': 'dailyLimit',
      '17': true
    },
    {
      '1': 'monthly_limit',
      '3': 6,
      '4': 1,
      '5': 3,
      '9': 4,
      '10': 'monthlyLimit',
      '17': true
    },
    {
      '1': 'approval_threshold',
      '3': 7,
      '4': 1,
      '5': 3,
      '9': 5,
      '10': 'approvalThreshold',
      '17': true
    },
  ],
  '8': [
    {'1': '_payments'},
    {'1': '_transfers'},
    {'1': '_internet'},
    {'1': '_daily_limit'},
    {'1': '_monthly_limit'},
    {'1': '_approval_threshold'},
  ],
};

/// Descriptor for `Policy`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List policyDescriptor = $convert.base64Decode(
    'CgZQb2xpY3kSPQoKY2F0ZWdvcmllcxgBIAEoCzIdLm1vYnkuZmFtaWx5LnYxLkNhdGVnb3J5Un'
    'VsZXNSCmNhdGVnb3JpZXMSHwoIcGF5bWVudHMYAiABKAhIAFIIcGF5bWVudHOIAQESIQoJdHJh'
    'bnNmZXJzGAMgASgISAFSCXRyYW5zZmVyc4gBARIfCghpbnRlcm5ldBgEIAEoCEgCUghpbnRlcm'
    '5ldIgBARIkCgtkYWlseV9saW1pdBgFIAEoA0gDUgpkYWlseUxpbWl0iAEBEigKDW1vbnRobHlf'
    'bGltaXQYBiABKANIBFIMbW9udGhseUxpbWl0iAEBEjIKEmFwcHJvdmFsX3RocmVzaG9sZBgHIA'
    'EoA0gFUhFhcHByb3ZhbFRocmVzaG9sZIgBAUILCglfcGF5bWVudHNCDAoKX3RyYW5zZmVyc0IL'
    'CglfaW50ZXJuZXRCDgoMX2RhaWx5X2xpbWl0QhAKDl9tb250aGx5X2xpbWl0QhUKE19hcHByb3'
    'ZhbF90aHJlc2hvbGQ=');

@$core.Deprecated('Use childDescriptor instead')
const Child$json = {
  '1': 'Child',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '9': 0, '10': 'id', '17': true},
    {
      '1': 'display_name',
      '3': 2,
      '4': 1,
      '5': 9,
      '9': 1,
      '10': 'displayName',
      '17': true
    },
    {
      '1': 'legal_name',
      '3': 3,
      '4': 1,
      '5': 9,
      '9': 2,
      '10': 'legalName',
      '17': true
    },
    {
      '1': 'date_of_birth',
      '3': 4,
      '4': 1,
      '5': 9,
      '9': 3,
      '10': 'dateOfBirth',
      '17': true
    },
    {
      '1': 'identity_status',
      '3': 5,
      '4': 1,
      '5': 9,
      '9': 4,
      '10': 'identityStatus',
      '17': true
    },
    {
      '1': 'representation_status',
      '3': 6,
      '4': 1,
      '5': 9,
      '9': 5,
      '10': 'representationStatus',
      '17': true
    },
    {
      '1': 'agreement_status',
      '3': 7,
      '4': 1,
      '5': 9,
      '9': 6,
      '10': 'agreementStatus',
      '17': true
    },
    {
      '1': 'account_status',
      '3': 8,
      '4': 1,
      '5': 9,
      '9': 7,
      '10': 'accountStatus',
      '17': true
    },
    {
      '1': 'card_status',
      '3': 9,
      '4': 1,
      '5': 9,
      '9': 8,
      '10': 'cardStatus',
      '17': true
    },
    {
      '1': 'device_access_status',
      '3': 10,
      '4': 1,
      '5': 9,
      '9': 9,
      '10': 'deviceAccessStatus',
      '17': true
    },
    {
      '1': 'membership_status',
      '3': 11,
      '4': 1,
      '5': 9,
      '9': 10,
      '10': 'membershipStatus',
      '17': true
    },
    {
      '1': 'policy',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.moby.family.v1.Policy',
      '10': 'policy'
    },
    {
      '1': 'balance_minor',
      '3': 13,
      '4': 1,
      '5': 3,
      '9': 11,
      '10': 'balanceMinor',
      '17': true
    },
    {
      '1': 'currency',
      '3': 14,
      '4': 1,
      '5': 9,
      '9': 12,
      '10': 'currency',
      '17': true
    },
    {
      '1': 'agreement_version',
      '3': 15,
      '4': 1,
      '5': 9,
      '9': 13,
      '10': 'agreementVersion',
      '17': true
    },
    {
      '1': 'signer_id',
      '3': 16,
      '4': 1,
      '5': 9,
      '9': 14,
      '10': 'signerId',
      '17': true
    },
    {
      '1': 'signed_at',
      '3': 17,
      '4': 1,
      '5': 3,
      '9': 15,
      '10': 'signedAt',
      '17': true
    },
    {
      '1': 'version',
      '3': 18,
      '4': 1,
      '5': 3,
      '9': 16,
      '10': 'version',
      '17': true
    },
  ],
  '8': [
    {'1': '_id'},
    {'1': '_display_name'},
    {'1': '_legal_name'},
    {'1': '_date_of_birth'},
    {'1': '_identity_status'},
    {'1': '_representation_status'},
    {'1': '_agreement_status'},
    {'1': '_account_status'},
    {'1': '_card_status'},
    {'1': '_device_access_status'},
    {'1': '_membership_status'},
    {'1': '_balance_minor'},
    {'1': '_currency'},
    {'1': '_agreement_version'},
    {'1': '_signer_id'},
    {'1': '_signed_at'},
    {'1': '_version'},
  ],
};

/// Descriptor for `Child`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List childDescriptor = $convert.base64Decode(
    'CgVDaGlsZBITCgJpZBgBIAEoCUgAUgJpZIgBARImCgxkaXNwbGF5X25hbWUYAiABKAlIAVILZG'
    'lzcGxheU5hbWWIAQESIgoKbGVnYWxfbmFtZRgDIAEoCUgCUglsZWdhbE5hbWWIAQESJwoNZGF0'
    'ZV9vZl9iaXJ0aBgEIAEoCUgDUgtkYXRlT2ZCaXJ0aIgBARIsCg9pZGVudGl0eV9zdGF0dXMYBS'
    'ABKAlIBFIOaWRlbnRpdHlTdGF0dXOIAQESOAoVcmVwcmVzZW50YXRpb25fc3RhdHVzGAYgASgJ'
    'SAVSFHJlcHJlc2VudGF0aW9uU3RhdHVziAEBEi4KEGFncmVlbWVudF9zdGF0dXMYByABKAlIBl'
    'IPYWdyZWVtZW50U3RhdHVziAEBEioKDmFjY291bnRfc3RhdHVzGAggASgJSAdSDWFjY291bnRT'
    'dGF0dXOIAQESJAoLY2FyZF9zdGF0dXMYCSABKAlICFIKY2FyZFN0YXR1c4gBARI1ChRkZXZpY2'
    'VfYWNjZXNzX3N0YXR1cxgKIAEoCUgJUhJkZXZpY2VBY2Nlc3NTdGF0dXOIAQESMAoRbWVtYmVy'
    'c2hpcF9zdGF0dXMYCyABKAlIClIQbWVtYmVyc2hpcFN0YXR1c4gBARIuCgZwb2xpY3kYDCABKA'
    'syFi5tb2J5LmZhbWlseS52MS5Qb2xpY3lSBnBvbGljeRIoCg1iYWxhbmNlX21pbm9yGA0gASgD'
    'SAtSDGJhbGFuY2VNaW5vcogBARIfCghjdXJyZW5jeRgOIAEoCUgMUghjdXJyZW5jeYgBARIwCh'
    'FhZ3JlZW1lbnRfdmVyc2lvbhgPIAEoCUgNUhBhZ3JlZW1lbnRWZXJzaW9uiAEBEiAKCXNpZ25l'
    'cl9pZBgQIAEoCUgOUghzaWduZXJJZIgBARIgCglzaWduZWRfYXQYESABKANID1IIc2lnbmVkQX'
    'SIAQESHQoHdmVyc2lvbhgSIAEoA0gQUgd2ZXJzaW9uiAEBQgUKA19pZEIPCg1fZGlzcGxheV9u'
    'YW1lQg0KC19sZWdhbF9uYW1lQhAKDl9kYXRlX29mX2JpcnRoQhIKEF9pZGVudGl0eV9zdGF0dX'
    'NCGAoWX3JlcHJlc2VudGF0aW9uX3N0YXR1c0ITChFfYWdyZWVtZW50X3N0YXR1c0IRCg9fYWNj'
    'b3VudF9zdGF0dXNCDgoMX2NhcmRfc3RhdHVzQhcKFV9kZXZpY2VfYWNjZXNzX3N0YXR1c0IUCh'
    'JfbWVtYmVyc2hpcF9zdGF0dXNCEAoOX2JhbGFuY2VfbWlub3JCCwoJX2N1cnJlbmN5QhQKEl9h'
    'Z3JlZW1lbnRfdmVyc2lvbkIMCgpfc2lnbmVyX2lkQgwKCl9zaWduZWRfYXRCCgoIX3ZlcnNpb2'
    '4=');

@$core.Deprecated('Use actorDescriptor instead')
const Actor$json = {
  '1': 'Actor',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '9': 0, '10': 'id', '17': true},
    {'1': 'role', '3': 2, '4': 1, '5': 9, '9': 1, '10': 'role', '17': true},
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
      '1': 'session_id',
      '3': 4,
      '4': 1,
      '5': 9,
      '9': 3,
      '10': 'sessionId',
      '17': true
    },
  ],
  '8': [
    {'1': '_id'},
    {'1': '_role'},
    {'1': '_child_id'},
    {'1': '_session_id'},
  ],
};

/// Descriptor for `Actor`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List actorDescriptor = $convert.base64Decode(
    'CgVBY3RvchITCgJpZBgBIAEoCUgAUgJpZIgBARIXCgRyb2xlGAIgASgJSAFSBHJvbGWIAQESHg'
    'oIY2hpbGRfaWQYAyABKAlIAlIHY2hpbGRJZIgBARIiCgpzZXNzaW9uX2lkGAQgASgJSANSCXNl'
    'c3Npb25JZIgBAUIFCgNfaWRCBwoFX3JvbGVCCwoJX2NoaWxkX2lkQg0KC19zZXNzaW9uX2lk');

@$core.Deprecated('Use adultPreferencesDescriptor instead')
const AdultPreferences$json = {
  '1': 'AdultPreferences',
  '2': [
    {
      '1': 'family_intro_seen',
      '3': 1,
      '4': 1,
      '5': 8,
      '9': 0,
      '10': 'familyIntroSeen',
      '17': true
    },
  ],
  '8': [
    {'1': '_family_intro_seen'},
  ],
};

/// Descriptor for `AdultPreferences`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List adultPreferencesDescriptor = $convert.base64Decode(
    'ChBBZHVsdFByZWZlcmVuY2VzEi8KEWZhbWlseV9pbnRyb19zZWVuGAEgASgISABSD2ZhbWlseU'
    'ludHJvU2VlbogBAUIUChJfZmFtaWx5X2ludHJvX3NlZW4=');

@$core.Deprecated('Use snapshotDescriptor instead')
const Snapshot$json = {
  '1': 'Snapshot',
  '2': [
    {
      '1': 'family_space',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.moby.family.v1.FamilySpaceSnapshot',
      '10': 'familySpace'
    },
    {
      '1': 'revision',
      '3': 2,
      '4': 1,
      '5': 3,
      '9': 0,
      '10': 'revision',
      '17': true
    },
    {
      '1': 'actor',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.moby.family.v1.Actor',
      '10': 'actor'
    },
    {
      '1': 'preferences',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.moby.family.v1.AdultPreferences',
      '10': 'preferences'
    },
    {
      '1': 'children',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.moby.family.v1.Child',
      '10': 'children'
    },
    {
      '1': 'operations',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.moby.family.v1.Operation',
      '10': 'operations'
    },
    {
      '1': 'synthetic',
      '3': 7,
      '4': 1,
      '5': 8,
      '9': 1,
      '10': 'synthetic',
      '17': true
    },
    {
      '1': 'business_date',
      '3': 8,
      '4': 1,
      '5': 9,
      '9': 2,
      '10': 'businessDate',
      '17': true
    },
  ],
  '8': [
    {'1': '_revision'},
    {'1': '_synthetic'},
    {'1': '_business_date'},
  ],
};

/// Descriptor for `Snapshot`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List snapshotDescriptor = $convert.base64Decode(
    'CghTbmFwc2hvdBJGCgxmYW1pbHlfc3BhY2UYASABKAsyIy5tb2J5LmZhbWlseS52MS5GYW1pbH'
    'lTcGFjZVNuYXBzaG90UgtmYW1pbHlTcGFjZRIfCghyZXZpc2lvbhgCIAEoA0gAUghyZXZpc2lv'
    'bogBARIrCgVhY3RvchgDIAEoCzIVLm1vYnkuZmFtaWx5LnYxLkFjdG9yUgVhY3RvchJCCgtwcm'
    'VmZXJlbmNlcxgEIAEoCzIgLm1vYnkuZmFtaWx5LnYxLkFkdWx0UHJlZmVyZW5jZXNSC3ByZWZl'
    'cmVuY2VzEjEKCGNoaWxkcmVuGAUgAygLMhUubW9ieS5mYW1pbHkudjEuQ2hpbGRSCGNoaWxkcm'
    'VuEjkKCm9wZXJhdGlvbnMYBiADKAsyGS5tb2J5LmZhbWlseS52MS5PcGVyYXRpb25SCm9wZXJh'
    'dGlvbnMSIQoJc3ludGhldGljGAcgASgISAFSCXN5bnRoZXRpY4gBARIoCg1idXNpbmVzc19kYX'
    'RlGAggASgJSAJSDGJ1c2luZXNzRGF0ZYgBAUILCglfcmV2aXNpb25CDAoKX3N5bnRoZXRpY0IQ'
    'Cg5fYnVzaW5lc3NfZGF0ZQ==');

@$core.Deprecated('Use operationDescriptor instead')
const Operation$json = {
  '1': 'Operation',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '9': 0, '10': 'id', '17': true},
    {
      '1': 'child_id',
      '3': 2,
      '4': 1,
      '5': 9,
      '9': 1,
      '10': 'childId',
      '17': true
    },
    {'1': 'kind', '3': 3, '4': 1, '5': 9, '9': 2, '10': 'kind', '17': true},
    {
      '1': 'amount_minor',
      '3': 4,
      '4': 1,
      '5': 3,
      '9': 3,
      '10': 'amountMinor',
      '17': true
    },
    {
      '1': 'currency',
      '3': 5,
      '4': 1,
      '5': 9,
      '9': 4,
      '10': 'currency',
      '17': true
    },
    {
      '1': 'channel',
      '3': 6,
      '4': 1,
      '5': 9,
      '9': 5,
      '10': 'channel',
      '17': true
    },
    {
      '1': 'category',
      '3': 7,
      '4': 1,
      '5': 9,
      '9': 6,
      '10': 'category',
      '17': true
    },
    {
      '1': 'completed_at',
      '3': 8,
      '4': 1,
      '5': 3,
      '9': 7,
      '10': 'completedAt',
      '17': true
    },
    {
      '1': 'merchant',
      '3': 9,
      '4': 1,
      '5': 9,
      '9': 8,
      '10': 'merchant',
      '17': true
    },
    {
      '1': 'status',
      '3': 10,
      '4': 1,
      '5': 9,
      '9': 9,
      '10': 'status',
      '17': true
    },
    {
      '1': 'created_at',
      '3': 11,
      '4': 1,
      '5': 3,
      '9': 10,
      '10': 'createdAt',
      '17': true
    },
    {
      '1': 'version',
      '3': 12,
      '4': 1,
      '5': 3,
      '9': 11,
      '10': 'version',
      '17': true
    },
    {
      '1': 'decision',
      '3': 13,
      '4': 1,
      '5': 8,
      '9': 12,
      '10': 'decision',
      '17': true
    },
  ],
  '8': [
    {'1': '_id'},
    {'1': '_child_id'},
    {'1': '_kind'},
    {'1': '_amount_minor'},
    {'1': '_currency'},
    {'1': '_channel'},
    {'1': '_category'},
    {'1': '_completed_at'},
    {'1': '_merchant'},
    {'1': '_status'},
    {'1': '_created_at'},
    {'1': '_version'},
    {'1': '_decision'},
  ],
};

/// Descriptor for `Operation`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List operationDescriptor = $convert.base64Decode(
    'CglPcGVyYXRpb24SEwoCaWQYASABKAlIAFICaWSIAQESHgoIY2hpbGRfaWQYAiABKAlIAVIHY2'
    'hpbGRJZIgBARIXCgRraW5kGAMgASgJSAJSBGtpbmSIAQESJgoMYW1vdW50X21pbm9yGAQgASgD'
    'SANSC2Ftb3VudE1pbm9yiAEBEh8KCGN1cnJlbmN5GAUgASgJSARSCGN1cnJlbmN5iAEBEh0KB2'
    'NoYW5uZWwYBiABKAlIBVIHY2hhbm5lbIgBARIfCghjYXRlZ29yeRgHIAEoCUgGUghjYXRlZ29y'
    'eYgBARImCgxjb21wbGV0ZWRfYXQYCCABKANIB1ILY29tcGxldGVkQXSIAQESHwoIbWVyY2hhbn'
    'QYCSABKAlICFIIbWVyY2hhbnSIAQESGwoGc3RhdHVzGAogASgJSAlSBnN0YXR1c4gBARIiCgpj'
    'cmVhdGVkX2F0GAsgASgDSApSCWNyZWF0ZWRBdIgBARIdCgd2ZXJzaW9uGAwgASgDSAtSB3Zlcn'
    'Npb26IAQESHwoIZGVjaXNpb24YDSABKAhIDFIIZGVjaXNpb26IAQFCBQoDX2lkQgsKCV9jaGls'
    'ZF9pZEIHCgVfa2luZEIPCg1fYW1vdW50X21pbm9yQgsKCV9jdXJyZW5jeUIKCghfY2hhbm5lbE'
    'ILCglfY2F0ZWdvcnlCDwoNX2NvbXBsZXRlZF9hdEILCglfbWVyY2hhbnRCCQoHX3N0YXR1c0IN'
    'CgtfY3JlYXRlZF9hdEIKCghfdmVyc2lvbkILCglfZGVjaXNpb24=');

@$core.Deprecated('Use walletDescriptor instead')
const Wallet$json = {
  '1': 'Wallet',
  '2': [
    {
      '1': 'available_minor',
      '3': 1,
      '4': 1,
      '5': 3,
      '9': 0,
      '10': 'availableMinor',
      '17': true
    },
    {
      '1': 'reserved_minor',
      '3': 2,
      '4': 1,
      '5': 3,
      '9': 1,
      '10': 'reservedMinor',
      '17': true
    },
    {
      '1': 'currency',
      '3': 3,
      '4': 1,
      '5': 9,
      '9': 2,
      '10': 'currency',
      '17': true
    },
  ],
  '8': [
    {'1': '_available_minor'},
    {'1': '_reserved_minor'},
    {'1': '_currency'},
  ],
};

/// Descriptor for `Wallet`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List walletDescriptor = $convert.base64Decode(
    'CgZXYWxsZXQSLAoPYXZhaWxhYmxlX21pbm9yGAEgASgDSABSDmF2YWlsYWJsZU1pbm9yiAEBEi'
    'oKDnJlc2VydmVkX21pbm9yGAIgASgDSAFSDXJlc2VydmVkTWlub3KIAQESHwoIY3VycmVuY3kY'
    'AyABKAlIAlIIY3VycmVuY3mIAQFCEgoQX2F2YWlsYWJsZV9taW5vckIRCg9fcmVzZXJ2ZWRfbW'
    'lub3JCCwoJX2N1cnJlbmN5');

@$core.Deprecated('Use goalDescriptor instead')
const Goal$json = {
  '1': 'Goal',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '9': 0, '10': 'id', '17': true},
    {
      '1': 'child_id',
      '3': 2,
      '4': 1,
      '5': 9,
      '9': 1,
      '10': 'childId',
      '17': true
    },
    {'1': 'title', '3': 3, '4': 1, '5': 9, '9': 2, '10': 'title', '17': true},
    {
      '1': 'target_minor',
      '3': 4,
      '4': 1,
      '5': 3,
      '9': 3,
      '10': 'targetMinor',
      '17': true
    },
    {
      '1': 'saved_minor',
      '3': 5,
      '4': 1,
      '5': 3,
      '9': 4,
      '10': 'savedMinor',
      '17': true
    },
    {
      '1': 'matched_minor',
      '3': 6,
      '4': 1,
      '5': 3,
      '9': 5,
      '10': 'matchedMinor',
      '17': true
    },
    {
      '1': 'net_deposits_minor',
      '3': 7,
      '4': 1,
      '5': 3,
      '9': 6,
      '10': 'netDepositsMinor',
      '17': true
    },
    {
      '1': 'matched_basis_minor',
      '3': 8,
      '4': 1,
      '5': 3,
      '9': 7,
      '10': 'matchedBasisMinor',
      '17': true
    },
    {
      '1': 'matching_available_minor',
      '3': 9,
      '4': 1,
      '5': 3,
      '9': 8,
      '10': 'matchingAvailableMinor',
      '17': true
    },
    {
      '1': 'matching_status',
      '3': 10,
      '4': 1,
      '5': 9,
      '9': 9,
      '10': 'matchingStatus',
      '17': true
    },
  ],
  '8': [
    {'1': '_id'},
    {'1': '_child_id'},
    {'1': '_title'},
    {'1': '_target_minor'},
    {'1': '_saved_minor'},
    {'1': '_matched_minor'},
    {'1': '_net_deposits_minor'},
    {'1': '_matched_basis_minor'},
    {'1': '_matching_available_minor'},
    {'1': '_matching_status'},
  ],
};

/// Descriptor for `Goal`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List goalDescriptor = $convert.base64Decode(
    'CgRHb2FsEhMKAmlkGAEgASgJSABSAmlkiAEBEh4KCGNoaWxkX2lkGAIgASgJSAFSB2NoaWxkSW'
    'SIAQESGQoFdGl0bGUYAyABKAlIAlIFdGl0bGWIAQESJgoMdGFyZ2V0X21pbm9yGAQgASgDSANS'
    'C3RhcmdldE1pbm9yiAEBEiQKC3NhdmVkX21pbm9yGAUgASgDSARSCnNhdmVkTWlub3KIAQESKA'
    'oNbWF0Y2hlZF9taW5vchgGIAEoA0gFUgxtYXRjaGVkTWlub3KIAQESMQoSbmV0X2RlcG9zaXRz'
    'X21pbm9yGAcgASgDSAZSEG5ldERlcG9zaXRzTWlub3KIAQESMwoTbWF0Y2hlZF9iYXNpc19taW'
    '5vchgIIAEoA0gHUhFtYXRjaGVkQmFzaXNNaW5vcogBARI9ChhtYXRjaGluZ19hdmFpbGFibGVf'
    'bWlub3IYCSABKANICFIWbWF0Y2hpbmdBdmFpbGFibGVNaW5vcogBARIsCg9tYXRjaGluZ19zdG'
    'F0dXMYCiABKAlICVIObWF0Y2hpbmdTdGF0dXOIAQFCBQoDX2lkQgsKCV9jaGlsZF9pZEIICgZf'
    'dGl0bGVCDwoNX3RhcmdldF9taW5vckIOCgxfc2F2ZWRfbWlub3JCEAoOX21hdGNoZWRfbWlub3'
    'JCFQoTX25ldF9kZXBvc2l0c19taW5vckIWChRfbWF0Y2hlZF9iYXNpc19taW5vckIbChlfbWF0'
    'Y2hpbmdfYXZhaWxhYmxlX21pbm9yQhIKEF9tYXRjaGluZ19zdGF0dXM=');

@$core.Deprecated('Use familyTaskDescriptor instead')
const FamilyTask$json = {
  '1': 'FamilyTask',
  '2': [
    {
      '1': 'cancel_reason',
      '3': 1,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'cancelReason',
      '17': true
    },
    {'1': 'id', '3': 2, '4': 1, '5': 9, '9': 1, '10': 'id', '17': true},
    {
      '1': 'child_id',
      '3': 3,
      '4': 1,
      '5': 9,
      '9': 2,
      '10': 'childId',
      '17': true
    },
    {'1': 'title', '3': 4, '4': 1, '5': 9, '9': 3, '10': 'title', '17': true},
    {
      '1': 'reward_minor',
      '3': 5,
      '4': 1,
      '5': 3,
      '9': 4,
      '10': 'rewardMinor',
      '17': true
    },
    {'1': 'status', '3': 6, '4': 1, '5': 9, '9': 5, '10': 'status', '17': true},
    {
      '1': 'cancel_requested',
      '3': 7,
      '4': 1,
      '5': 8,
      '9': 6,
      '10': 'cancelRequested',
      '17': true
    },
  ],
  '8': [
    {'1': '_cancel_reason'},
    {'1': '_id'},
    {'1': '_child_id'},
    {'1': '_title'},
    {'1': '_reward_minor'},
    {'1': '_status'},
    {'1': '_cancel_requested'},
  ],
};

/// Descriptor for `FamilyTask`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List familyTaskDescriptor = $convert.base64Decode(
    'CgpGYW1pbHlUYXNrEigKDWNhbmNlbF9yZWFzb24YASABKAlIAFIMY2FuY2VsUmVhc29uiAEBEh'
    'MKAmlkGAIgASgJSAFSAmlkiAEBEh4KCGNoaWxkX2lkGAMgASgJSAJSB2NoaWxkSWSIAQESGQoF'
    'dGl0bGUYBCABKAlIA1IFdGl0bGWIAQESJgoMcmV3YXJkX21pbm9yGAUgASgDSARSC3Jld2FyZE'
    '1pbm9yiAEBEhsKBnN0YXR1cxgGIAEoCUgFUgZzdGF0dXOIAQESLgoQY2FuY2VsX3JlcXVlc3Rl'
    'ZBgHIAEoCEgGUg9jYW5jZWxSZXF1ZXN0ZWSIAQFCEAoOX2NhbmNlbF9yZWFzb25CBQoDX2lkQg'
    'sKCV9jaGlsZF9pZEIICgZfdGl0bGVCDwoNX3Jld2FyZF9taW5vckIJCgdfc3RhdHVzQhMKEV9j'
    'YW5jZWxfcmVxdWVzdGVk');

@$core.Deprecated('Use errandDescriptor instead')
const Errand$json = {
  '1': 'Errand',
  '2': [
    {
      '1': 'cancel_reason',
      '3': 1,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'cancelReason',
      '17': true
    },
    {
      '1': 'reward_reserved',
      '3': 2,
      '4': 1,
      '5': 8,
      '9': 1,
      '10': 'rewardReserved',
      '17': true
    },
    {
      '1': 'expense_recorded',
      '3': 3,
      '4': 1,
      '5': 8,
      '9': 2,
      '10': 'expenseRecorded',
      '17': true
    },
    {'1': 'id', '3': 4, '4': 1, '5': 9, '9': 3, '10': 'id', '17': true},
    {
      '1': 'child_id',
      '3': 5,
      '4': 1,
      '5': 9,
      '9': 4,
      '10': 'childId',
      '17': true
    },
    {'1': 'title', '3': 6, '4': 1, '5': 9, '9': 5, '10': 'title', '17': true},
    {
      '1': 'budget_minor',
      '3': 7,
      '4': 1,
      '5': 3,
      '9': 6,
      '10': 'budgetMinor',
      '17': true
    },
    {
      '1': 'reward_minor',
      '3': 8,
      '4': 1,
      '5': 3,
      '9': 7,
      '10': 'rewardMinor',
      '17': true
    },
    {
      '1': 'actual_minor',
      '3': 9,
      '4': 1,
      '5': 3,
      '9': 8,
      '10': 'actualMinor',
      '17': true
    },
    {
      '1': 'returned_minor',
      '3': 10,
      '4': 1,
      '5': 3,
      '9': 9,
      '10': 'returnedMinor',
      '17': true
    },
    {
      '1': 'funding',
      '3': 11,
      '4': 1,
      '5': 9,
      '9': 10,
      '10': 'funding',
      '17': true
    },
    {
      '1': 'status',
      '3': 12,
      '4': 1,
      '5': 9,
      '9': 11,
      '10': 'status',
      '17': true
    },
    {
      '1': 'return_confirmed',
      '3': 13,
      '4': 1,
      '5': 8,
      '9': 12,
      '10': 'returnConfirmed',
      '17': true
    },
    {
      '1': 'own_money_consent',
      '3': 14,
      '4': 1,
      '5': 8,
      '9': 13,
      '10': 'ownMoneyConsent',
      '17': true
    },
    {
      '1': 'cancel_requested',
      '3': 15,
      '4': 1,
      '5': 8,
      '9': 14,
      '10': 'cancelRequested',
      '17': true
    },
  ],
  '8': [
    {'1': '_cancel_reason'},
    {'1': '_reward_reserved'},
    {'1': '_expense_recorded'},
    {'1': '_id'},
    {'1': '_child_id'},
    {'1': '_title'},
    {'1': '_budget_minor'},
    {'1': '_reward_minor'},
    {'1': '_actual_minor'},
    {'1': '_returned_minor'},
    {'1': '_funding'},
    {'1': '_status'},
    {'1': '_return_confirmed'},
    {'1': '_own_money_consent'},
    {'1': '_cancel_requested'},
  ],
};

/// Descriptor for `Errand`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List errandDescriptor = $convert.base64Decode(
    'CgZFcnJhbmQSKAoNY2FuY2VsX3JlYXNvbhgBIAEoCUgAUgxjYW5jZWxSZWFzb26IAQESLAoPcm'
    'V3YXJkX3Jlc2VydmVkGAIgASgISAFSDnJld2FyZFJlc2VydmVkiAEBEi4KEGV4cGVuc2VfcmVj'
    'b3JkZWQYAyABKAhIAlIPZXhwZW5zZVJlY29yZGVkiAEBEhMKAmlkGAQgASgJSANSAmlkiAEBEh'
    '4KCGNoaWxkX2lkGAUgASgJSARSB2NoaWxkSWSIAQESGQoFdGl0bGUYBiABKAlIBVIFdGl0bGWI'
    'AQESJgoMYnVkZ2V0X21pbm9yGAcgASgDSAZSC2J1ZGdldE1pbm9yiAEBEiYKDHJld2FyZF9taW'
    '5vchgIIAEoA0gHUgtyZXdhcmRNaW5vcogBARImCgxhY3R1YWxfbWlub3IYCSABKANICFILYWN0'
    'dWFsTWlub3KIAQESKgoOcmV0dXJuZWRfbWlub3IYCiABKANICVINcmV0dXJuZWRNaW5vcogBAR'
    'IdCgdmdW5kaW5nGAsgASgJSApSB2Z1bmRpbmeIAQESGwoGc3RhdHVzGAwgASgJSAtSBnN0YXR1'
    'c4gBARIuChByZXR1cm5fY29uZmlybWVkGA0gASgISAxSD3JldHVybkNvbmZpcm1lZIgBARIvCh'
    'Fvd25fbW9uZXlfY29uc2VudBgOIAEoCEgNUg9vd25Nb25leUNvbnNlbnSIAQESLgoQY2FuY2Vs'
    'X3JlcXVlc3RlZBgPIAEoCEgOUg9jYW5jZWxSZXF1ZXN0ZWSIAQFCEAoOX2NhbmNlbF9yZWFzb2'
    '5CEgoQX3Jld2FyZF9yZXNlcnZlZEITChFfZXhwZW5zZV9yZWNvcmRlZEIFCgNfaWRCCwoJX2No'
    'aWxkX2lkQggKBl90aXRsZUIPCg1fYnVkZ2V0X21pbm9yQg8KDV9yZXdhcmRfbWlub3JCDwoNX2'
    'FjdHVhbF9taW5vckIRCg9fcmV0dXJuZWRfbWlub3JCCgoIX2Z1bmRpbmdCCQoHX3N0YXR1c0IT'
    'ChFfcmV0dXJuX2NvbmZpcm1lZEIUChJfb3duX21vbmV5X2NvbnNlbnRCEwoRX2NhbmNlbF9yZX'
    'F1ZXN0ZWQ=');

@$core.Deprecated('Use allowanceDescriptor instead')
const Allowance$json = {
  '1': 'Allowance',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '9': 0, '10': 'id', '17': true},
    {
      '1': 'child_id',
      '3': 2,
      '4': 1,
      '5': 9,
      '9': 1,
      '10': 'childId',
      '17': true
    },
    {'1': 'title', '3': 3, '4': 1, '5': 9, '9': 2, '10': 'title', '17': true},
    {
      '1': 'amount_minor',
      '3': 4,
      '4': 1,
      '5': 3,
      '9': 3,
      '10': 'amountMinor',
      '17': true
    },
    {
      '1': 'frequency',
      '3': 5,
      '4': 1,
      '5': 9,
      '9': 4,
      '10': 'frequency',
      '17': true
    },
    {'1': 'weekdays', '3': 6, '4': 3, '5': 5, '10': 'weekdays'},
    {
      '1': 'month_day',
      '3': 7,
      '4': 1,
      '5': 5,
      '9': 5,
      '10': 'monthDay',
      '17': true
    },
    {
      '1': 'next_date',
      '3': 8,
      '4': 1,
      '5': 9,
      '9': 6,
      '10': 'nextDate',
      '17': true
    },
    {
      '1': 'retry_limit',
      '3': 9,
      '4': 1,
      '5': 5,
      '9': 7,
      '10': 'retryLimit',
      '17': true
    },
    {
      '1': 'active',
      '3': 10,
      '4': 1,
      '5': 8,
      '9': 8,
      '10': 'active',
      '17': true
    },
  ],
  '8': [
    {'1': '_id'},
    {'1': '_child_id'},
    {'1': '_title'},
    {'1': '_amount_minor'},
    {'1': '_frequency'},
    {'1': '_month_day'},
    {'1': '_next_date'},
    {'1': '_retry_limit'},
    {'1': '_active'},
  ],
};

/// Descriptor for `Allowance`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List allowanceDescriptor = $convert.base64Decode(
    'CglBbGxvd2FuY2USEwoCaWQYASABKAlIAFICaWSIAQESHgoIY2hpbGRfaWQYAiABKAlIAVIHY2'
    'hpbGRJZIgBARIZCgV0aXRsZRgDIAEoCUgCUgV0aXRsZYgBARImCgxhbW91bnRfbWlub3IYBCAB'
    'KANIA1ILYW1vdW50TWlub3KIAQESIQoJZnJlcXVlbmN5GAUgASgJSARSCWZyZXF1ZW5jeYgBAR'
    'IaCgh3ZWVrZGF5cxgGIAMoBVIId2Vla2RheXMSIAoJbW9udGhfZGF5GAcgASgFSAVSCG1vbnRo'
    'RGF5iAEBEiAKCW5leHRfZGF0ZRgIIAEoCUgGUghuZXh0RGF0ZYgBARIkCgtyZXRyeV9saW1pdB'
    'gJIAEoBUgHUgpyZXRyeUxpbWl0iAEBEhsKBmFjdGl2ZRgKIAEoCEgIUgZhY3RpdmWIAQFCBQoD'
    'X2lkQgsKCV9jaGlsZF9pZEIICgZfdGl0bGVCDwoNX2Ftb3VudF9taW5vckIMCgpfZnJlcXVlbm'
    'N5QgwKCl9tb250aF9kYXlCDAoKX25leHRfZGF0ZUIOCgxfcmV0cnlfbGltaXRCCQoHX2FjdGl2'
    'ZQ==');

@$core.Deprecated('Use installmentDescriptor instead')
const Installment$json = {
  '1': 'Installment',
  '2': [
    {
      '1': 'retry_limit',
      '3': 1,
      '4': 1,
      '5': 5,
      '9': 0,
      '10': 'retryLimit',
      '17': true
    },
    {'1': 'id', '3': 2, '4': 1, '5': 9, '9': 1, '10': 'id', '17': true},
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
      '1': 'allowance_id',
      '3': 4,
      '4': 1,
      '5': 9,
      '9': 3,
      '10': 'allowanceId',
      '17': true
    },
    {
      '1': 'due_date',
      '3': 5,
      '4': 1,
      '5': 9,
      '9': 4,
      '10': 'dueDate',
      '17': true
    },
    {
      '1': 'amount_minor',
      '3': 6,
      '4': 1,
      '5': 3,
      '9': 5,
      '10': 'amountMinor',
      '17': true
    },
    {'1': 'status', '3': 7, '4': 1, '5': 9, '9': 6, '10': 'status', '17': true},
    {
      '1': 'attempts',
      '3': 8,
      '4': 1,
      '5': 5,
      '9': 7,
      '10': 'attempts',
      '17': true
    },
    {
      '1': 'last_attempt_date',
      '3': 9,
      '4': 1,
      '5': 9,
      '9': 8,
      '10': 'lastAttemptDate',
      '17': true
    },
  ],
  '8': [
    {'1': '_retry_limit'},
    {'1': '_id'},
    {'1': '_child_id'},
    {'1': '_allowance_id'},
    {'1': '_due_date'},
    {'1': '_amount_minor'},
    {'1': '_status'},
    {'1': '_attempts'},
    {'1': '_last_attempt_date'},
  ],
};

/// Descriptor for `Installment`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List installmentDescriptor = $convert.base64Decode(
    'CgtJbnN0YWxsbWVudBIkCgtyZXRyeV9saW1pdBgBIAEoBUgAUgpyZXRyeUxpbWl0iAEBEhMKAm'
    'lkGAIgASgJSAFSAmlkiAEBEh4KCGNoaWxkX2lkGAMgASgJSAJSB2NoaWxkSWSIAQESJgoMYWxs'
    'b3dhbmNlX2lkGAQgASgJSANSC2FsbG93YW5jZUlkiAEBEh4KCGR1ZV9kYXRlGAUgASgJSARSB2'
    'R1ZURhdGWIAQESJgoMYW1vdW50X21pbm9yGAYgASgDSAVSC2Ftb3VudE1pbm9yiAEBEhsKBnN0'
    'YXR1cxgHIAEoCUgGUgZzdGF0dXOIAQESHwoIYXR0ZW1wdHMYCCABKAVIB1IIYXR0ZW1wdHOIAQ'
    'ESLwoRbGFzdF9hdHRlbXB0X2RhdGUYCSABKAlICFIPbGFzdEF0dGVtcHREYXRliAEBQg4KDF9y'
    'ZXRyeV9saW1pdEIFCgNfaWRCCwoJX2NoaWxkX2lkQg8KDV9hbGxvd2FuY2VfaWRCCwoJX2R1ZV'
    '9kYXRlQg8KDV9hbW91bnRfbWlub3JCCQoHX3N0YXR1c0ILCglfYXR0ZW1wdHNCFAoSX2xhc3Rf'
    'YXR0ZW1wdF9kYXRl');

@$core.Deprecated('Use spaceSettingsDescriptor instead')
const SpaceSettings$json = {
  '1': 'SpaceSettings',
  '2': [
    {
      '1': 'matching_enabled',
      '3': 1,
      '4': 1,
      '5': 8,
      '9': 0,
      '10': 'matchingEnabled',
      '17': true
    },
    {
      '1': 'matching_percent',
      '3': 2,
      '4': 1,
      '5': 3,
      '9': 1,
      '10': 'matchingPercent',
      '17': true
    },
    {
      '1': 'matching_cap_minor',
      '3': 3,
      '4': 1,
      '5': 3,
      '9': 2,
      '10': 'matchingCapMinor',
      '17': true
    },
    {
      '1': 'notifications',
      '3': 4,
      '4': 1,
      '5': 8,
      '9': 3,
      '10': 'notifications',
      '17': true
    },
    {
      '1': 'tasks_enabled',
      '3': 5,
      '4': 1,
      '5': 8,
      '9': 4,
      '10': 'tasksEnabled',
      '17': true
    },
    {
      '1': 'errands_enabled',
      '3': 6,
      '4': 1,
      '5': 8,
      '9': 5,
      '10': 'errandsEnabled',
      '17': true
    },
    {
      '1': 'learning_enabled',
      '3': 7,
      '4': 1,
      '5': 8,
      '9': 6,
      '10': 'learningEnabled',
      '17': true
    },
  ],
  '8': [
    {'1': '_matching_enabled'},
    {'1': '_matching_percent'},
    {'1': '_matching_cap_minor'},
    {'1': '_notifications'},
    {'1': '_tasks_enabled'},
    {'1': '_errands_enabled'},
    {'1': '_learning_enabled'},
  ],
};

/// Descriptor for `SpaceSettings`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List spaceSettingsDescriptor = $convert.base64Decode(
    'Cg1TcGFjZVNldHRpbmdzEi4KEG1hdGNoaW5nX2VuYWJsZWQYASABKAhIAFIPbWF0Y2hpbmdFbm'
    'FibGVkiAEBEi4KEG1hdGNoaW5nX3BlcmNlbnQYAiABKANIAVIPbWF0Y2hpbmdQZXJjZW50iAEB'
    'EjEKEm1hdGNoaW5nX2NhcF9taW5vchgDIAEoA0gCUhBtYXRjaGluZ0NhcE1pbm9yiAEBEikKDW'
    '5vdGlmaWNhdGlvbnMYBCABKAhIA1INbm90aWZpY2F0aW9uc4gBARIoCg10YXNrc19lbmFibGVk'
    'GAUgASgISARSDHRhc2tzRW5hYmxlZIgBARIsCg9lcnJhbmRzX2VuYWJsZWQYBiABKAhIBVIOZX'
    'JyYW5kc0VuYWJsZWSIAQESLgoQbGVhcm5pbmdfZW5hYmxlZBgHIAEoCEgGUg9sZWFybmluZ0Vu'
    'YWJsZWSIAQFCEwoRX21hdGNoaW5nX2VuYWJsZWRCEwoRX21hdGNoaW5nX3BlcmNlbnRCFQoTX2'
    '1hdGNoaW5nX2NhcF9taW5vckIQCg5fbm90aWZpY2F0aW9uc0IQCg5fdGFza3NfZW5hYmxlZEIS'
    'ChBfZXJyYW5kc19lbmFibGVkQhMKEV9sZWFybmluZ19lbmFibGVk');

@$core.Deprecated('Use familyRequestDescriptor instead')
const FamilyRequest$json = {
  '1': 'FamilyRequest',
  '2': [
    {
      '1': 'amount_minor',
      '3': 1,
      '4': 1,
      '5': 3,
      '9': 0,
      '10': 'amountMinor',
      '17': true
    },
    {'1': 'id', '3': 2, '4': 1, '5': 9, '9': 1, '10': 'id', '17': true},
    {
      '1': 'child_id',
      '3': 3,
      '4': 1,
      '5': 9,
      '9': 2,
      '10': 'childId',
      '17': true
    },
    {'1': 'kind', '3': 4, '4': 1, '5': 9, '9': 3, '10': 'kind', '17': true},
    {'1': 'title', '3': 5, '4': 1, '5': 9, '9': 4, '10': 'title', '17': true},
    {
      '1': 'policy',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.moby.family.v1.Policy',
      '10': 'policy'
    },
    {'1': 'status', '3': 7, '4': 1, '5': 9, '9': 5, '10': 'status', '17': true},
  ],
  '8': [
    {'1': '_amount_minor'},
    {'1': '_id'},
    {'1': '_child_id'},
    {'1': '_kind'},
    {'1': '_title'},
    {'1': '_status'},
  ],
};

/// Descriptor for `FamilyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List familyRequestDescriptor = $convert.base64Decode(
    'Cg1GYW1pbHlSZXF1ZXN0EiYKDGFtb3VudF9taW5vchgBIAEoA0gAUgthbW91bnRNaW5vcogBAR'
    'ITCgJpZBgCIAEoCUgBUgJpZIgBARIeCghjaGlsZF9pZBgDIAEoCUgCUgdjaGlsZElkiAEBEhcK'
    'BGtpbmQYBCABKAlIA1IEa2luZIgBARIZCgV0aXRsZRgFIAEoCUgEUgV0aXRsZYgBARIuCgZwb2'
    'xpY3kYBiABKAsyFi5tb2J5LmZhbWlseS52MS5Qb2xpY3lSBnBvbGljeRIbCgZzdGF0dXMYByAB'
    'KAlIBVIGc3RhdHVziAEBQg8KDV9hbW91bnRfbWlub3JCBQoDX2lkQgsKCV9jaGlsZF9pZEIHCg'
    'Vfa2luZEIICgZfdGl0bGVCCQoHX3N0YXR1cw==');

@$core.Deprecated('Use lessonDescriptor instead')
const Lesson$json = {
  '1': 'Lesson',
  '2': [
    {
      '1': 'question',
      '3': 1,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'question',
      '17': true
    },
    {'1': 'options', '3': 2, '4': 3, '5': 9, '10': 'options'},
    {'1': 'id', '3': 3, '4': 1, '5': 9, '9': 1, '10': 'id', '17': true},
    {'1': 'title', '3': 4, '4': 1, '5': 9, '9': 2, '10': 'title', '17': true},
    {'1': 'body', '3': 5, '4': 1, '5': 9, '9': 3, '10': 'body', '17': true},
    {'1': 'skill', '3': 6, '4': 1, '5': 9, '9': 4, '10': 'skill', '17': true},
  ],
  '8': [
    {'1': '_question'},
    {'1': '_id'},
    {'1': '_title'},
    {'1': '_body'},
    {'1': '_skill'},
  ],
};

/// Descriptor for `Lesson`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List lessonDescriptor = $convert.base64Decode(
    'CgZMZXNzb24SHwoIcXVlc3Rpb24YASABKAlIAFIIcXVlc3Rpb26IAQESGAoHb3B0aW9ucxgCIA'
    'MoCVIHb3B0aW9ucxITCgJpZBgDIAEoCUgBUgJpZIgBARIZCgV0aXRsZRgEIAEoCUgCUgV0aXRs'
    'ZYgBARIXCgRib2R5GAUgASgJSANSBGJvZHmIAQESGQoFc2tpbGwYBiABKAlIBFIFc2tpbGyIAQ'
    'FCCwoJX3F1ZXN0aW9uQgUKA19pZEIICgZfdGl0bGVCBwoFX2JvZHlCCAoGX3NraWxs');

@$core.Deprecated('Use lessonCompletionDescriptor instead')
const LessonCompletion$json = {
  '1': 'LessonCompletion',
  '2': [
    {
      '1': 'child_id',
      '3': 1,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'childId',
      '17': true
    },
    {
      '1': 'lesson_id',
      '3': 2,
      '4': 1,
      '5': 9,
      '9': 1,
      '10': 'lessonId',
      '17': true
    },
    {
      '1': 'completed_at',
      '3': 3,
      '4': 1,
      '5': 3,
      '9': 2,
      '10': 'completedAt',
      '17': true
    },
  ],
  '8': [
    {'1': '_child_id'},
    {'1': '_lesson_id'},
    {'1': '_completed_at'},
  ],
};

/// Descriptor for `LessonCompletion`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List lessonCompletionDescriptor = $convert.base64Decode(
    'ChBMZXNzb25Db21wbGV0aW9uEh4KCGNoaWxkX2lkGAEgASgJSABSB2NoaWxkSWSIAQESIAoJbG'
    'Vzc29uX2lkGAIgASgJSAFSCGxlc3NvbklkiAEBEiYKDGNvbXBsZXRlZF9hdBgDIAEoA0gCUgtj'
    'b21wbGV0ZWRBdIgBAUILCglfY2hpbGRfaWRCDAoKX2xlc3Nvbl9pZEIPCg1fY29tcGxldGVkX2'
    'F0');

@$core.Deprecated('Use spaceEntryDescriptor instead')
const SpaceEntry$json = {
  '1': 'SpaceEntry',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '9': 0, '10': 'id', '17': true},
    {
      '1': 'child_id',
      '3': 2,
      '4': 1,
      '5': 9,
      '9': 1,
      '10': 'childId',
      '17': true
    },
    {'1': 'kind', '3': 3, '4': 1, '5': 9, '9': 2, '10': 'kind', '17': true},
    {
      '1': 'amount_minor',
      '3': 4,
      '4': 1,
      '5': 3,
      '9': 3,
      '10': 'amountMinor',
      '17': true
    },
    {'1': 'at', '3': 5, '4': 1, '5': 3, '9': 4, '10': 'at', '17': true},
    {
      '1': 'entity_id',
      '3': 6,
      '4': 1,
      '5': 9,
      '9': 5,
      '10': 'entityId',
      '17': true
    },
  ],
  '8': [
    {'1': '_id'},
    {'1': '_child_id'},
    {'1': '_kind'},
    {'1': '_amount_minor'},
    {'1': '_at'},
    {'1': '_entity_id'},
  ],
};

/// Descriptor for `SpaceEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List spaceEntryDescriptor = $convert.base64Decode(
    'CgpTcGFjZUVudHJ5EhMKAmlkGAEgASgJSABSAmlkiAEBEh4KCGNoaWxkX2lkGAIgASgJSAFSB2'
    'NoaWxkSWSIAQESFwoEa2luZBgDIAEoCUgCUgRraW5kiAEBEiYKDGFtb3VudF9taW5vchgEIAEo'
    'A0gDUgthbW91bnRNaW5vcogBARITCgJhdBgFIAEoA0gEUgJhdIgBARIgCgllbnRpdHlfaWQYBi'
    'ABKAlIBVIIZW50aXR5SWSIAQFCBQoDX2lkQgsKCV9jaGlsZF9pZEIHCgVfa2luZEIPCg1fYW1v'
    'dW50X21pbm9yQgUKA19hdEIMCgpfZW50aXR5X2lk');

@$core.Deprecated('Use weeklyOverviewDescriptor instead')
const WeeklyOverview$json = {
  '1': 'WeeklyOverview',
  '2': [
    {
      '1': 'child_id',
      '3': 1,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'childId',
      '17': true
    },
    {'1': 'since', '3': 2, '4': 1, '5': 9, '9': 1, '10': 'since', '17': true},
    {
      '1': 'incoming_minor',
      '3': 3,
      '4': 1,
      '5': 3,
      '9': 2,
      '10': 'incomingMinor',
      '17': true
    },
    {
      '1': 'spent_minor',
      '3': 4,
      '4': 1,
      '5': 3,
      '9': 3,
      '10': 'spentMinor',
      '17': true
    },
    {
      '1': 'saved_minor',
      '3': 5,
      '4': 1,
      '5': 3,
      '9': 4,
      '10': 'savedMinor',
      '17': true
    },
    {
      '1': 'tasks_completed',
      '3': 6,
      '4': 1,
      '5': 5,
      '9': 5,
      '10': 'tasksCompleted',
      '17': true
    },
    {
      '1': 'lessons_completed',
      '3': 7,
      '4': 1,
      '5': 5,
      '9': 6,
      '10': 'lessonsCompleted',
      '17': true
    },
  ],
  '8': [
    {'1': '_child_id'},
    {'1': '_since'},
    {'1': '_incoming_minor'},
    {'1': '_spent_minor'},
    {'1': '_saved_minor'},
    {'1': '_tasks_completed'},
    {'1': '_lessons_completed'},
  ],
};

/// Descriptor for `WeeklyOverview`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List weeklyOverviewDescriptor = $convert.base64Decode(
    'Cg5XZWVrbHlPdmVydmlldxIeCghjaGlsZF9pZBgBIAEoCUgAUgdjaGlsZElkiAEBEhkKBXNpbm'
    'NlGAIgASgJSAFSBXNpbmNliAEBEioKDmluY29taW5nX21pbm9yGAMgASgDSAJSDWluY29taW5n'
    'TWlub3KIAQESJAoLc3BlbnRfbWlub3IYBCABKANIA1IKc3BlbnRNaW5vcogBARIkCgtzYXZlZF'
    '9taW5vchgFIAEoA0gEUgpzYXZlZE1pbm9yiAEBEiwKD3Rhc2tzX2NvbXBsZXRlZBgGIAEoBUgF'
    'Ug50YXNrc0NvbXBsZXRlZIgBARIwChFsZXNzb25zX2NvbXBsZXRlZBgHIAEoBUgGUhBsZXNzb2'
    '5zQ29tcGxldGVkiAEBQgsKCV9jaGlsZF9pZEIICgZfc2luY2VCEQoPX2luY29taW5nX21pbm9y'
    'Qg4KDF9zcGVudF9taW5vckIOCgxfc2F2ZWRfbWlub3JCEgoQX3Rhc2tzX2NvbXBsZXRlZEIUCh'
    'JfbGVzc29uc19jb21wbGV0ZWQ=');

@$core.Deprecated('Use familyCapabilitiesDescriptor instead')
const FamilyCapabilities$json = {
  '1': 'FamilyCapabilities',
  '2': [
    {
      '1': 'synthetic',
      '3': 1,
      '4': 1,
      '5': 8,
      '9': 0,
      '10': 'synthetic',
      '17': true
    },
    {
      '1': 'currency',
      '3': 2,
      '4': 1,
      '5': 9,
      '9': 1,
      '10': 'currency',
      '17': true
    },
    {
      '1': 'time_zone',
      '3': 3,
      '4': 1,
      '5': 9,
      '9': 2,
      '10': 'timeZone',
      '17': true
    },
    {
      '1': 'max_amount_minor',
      '3': 4,
      '4': 1,
      '5': 3,
      '9': 3,
      '10': 'maxAmountMinor',
      '17': true
    },
    {
      '1': 'matching_cap_period',
      '3': 5,
      '4': 1,
      '5': 9,
      '9': 4,
      '10': 'matchingCapPeriod',
      '17': true
    },
    {
      '1': 'lessons_grant_permissions',
      '3': 6,
      '4': 1,
      '5': 8,
      '9': 5,
      '10': 'lessonsGrantPermissions',
      '17': true
    },
  ],
  '8': [
    {'1': '_synthetic'},
    {'1': '_currency'},
    {'1': '_time_zone'},
    {'1': '_max_amount_minor'},
    {'1': '_matching_cap_period'},
    {'1': '_lessons_grant_permissions'},
  ],
};

/// Descriptor for `FamilyCapabilities`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List familyCapabilitiesDescriptor = $convert.base64Decode(
    'ChJGYW1pbHlDYXBhYmlsaXRpZXMSIQoJc3ludGhldGljGAEgASgISABSCXN5bnRoZXRpY4gBAR'
    'IfCghjdXJyZW5jeRgCIAEoCUgBUghjdXJyZW5jeYgBARIgCgl0aW1lX3pvbmUYAyABKAlIAlII'
    'dGltZVpvbmWIAQESLQoQbWF4X2Ftb3VudF9taW5vchgEIAEoA0gDUg5tYXhBbW91bnRNaW5vco'
    'gBARIzChNtYXRjaGluZ19jYXBfcGVyaW9kGAUgASgJSARSEW1hdGNoaW5nQ2FwUGVyaW9kiAEB'
    'Ej8KGWxlc3NvbnNfZ3JhbnRfcGVybWlzc2lvbnMYBiABKAhIBVIXbGVzc29uc0dyYW50UGVybW'
    'lzc2lvbnOIAQFCDAoKX3N5bnRoZXRpY0ILCglfY3VycmVuY3lCDAoKX3RpbWVfem9uZUITChFf'
    'bWF4X2Ftb3VudF9taW5vckIWChRfbWF0Y2hpbmdfY2FwX3BlcmlvZEIcChpfbGVzc29uc19ncm'
    'FudF9wZXJtaXNzaW9ucw==');

@$core.Deprecated('Use spaceNoticeDescriptor instead')
const SpaceNotice$json = {
  '1': 'SpaceNotice',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '9': 0, '10': 'id', '17': true},
    {
      '1': 'child_id',
      '3': 2,
      '4': 1,
      '5': 9,
      '9': 1,
      '10': 'childId',
      '17': true
    },
    {
      '1': 'recipient',
      '3': 3,
      '4': 1,
      '5': 9,
      '9': 2,
      '10': 'recipient',
      '17': true
    },
    {'1': 'title', '3': 4, '4': 1, '5': 9, '9': 3, '10': 'title', '17': true},
    {'1': 'body', '3': 5, '4': 1, '5': 9, '9': 4, '10': 'body', '17': true},
    {'1': 'kind', '3': 6, '4': 1, '5': 9, '9': 5, '10': 'kind', '17': true},
    {
      '1': 'created_at',
      '3': 7,
      '4': 1,
      '5': 3,
      '9': 6,
      '10': 'createdAt',
      '17': true
    },
    {'1': 'read', '3': 8, '4': 1, '5': 8, '9': 7, '10': 'read', '17': true},
    {
      '1': 'mandatory',
      '3': 9,
      '4': 1,
      '5': 8,
      '9': 8,
      '10': 'mandatory',
      '17': true
    },
  ],
  '8': [
    {'1': '_id'},
    {'1': '_child_id'},
    {'1': '_recipient'},
    {'1': '_title'},
    {'1': '_body'},
    {'1': '_kind'},
    {'1': '_created_at'},
    {'1': '_read'},
    {'1': '_mandatory'},
  ],
};

/// Descriptor for `SpaceNotice`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List spaceNoticeDescriptor = $convert.base64Decode(
    'CgtTcGFjZU5vdGljZRITCgJpZBgBIAEoCUgAUgJpZIgBARIeCghjaGlsZF9pZBgCIAEoCUgBUg'
    'djaGlsZElkiAEBEiEKCXJlY2lwaWVudBgDIAEoCUgCUglyZWNpcGllbnSIAQESGQoFdGl0bGUY'
    'BCABKAlIA1IFdGl0bGWIAQESFwoEYm9keRgFIAEoCUgEUgRib2R5iAEBEhcKBGtpbmQYBiABKA'
    'lIBVIEa2luZIgBARIiCgpjcmVhdGVkX2F0GAcgASgDSAZSCWNyZWF0ZWRBdIgBARIXCgRyZWFk'
    'GAggASgISAdSBHJlYWSIAQESIQoJbWFuZGF0b3J5GAkgASgISAhSCW1hbmRhdG9yeYgBAUIFCg'
    'NfaWRCCwoJX2NoaWxkX2lkQgwKCl9yZWNpcGllbnRCCAoGX3RpdGxlQgcKBV9ib2R5QgcKBV9r'
    'aW5kQg0KC19jcmVhdGVkX2F0QgcKBV9yZWFkQgwKCl9tYW5kYXRvcnk=');

@$core.Deprecated('Use familySpaceSnapshotDescriptor instead')
const FamilySpaceSnapshot$json = {
  '1': 'FamilySpaceSnapshot',
  '2': [
    {
      '1': 'activity',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.moby.family.v1.SpaceEntry',
      '10': 'activity'
    },
    {
      '1': 'notices',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.moby.family.v1.SpaceNotice',
      '10': 'notices'
    },
    {
      '1': 'capabilities',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.moby.family.v1.FamilyCapabilities',
      '10': 'capabilities'
    },
    {
      '1': 'adult_wallet',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.moby.family.v1.Wallet',
      '10': 'adultWallet'
    },
    {
      '1': 'goals',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.moby.family.v1.Goal',
      '10': 'goals'
    },
    {
      '1': 'tasks',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.moby.family.v1.FamilyTask',
      '10': 'tasks'
    },
    {
      '1': 'errands',
      '3': 7,
      '4': 3,
      '5': 11,
      '6': '.moby.family.v1.Errand',
      '10': 'errands'
    },
    {
      '1': 'allowances',
      '3': 8,
      '4': 3,
      '5': 11,
      '6': '.moby.family.v1.Allowance',
      '10': 'allowances'
    },
    {
      '1': 'installments',
      '3': 9,
      '4': 3,
      '5': 11,
      '6': '.moby.family.v1.Installment',
      '10': 'installments'
    },
    {
      '1': 'requests',
      '3': 10,
      '4': 3,
      '5': 11,
      '6': '.moby.family.v1.FamilyRequest',
      '10': 'requests'
    },
    {
      '1': 'settings',
      '3': 11,
      '4': 3,
      '5': 11,
      '6': '.moby.family.v1.FamilySpaceSnapshot.SettingsEntry',
      '10': 'settings'
    },
    {
      '1': 'learning',
      '3': 12,
      '4': 3,
      '5': 11,
      '6': '.moby.family.v1.LessonCompletion',
      '10': 'learning'
    },
    {
      '1': 'lessons',
      '3': 13,
      '4': 3,
      '5': 11,
      '6': '.moby.family.v1.Lesson',
      '10': 'lessons'
    },
    {
      '1': 'weekly',
      '3': 14,
      '4': 3,
      '5': 11,
      '6': '.moby.family.v1.WeeklyOverview',
      '10': 'weekly'
    },
  ],
  '3': [FamilySpaceSnapshot_SettingsEntry$json],
};

@$core.Deprecated('Use familySpaceSnapshotDescriptor instead')
const FamilySpaceSnapshot_SettingsEntry$json = {
  '1': 'SettingsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.moby.family.v1.SpaceSettings',
      '10': 'value'
    },
  ],
  '7': {'7': true},
};

/// Descriptor for `FamilySpaceSnapshot`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List familySpaceSnapshotDescriptor = $convert.base64Decode(
    'ChNGYW1pbHlTcGFjZVNuYXBzaG90EjYKCGFjdGl2aXR5GAEgAygLMhoubW9ieS5mYW1pbHkudj'
    'EuU3BhY2VFbnRyeVIIYWN0aXZpdHkSNQoHbm90aWNlcxgCIAMoCzIbLm1vYnkuZmFtaWx5LnYx'
    'LlNwYWNlTm90aWNlUgdub3RpY2VzEkYKDGNhcGFiaWxpdGllcxgDIAEoCzIiLm1vYnkuZmFtaW'
    'x5LnYxLkZhbWlseUNhcGFiaWxpdGllc1IMY2FwYWJpbGl0aWVzEjkKDGFkdWx0X3dhbGxldBgE'
    'IAEoCzIWLm1vYnkuZmFtaWx5LnYxLldhbGxldFILYWR1bHRXYWxsZXQSKgoFZ29hbHMYBSADKA'
    'syFC5tb2J5LmZhbWlseS52MS5Hb2FsUgVnb2FscxIwCgV0YXNrcxgGIAMoCzIaLm1vYnkuZmFt'
    'aWx5LnYxLkZhbWlseVRhc2tSBXRhc2tzEjAKB2VycmFuZHMYByADKAsyFi5tb2J5LmZhbWlseS'
    '52MS5FcnJhbmRSB2VycmFuZHMSOQoKYWxsb3dhbmNlcxgIIAMoCzIZLm1vYnkuZmFtaWx5LnYx'
    'LkFsbG93YW5jZVIKYWxsb3dhbmNlcxI/CgxpbnN0YWxsbWVudHMYCSADKAsyGy5tb2J5LmZhbW'
    'lseS52MS5JbnN0YWxsbWVudFIMaW5zdGFsbG1lbnRzEjkKCHJlcXVlc3RzGAogAygLMh0ubW9i'
    'eS5mYW1pbHkudjEuRmFtaWx5UmVxdWVzdFIIcmVxdWVzdHMSTQoIc2V0dGluZ3MYCyADKAsyMS'
    '5tb2J5LmZhbWlseS52MS5GYW1pbHlTcGFjZVNuYXBzaG90LlNldHRpbmdzRW50cnlSCHNldHRp'
    'bmdzEjwKCGxlYXJuaW5nGAwgAygLMiAubW9ieS5mYW1pbHkudjEuTGVzc29uQ29tcGxldGlvbl'
    'IIbGVhcm5pbmcSMAoHbGVzc29ucxgNIAMoCzIWLm1vYnkuZmFtaWx5LnYxLkxlc3NvblIHbGVz'
    'c29ucxI2CgZ3ZWVrbHkYDiADKAsyHi5tb2J5LmZhbWlseS52MS5XZWVrbHlPdmVydmlld1IGd2'
    'Vla2x5GloKDVNldHRpbmdzRW50cnkSEAoDa2V5GAEgASgJUgNrZXkSMwoFdmFsdWUYAiABKAsy'
    'HS5tb2J5LmZhbWlseS52MS5TcGFjZVNldHRpbmdzUgV2YWx1ZToCOAE=');

@$core.Deprecated('Use spaceCommandDescriptor instead')
const SpaceCommand$json = {
  '1': 'SpaceCommand',
  '2': [
    {'1': 'reason', '3': 1, '4': 1, '5': 9, '9': 0, '10': 'reason', '17': true},
    {
      '1': 'answer_index',
      '3': 2,
      '4': 1,
      '5': 5,
      '9': 1,
      '10': 'answerIndex',
      '17': true
    },
    {'1': 'type', '3': 3, '4': 1, '5': 9, '9': 2, '10': 'type', '17': true},
    {
      '1': 'child_id',
      '3': 4,
      '4': 1,
      '5': 9,
      '9': 3,
      '10': 'childId',
      '17': true
    },
    {
      '1': 'entity_id',
      '3': 5,
      '4': 1,
      '5': 9,
      '9': 4,
      '10': 'entityId',
      '17': true
    },
    {'1': 'title', '3': 6, '4': 1, '5': 9, '9': 5, '10': 'title', '17': true},
    {
      '1': 'amount_minor',
      '3': 7,
      '4': 1,
      '5': 3,
      '9': 6,
      '10': 'amountMinor',
      '17': true
    },
    {
      '1': 'budget_minor',
      '3': 8,
      '4': 1,
      '5': 3,
      '9': 7,
      '10': 'budgetMinor',
      '17': true
    },
    {
      '1': 'reward_minor',
      '3': 9,
      '4': 1,
      '5': 3,
      '9': 8,
      '10': 'rewardMinor',
      '17': true
    },
    {
      '1': 'target_minor',
      '3': 10,
      '4': 1,
      '5': 3,
      '9': 9,
      '10': 'targetMinor',
      '17': true
    },
    {
      '1': 'action',
      '3': 11,
      '4': 1,
      '5': 9,
      '9': 10,
      '10': 'action',
      '17': true
    },
    {
      '1': 'idempotency_key',
      '3': 12,
      '4': 1,
      '5': 9,
      '9': 11,
      '10': 'idempotencyKey',
      '17': true
    },
    {
      '1': 'funding',
      '3': 13,
      '4': 1,
      '5': 9,
      '9': 12,
      '10': 'funding',
      '17': true
    },
    {
      '1': 'own_money_consent',
      '3': 14,
      '4': 1,
      '5': 8,
      '9': 13,
      '10': 'ownMoneyConsent',
      '17': true
    },
    {
      '1': 'frequency',
      '3': 15,
      '4': 1,
      '5': 9,
      '9': 14,
      '10': 'frequency',
      '17': true
    },
    {'1': 'weekdays', '3': 16, '4': 3, '5': 5, '10': 'weekdays'},
    {
      '1': 'month_day',
      '3': 17,
      '4': 1,
      '5': 5,
      '9': 15,
      '10': 'monthDay',
      '17': true
    },
    {
      '1': 'next_date',
      '3': 18,
      '4': 1,
      '5': 9,
      '9': 16,
      '10': 'nextDate',
      '17': true
    },
    {
      '1': 'retry_limit',
      '3': 19,
      '4': 1,
      '5': 5,
      '9': 17,
      '10': 'retryLimit',
      '17': true
    },
    {
      '1': 'settings',
      '3': 20,
      '4': 1,
      '5': 11,
      '6': '.moby.family.v1.SpaceSettings',
      '10': 'settings'
    },
    {
      '1': 'policy',
      '3': 21,
      '4': 1,
      '5': 11,
      '6': '.moby.family.v1.Policy',
      '10': 'policy'
    },
    {'1': 'kind', '3': 22, '4': 1, '5': 9, '9': 18, '10': 'kind', '17': true},
    {
      '1': 'approve',
      '3': 23,
      '4': 1,
      '5': 8,
      '9': 19,
      '10': 'approve',
      '17': true
    },
  ],
  '8': [
    {'1': '_reason'},
    {'1': '_answer_index'},
    {'1': '_type'},
    {'1': '_child_id'},
    {'1': '_entity_id'},
    {'1': '_title'},
    {'1': '_amount_minor'},
    {'1': '_budget_minor'},
    {'1': '_reward_minor'},
    {'1': '_target_minor'},
    {'1': '_action'},
    {'1': '_idempotency_key'},
    {'1': '_funding'},
    {'1': '_own_money_consent'},
    {'1': '_frequency'},
    {'1': '_month_day'},
    {'1': '_next_date'},
    {'1': '_retry_limit'},
    {'1': '_kind'},
    {'1': '_approve'},
  ],
};

/// Descriptor for `SpaceCommand`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List spaceCommandDescriptor = $convert.base64Decode(
    'CgxTcGFjZUNvbW1hbmQSGwoGcmVhc29uGAEgASgJSABSBnJlYXNvbogBARImCgxhbnN3ZXJfaW'
    '5kZXgYAiABKAVIAVILYW5zd2VySW5kZXiIAQESFwoEdHlwZRgDIAEoCUgCUgR0eXBliAEBEh4K'
    'CGNoaWxkX2lkGAQgASgJSANSB2NoaWxkSWSIAQESIAoJZW50aXR5X2lkGAUgASgJSARSCGVudG'
    'l0eUlkiAEBEhkKBXRpdGxlGAYgASgJSAVSBXRpdGxliAEBEiYKDGFtb3VudF9taW5vchgHIAEo'
    'A0gGUgthbW91bnRNaW5vcogBARImCgxidWRnZXRfbWlub3IYCCABKANIB1ILYnVkZ2V0TWlub3'
    'KIAQESJgoMcmV3YXJkX21pbm9yGAkgASgDSAhSC3Jld2FyZE1pbm9yiAEBEiYKDHRhcmdldF9t'
    'aW5vchgKIAEoA0gJUgt0YXJnZXRNaW5vcogBARIbCgZhY3Rpb24YCyABKAlIClIGYWN0aW9uiA'
    'EBEiwKD2lkZW1wb3RlbmN5X2tleRgMIAEoCUgLUg5pZGVtcG90ZW5jeUtleYgBARIdCgdmdW5k'
    'aW5nGA0gASgJSAxSB2Z1bmRpbmeIAQESLwoRb3duX21vbmV5X2NvbnNlbnQYDiABKAhIDVIPb3'
    'duTW9uZXlDb25zZW50iAEBEiEKCWZyZXF1ZW5jeRgPIAEoCUgOUglmcmVxdWVuY3mIAQESGgoI'
    'd2Vla2RheXMYECADKAVSCHdlZWtkYXlzEiAKCW1vbnRoX2RheRgRIAEoBUgPUghtb250aERheY'
    'gBARIgCgluZXh0X2RhdGUYEiABKAlIEFIIbmV4dERhdGWIAQESJAoLcmV0cnlfbGltaXQYEyAB'
    'KAVIEVIKcmV0cnlMaW1pdIgBARI5CghzZXR0aW5ncxgUIAEoCzIdLm1vYnkuZmFtaWx5LnYxLl'
    'NwYWNlU2V0dGluZ3NSCHNldHRpbmdzEi4KBnBvbGljeRgVIAEoCzIWLm1vYnkuZmFtaWx5LnYx'
    'LlBvbGljeVIGcG9saWN5EhcKBGtpbmQYFiABKAlIElIEa2luZIgBARIdCgdhcHByb3ZlGBcgAS'
    'gISBNSB2FwcHJvdmWIAQFCCQoHX3JlYXNvbkIPCg1fYW5zd2VyX2luZGV4QgcKBV90eXBlQgsK'
    'CV9jaGlsZF9pZEIMCgpfZW50aXR5X2lkQggKBl90aXRsZUIPCg1fYW1vdW50X21pbm9yQg8KDV'
    '9idWRnZXRfbWlub3JCDwoNX3Jld2FyZF9taW5vckIPCg1fdGFyZ2V0X21pbm9yQgkKB19hY3Rp'
    'b25CEgoQX2lkZW1wb3RlbmN5X2tleUIKCghfZnVuZGluZ0IUChJfb3duX21vbmV5X2NvbnNlbn'
    'RCDAoKX2ZyZXF1ZW5jeUIMCgpfbW9udGhfZGF5QgwKCl9uZXh0X2RhdGVCDgoMX3JldHJ5X2xp'
    'bWl0QgcKBV9raW5kQgoKCF9hcHByb3Zl');
