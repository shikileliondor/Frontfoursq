import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../news/domain/models/news_article.dart';

class FeaturedStoryBanner extends StatefulWidget {
  const FeaturedStoryBanner({this.articles = const [], this.onTap, super.key});

  final List<NewsArticle> articles;
  final VoidCallback? onTap;

  @override
  State<FeaturedStoryBanner> createState() => _FeaturedStoryBannerState();
}

class _FeaturedStoryBannerState extends State<FeaturedStoryBanner> {
  static const _fallbackStories = [
    (
      image: AppAssets.homeFeatured,
      imageUrl: null,
      title: 'Assemblee Generale Nationale 2025',
      detail: '12-14 Octobre - Abidjan',
    ),
    (
      image: AppAssets.youthEvent,
      imageUrl: null,
      title: 'La jeunesse Foursquare en mission',
      detail: 'Camp de Jacqueville - Cote dIvoire',
    ),
    (
      image: AppAssets.conventionNews,
      imageUrl: null,
      title: 'Retour sur la Convention 2026',
      detail: 'Vie de lEglise - Abidjan',
    ),
  ];

  final PageController _pageController = PageController();
  Timer? _autoScrollTimer;
  int _currentPage = 0;

  List<({String image, String? imageUrl, String title, String detail})>
  get _stories {
    if (widget.articles.isEmpty) return _fallbackStories;
    return [
      for (final article in widget.articles.take(3))
        (
          image: article.imagePath,
          imageUrl: article.imageUrl,
          title: article.title,
          detail: article.date,
        ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      final stories = _stories;
      if (!_pageController.hasClients || stories.isEmpty) return;
      _pageController.animateToPage(
        (_currentPage + 1) % stories.length,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stories = _stories;

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = (constraints.maxWidth / 2.05).clamp(142.0, 200.0);

        return Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: double.infinity,
              height: height,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: stories.length,
                      onPageChanged: (page) =>
                          setState(() => _currentPage = page),
                      itemBuilder: (context, index) {
                        final story = stories[index];
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            _StoryImage(
                              image: story.image,
                              imageUrl: story.imageUrl,
                            ),
                            const DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Color(0xD9000000),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              left: 14,
                              right: 14,
                              bottom: 13,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'A LA UNE',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    story.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    story.detail,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Positioned(
                              right: 12,
                              bottom: 12,
                              child: Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Semantics(
                        label:
                            'Actualite ${_currentPage + 1} sur ${stories.length}',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(stories.length, (index) {
                            final selected = index == _currentPage;
                            return Container(
                              width: selected ? 16 : 6,
                              height: 6,
                              margin: const EdgeInsets.only(left: 4),
                              decoration: BoxDecoration(
                                color: selected ? Colors.white : Colors.white54,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StoryImage extends StatelessWidget {
  const _StoryImage({required this.image, required this.imageUrl});

  final String image;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    if (url != null && url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        errorBuilder: (context, error, stackTrace) =>
            Image.asset(image, fit: BoxFit.cover, alignment: Alignment.center),
      );
    }

    return Image.asset(image, fit: BoxFit.cover, alignment: Alignment.center);
  }
}
