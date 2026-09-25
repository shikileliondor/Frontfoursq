import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mon_app/features/home/presentation/pages/home_page.dart';
import 'package:mon_app/features/home/presentation/widgets/news_card.dart';

void main() {
  Future<void> pumpHome(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomePage()));
  }

  testWidgets('shows the featured content and news sections', (tester) async {
    await pumpHome(tester);

    expect(find.text("Foursquare Côte d'Ivoire"), findsOneWidget);
    expect(find.text('Assemblée Générale Nationale 2025'), findsWidgets);
    expect(find.text('PROCHAIN EVENEMENT'), findsOneWidget);
    expect(find.text('DERNIERES ACTUALITES'), findsOneWidget);
  });

  testWidgets('swipes through featured news', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpHome(tester);

    await tester.drag(find.byType(PageView), const Offset(-320, 0));
    await tester.pumpAndSettle();

    expect(find.text('La jeunesse Foursquare en mission'), findsOneWidget);
    expect(find.bySemanticsLabel('Actualité 2 sur 3'), findsOneWidget);
  });

  testWidgets('automatically advances featured news', (tester) async {
    await pumpHome(tester);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    expect(find.text('La jeunesse Foursquare en mission'), findsOneWidget);
  });

  testWidgets('scrolls to church discovery and upcoming programs', (
    tester,
  ) async {
    await pumpHome(tester);

    await tester.scrollUntilVisible(
      find.text('Trouver une Église'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Trouver une Église'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('PROGRAMMES A VENIR'),
      220,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('PROGRAMMES A VENIR'), findsOneWidget);
    expect(find.text('Nuit de Prieres Nationale'), findsOneWidget);
  });

  testWidgets('shows all primary navigation destinations', (tester) async {
    await pumpHome(tester);

    expect(find.text('Accueil'), findsOneWidget);
    expect(find.text('Actus'), findsOneWidget);
    expect(find.text('Evenements'), findsOneWidget);
    expect(find.text('Eglises'), findsOneWidget);
    expect(find.text('Formation'), findsNothing);
  });

  testWidgets('opens the news tab with category filters', (tester) async {
    await pumpHome(tester);

    await tester.tap(find.text('Actus'));
    await tester.pump();

    expect(find.text('Actualites'), findsOneWidget);
    expect(find.text('Publications officielles Foursquare CI'), findsOneWidget);
    expect(find.text('Tous'), findsOneWidget);
    expect(find.text('National'), findsOneWidget);
    expect(find.text('Districts'), findsOneWidget);
    expect(find.text('Zones'), findsOneWidget);
    expect(find.text('Eglise'), findsOneWidget);
    expect(
      find.text('Assemblee Generale Nationale Foursquare 2025'),
      findsOneWidget,
    );
  });

  testWidgets('opens a news article detail from the news tab', (tester) async {
    await pumpHome(tester);

    await tester.tap(find.text('Actus'));
    await tester.pump();
    await tester.tap(
      find.text('Seminaire de formation des leaders - District Abidjan Sud'),
    );
    await tester.pump();

    expect(find.text('28 Sep 2025'), findsOneWidget);
    expect(find.text('Formation'), findsOneWidget);
    expect(
      find.textContaining('Le district Abidjan Sud organise un seminaire'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
  });

  testWidgets('opens the churches tab with search', (tester) async {
    await pumpHome(tester);

    await tester.tap(find.text('Eglises'));
    await tester.pump();

    expect(find.text('Eglises'), findsWidgets);
    expect(find.text('Annuaire Foursquare Cote dIvoire'), findsOneWidget);
    expect(find.text('Foursquare Abidjan-Cocody'), findsOneWidget);
    expect(find.text('Foursquare Bouake-Centre'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'yopougon');
    await tester.pump();

    expect(find.text('Foursquare Yopougon-Selmer'), findsOneWidget);
    expect(find.text('Foursquare Bouake-Centre'), findsNothing);
  });

  testWidgets('opens a church detail from the churches tab', (tester) async {
    await pumpHome(tester);

    await tester.tap(find.text('Eglises'));
    await tester.pump();
    await tester.tap(find.text('Foursquare Bouake-Centre'));
    await tester.pump();

    expect(find.text('Dar Es Salam, Bouake'), findsOneWidget);
    expect(find.text('Rev. Fatou Bamba'), findsOneWidget);
    expect(find.text('+225 07 33 44 55'), findsOneWidget);
    expect(find.text('Itineraire'), findsOneWidget);
    expect(find.text('Appeler'), findsOneWidget);
    expect(find.text('WhatsApp'), findsOneWidget);
  });

  testWidgets('shows complete centered artwork in news cards', (tester) async {
    await pumpHome(tester);

    final images = tester.widgetList<Image>(
      find.descendant(of: find.byType(NewsCard), matching: find.byType(Image)),
    );

    expect(images, isNotEmpty);
    for (final image in images) {
      expect(image.fit, BoxFit.contain);
      expect(image.alignment, Alignment.center);
    }
  });

  testWidgets('fits on a compact phone while scrolling to the last program', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpHome(tester);
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(
      find.text('Congres Jeunesse 2025'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(tester.takeException(), isNull);
  });
}
