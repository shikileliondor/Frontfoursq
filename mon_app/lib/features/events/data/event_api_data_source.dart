import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/network/api_config.dart';
import '../domain/models/event.dart';
import 'events.dart';

class EventApiDataSource {
  EventApiDataSource({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<Event>> fetchEvents({String status = 'upcoming'}) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/events',
    ).replace(queryParameters: {'per_page': '100', 'status': status});
    final response = await _client.get(uri);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Events request failed: ${response.statusCode}');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic> || decoded['success'] != true) {
      throw Exception('Invalid events response');
    }
    final data = decoded['data'];
    if (data is! List) return const [];

    return [
      for (var i = 0; i < data.length; i++)
        if (data[i] is Map<String, dynamic>)
          eventFromJson(
            data[i] as Map<String, dynamic>,
            fallback: fallbackEvents[i % fallbackEvents.length],
          ),
    ];
  }
}

Event eventFromJson(Map<String, dynamic> json, {required Event fallback}) {
  final start = _read(json, ['start_at', 'date', 'event_date']);
  return Event(
    id: _read(json, ['slug', 'id']) ?? fallback.id,
    title: _read(json, ['title', 'name']) ?? fallback.title,
    location:
        _read(json, ['location', 'venue', 'address']) ?? fallback.location,
    date: _formatDate(start) ?? fallback.date,
    time: _formatTime(start) ?? _read(json, ['time']) ?? fallback.time,
    scopeLabel:
        _read(json, ['scope', 'scope_type', 'category']) ?? fallback.scopeLabel,
    imagePath: fallback.imagePath,
    imageUrl: _imageUrl(json),
  );
}

String? _read(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty && text != 'null') return text;
  }
  return null;
}

String? _formatDate(String? value) {
  if (value == null) return null;
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return value;
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${parsed.day.toString().padLeft(2, '0')} '
      '${months[parsed.month - 1]} ${parsed.year}';
}

String? _formatTime(String? value) {
  if (value == null) return null;
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return null;
  return '${parsed.hour.toString().padLeft(2, '0')}h'
      '${parsed.minute.toString().padLeft(2, '0')}';
}

String? _imageUrl(Map<String, dynamic> json) {
  final direct = _read(json, ['image_url', 'cover_url', 'thumbnail_url']);
  if (direct != null) return direct;
  final image = json['image'] ?? json['cover'] ?? json['media'];
  if (image is Map<String, dynamic>) {
    return _read(image, ['url', 'full_url', 'path']);
  }
  if (image is String && image.trim().startsWith('http')) return image.trim();
  return null;
}
