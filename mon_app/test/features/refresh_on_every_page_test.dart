import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mon_app/features/churches/data/church_repository.dart';
import 'package:mon_app/features/churches/data/churches.dart';
import 'package:mon_app/features/churches/domain/models/church.dart';
import 'package:mon_app/features/churches/presentation/pages/churches_page.dart';
import 'package:mon_app/features/events/data/event_repository.dart';
import 'package:mon_app/features/events/data/events.dart';
import 'package:mon_app/features/events/domain/models/event.dart';
import 'package:mon_app/features/events/presentation/pages/events_page.dart';
import 'package:mon_app/features/news/data/news_articles.dart';
import 'package:mon_app/features/news/data/news_repository.dart';
import 'package:mon_app/features/news/domain/models/news_article.dart';
import 'package:mon_app/features/news/presentation/pages/news_page.dart';

class _CountingNewsRepository extends NewsRepository {
  int calls = 0;
  final List<NewsCategory?> categories = [];

  @override
  Future<List<NewsArticle>> getNews({NewsCategory? category}) async {
    calls++;
    categories.add(category);
    return category == null
        ? newsArticles
        : newsArticles
              .where((article) => article.category == category)
              .toList(growable: false);
  }
}

class _CountingEventRepository extends EventRepository {
  int calls = 0;

  @override
  Future<List<Event>> getUpcomingEvents() async {
    calls++;
    return fallbackEvents;
  }
}

class _CountingChurchRepository extends ChurchRepository {
  int calls = 0;
  final List<String> searches = [];

  @override
  Future<List<Church>> getChurches({String search = ''}) async {
    calls++;
    searches.add(search);
    return churches.where((church) => church.matches(search)).toList();
  }
}

void main() {
  /// Le geste doit depasser 25 % de la hauteur du conteneur pour armer
  /// `RefreshIndicator` : sur 844 px, 320 px suffisent largement.
  Future<void> pullDown(WidgetTester tester, Finder target) async {
    await tester.fling(target, const Offset(0, 320), 1200);
    await tester.pumpAndSettle();
  }

  Future<void> pumpPage(WidgetTester tester, Widget page) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp(home: Scaffold(body: page)));
    await tester.pumpAndSettle();
  }

  group('Actus', () {
    testWidgets('pulling down reloads the list', (tester) async {
      final repository = _CountingNewsRepository();
      await pumpPage(tester, NewsPage(repository: repository));

      expect(repository.calls, 1);

      await pullDown(tester, find.text('Actualites'));

      expect(repository.calls, 2);
    });

    testWidgets('reloading keeps the selected category', (tester) async {
      final repository = _CountingNewsRepository();
      await pumpPage(tester, NewsPage(repository: repository));

      await tester.tap(find.text('Districts'));
      await tester.pumpAndSettle();

      await pullDown(tester, find.text('Actualites'));

      // Le filtre survit au rechargement : tirer sur « Districts » ne doit
      // pas ramener toutes les actualites.
      expect(repository.categories.last, NewsCategory.district);
    });
  });

  group('Evenements', () {
    testWidgets('pulling down reloads the list', (tester) async {
      final repository = _CountingEventRepository();
      await pumpPage(tester, EventsPage(repository: repository));

      expect(repository.calls, 1);

      await pullDown(tester, find.text('Evenements'));

      expect(repository.calls, 2);
    });
  });

  group('Eglises', () {
    testWidgets('pulling down reloads the list', (tester) async {
      final repository = _CountingChurchRepository();
      await pumpPage(tester, ChurchesPage(repository: repository));

      expect(repository.calls, 1);

      await pullDown(tester, find.text('Eglises'));

      expect(repository.calls, 2);
    });

    testWidgets('reloading keeps the current search', (tester) async {
      final repository = _CountingChurchRepository();
      await pumpPage(tester, ChurchesPage(repository: repository));

      await tester.enterText(find.byType(TextField), 'yopougon');
      await tester.pumpAndSettle();

      await pullDown(tester, find.text('Eglises'));

      expect(repository.searches.last, 'yopougon');
      expect(find.byType(TextField), findsOneWidget);
    });
  });
}
