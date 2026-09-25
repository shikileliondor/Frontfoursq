import 'package:flutter_test/flutter_test.dart';
import 'package:mon_app/features/onboarding/data/repositories/shared_preferences_onboarding_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('returns false before onboarding has been completed', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesOnboardingRepository(preferences);

    expect(repository.hasCompletedOnboarding(), isFalse);
  });

  test('persists onboarding completion', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesOnboardingRepository(preferences);

    await repository.completeOnboarding();

    expect(repository.hasCompletedOnboarding(), isTrue);
    expect(preferences.getBool('has_completed_onboarding'), isTrue);
  });
}
