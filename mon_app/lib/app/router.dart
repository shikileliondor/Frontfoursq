import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/home/presentation/pages/home_page.dart';
import '../features/onboarding/presentation/pages/onboarding_page.dart';
import '../features/onboarding/presentation/providers/onboarding_providers.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final hasCompletedOnboarding = ref.watch(onboardingControllerProvider);
  final router = GoRouter(
    initialLocation: hasCompletedOnboarding ? '/home' : '/onboarding',
    redirect: (context, state) {
      final isOnboarding = state.matchedLocation == '/onboarding';

      if (!hasCompletedOnboarding && !isOnboarding) {
        return '/onboarding';
      }
      if (hasCompletedOnboarding && isOnboarding) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => OnboardingPage(
          onCompleted: () {
            return ref.read(onboardingControllerProvider.notifier).complete();
          },
        ),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomePage()),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});
