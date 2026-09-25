import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mon_app/app/app.dart';
import 'package:mon_app/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:mon_app/features/onboarding/presentation/providers/onboarding_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class _FailingWriteOnboardingRepository implements OnboardingRepository {
  @override
  bool hasCompletedOnboarding() => false;

  @override
  Future<void> completeOnboarding() {
    throw Exception('Storage unavailable');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpApplication(
    WidgetTester tester,
    Map<String, Object> initialValues,
  ) async {
    SharedPreferences.setMockInitialValues(initialValues);
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
        child: const FoursquareApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('first launch opens onboarding', (tester) async {
    await pumpApplication(tester, {});

    expect(
      find.text("Bienvenue chez Foursquare Côte d'Ivoire"),
      findsOneWidget,
    );
    expect(find.text('Accueil'), findsNothing);
  });

  testWidgets('returning user opens home directly', (tester) async {
    await pumpApplication(tester, {'has_completed_onboarding': true});

    expect(find.text('Accueil'), findsOneWidget);
    expect(find.text("Bienvenue chez Foursquare Côte d'Ivoire"), findsNothing);
  });

  testWidgets('skip persists completion and opens home', (tester) async {
    await pumpApplication(tester, {});

    await tester.tap(find.text('Passer'));
    await tester.pumpAndSettle();

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool('has_completed_onboarding'), isTrue);
    expect(find.text('Accueil'), findsOneWidget);
  });

  testWidgets('storage write failure does not block access to home', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingRepositoryProvider.overrideWithValue(
            _FailingWriteOnboardingRepository(),
          ),
        ],
        child: const FoursquareApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Passer'));
    await tester.pumpAndSettle();

    expect(find.text('Accueil'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
