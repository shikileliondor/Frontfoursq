import 'dart:async';

class NotificationRegistrationService {
  NotificationRegistrationService({
    required this.messaging,
    required this.devices,
    required this.platform,
    this.appVersion = '1.0.0',
    this.churchId,
  });

  final PushMessagingClient messaging;
  final DeviceRegistrationClient devices;
  final String platform;
  final String appVersion;
  final String? churchId;

  StreamSubscription<String>? _tokenRefreshSubscription;

  Future<void> start() async {
    await messaging.requestPermission();
    await _registerCurrentToken();
    _tokenRefreshSubscription ??= messaging.onTokenRefresh.listen(
      _tryRegisterToken,
    );
  }

  Future<void> dispose() async {
    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = null;
  }

  Future<void> _registerCurrentToken() async {
    final token = await messaging.getToken();
    if (token == null || token.isEmpty) {
      return;
    }

    await _tryRegisterToken(token);
  }

  Future<void> _tryRegisterToken(String token) async {
    try {
      await devices.registerDevice(
        DeviceRegistration(
          fcmToken: token,
          platform: platform,
          appVersion: appVersion,
          churchId: churchId,
        ),
      );
    } catch (_) {
      // Registration can fail when the API is offline; notification setup should not block app startup.
    }
  }
}

abstract interface class PushMessagingClient {
  Future<void> requestPermission();

  Future<String?> getToken();

  Stream<String> get onTokenRefresh;
}

abstract interface class DeviceRegistrationClient {
  Future<void> registerDevice(DeviceRegistration registration);
}

class DeviceRegistration {
  const DeviceRegistration({
    required this.fcmToken,
    required this.platform,
    required this.appVersion,
    this.churchId,
  });

  final String fcmToken;
  final String platform;
  final String appVersion;
  final String? churchId;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is DeviceRegistration &&
            other.fcmToken == fcmToken &&
            other.platform == platform &&
            other.appVersion == appVersion &&
            other.churchId == churchId;
  }

  @override
  int get hashCode => Object.hash(fcmToken, platform, appVersion, churchId);
}
