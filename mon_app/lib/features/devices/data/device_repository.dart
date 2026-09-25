import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/network/api_config.dart';

class DeviceRepository {
  DeviceRepository({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<void> registerDevice({
    required String fcmToken,
    required String platform,
    String appVersion = '1.0.0',
    String? churchId,
  }) async {
    final payload = <String, Object?>{
      'fcm_token': fcmToken,
      'platform': platform,
      'app_version': appVersion,
    };
    if (churchId != null && churchId.isNotEmpty) {
      payload['church_id'] = churchId;
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
