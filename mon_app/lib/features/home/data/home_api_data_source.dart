import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/network/api_config.dart';
import '../../events/data/event_api_data_source.dart';
import '../../events/data/events.dart';
import '../../events/domain/models/event.dart';
import '../../news/data/news_api_data_source.dart';
import '../../news/data/news_articles.dart';
import '../../news/domain/models/news_article.dart';
import '../domain/models/home_snapshot.dart';

/// `GET /home` sert tout l'ecran d'accueil en une requete : banniere, actualite
/// en avant, evenement en avant, dernieres actualites et prochains programmes.
/// Deux appels separes vers /news et /events feraient le meme travail en deux
/// fois plus de temps, et pourraient se contredire.
class HomeApiDataSource {
  HomeApiDataSource({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<HomeSnapshot> fetchHome() async {
    final response = await _client.get(Uri.parse('${ApiConfig.baseUrl}/home'));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Home request failed: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic> || decoded['success'] != true) {
      throw Exception('Invalid home response');
    }

    final data = decoded['data'];
    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid home payload');
    }

    final upcomingEvents = _events(data['upcoming_events']);

    return HomeSnapshot(
      featuredArticles: _articles(data['featured_news']),
      latestArticles: _articles(data['latest_news']),
      upcomingEvents: upcomingEvents,
      featuredEvent: _event(data['featured_event']),
      source: HomeSource.api,
    );
  }

  /// Les visuels et libelles par defaut viennent du contenu embarque : l'API ne
  /// fournit pas d'illustration locale, et un champ absent ne doit pas laisser
  /// un trou dans la maquette.
  List<NewsArticle> _articles(Object? raw) {
    if (raw is! List) return const [];

    return [
      for (var i = 0; i < raw.length; i++)
        if (raw[i] is Map<String, dynamic>)
          newsArticleFromJson(
            raw[i] as Map<String, dynamic>,
            fallback: newsArticles[i % newsArticles.length],
          ),
    ];
  }

  List<Event> _events(Object? raw) {
    if (raw is! List) return const [];

    return [
      for (var i = 0; i < raw.length; i++)
        if (raw[i] is Map<String, dynamic>)
          eventFromJson(
            raw[i] as Map<String, dynamic>,
            fallback: fallbackEvents[i % fallbackEvents.length],
          ),
    ];
  }

  Event? _event(Object? raw) {
    if (raw is! Map<String, dynamic>) return null;

    return eventFromJson(raw, fallback: fallbackEvents.first);
  }
}
