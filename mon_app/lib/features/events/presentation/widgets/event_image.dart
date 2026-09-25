import 'package:flutter/material.dart';

import '../../domain/models/event.dart';

class EventImage extends StatelessWidget {
  const EventImage({required this.event, required this.fit, super.key});

  final Event event;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final imageUrl = event.imageUrl;
    if (imageUrl != null && imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: fit,
        alignment: Alignment.center,
        errorBuilder: (context, error, stackTrace) =>
            Image.asset(event.imagePath, fit: fit),
      );
    }
    return Image.asset(event.imagePath, fit: fit);
  }
}
