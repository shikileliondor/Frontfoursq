import 'dart:async';
import 'dart:convert';

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
  'orientemoi_alerts',
  'Alertes Oriente Moi',
  description: 'Notifications importantes',
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
  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    handleNotificationOpenedApp(initialMessage);
  }

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

void handleNotificationOpenedApp(RemoteMessage message) {
  _onNotificationTap(message.data, messageId: message.messageId);
}

Future<void> _initializeLocalNotifications() async {
  const initializationSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/launcher_icon'),
    iOS: DarwinInitializationSettings(),
  );

  await _localNotifications.initialize(
    settings: initializationSettings,
    onDidReceiveNotificationResponse: (response) {
      _handleLocalNotificationTap(response.payload);
    },
  );
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
    payload: jsonEncode(message.data),
  );
}

void _handleLocalNotificationTap(String? payload) {
  if (payload == null || payload.isEmpty) {
    _onNotificationTap(const <String, dynamic>{});
    return;
  }

  try {
    final decoded = jsonDecode(payload);
    if (decoded is Map<String, dynamic>) {
      _onNotificationTap(decoded);
      return;
    }
  } catch (_) {
    // A malformed local payload should only lose navigation context.
  }

  _onNotificationTap(<String, dynamic>{'payload': payload});
}

void _onNotificationTap(Map<String, dynamic> data, {String? messageId}) {
  debugPrint(
    '[FCM] Notification ouverte: ${messageId ?? data['notification_id'] ?? 'locale'}',
  );
  debugPrint('[FCM] Donnees notification: $data');

  final type = data['type']?.toString().toLowerCase();
  switch (type) {
    case 'alert':
    case 'general':
      debugPrint('[FCM] Navigation cible: accueil');
      break;
    case 'news':
      debugPrint(
        '[FCM] Navigation cible: actualite ${data['news_id'] ?? data['id'] ?? ''}',
      );
      break;
    case 'event':
      debugPrint(
        '[FCM] Navigation cible: evenement ${data['event_id'] ?? data['id'] ?? ''}',
      );
      break;
    case 'school':
      debugPrint('[FCM] Navigation cible: ecole ${data['id'] ?? ''}');
      break;
    case 'internship':
      debugPrint('[FCM] Navigation cible: stage ${data['id'] ?? ''}');
      break;
    default:
      debugPrint('[FCM] Navigation cible: accueil');
  }
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
