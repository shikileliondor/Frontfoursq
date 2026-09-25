import '../repositories/onboarding_repository.dart';

final class GetOnboardingStatus {
  const GetOnboardingStatus(this._repository);

  final OnboardingRepository _repository;

  bool call() {
    try {
      return _repository.hasCompletedOnboarding();
    } catch (_) {
      return false;
    }
  }
}
