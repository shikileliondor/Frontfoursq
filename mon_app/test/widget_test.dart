import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mon_app/app/app.dart';
import 'package:mon_app/features/onboarding/presentation/providers/onboarding_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('starts with the branded onboarding on first launch', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
        child: const FoursquareApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('onboarding-logo')), findsOneWidget);
    expect(
      find.text("Bienvenue chez Foursquare Côte d'Ivoire"),
      findsOneWidget,
    );
  });
}
