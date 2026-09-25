import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/presentation/refreshable_scroll_view.dart';
import '../../../churches/presentation/pages/churches_page.dart';
import '../../../events/presentation/pages/events_page.dart';
import '../../../news/presentation/pages/news_page.dart';
import '../../data/home_repository.dart';
import '../../domain/models/home_snapshot.dart';
import '../widgets/church_discovery_banner.dart';
import '../widgets/featured_story_banner.dart';
import '../widgets/home_header.dart';
import '../widgets/home_section_header.dart';
import '../widgets/news_card.dart';
import '../widgets/program_item.dart';
import '../widgets/upcoming_event_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.homeRepository});

  /// Injectable pour les tests : sans cela, l'ecran ne peut etre exerce
  /// qu'au travers d'un vrai appel reseau.
  final HomeRepository? homeRepository;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _handleDestination(BuildContext context, int index) {
    if (index == _selectedIndex) return;

    if (index >= 0 && index <= 3) {
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _HomeContent(repository: widget.homeRepository),
            const NewsPage(),
            const EventsPage(),
            const ChurchesPage(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        height: 68,
        backgroundColor: Colors.white,
        indicatorColor: const Color(0x18E31E2D),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (index) => _handleDestination(context, index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: Color(0xFFE31E2D)),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.article_outlined),
            selectedIcon: Icon(Icons.article_rounded, color: Color(0xFFE31E2D)),
            label: 'Actus',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Evenements',
          ),
          NavigationDestination(
            icon: Icon(Icons.church_outlined),
            selectedIcon: Icon(Icons.church_rounded, color: Color(0xFFE31E2D)),
            label: 'Eglises',
          ),
        ],
      ),
    );
  }
}

class _HomeContent extends StatefulWidget {
  const _HomeContent({this.repository});

  final HomeRepository? repository;

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  late final HomeRepository _repository = widget.repository ?? HomeRepository();

  HomeSnapshot? _snapshot;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Rend la main a `RefreshIndicator`, qui garde son animation tant que le
  /// future n'est pas termine.
  Future<void> _load() async {
    final snapshot = await _repository.getHome();

    // L'ecran a pu etre quitte pendant la requete.
    if (!mounted) return;

    setState(() => _snapshot = snapshot);
  }

  @override
  Widget build(BuildContext context) {
    final data = _snapshot;

    return RefreshableScrollView(
      onRefresh: _load,
      slivers: data == null ? _firstLoadSlivers() : _contentSlivers(data),
    );
  }

  /// Au premier chargement il n'y a rien a montrer. Une maquette vide laisserait
  /// croire que l'accueil n'a aucun contenu.
  List<Widget> _firstLoadSlivers() {
    return const [
      SliverToBoxAdapter(child: HomeHeader()),
      SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: CircularProgressIndicator(color: AppTheme.actionRed),
          ),
        ),
      ),
    ];
  }

  List<Widget> _contentSlivers(HomeSnapshot data) {
    final latestArticles = data.latestArticles.take(4).toList(growable: false);
    final upcomingEvents = data.upcomingEvents.take(3).toList(growable: false);

    return [
      const SliverToBoxAdapter(child: HomeHeader()),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        sliver: SliverList.list(
          children: [
            if (data.source == HomeSource.fallback) ...[
              const _OfflineNotice(),
              const SizedBox(height: 12),
            ],
            FeaturedStoryBanner(articles: data.headlineArticles),
            const SizedBox(height: 8),
            const HomeSectionHeader(title: 'PROCHAIN EVENEMENT'),
            UpcomingEventCard(event: data.highlightedEvent),
            const SizedBox(height: 8),
            const HomeSectionHeader(title: 'DERNIERES ACTUALITES'),
            SizedBox(
              height: 230,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: latestArticles.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final article = latestArticles[index];
                  return NewsCard(
                    imagePath: article.imagePath,
                    imageUrl: article.imageUrl,
                    scope: article.badgeLabel,
                    title: article.title,
                    date: article.date,
                    scopeColor: article.badgeColor,
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            const ChurchDiscoveryBanner(),
            const SizedBox(height: 18),
            const HomeSectionHeader(
              title: 'PROGRAMMES A VENIR',
              showAction: false,
            ),
            for (final event in upcomingEvents) ...[
              ProgramItem(
                month: _month(event.date),
                day: _day(event.date),
                title: event.title,
                location: event.location,
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    ];
  }
}

/// Dit clairement que l'API n'a pas repondu. Un ecran nourri par le contenu de
/// demonstration sans le dire est pire qu'un ecran en erreur : il fait croire
/// que tout va bien.
class _OfflineNotice extends StatelessWidget {
  const _OfflineNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD8A8)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 20,
            color: Color(0xFFB26A00),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Contenu de demonstration : le serveur est injoignable. '
              'Tirez vers le bas pour reessayer.',
              style: TextStyle(
                fontSize: 12.5,
                height: 1.35,
                color: Color(0xFF8A5200),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _day(String date) {
  final parts = date.split(' ');
  if (parts.isEmpty) return '--';
  return parts.first.padLeft(2, '0');
}

String _month(String date) {
  final parts = date.split(' ');
  if (parts.length < 2) return '---';
  return parts[1].toUpperCase();
}
