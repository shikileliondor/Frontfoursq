import '../domain/models/news_article.dart';
import 'news_api_data_source.dart';
import 'news_articles.dart';

class NewsRepository {
  NewsRepository({NewsApiDataSource? apiDataSource})
    : _apiDataSource = apiDataSource ?? NewsApiDataSource();

  final NewsApiDataSource _apiDataSource;

  Future<List<NewsArticle>> getNews({NewsCategory? category}) async {
    try {
      final remoteArticles = await _apiDataSource.fetchNews(category: category);
      if (remoteArticles.isNotEmpty) return remoteArticles;
    } catch (_) {
      // Keep the screen useful offline and during API maintenance.
    }

    if (category == null) return newsArticles;
    return newsArticles
        .where((article) => article.category == category)
        .toList(growable: false);
  }
}
