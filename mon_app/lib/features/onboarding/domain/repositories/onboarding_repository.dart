abstract interface class OnboardingRepository {
  bool hasCompletedOnboarding();

  Future<void> completeOnboarding();
}
