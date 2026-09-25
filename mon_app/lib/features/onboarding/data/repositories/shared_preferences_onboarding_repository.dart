import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/onboarding_repository.dart';

final class SharedPreferencesOnboardingRepository
    implements OnboardingRepository {
  SharedPreferencesOnboardingRepository(this._preferences);

  static const completionKey = 'has_completed_onboarding';

  final SharedPreferences _preferences;

  @override
  bool hasCompletedOnboarding() {
    return _preferences.getBool(completionKey) ?? false;
  }

  @override
  Future<void> completeOnboarding() async {
    await _preferences.setBool(completionKey, true);
  }
}
