import 'package:flutter/material.dart';

import '../../domain/models/church.dart';

class ChurchImage extends StatelessWidget {
  const ChurchImage({
    required this.church,
    required this.fit,
    this.alignment = Alignment.center,
    super.key,
  });

  final Church church;
  final BoxFit fit;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final imageUrl = church.imageUrl;
    if (imageUrl != null && imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: fit,
        alignment: alignment,
        errorBuilder: (context, error, stackTrace) =>
            _AssetFallback(church: church, fit: fit, alignment: alignment),
      );
    }

    return _AssetFallback(church: church, fit: fit, alignment: alignment);
  }
}

class _AssetFallback extends StatelessWidget {
  const _AssetFallback({
    required this.church,
    required this.fit,
    required this.alignment,
  });

  final Church church;
  final BoxFit fit;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Image.asset(church.imagePath, fit: fit, alignment: alignment);
  }
}
