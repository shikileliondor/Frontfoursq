import 'package:flutter/material.dart';

import '../../domain/models/news_article.dart';

class NewsArticleImage extends StatelessWidget {
  const NewsArticleImage({
    required this.article,
    required this.fit,
    this.alignment = Alignment.center,
    super.key,
  });

  final NewsArticle article;
  final BoxFit fit;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final imageUrl = article.imageUrl;
    if (imageUrl != null && imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: fit,
        alignment: alignment,
        errorBuilder: (context, error, stackTrace) =>
            _AssetFallback(article: article, fit: fit, alignment: alignment),
      );
    }

    return _AssetFallback(article: article, fit: fit, alignment: alignment);
  }
}

class _AssetFallback extends StatelessWidget {
  const _AssetFallback({
    required this.article,
    required this.fit,
    required this.alignment,
  });

  final NewsArticle article;
  final BoxFit fit;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Image.asset(article.imagePath, fit: fit, alignment: alignment);
  }
}
