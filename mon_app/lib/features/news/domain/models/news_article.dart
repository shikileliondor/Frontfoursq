import 'package:flutter/material.dart';

enum NewsCategory {
  national('National', 'NATIONAL'),
  district('Districts', 'DISTRICT'),
  zone('Zones', 'ZONE'),
  church('Eglise', 'CHURCH');

  const NewsCategory(this.label, this.scope);

  final String label;
  final String scope;
}

class NewsArticle {
  const NewsArticle({
    required this.id,
    required this.title,
    required this.summary,
    required this.body,
    required this.date,
    required this.imagePath,
    required this.category,
    required this.badgeLabel,
    required this.badgeColor,
    required this.typeLabel,
    this.imageUrl,
  });

  final String id;
  final String title;
  final String summary;
  final String body;
  final String date;
  final String imagePath;
  final NewsCategory category;
  final String badgeLabel;
  final Color badgeColor;
  final String typeLabel;
  final String? imageUrl;
}
