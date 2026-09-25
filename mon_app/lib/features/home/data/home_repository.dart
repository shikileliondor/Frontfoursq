import '../../events/data/events.dart';
import '../../news/data/news_articles.dart';
import '../domain/models/home_snapshot.dart';
import 'home_api_data_source.dart';

class HomeRepository {
  HomeRepository({HomeApiDataSource? apiDataSource})
    : _apiDataSource = apiDataSource ?? HomeApiDataSource();

  final HomeApiDataSource _apiDataSource;

  /// Ne leve jamais : l'accueil reste lisible hors ligne. Mais le repli est
  /// annonce dans `source`, pour que l'ecran puisse le dire au lieu de faire
  /// passer du contenu de demonstration pour la realite.
  Future<HomeSnapshot> getHome() async {
    try {
      final snapshot = await _apiDataSource.fetchHome();

      // Une API qui repond « rien a afficher » n'est pas une panne, mais un
      // accueil vide n'aide personne : on montre la demonstration en le disant.
      if (!snapshot.isEmpty) return snapshot;
    } catch (_) {
      // Hors ligne, maintenance, DNS : le repli est le meme.
    }

    return _fallback();
  }

  HomeSnapshot _fallback() {
    return HomeSnapshot(
      featuredArticles: newsArticles.take(4).toList(growable: false),
      latestArticles: newsArticles,
      upcomingEvents: fallbackEvents,
      featuredEvent: fallbackEvents.isEmpty ? null : fallbackEvents.first,
      source: HomeSource.fallback,
    );
  }
}
