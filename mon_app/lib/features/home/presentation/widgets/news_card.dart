import 'package:flutter/material.dart';

class NewsCard extends StatelessWidget {
  const NewsCard({
    required this.imagePath,
    required this.scope,
    required this.title,
    required this.date,
    required this.scopeColor,
    this.imageUrl,
    this.onTap,
    super.key,
  });

  final String imagePath;
  final String? imageUrl;
  final String scope;
  final String title;
  final String date;
  final Color scopeColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 174,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE4E6EC)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 116,
                width: double.infinity,
                child: ColoredBox(
                  color: const Color(0xFFF2F3F6),
                  child: _CardImage(imagePath: imagePath, imageUrl: imageUrl),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: scopeColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          scope,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        date,
                        style: const TextStyle(
                          color: Color(0xFFA1A7B5),
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardImage extends StatelessWidget {
  const _CardImage({required this.imagePath, required this.imageUrl});

  final String imagePath;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    if (url != null && url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          imagePath,
          fit: BoxFit.contain,
          alignment: Alignment.center,
        ),
      );
    }

    return Image.asset(
      imagePath,
      fit: BoxFit.contain,
      alignment: Alignment.center,
    );
  }
}
