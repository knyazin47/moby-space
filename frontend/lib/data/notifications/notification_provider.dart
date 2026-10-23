import 'notification_models.dart';

/// Future provider seam only. This milestone has no active implementation,
/// network registration, platform permissions, listeners or notification UI.
abstract interface class NotificationProvider {
  bool get isConfigured;
  Future<NotificationDeliveryReceipt> submit(
    NotificationDeliveryEnvelope envelope,
  );
}

/// The sole foundation implementation. A call always reports not configured;
/// it never creates a pending attempt or claims acceptance, delivery or reading.
final class DisabledNotificationProvider implements NotificationProvider {
  const DisabledNotificationProvider();
  @override
  bool get isConfigured => false;
  @override
  Future<NotificationDeliveryReceipt> submit(
    NotificationDeliveryEnvelope envelope,
  ) async => NotificationDeliveryReceipt(
    eventId: envelope.eventId,
    installationId: envelope.installation.installationId,
    status: NotificationDeliveryStatus.notConfigured,
  );
}
