import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mon_app/features/events/data/events.dart';
import 'package:mon_app/features/home/data/home_repository.dart';
import 'package:mon_app/features/home/domain/models/home_snapshot.dart';
import 'package:mon_app/features/home/presentation/pages/home_page.dart';
import 'package:mon_app/features/news/data/news_articles.dart';

/// Sert une reponse differente a chaque appel, pour distinguer le premier
/// chargement du rechargement.
class _ScriptedHomeRepository extends HomeRepository {
  _ScriptedHomeRepository(this._responses);

  final List<HomeSnapshot> _responses;

  int calls = 0;

  @override
  Future<HomeSnapshot> getHome() async {
    final index = calls < _responses.length ? calls : _responses.length - 1;
    calls++;
    return _responses[index];
  }
}

HomeSnapshot _snapshot(HomeSource source) {
  return HomeSnapshot(
    featuredArticles: newsArticles.take(2).toList(growable: false),
    latestArticles: newsArticles.take(3).toList(growable: false),
    upcomingEvents: fallbackEvents.take(2).toList(growable: false),
    featuredEvent: fallbackEvents.first,
    source: source,
  );
}

void main() {
  const notice =
      'Contenu de demonstration : le serveur est injoignable. '
      'Tirez vers le bas pour reessayer.';

  Future<_ScriptedHomeRepository> pump(
    WidgetTester tester,
    List<HomeSnapshot> responses,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = _ScriptedHomeRepository(responses);

    await tester.pumpWidget(
      MaterialApp(home: HomePage(homeRepository: repository)),
    );
    await tester.pumpAndSettle();

    return repository;
  }

  testWidgets('shows a spinner before the first answer arrives', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomePage(
          homeRepository: _ScriptedHomeRepository([_snapshot(HomeSource.api)]),
        ),
      ),
    );

    // Avant que le future ne soit resolu : pas une maquette vide, une attente
    // explicite.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('PROCHAIN EVENEMENT'), findsOneWidget);
  });

  testWidgets('loads the home screen once on opening', (tester) async {
    final repository = await pump(tester, [_snapshot(HomeSource.api)]);

    expect(repository.calls, 1);
    expect(find.text('DERNIERES ACTUALITES'), findsOneWidget);
    expect(find.text(notice), findsNothing);
  });

  testWidgets('pulling down asks the server again', (tester) async {
    final repository = await pump(tester, [_snapshot(HomeSource.api)]);

    await tester.fling(
      find.text('PROCHAIN EVENEMENT'),
      const Offset(0, 320),
      1200,
    );
    await tester.pumpAndSettle();

    // Le geste seul doit suffire : plus besoin de relancer `flutter run`.
    expect(repository.calls, 2);
  });

  testWidgets('says so when it is showing demonstration content', (
    tester,
  ) async {
    await pump(tester, [_snapshot(HomeSource.fallback)]);

    expect(find.text(notice), findsOneWidget);
  });

  testWidgets('drops the warning once the server answers again', (
    tester,
  ) async {
    await pump(tester, [
      _snapshot(HomeSource.fallback),
      _snapshot(HomeSource.api),
    ]);

    expect(find.text(notice), findsOneWidget);

    await tester.fling(
      find.text('PROCHAIN EVENEMENT'),
      const Offset(0, 320),
      1200,
    );
    await tester.pumpAndSettle();

    expect(find.text(notice), findsNothing);
  });

  testWidgets('can be pulled even when the API returned nothing', (
    tester,
  ) async {
    // Contenu plus court que l'ecran : sans AlwaysScrollableScrollPhysics, la
    // liste refuse le geste et le rechargement devient inaccessible.
    final repository = _ScriptedHomeRepository([
      const HomeSnapshot(
        featuredArticles: [],
        latestArticles: [],
        upcomingEvents: [],
        source: HomeSource.api,
      ),
    ]);

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(home: HomePage(homeRepository: repository)),
    );
    await tester.pumpAndSettle();

    await tester.fling(
      find.text('PROCHAIN EVENEMENT'),
      const Offset(0, 320),
      1200,
    );
    await tester.pumpAndSettle();

    expect(repository.calls, 2);
  });
}
