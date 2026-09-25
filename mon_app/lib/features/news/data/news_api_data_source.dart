import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../core/network/api_config.dart';
import '../domain/models/news_article.dart';
import 'news_articles.dart';

class NewsApiDataSource {
  NewsApiDataSource({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<NewsArticle>> fetchNews({NewsCategory? category}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/news').replace(
      queryParameters: {
        'per_page': '100',
        if (category != null) 'scope': category.scope,
      },
    );

    final response = await _client.get(uri);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('News request failed: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic> || decoded['success'] != true) {
      throw Exception('Invalid news response');
    }

    final data = decoded['data'];
    if (data is! List) return const [];

    return [
      for (var i = 0; i < data.length; i++)
        if (data[i] is Map<String, dynamic>)
          _articleFromJson(
            data[i] as Map<String, dynamic>,
            fallback: newsArticles[i % newsArticles.length],
          ),
    ];
  }
}

NewsArticle _articleFromJson(
  Map<String, dynamic> json, {
  required NewsArticle fallback,
}) {
  final category =
      _categoryFromScope(_read(json, ['scope', 'scope_type'])) ??
      fallback.category;
  final badgeColor = _badgeColor(category);
  final title = _read(json, ['title', 'name']) ?? fallback.title;
  final body = _plainText(
    _read(json, ['body', 'content', 'description']) ?? fallback.body,
  );

  return NewsArticle(
    id: _read(json, ['slug', 'id']) ?? fallback.id,
    title: title,
    summary: _plainText(
      _read(json, ['summary', 'excerpt', 'description']) ?? body,
    ),
    body: body,
    date:
        _formatDate(_read(json, ['published_at', 'date', 'created_at'])) ??
        fallback.date,
    imagePath: fallback.imagePath,
    category: category,
    badgeLabel: category.scope,
    badgeColor: badgeColor,
    typeLabel: _read(json, ['type', 'category', 'label']) ?? fallback.typeLabel,
    imageUrl: _imageUrl(json),
  );
}

NewsCategory? _categoryFromScope(String? scope) {
  final normalized = scope?.trim().toUpperCase();
  if (normalized == null) return null;
  for (final category in NewsCategory.values) {
    if (category.scope == normalized) return category;
  }
  return null;
}

Color _badgeColor(NewsCategory category) {
  return switch (category) {
    NewsCategory.national => const Color(0xFFE31E2D),
    NewsCategory.district => const Color(0xFF3154C7),
    NewsCategory.zone => const Color(0xFF0E9F6E),
    NewsCategory.church => const Color(0xFF7C3AED),
  };
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

String _plainText(String value) {
  return value
      .replaceAll(RegExp('<[^>]*>'), ' ')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
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
