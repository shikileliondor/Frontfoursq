import 'package:flutter/material.dart';

import '../../../churches/presentation/pages/churches_page.dart';
import '../../../events/data/event_repository.dart';
import '../../../events/domain/models/event.dart';
import '../../../events/presentation/pages/events_page.dart';
import '../../../news/data/news_repository.dart';
import '../../../news/domain/models/news_article.dart';
import '../../../news/presentation/pages/news_page.dart';
import '../widgets/church_discovery_banner.dart';
import '../widgets/featured_story_banner.dart';
import '../widgets/home_header.dart';
import '../widgets/home_section_header.dart';
import '../widgets/news_card.dart';
import '../widgets/program_item.dart';
import '../widgets/upcoming_event_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _handleDestination(BuildContext context, int index) {
    if (index == _selectedIndex) return;

    if (index == 0 || index == 1 || index == 2 || index == 3) {
      setState(() => _selectedIndex = index);
      return;
    }

    const labels = ['Accueil', 'Actus', 'Evenements', 'Eglises', 'Formation'];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(labels[index]),
        duration: const Duration(milliseconds: 900),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _selectedIndex,
          children: const [
            _HomeContent(),
            NewsPage(),
            EventsPage(),
            ChurchesPage(),
            SizedBox.shrink(),
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
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            label: 'Formation',
          ),
        ],
      ),
    );
  }
}

class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  final NewsRepository _newsRepository = NewsRepository();
  final EventRepository _eventRepository = EventRepository();
  late final Future<_HomeData> _homeFuture = _loadHome();

  Future<_HomeData> _loadHome() async {
    final results = await Future.wait([
      _newsRepository.getNews(),
      _eventRepository.getUpcomingEvents(),
    ]);
    return _HomeData(
      articles: results[0] as List<NewsArticle>,
      events: results[1] as List<Event>,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_HomeData>(
      future: _homeFuture,
      builder: (context, snapshot) {
        final data = snapshot.data ?? _HomeData.empty();
        final latestArticles = data.articles.take(4).toList(growable: false);
        final upcomingEvents = data.events.take(3).toList(growable: false);

        return CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: HomeHeader()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              sliver: SliverList.list(
                children: [
                  FeaturedStoryBanner(articles: latestArticles),
                  const SizedBox(height: 8),
                  const HomeSectionHeader(title: 'PROCHAIN EVENEMENT'),
                  UpcomingEventCard(
                    event: upcomingEvents.isEmpty ? null : upcomingEvents.first,
                  ),
                  const SizedBox(height: 8),
                  const HomeSectionHeader(title: 'DERNIERES ACTUALITES'),
                  SizedBox(
                    height: 230,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: latestArticles.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 10),
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
          ],
        );
      },
    );
  }
}

class _HomeData {
  const _HomeData({required this.articles, required this.events});

  factory _HomeData.empty() {
    return const _HomeData(articles: [], events: []);
  }

  final List<NewsArticle> articles;
  final List<Event> events;
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
