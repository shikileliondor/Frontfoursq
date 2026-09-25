import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/network/api_config.dart';
import '../domain/models/church.dart';
import 'churches.dart';

class ChurchApiDataSource {
  ChurchApiDataSource({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<Church>> fetchChurches({String search = ''}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/churches').replace(
      queryParameters: {
        'per_page': '100',
        if (search.trim().isNotEmpty) 'search': search.trim(),
      },
    );

    final response = await _client.get(uri);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Churches request failed: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic> || decoded['success'] != true) {
      throw Exception('Invalid churches response');
    }

    final data = decoded['data'];
    if (data is! List) return const [];

    return [
      for (var i = 0; i < data.length; i++)
        if (data[i] is Map<String, dynamic>)
          _churchFromJson(
            data[i] as Map<String, dynamic>,
            fallback: churches[i % churches.length],
          ),
    ];
  }
}

Church _churchFromJson(Map<String, dynamic> json, {required Church fallback}) {
  final district =
      _nestedName(json['district']) ?? _read(json, ['district_name']);
  final zone = _nestedName(json['zone']) ?? _read(json, ['zone_name']);

  return Church(
    id: _read(json, ['id', 'slug']) ?? fallback.id,
    name: _read(json, ['name', 'title']) ?? fallback.name,
    area: _read(json, ['quarter', 'neighborhood', 'commune']) ?? fallback.area,
    district: district ?? fallback.district,
    zone: zone ?? fallback.zone,
    address: _read(json, ['address', 'location']) ?? fallback.address,
    pastor: _read(json, ['pastor_name', 'pastor', 'leader']) ?? fallback.pastor,
    phone: _read(json, ['phone', 'telephone', 'whatsapp']) ?? fallback.phone,
    schedule:
        _read(json, ['schedule', 'service_time', 'service_times']) ??
        fallback.schedule,
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

String? _nestedName(Object? value) {
  if (value is Map<String, dynamic>) {
    return _read(value, ['name', 'title', 'label']);
  }
  if (value is String && value.trim().isNotEmpty) return value.trim();
  return null;
}

String? _imageUrl(Map<String, dynamic> json) {
  final direct = _read(json, ['image_url', 'cover_url', 'photo_url']);
  if (direct != null) return direct;

  final image = json['image'] ?? json['cover'] ?? json['media'];
  if (image is Map<String, dynamic>) {
    return _read(image, ['url', 'full_url', 'path']);
  }
  if (image is String && image.trim().startsWith('http')) return image.trim();
  return null;
}
