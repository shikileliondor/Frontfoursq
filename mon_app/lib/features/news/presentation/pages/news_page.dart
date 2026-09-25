import 'package:flutter/material.dart';

import '../../../../core/presentation/refreshable_scroll_view.dart';
import '../../data/news_repository.dart';
import '../../domain/models/news_article.dart';
import '../widgets/news_article_card.dart';
import '../widgets/news_category_chip.dart';
import 'news_detail_page.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key, this.repository});

  /// Injectable pour les tests : sans cela, la page ne peut etre
  /// exercee qu'au travers d'un vrai appel reseau.
  final NewsRepository? repository;

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  late final NewsRepository _repository = widget.repository ?? NewsRepository();
  NewsCategory? _selectedCategory;
  NewsArticle? _selectedArticle;
  late Future<List<NewsArticle>> _articlesFuture = _repository.getNews();

  void _selectCategory(NewsCategory? category) {
    setState(() {
      _selectedCategory = category;
      _articlesFuture = _repository.getNews(category: category);
    });
  }

  /// Recharge sans perdre le filtre en cours : tirer sur « Districts » doit
  /// rapporter les actualites de district, pas revenir a « Tous ».
  Future<void> _refresh() async {
    final future = _repository.getNews(category: _selectedCategory);
    // Corps de bloc obligatoire : la forme flechee renverrait le Future,
    // ce que setState refuse.
    setState(() {
      _articlesFuture = future;
    });
    await future;
  }

  @override
  Widget build(BuildContext context) {
    final selectedArticle = _selectedArticle;
    if (selectedArticle != null) {
      return NewsDetailPage(
        article: selectedArticle,
        onBack: () => setState(() => _selectedArticle = null),
      );
    }

    return RefreshableScrollView(
      onRefresh: _refresh,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: _NewsHeader(
              selectedCategory: _selectedCategory,
              onSelected: _selectCategory,
            ),
          ),
        ),
        FutureBuilder<List<NewsArticle>>(
          future: _articlesFuture,
          builder: (context, snapshot) {
            final articles = snapshot.data ?? const <NewsArticle>[];

            if (snapshot.connectionState == ConnectionState.waiting &&
                articles.isEmpty) {
              return const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (articles.isEmpty) {
              return const SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyNewsState(),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList.builder(
                itemCount: articles.length,
                itemBuilder: (context, index) {
                  final article = articles[index];
                  return NewsArticleCard(
                    article: article,
                    onTap: () => setState(() => _selectedArticle = article),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class _NewsHeader extends StatelessWidget {
  const _NewsHeader({required this.selectedCategory, required this.onSelected});

  final NewsCategory? selectedCategory;
  final ValueChanged<NewsCategory?> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actualites',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 3),
        const Text(
          'Publications officielles Foursquare CI',
          style: TextStyle(
            color: Color(0xFF8E95A6),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              NewsCategoryChip(
                label: 'Tous',
                selected: selectedCategory == null,
                onSelected: () => onSelected(null),
              ),
              for (final category in NewsCategory.values)
                NewsCategoryChip(
                  label: category.label,
                  selected: selectedCategory == category,
                  onSelected: () => onSelected(category),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyNewsState extends StatelessWidget {
  const _EmptyNewsState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Center(
        child: Text(
          'Aucune actualite disponible',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF667085),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
