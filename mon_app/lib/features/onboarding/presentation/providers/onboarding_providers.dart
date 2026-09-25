import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/repositories/shared_preferences_onboarding_repository.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../../domain/usecases/complete_onboarding.dart';
import '../../domain/usecases/get_onboarding_status.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw StateError('SharedPreferences must be initialized before runApp.');
});

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return SharedPreferencesOnboardingRepository(
    ref.watch(sharedPreferencesProvider),
  );
});

final getOnboardingStatusProvider = Provider<GetOnboardingStatus>((ref) {
  return GetOnboardingStatus(ref.watch(onboardingRepositoryProvider));
});

final completeOnboardingProvider = Provider<CompleteOnboarding>((ref) {
  return CompleteOnboarding(ref.watch(onboardingRepositoryProvider));
});

final onboardingControllerProvider =
    NotifierProvider<OnboardingController, bool>(OnboardingController.new);

final class OnboardingController extends Notifier<bool> {
  @override
  bool build() => ref.watch(getOnboardingStatusProvider)();

  Future<void> complete() async {
    try {
      await ref.read(completeOnboardingProvider)();
    } catch (_) {
      // A storage failure must never prevent access to the application.
    } finally {
      state = true;
    }
  }
}
