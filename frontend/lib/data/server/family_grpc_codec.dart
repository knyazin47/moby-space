import 'package:fixnum/fixnum.dart';
import 'package:protobuf/protobuf.dart';

import 'family_api_contract.dart';
import 'family_space.dart';

/// Explicit projection of typed protobuf fields into the existing domain model.
/// Unlike proto JSON, int64 stays an int and absent scalars stay absent.
JsonMap familyMessageMap(GeneratedMessage message) {
  final result = <String, dynamic>{
    for (final field in message.info_.fieldInfo.values)
      if (field.isRepeated ||
          field.isMapField ||
          message.hasField(field.tagNumber))
        field.name: _value(message.getField(field.tagNumber)),
  };
  if (message.info_.qualifiedMessageName == 'moby.family.v1.Policy') {
    final categories = result['categories'];
    if (categories is JsonMap) result['categories'] = categories['values'];
  }
  return result;
}

Object? _value(Object? value) => switch (value) {
  Int64() => value.toInt(),
  GeneratedMessage() => familyMessageMap(value),
  Map() => <String, dynamic>{
    for (final entry in value.entries) entry.key as String: _value(entry.value),
  },
  Iterable() => value.map(_value).toList(growable: false),
  _ => value,
};

T familyMessage<T extends GeneratedMessage>(T target, JsonMap values) {
  try {
    for (final entry in values.entries) {
      final field = target.info_.byName[entry.key];
      if (field == null || entry.value == null) {
        throw const FormatException('unknown_or_null_field');
      }
      var value = entry.value;
      if (target.info_.qualifiedMessageName == 'moby.family.v1.Policy' &&
          entry.key == 'categories') {
        value = <String, dynamic>{'values': value};
      }
      if (field is MapFieldInfo) {
        if (value is! Map<String, dynamic>) {
          throw const FormatException('invalid_map');
        }
        final destination = target.getField(field.tagNumber) as Map;
        for (final item in value.entries) {
          destination[item.key] = _wireValue(field.valueFieldInfo, item.value);
        }
      } else if (field.isRepeated) {
        if (value is! List) throw const FormatException('invalid_list');
        final destination = target.getField(field.tagNumber) as List;
        for (final item in value) {
          destination.add(_wireValue(field, item));
        }
      } else {
        target.setField(field.tagNumber, _wireValue(field, value));
      }
    }
    return target;
  } on FamilyApiException {
    rethrow;
  } catch (_) {
    throw const FamilyApiException(400, 'invalid_request');
  }
}

Object _wireValue(FieldInfo field, Object? value) {
  if (field.isGroupOrMessage) {
    if (value is! JsonMap) throw const FormatException('invalid_message');
    return familyMessage(field.subBuilder!(), value);
  }
  return switch (PbFieldType.baseType(field.type)) {
    PbFieldType.OPTIONAL_STRING when value is String => value,
    PbFieldType.OPTIONAL_BOOL when value is bool => value,
    PbFieldType.OPTIONAL_INT64 when value is int => Int64(value),
    PbFieldType.OPTIONAL_INT32
        when value is int && value >= -2147483648 && value <= 2147483647 =>
      value,
    _ => throw const FormatException('invalid_scalar'),
  };
}

JsonMap familySnapshotMap(GeneratedMessage message) {
  final result = familyMessageMap(message);
  final actor = result['actor'];
  final children = result['children'];
  final operations = result['operations'];
  final space = result['familySpace'];
  bool nonempty(Object? value) => value is String && value.isNotEmpty;
  bool money(Object? value) => value is int && value >= 0;
  if (result['revision'] is! int ||
      (result['revision'] as int) < 0 ||
      actor is! JsonMap ||
      !nonempty(actor['id']) ||
      !{'adult', 'child'}.contains(actor['role']) ||
      (actor['role'] == 'child' && !nonempty(actor['childId'])) ||
      children is! List ||
      operations is! List ||
      space is! JsonMap ||
      space['capabilities'] is! JsonMap ||
      !FamilySpace.fromSnapshot(result).isAvailable) {
    throw const FamilyApiException(502, 'invalid_snapshot');
  }
  if (actor['role'] == 'adult' && space['adultWallet'] is! JsonMap) {
    throw const FamilyApiException(502, 'invalid_snapshot');
  }
  final wallet = space['adultWallet'];
  final capabilities = space['capabilities'] as JsonMap;
  if ((wallet is JsonMap &&
          (!money(wallet['availableMinor']) ||
              !money(wallet['reservedMinor']))) ||
      !money(capabilities['maxAmountMinor']) ||
      capabilities['maxAmountMinor'] == 0) {
    throw const FamilyApiException(502, 'invalid_snapshot');
  }
  for (final child in children) {
    if (child is! JsonMap ||
        !nonempty(child['id']) ||
        child['currency'] != 'BYN' ||
        !money(child['balanceMinor'])) {
      throw const FamilyApiException(502, 'invalid_snapshot');
    }
  }
  for (final operation in operations) {
    if (operation is! JsonMap ||
        !nonempty(operation['id']) ||
        !nonempty(operation['childId']) ||
        operation['currency'] != 'BYN' ||
        !money(operation['amountMinor'])) {
      throw const FamilyApiException(502, 'invalid_snapshot');
    }
  }
  return result;
}
