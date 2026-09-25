import 'package:flutter/material.dart';

import '../../domain/models/news_article.dart';
import '../widgets/news_article_image.dart';

class NewsDetailPage extends StatelessWidget {
  const NewsDetailPage({
    required this.article,
    required this.onBack,
    super.key,
  });

  final NewsArticle article;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Stack(
            children: [
              AspectRatio(
                aspectRatio: 1.7,
                child: NewsArticleImage(
                  article: article,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
              Positioned(
                left: 16,
                top: 16,
                child: _RoundIconButton(
                  tooltip: 'Retour',
                  icon: Icons.arrow_back_ios_new_rounded,
                  onPressed: onBack,
                ),
              ),
              Positioned(
                right: 16,
                top: 16,
                child: _RoundIconButton(
                  tooltip: 'Partager',
                  icon: Icons.share_outlined,
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
          sliver: SliverList.list(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: article.badgeColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      article.badgeLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      article.typeLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF98A0B3),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                article.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w900,
                  height: 1.18,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                article.date,
                style: const TextStyle(
                  color: Color(0xFF98A0B3),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 10),
              const SizedBox(
                width: 34,
                child: Divider(
                  color: Color(0xFFE31E2D),
                  height: 18,
                  thickness: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                article.body,
                style: const TextStyle(
                  color: Color(0xFF25324B),
                  fontSize: 14,
                  height: 1.55,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, size: 19, color: const Color(0xFF102A63)),
      ),
    );
  }
}
