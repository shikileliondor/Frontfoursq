import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/network/api_config.dart';

class DeviceRepository {
  DeviceRepository({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<void> registerDevice({
    required String fcmToken,
    required String platform,
    String? appVersion,
    String? churchId,
    bool notificationsEnabled = true,
  }) async {
    final payload = <String, Object?>{
      'fcm_token': fcmToken,
      'platform': platform,
      'church_id': churchId,
      'notifications_enabled': notificationsEnabled,
    };
    if (appVersion != null) {
      payload['app_version'] = appVersion;
    }

    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/devices'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Device registration failed: ${response.statusCode}');
    }
  }
}
