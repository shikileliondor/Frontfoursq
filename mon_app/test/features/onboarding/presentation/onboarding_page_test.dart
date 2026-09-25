import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mon_app/features/onboarding/presentation/pages/onboarding_page.dart';

void main() {
  Future<void> pumpOnboarding(
    WidgetTester tester, {
    required Future<void> Function() onCompleted,
  }) async {
    await tester.pumpWidget(
      MaterialApp(home: OnboardingPage(onCompleted: onCompleted)),
    );
  }

  testWidgets('shows the welcome content on the first page', (tester) async {
    await pumpOnboarding(tester, onCompleted: () async {});

    expect(find.byKey(const Key('onboarding-logo')), findsOneWidget);
    expect(
      find.text("Bienvenue chez Foursquare Côte d'Ivoire"),
      findsOneWidget,
    );
    expect(find.text('Passer'), findsOneWidget);
    expect(find.text('Suivant'), findsOneWidget);
    expect(find.text('Commencer'), findsNothing);
  });

  testWidgets('moves through all pages and completes from the last page', (
    tester,
  ) async {
    var completionCount = 0;
    await pumpOnboarding(tester, onCompleted: () async => completionCount++);

    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();
    expect(find.text('Reste informe'), findsOneWidget);

    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();
    expect(find.text('Trouve ton eglise'), findsOneWidget);
    expect(find.text('Commencer'), findsOneWidget);
    expect(find.text('Suivant'), findsNothing);

    await tester.tap(find.text('Commencer'));
    await tester.pumpAndSettle();
    expect(completionCount, 1);
  });

  testWidgets('skip completes onboarding from the first page', (tester) async {
    var completionCount = 0;
    await pumpOnboarding(tester, onCompleted: () async => completionCount++);

    await tester.tap(find.text('Passer'));
    await tester.pumpAndSettle();

    expect(completionCount, 1);
  });

  testWidgets('fits without overflow on a compact phone', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpOnboarding(tester, onCompleted: () async {});
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
