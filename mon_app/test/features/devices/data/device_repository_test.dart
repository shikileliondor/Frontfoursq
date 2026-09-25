import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mon_app/features/devices/data/device_repository.dart';

void main() {
  test('posts FCM token to devices endpoint', () async {
    late http.Request capturedRequest;
    final repository = DeviceRepository(
      client: MockClient((request) async {
        capturedRequest = request;
        return http.Response('{}', 201);
      }),
    );

    await repository.registerDevice(fcmToken: 'fcm-token', platform: 'android');

    expect(capturedRequest.url.path, endsWith('/devices'));
    expect(capturedRequest.headers['Content-Type'], 'application/json');
    expect(jsonDecode(capturedRequest.body), {
      'fcm_token': 'fcm-token',
      'platform': 'android',
      'app_version': '1.0.0',
    });
  });

  test('posts optional church id when available', () async {
    late http.Request capturedRequest;
    final repository = DeviceRepository(
      client: MockClient((request) async {
        capturedRequest = request;
        return http.Response('{}', 200);
      }),
    );

    await repository.registerDevice(
      fcmToken: 'fcm-token',
      platform: 'ios',
      appVersion: '1.2.3',
      churchId: 'church-uuid',
    );

    expect(jsonDecode(capturedRequest.body), {
      'fcm_token': 'fcm-token',
      'platform': 'ios',
      'app_version': '1.2.3',
      'church_id': 'church-uuid',
    });
  });
}
