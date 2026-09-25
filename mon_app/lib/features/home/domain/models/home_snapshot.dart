import '../../../events/domain/models/event.dart';
import '../../../news/domain/models/news_article.dart';

/// D'ou vient ce qui est affiche.
///
/// Sans cette distinction, un ecran nourri par les donnees de secours est
/// indiscernable d'un ecran connecte : c'est exactement ce qui rend une panne
/// d'API invisible.
enum HomeSource {
  /// Charge depuis `GET /home`.
  api,

  /// L'API n'a pas repondu : contenu de demonstration embarque dans l'app.
  fallback,
}

/// Tout ce que l'ecran d'accueil affiche, en un seul objet — l'API le sert en
/// une seule requete (`GET /home`).
class HomeSnapshot {
  const HomeSnapshot({
    required this.featuredArticles,
    required this.latestArticles,
    required this.upcomingEvents,
    required this.source,
    this.featuredEvent,
  });

  const HomeSnapshot.empty()
    : featuredArticles = const [],
      latestArticles = const [],
      upcomingEvents = const [],
      featuredEvent = null,
      source = HomeSource.api;

  /// Le carrousel de tete.
  final List<NewsArticle> featuredArticles;

  /// La bande horizontale « DERNIERES ACTUALITES ».
  final List<NewsArticle> latestArticles;

  /// La liste « PROGRAMMES A VENIR ».
  final List<Event> upcomingEvents;

  /// L'evenement mis en avant. L'API peut n'en designer aucun.
  final Event? featuredEvent;

  final HomeSource source;

  /// L'encart « PROCHAIN EVENEMENT » : celui que l'API met en avant, sinon le
  /// prochain dans l'ordre chronologique.
  Event? get highlightedEvent =>
      featuredEvent ?? (upcomingEvents.isEmpty ? null : upcomingEvents.first);

  /// Le carrousel se rabat sur les dernieres actualites : une redaction qui
  /// n'a coche aucune actualite en avant ne doit pas vider le haut de l'ecran.
  List<NewsArticle> get headlineArticles =>
      featuredArticles.isNotEmpty ? featuredArticles : latestArticles;

  bool get isEmpty =>
      headlineArticles.isEmpty &&
      latestArticles.isEmpty &&
      upcomingEvents.isEmpty &&
      featuredEvent == null;
}
