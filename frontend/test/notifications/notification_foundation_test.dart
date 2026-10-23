import 'dart:io';

import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:protobuf/protobuf.dart';
import 'package:moby_demo/data/notifications/notification_models.dart';
import 'package:moby_demo/data/notifications/notification_provider.dart';
import 'package:moby_demo/data/server/generated/moby/notifications/v1/notifications.pb.dart'
    as wire;

NotificationEvent event({String actor = 'actor-one', int sequence = 1}) =>
    NotificationEvent(
      eventId: 'event-one',
      recipientActorId: actor,
      childId: 'child-one',
      sequence: sequence,
      kind: NotificationKind.decisionRequired,
      category: NotificationCategory.money,
      target: NotificationTarget.childMoney,
      createdAt: 1792540000,
      expiresAt: 1792543600,
      mandatory: false,
    );

Matcher invalid([String? code]) => code == null
    ? isA<NotificationValidationException>()
    : isA<NotificationValidationException>().having(
        (e) => e.code,
        'code',
        code,
      );

void main() {
  test(
    'preferences preserve explicit false, version and immutable categories',
    () {
      final source = <NotificationCategory>{NotificationCategory.money};
      final prefs = NotificationPreferences(
        actorId: 'actor-one',
        version: 2,
        enabled: false,
        enabledCategories: source,
      );
      source.add(NotificationCategory.work);
      expect(prefs.enabledCategories, {NotificationCategory.money});
      expect(
        () => prefs.enabledCategories.add(NotificationCategory.security),
        throwsUnsupportedError,
      );
      final copy = NotificationPreferences.fromProto(prefs.toProto());
      expect(copy.actorId, 'actor-one');
      expect(copy.version, 2);
      expect(copy.enabled, false);
      expect(copy.toProto().hasEnabled(), true);
    },
  );

  test('incomplete, unknown or duplicate preferences fail closed', () {
    expect(
      () => NotificationPreferences(
        actorId: 'actor-one',
        version: 0,
        enabled: true,
        enabledCategories: [],
      ),
      throwsA(invalid('invalid_notification_preferences_version')),
    );
    expect(
      () => NotificationPreferences.fromProto(
        wire.NotificationPreferences(actorId: 'actor-one', version: Int64.ONE),
      ),
      throwsA(invalid('incomplete_notification_preferences')),
    );
    final duplicate = wire.NotificationPreferences(
      actorId: 'actor-one',
      version: Int64.ONE,
      enabled: true,
      enabledCategories: [
        wire.NotificationCategory.valueOf(1)!,
        wire.NotificationCategory.valueOf(1)!,
      ],
    );
    expect(
      () => NotificationPreferences.fromProto(duplicate),
      throwsA(invalid('duplicate_notification_category')),
    );
    final unknown = CodedBufferWriter()..writeField(4, PbFieldType.O3, 999);
    final preferences = wire.NotificationPreferences.fromBuffer([
      ...NotificationPreferences(
        actorId: 'actor-one',
        version: 1,
        enabled: true,
        enabledCategories: [],
      ).toProto().writeToBuffer(),
      ...unknown.toBuffer(),
    ]);
    expect(
      () => NotificationPreferences.fromProto(preferences),
      throwsA(invalid('unknown_notification_category')),
    );
  });

  test(
    'event roundtrip retains exact sequence and mandatory false presence',
    () {
      final original = event(sequence: 9007199254740993);
      final copy = NotificationEvent.fromProto(original.toProto());
      expect(copy.sequence, 9007199254740993);
      expect(copy.mandatory, false);
      expect(copy.toProto().hasMandatory(), true);
      expect(copy.target, NotificationTarget.childMoney);
      expect(copy.childId, 'child-one');
    },
  );

  test('an unknown routing enum is rejected even alongside a known target', () {
    final unknownTarget = CodedBufferWriter()
      ..writeField(7, PbFieldType.O3, 999);
    final malformed = wire.NotificationEvent.fromBuffer([
      ...event().toProto().writeToBuffer(),
      ...unknownTarget.toBuffer(),
    ]);
    expect(
      () => NotificationEvent.fromProto(malformed),
      throwsA(invalid('unknown_notification_target')),
    );
    expect(
      () => NotificationEvent.fromProto(event().toProto()..clearTarget()),
      throwsA(invalid('incomplete_notification_event')),
    );
  });

  test(
    'targets require scoped child reference and reject free URLs as IDs',
    () {
      final missingChild = event().toProto()..clearChildId();
      expect(
        () => NotificationEvent.fromProto(missingChild),
        throwsA(invalid('notification_child_required')),
      );
      final arbitraryUrl = event().toProto()
        ..entityId = 'https://example.invalid/private';
      expect(
        () => NotificationEvent.fromProto(arbitraryUrl),
        throwsA(invalid('invalid_notification_reference')),
      );
    },
  );

  test('invalid sequence and lifetime never become a valid event', () {
    expect(
      () =>
          NotificationEvent.fromProto(event().toProto()..sequence = Int64.ZERO),
      throwsA(invalid('invalid_notification_sequence')),
    );
    expect(
      () => NotificationEvent.fromProto(
        event().toProto()..expiresAt = Int64(1792540000),
      ),
      throwsA(invalid('invalid_notification_lifetime')),
    );
    expect(
      () => NotificationEvent.fromProto(event().toProto()..clearMandatory()),
      throwsA(invalid('incomplete_notification_event')),
    );
  });

  test(
    'cursor advances only monotonically within the same recipient actor',
    () {
      final start = NotificationCursor(actorId: 'actor-one', sequence: 1);
      final next = start.advance(event(sequence: 2));
      expect(start.sequence, 1);
      expect(next.sequence, 2);
      expect(
        () => next.advance(event(sequence: 2)),
        throwsA(invalid('notification_sequence_regression')),
      );
      expect(
        () => next.advance(event(actor: 'actor-two', sequence: 3)),
        throwsA(invalid('notification_actor_mismatch')),
      );
    },
  );

  test(
    'installation binding rejects a sibling actor before provider submission',
    () {
      expect(
        () => NotificationDeliveryEnvelope(
          eventId: 'event-one',
          recipientActorId: 'actor-one',
          installation: NotificationInstallationRef(
            installationId: 'installation-one',
            actorId: 'actor-two',
          ),
        ),
        throwsA(invalid('notification_actor_mismatch')),
      );
    },
  );

  test(
    'provider boundary drops undeclared private payload and carries references only',
    () {
      final undeclared = CodedBufferWriter()
        ..writeField(99, PbFieldType.OS, 'private wallet balance and body');
      final received = wire.NotificationEvent.fromBuffer([
        ...event().toProto().writeToBuffer(),
        ...undeclared.toBuffer(),
      ]);
      final metadata = NotificationEvent.fromProto(received);
      expect(metadata.toProto().unknownFields.isEmpty, true);
      final envelope = NotificationDeliveryEnvelope(
        eventId: metadata.eventId,
        recipientActorId: metadata.recipientActorId,
        installation: NotificationInstallationRef(
          installationId: 'installation-one',
          actorId: metadata.recipientActorId,
        ),
      );
      final proto = envelope.toProto();
      expect(proto.info_.byName.keys.toSet(), {
        'eventId',
        'recipientActorId',
        'installation',
      });
      expect(proto.installation.info_.byName.keys.toSet(), {
        'installationId',
        'actorId',
      });
      final copy = NotificationDeliveryEnvelope.fromProto(proto);
      expect(copy.eventId, metadata.eventId);
      expect(copy.installation.actorId, metadata.recipientActorId);
    },
  );

  test(
    'disabled provider always reports not configured and never opens a connection',
    () async {
      const provider = DisabledNotificationProvider();
      var connections = 0;
      final receipt = await HttpOverrides.runZoned(
        () => provider.submit(
          NotificationDeliveryEnvelope(
            eventId: 'event-one',
            recipientActorId: 'actor-one',
            installation: NotificationInstallationRef(
              installationId: 'installation-one',
              actorId: 'actor-one',
            ),
          ),
        ),
        createHttpClient: (_) {
          connections++;
          throw StateError('Network must not run in disabled provider');
        },
      );
      expect(connections, 0);
      expect(provider.isConfigured, false);
      expect(receipt.status, NotificationDeliveryStatus.notConfigured);
      expect(receipt.providerAccepted, false);
      expect(receipt.confirmsDeviceDelivery, false);
      expect(receipt.confirmsRead, false);
    },
  );

  test(
    'provider accepted, pending and read/delivery confirmation are distinct',
    () {
      for (final status in NotificationDeliveryStatus.values) {
        final receipt = NotificationDeliveryReceipt.fromProto(
          NotificationDeliveryReceipt(
            eventId: 'event-one',
            installationId: 'installation-one',
            status: status,
          ).toProto(),
        );
        expect(
          receipt.providerAccepted,
          status == NotificationDeliveryStatus.providerAccepted,
        );
        expect(receipt.confirmsDeviceDelivery, false);
        expect(receipt.confirmsRead, false);
      }
    },
  );
}
