import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/network/api_config.dart';
import 'features/notifications/application/notification_registration_service.dart';
import 'features/notifications/data/device_registration_api_client.dart';
import 'features/notifications/data/firebase_push_messaging_client.dart';
import 'features/onboarding/presentation/providers/onboarding_providers.dart';
import 'firebase_options.dart';

const _notificationChannel = AndroidNotificationChannel(
  'foursquare_notifications',
  'Notifications Foursquare',
  description: 'Notifications de Foursquare CI',
  importance: Importance.high,
);

final _localNotifications = FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _initializeLocalNotifications();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen(handleForegroundMessage);
  FirebaseMessaging.onMessageOpenedApp.listen(handleNotificationOpenedApp);

  final preferences = await SharedPreferences.getInstance();
  if (_canRegisterPushNotifications) {
    unawaited(_startNotificationRegistration());
  }

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
      child: const FoursquareApp(),
    ),
  );
}

void handleForegroundMessage(RemoteMessage message) {
  unawaited(_showForegroundNotification(message));
}

void handleNotificationOpenedApp(RemoteMessage message) {}

Future<void> _initializeLocalNotifications() async {
  const initializationSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/launcher_icon'),
    iOS: DarwinInitializationSettings(),
  );

  await _localNotifications.initialize(settings: initializationSettings);
  await _localNotifications
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(_notificationChannel);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
}

Future<void> _showForegroundNotification(RemoteMessage message) async {
  final notification = message.notification;
  if (notification == null) {
    return;
  }

  await _localNotifications.show(
    id: notification.hashCode,
    title: notification.title,
    body: notification.body,
    notificationDetails: NotificationDetails(
      android: AndroidNotificationDetails(
        _notificationChannel.id,
        _notificationChannel.name,
        channelDescription: _notificationChannel.description,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    ),
    payload: message.data['notification_id'],
  );
}

Future<void> _startNotificationRegistration() async {
  try {
    final service = NotificationRegistrationService(
      messaging: FirebasePushMessagingClient(),
      devices: DeviceRegistrationApiClient(),
      platform: _currentDevicePlatform,
    );

    await service.start();
    await _logPushDiagnostics();
  } catch (_) {
    // Push setup depends on native services and should never prevent the app from opening.
  }
}

/// Le token n'apparait nulle part dans l'interface. Sans lui, impossible de
/// viser ce telephone depuis le serveur (`php artisan fcm:test --token=...`).
Future<void> _logPushDiagnostics() async {
  if (!kDebugMode) {
    return;
  }

  debugPrint('API_BASE_URL : ${ApiConfig.baseUrl}');
  debugPrint('FCM token    : ${await FirebaseMessaging.instance.getToken()}');
}

bool get _canRegisterPushNotifications {
  return !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
}

String get _currentDevicePlatform {
  return switch (defaultTargetPlatform) {
    TargetPlatform.android => 'android',
    TargetPlatform.iOS => 'ios',
    TargetPlatform.macOS => 'macos',
    TargetPlatform.windows => 'windows',
    TargetPlatform.linux => 'linux',
    TargetPlatform.fuchsia => 'fuchsia',
  };
}
