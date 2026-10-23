import 'package:fixnum/fixnum.dart';

import '../server/generated/moby/notifications/v1/notifications.pb.dart'
    as wire;

/// Validation of future notification data is separate from server authorization.
final class NotificationValidationException implements Exception {
  const NotificationValidationException(this.code);
  final String code;
  @override
  String toString() => 'NotificationValidationException($code)';
}

enum NotificationCategory { money, work, goals, learning, security }

enum NotificationKind { decisionRequired, stateChanged, securityAlert }

enum NotificationTarget {
  familyOverview,
  childMoney,
  childGoals,
  childWork,
  childRules,
  childLearning,
}

enum NotificationDeliveryStatus {
  notConfigured,
  pending,
  providerAccepted,
  failed,
  expired,
}

void _require(bool valid, String code) {
  if (!valid) throw NotificationValidationException(code);
}

void _opaque(String value) => _require(
  RegExp(r'^[A-Za-z0-9][A-Za-z0-9._:-]{0,127}$').hasMatch(value),
  'invalid_notification_reference',
);

T _known<T>(List<T> values, int wireValue, String code) {
  _require(wireValue > 0 && wireValue <= values.length, code);
  return values[wireValue - 1];
}

/// Metadata only. No wallet, financial amount, title, body or free-form URL.
/// A future recipient must fetch data again under its current authenticated actor.
final class NotificationEvent {
  NotificationEvent({
    required this.eventId,
    required this.recipientActorId,
    this.childId,
    required this.sequence,
    required this.kind,
    required this.category,
    required this.target,
    this.entityId,
    required this.createdAt,
    required this.expiresAt,
    required this.mandatory,
  }) {
    _opaque(eventId);
    _opaque(recipientActorId);
    if (childId != null) _opaque(childId!);
    if (entityId != null) _opaque(entityId!);
    _require(sequence > 0, 'invalid_notification_sequence');
    _require(
      createdAt >= 0 && expiresAt > createdAt,
      'invalid_notification_lifetime',
    );
    _require(
      target == NotificationTarget.familyOverview || childId != null,
      'notification_child_required',
    );
  }

  factory NotificationEvent.fromProto(wire.NotificationEvent value) {
    _require(
      value.hasEventId() &&
          value.hasRecipientActorId() &&
          value.hasSequence() &&
          value.hasKind() &&
          value.hasCategory() &&
          value.hasTarget() &&
          value.hasCreatedAt() &&
          value.hasExpiresAt() &&
          value.hasMandatory(),
      'incomplete_notification_event',
    );
    // An unknown enum on a routing field must fail closed even if another
    // occurrence of that field carried a known value earlier in the message.
    _require(!value.unknownFields.hasField(7), 'unknown_notification_target');
    _require(
      !value.unknownFields.hasField(5) && !value.unknownFields.hasField(6),
      'unknown_notification_kind',
    );
    return NotificationEvent(
      eventId: value.eventId,
      recipientActorId: value.recipientActorId,
      childId: value.hasChildId() ? value.childId : null,
      sequence: value.sequence.toInt(),
      kind: _known(
        NotificationKind.values,
        value.kind.value,
        'unknown_notification_kind',
      ),
      category: _known(
        NotificationCategory.values,
        value.category.value,
        'unknown_notification_category',
      ),
      target: _known(
        NotificationTarget.values,
        value.target.value,
        'unknown_notification_target',
      ),
      entityId: value.hasEntityId() ? value.entityId : null,
      createdAt: value.createdAt.toInt(),
      expiresAt: value.expiresAt.toInt(),
      mandatory: value.mandatory,
    );
  }

  final String eventId, recipientActorId;
  final String? childId, entityId;
  final int sequence, createdAt, expiresAt;
  final NotificationKind kind;
  final NotificationCategory category;
  final NotificationTarget target;
  final bool mandatory;

  wire.NotificationEvent toProto() => wire.NotificationEvent(
    eventId: eventId,
    recipientActorId: recipientActorId,
    childId: childId,
    sequence: Int64(sequence),
    kind: wire.NotificationKind.valueOf(kind.index + 1),
    category: wire.NotificationCategory.valueOf(category.index + 1),
    target: wire.NotificationTarget.valueOf(target.index + 1),
    entityId: entityId,
    createdAt: Int64(createdAt),
    expiresAt: Int64(expiresAt),
    mandatory: mandatory,
  );
}

/// An immutable cursor, not a subscription, acknowledgement or permission grant.
final class NotificationCursor {
  NotificationCursor({required this.actorId, required this.sequence}) {
    _opaque(actorId);
    _require(sequence >= 0, 'invalid_notification_sequence');
  }
  final String actorId;
  final int sequence;
  NotificationCursor advance(NotificationEvent event) {
    _require(event.recipientActorId == actorId, 'notification_actor_mismatch');
    _require(event.sequence > sequence, 'notification_sequence_regression');
    return NotificationCursor(actorId: actorId, sequence: event.sequence);
  }
}

/// Future server-owned actor preferences. No permission requests or listeners.
final class NotificationPreferences {
  NotificationPreferences({
    required this.actorId,
    required this.version,
    required this.enabled,
    required Iterable<NotificationCategory> enabledCategories,
  }) : enabledCategories = Set.unmodifiable(enabledCategories) {
    _opaque(actorId);
    _require(version > 0, 'invalid_notification_preferences_version');
  }
  factory NotificationPreferences.fromProto(
    wire.NotificationPreferences value,
  ) {
    _require(
      value.hasActorId() && value.hasVersion() && value.hasEnabled(),
      'incomplete_notification_preferences',
    );
    _require(!value.unknownFields.hasField(4), 'unknown_notification_category');
    final categories = value.enabledCategories
        .map(
          (category) => _known(
            NotificationCategory.values,
            category.value,
            'unknown_notification_category',
          ),
        )
        .toList();
    _require(
      categories.toSet().length == categories.length,
      'duplicate_notification_category',
    );
    return NotificationPreferences(
      actorId: value.actorId,
      version: value.version.toInt(),
      enabled: value.enabled,
      enabledCategories: categories,
    );
  }
  final String actorId;
  final int version;
  final bool enabled;
  final Set<NotificationCategory> enabledCategories;
  wire.NotificationPreferences toProto() => wire.NotificationPreferences(
    actorId: actorId,
    version: Int64(version),
    enabled: enabled,
    enabledCategories: enabledCategories.map(
      (value) => wire.NotificationCategory.valueOf(value.index + 1)!,
    ),
  );
}

/// Opaque installation identity. It is never a push token or an OS registration.
final class NotificationInstallationRef {
  NotificationInstallationRef({
    required this.installationId,
    required this.actorId,
  }) {
    _opaque(installationId);
    _opaque(actorId);
  }
  factory NotificationInstallationRef.fromProto(
    wire.NotificationInstallationRef value,
  ) {
    _require(
      value.hasInstallationId() && value.hasActorId(),
      'incomplete_notification_installation',
    );
    return NotificationInstallationRef(
      installationId: value.installationId,
      actorId: value.actorId,
    );
  }
  final String installationId, actorId;
  wire.NotificationInstallationRef toProto() =>
      wire.NotificationInstallationRef(
        installationId: installationId,
        actorId: actorId,
      );
}

/// The provider boundary carries references only, never private event contents.
final class NotificationDeliveryEnvelope {
  NotificationDeliveryEnvelope({
    required this.eventId,
    required this.recipientActorId,
    required this.installation,
  }) {
    _opaque(eventId);
    _opaque(recipientActorId);
    _require(
      installation.actorId == recipientActorId,
      'notification_actor_mismatch',
    );
  }
  factory NotificationDeliveryEnvelope.fromProto(
    wire.NotificationDeliveryEnvelope value,
  ) {
    _require(
      value.hasEventId() &&
          value.hasRecipientActorId() &&
          value.hasInstallation(),
      'incomplete_notification_envelope',
    );
    return NotificationDeliveryEnvelope(
      eventId: value.eventId,
      recipientActorId: value.recipientActorId,
      installation: NotificationInstallationRef.fromProto(value.installation),
    );
  }
  final String eventId, recipientActorId;
  final NotificationInstallationRef installation;
  wire.NotificationDeliveryEnvelope toProto() =>
      wire.NotificationDeliveryEnvelope(
        eventId: eventId,
        recipientActorId: recipientActorId,
        installation: installation.toProto(),
      );
}

/// Provider acceptance is not a device-delivery or read acknowledgement.
final class NotificationDeliveryReceipt {
  NotificationDeliveryReceipt({
    required this.eventId,
    required this.installationId,
    required this.status,
  }) {
    _opaque(eventId);
    _opaque(installationId);
  }
  factory NotificationDeliveryReceipt.fromProto(
    wire.NotificationDeliveryReceipt value,
  ) {
    _require(
      value.hasEventId() && value.hasInstallationId() && value.hasStatus(),
      'incomplete_notification_receipt',
    );
    _require(
      !value.unknownFields.hasField(3),
      'unknown_notification_delivery_status',
    );
    return NotificationDeliveryReceipt(
      eventId: value.eventId,
      installationId: value.installationId,
      status: _known(
        NotificationDeliveryStatus.values,
        value.status.value,
        'unknown_notification_delivery_status',
      ),
    );
  }
  final String eventId, installationId;
  final NotificationDeliveryStatus status;
  bool get providerAccepted =>
      status == NotificationDeliveryStatus.providerAccepted;
  bool get confirmsDeviceDelivery => false;
  bool get confirmsRead => false;
  wire.NotificationDeliveryReceipt toProto() =>
      wire.NotificationDeliveryReceipt(
        eventId: eventId,
        installationId: installationId,
        status: wire.NotificationDeliveryStatus.valueOf(status.index + 1),
      );
}
