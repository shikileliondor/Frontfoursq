import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mon_app/features/notifications/application/notification_registration_service.dart';

void main() {
  test('registers the current FCM token when notifications start', () async {
    final messaging = FakePushMessagingClient(initialToken: 'token-123');
    final devices = RecordingDeviceRegistrationClient();
    final service = NotificationRegistrationService(
      messaging: messaging,
      devices: devices,
      platform: 'android',
      churchId: 'church-1',
    );

    await service.start();

    expect(devices.registrations, [
      const DeviceRegistration(
        fcmToken: 'token-123',
        platform: 'android',
        churchId: 'church-1',
        notificationsEnabled: true,
      ),
    ]);
  });

  test('does not register a device when FCM returns no token', () async {
    final messaging = FakePushMessagingClient(initialToken: null);
    final devices = RecordingDeviceRegistrationClient();
    final service = NotificationRegistrationService(
      messaging: messaging,
      devices: devices,
      platform: 'android',
    );

    await service.start();

    expect(devices.registrations, isEmpty);
  });

  test('registers refreshed FCM tokens after startup', () async {
    final messaging = FakePushMessagingClient(initialToken: 'token-123');
    final devices = RecordingDeviceRegistrationClient();
    final service = NotificationRegistrationService(
      messaging: messaging,
      devices: devices,
      platform: 'android',
    );

    await service.start();
    messaging.refreshToken('token-456');
    await Future<void>.delayed(Duration.zero);

    expect(devices.registrations.map((registration) => registration.fcmToken), [
      'token-123',
      'token-456',
    ]);

    await service.dispose();
  });

  test('keeps startup alive when device registration fails', () async {
    final messaging = FakePushMessagingClient(initialToken: 'token-123');
    final service = NotificationRegistrationService(
      messaging: messaging,
      devices: FailingDeviceRegistrationClient(),
      platform: 'android',
    );

    await expectLater(service.start(), completes);
  });
}

class FakePushMessagingClient implements PushMessagingClient {
  FakePushMessagingClient({required this.initialToken});

  final String? initialToken;
  final _tokenRefreshController = StreamController<String>.broadcast();

  @override
  Future<String?> getToken() async => initialToken;

  @override
  Future<void> requestPermission() async {}

  @override
  Stream<String> get onTokenRefresh => _tokenRefreshController.stream;

  void refreshToken(String token) {
    _tokenRefreshController.add(token);
  }
}

class RecordingDeviceRegistrationClient implements DeviceRegistrationClient {
  final registrations = <DeviceRegistration>[];

  @override
  Future<void> registerDevice(DeviceRegistration registration) async {
    registrations.add(registration);
  }
}

class FailingDeviceRegistrationClient implements DeviceRegistrationClient {
  @override
  Future<void> registerDevice(DeviceRegistration registration) async {
    throw Exception('API unavailable');
  }
}
