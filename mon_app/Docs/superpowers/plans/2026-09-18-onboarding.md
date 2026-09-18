# Foursquare Onboarding Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a responsive three-page Flutter onboarding that uses the supplied church logo and photographs, persists completion locally, and opens the home route after the first visit.

**Architecture:** The feature follows a pragmatic feature-first Clean Architecture. Domain contracts isolate onboarding completion from `shared_preferences`; Riverpod wires dependencies and presentation state; `go_router` redirects between `/onboarding` and `/home` from that state.

**Tech Stack:** Flutter, Dart 3.12, Material 3, `flutter_riverpod`, `go_router`, `shared_preferences`, `flutter_test`.

**Spec:** `Docs/superpowers/specs/2026-09-18-onboarding-design.md`

## Global Constraints

- Use only local assets from `assets/images`; do not download or generate images.
- Use `assets/images/LOGO DE.jpeg` as the official logo on every onboarding page.
- Use blue as the primary color, red as the action accent, and white as the content background.
- Display onboarding only until `has_completed_onboarding` becomes `true`.
- `Passer` and `Commencer` must open `/home`, even when the preference write fails.
- Reading a missing or invalid preference must behave as a first launch.
- Keep touch targets at least 48 logical pixels high and prevent overflow on small screens.
- Do not add API connectivity, push permissions, church location, or the final home screen in this implementation.

---

## File Map

- `lib/main.dart`: initializes Flutter, shared preferences, and the root provider scope.
- `lib/app/app.dart`: owns `MaterialApp.router`.
- `lib/app/router.dart`: declares `/onboarding` and `/home` plus completion redirects.
- `lib/app/theme/app_theme.dart`: centralizes the blue, red, white theme and typography.
- `lib/core/constants/app_assets.dart`: defines the exact local asset paths.
- `lib/features/onboarding/domain/repositories/onboarding_repository.dart`: storage-independent completion contract.
- `lib/features/onboarding/domain/usecases/get_onboarding_status.dart`: reads first-launch status.
- `lib/features/onboarding/domain/usecases/complete_onboarding.dart`: persists completion.
- `lib/features/onboarding/data/repositories/shared_preferences_onboarding_repository.dart`: local repository implementation.
- `lib/features/onboarding/presentation/models/onboarding_page_data.dart`: immutable page content.
- `lib/features/onboarding/presentation/providers/onboarding_providers.dart`: dependency wiring and completion state.
- `lib/features/onboarding/presentation/pages/onboarding_page.dart`: page controller, actions, and layout.
- `lib/features/onboarding/presentation/widgets/onboarding_slide.dart`: responsive logo, photograph, and copy.
- `lib/features/onboarding/presentation/widgets/onboarding_page_indicator.dart`: stable three-dot progress indicator.
- `lib/features/home/presentation/pages/home_page.dart`: temporary destination after onboarding.
- `test/features/onboarding/data/shared_preferences_onboarding_repository_test.dart`: repository behavior.
- `test/features/onboarding/presentation/onboarding_page_test.dart`: page content and controls.
- `test/app/router_test.dart`: first-launch and returning-user routing.

---

### Task 1: Persistence Boundary and App Foundation

**Files:**
- Modify: `pubspec.yaml`
- Create: `lib/app/theme/app_theme.dart`
- Create: `lib/core/constants/app_assets.dart`
- Create: `lib/features/onboarding/domain/repositories/onboarding_repository.dart`
- Create: `lib/features/onboarding/domain/usecases/get_onboarding_status.dart`
- Create: `lib/features/onboarding/domain/usecases/complete_onboarding.dart`
- Create: `lib/features/onboarding/data/repositories/shared_preferences_onboarding_repository.dart`
- Test: `test/features/onboarding/data/shared_preferences_onboarding_repository_test.dart`

**Interfaces:**
- Produces: `OnboardingRepository.hasCompletedOnboarding() -> bool`.
- Produces: `OnboardingRepository.completeOnboarding() -> Future<void>`.
- Produces: `GetOnboardingStatus.call() -> bool`.
- Produces: `CompleteOnboarding.call() -> Future<void>`.
- Produces: `AppAssets.logo`, `AppAssets.welcome`, `AppAssets.community`, and `AppAssets.events`.

- [ ] **Step 1: Add packages and declare image assets**

Run:

```bash
flutter pub add flutter_riverpod go_router shared_preferences
```

Add to the existing `flutter` section of `pubspec.yaml`:

```yaml
  assets:
    - assets/images/
```

- [ ] **Step 2: Write failing repository tests**

Create `test/features/onboarding/data/shared_preferences_onboarding_repository_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mon_app/features/onboarding/data/repositories/shared_preferences_onboarding_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('returns false when onboarding has not been completed', () async {
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

    expect(preferences.getBool('has_completed_onboarding'), isTrue);
    expect(repository.hasCompletedOnboarding(), isTrue);
  });
}
```

- [ ] **Step 3: Run the repository test and confirm the expected failure**

Run:

```bash
flutter test test/features/onboarding/data/shared_preferences_onboarding_repository_test.dart
```

Expected: compilation fails because `SharedPreferencesOnboardingRepository` does not exist.

- [ ] **Step 4: Implement the domain contract, use cases, and local repository**

Create `onboarding_repository.dart`:

```dart
abstract interface class OnboardingRepository {
  bool hasCompletedOnboarding();
  Future<void> completeOnboarding();
}
```

Create `get_onboarding_status.dart`:

```dart
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
```

Create `complete_onboarding.dart`:

```dart
import '../repositories/onboarding_repository.dart';

final class CompleteOnboarding {
  const CompleteOnboarding(this._repository);
  final OnboardingRepository _repository;

  Future<void> call() => _repository.completeOnboarding();
}
```

Create `shared_preferences_onboarding_repository.dart`:

```dart
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/onboarding_repository.dart';

final class SharedPreferencesOnboardingRepository
    implements OnboardingRepository {
  SharedPreferencesOnboardingRepository(this._preferences);

  static const completionKey = 'has_completed_onboarding';
  final SharedPreferences _preferences;

  @override
  bool hasCompletedOnboarding() =>
      _preferences.getBool(completionKey) ?? false;

  @override
  Future<void> completeOnboarding() async {
    await _preferences.setBool(completionKey, true);
  }
}
```

- [ ] **Step 5: Add asset constants and the shared theme**

Create `app_assets.dart` with:

```dart
abstract final class AppAssets {
  static const logo = 'assets/images/LOGO DE.jpeg';
  static const welcome =
      'assets/images/WhatsApp Image 2026-09-18 at a.jpeg';
  static const community = 'assets/images/image 2 .jpg';
  static const events = 'assets/images/image 6.jpg';
}
```

Create `app_theme.dart` with:

```dart
import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const primaryBlue = Color(0xFF132A63);
  static const actionRed = Color(0xFFE31E2D);

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.light,
    ).copyWith(primary: primaryBlue, secondary: actionRed);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.white,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          backgroundColor: actionRed,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
```

- [ ] **Step 6: Run the repository tests**

Run:

```bash
flutter test test/features/onboarding/data/shared_preferences_onboarding_repository_test.dart
```

Expected: both tests pass.

- [ ] **Step 7: Commit the persistence foundation**

```bash
git add pubspec.yaml pubspec.lock lib/app/theme lib/core lib/features/onboarding/domain lib/features/onboarding/data test/features/onboarding/data
git commit -m "feat: add onboarding persistence foundation"
```

---

### Task 2: Onboarding Presentation

**Files:**
- Create: `lib/features/onboarding/presentation/models/onboarding_page_data.dart`
- Create: `lib/features/onboarding/presentation/providers/onboarding_providers.dart`
- Create: `lib/features/onboarding/presentation/widgets/onboarding_slide.dart`
- Create: `lib/features/onboarding/presentation/widgets/onboarding_page_indicator.dart`
- Create: `lib/features/onboarding/presentation/pages/onboarding_page.dart`
- Test: `test/features/onboarding/presentation/onboarding_page_test.dart`

**Interfaces:**
- Consumes: `GetOnboardingStatus.call() -> bool` and `CompleteOnboarding.call() -> Future<void>`.
- Produces: `sharedPreferencesProvider: Provider<SharedPreferences>`.
- Produces: `onboardingControllerProvider: NotifierProvider<OnboardingController, bool>`.
- Produces: `OnboardingPage(onCompleted: Future<void> Function())`.

- [ ] **Step 1: Write failing widget tests for the three-page flow**

Create `onboarding_page_test.dart` with a helper that pumps `MaterialApp(home: OnboardingPage(onCompleted: callback))`. Add tests that assert:

```dart
expect(find.byKey(const Key('onboarding-logo')), findsOneWidget);
expect(find.text("Bienvenue chez Foursquare Côte d'Ivoire"), findsOneWidget);
expect(find.text('Passer'), findsOneWidget);
expect(find.text('Suivant'), findsOneWidget);
expect(find.text('Commencer'), findsNothing);
```

Then tap `Suivant` twice with `pumpAndSettle()` and assert:

```dart
expect(find.text('Vivez nos événements'), findsOneWidget);
expect(find.text('Commencer'), findsOneWidget);
expect(find.text('Suivant'), findsNothing);
```

Finally, tap `Commencer` and verify the callback was called once. Add a second test that taps `Passer` on page one and verifies the same callback.

- [ ] **Step 2: Run the widget test and confirm the expected failure**

Run:

```bash
flutter test test/features/onboarding/presentation/onboarding_page_test.dart
```

Expected: compilation fails because `OnboardingPage` does not exist.

- [ ] **Step 3: Implement immutable page content and providers**

Define `OnboardingPageData` with `title`, `description`, and `imagePath`. Expose this exact list:

```dart
const onboardingPages = [
  OnboardingPageData(
    title: "Bienvenue chez Foursquare Côte d'Ivoire",
    description:
        "Découvrez notre communauté et restez proche de la vie de l'Église.",
    imagePath: AppAssets.welcome,
  ),
  OnboardingPageData(
    title: 'Une communauté vivante',
    description:
        'Suivez les activités de la jeunesse, des assemblées, des zones et des districts.',
    imagePath: AppAssets.community,
  ),
  OnboardingPageData(
    title: 'Vivez nos événements',
    description:
        'Retrouvez les événements et les actualités importantes au même endroit.',
    imagePath: AppAssets.events,
  ),
];
```

In `onboarding_providers.dart`, define:

```dart
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('SharedPreferences must be overridden'),
);

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return SharedPreferencesOnboardingRepository(
    ref.watch(sharedPreferencesProvider),
  );
});
```

Add providers for both use cases and an `OnboardingController extends Notifier<bool>`. Its `build()` returns `GetOnboardingStatus()`. Its `complete()` awaits `CompleteOnboarding()` inside `try/finally` and always sets `state = true` in `finally`, satisfying the non-blocking write-failure requirement.

- [ ] **Step 4: Implement the responsive slide and indicator widgets**

`OnboardingSlide` must use a `LayoutBuilder`, reserve stable image space with `AspectRatio`, display the logo with key `onboarding-logo`, use `BoxFit.cover` for photographs, and constrain text width. Wrap textual content in a scrollable area when available height is limited.

`OnboardingPageIndicator` must always render three fixed-size dots. The active dot uses the primary blue; inactive dots use a neutral grey. Dots must not change the parent height when the page changes.

- [ ] **Step 5: Implement page navigation and actions**

`OnboardingPage` owns a `PageController` and current index. `Suivant` animates to the next page. `Passer` and `Commencer` await the injected `onCompleted` callback. Disable repeated completion taps while that future is running. Dispose the `PageController`.

Use a `SafeArea`, keep each button at least 48 logical pixels high, and use the theme's red accent for the primary button. Do not place the content inside decorative cards.

- [ ] **Step 6: Run widget tests and analyze the project**

Run:

```bash
flutter test test/features/onboarding/presentation/onboarding_page_test.dart
flutter analyze
```

Expected: onboarding tests pass and analysis reports no issues.

- [ ] **Step 7: Commit the presentation**

```bash
git add lib/features/onboarding test/features/onboarding/presentation
git commit -m "feat: build onboarding experience"
```

---

### Task 3: Routing, First-Launch Behavior, and Responsive Verification

**Files:**
- Create: `lib/app/app.dart`
- Create: `lib/app/router.dart`
- Create: `lib/features/home/presentation/pages/home_page.dart`
- Modify: `lib/main.dart`
- Replace: `test/widget_test.dart`
- Create: `test/app/router_test.dart`

**Interfaces:**
- Consumes: `onboardingControllerProvider` completion state.
- Consumes: `OnboardingPage(onCompleted: ...)`.
- Produces: `appRouterProvider: Provider<GoRouter>`.
- Produces: `FoursquareApp` as the application root.

- [ ] **Step 1: Write failing routing tests**

In `router_test.dart`, call `SharedPreferences.setMockInitialValues({})`, initialize preferences, override `sharedPreferencesProvider`, pump `FoursquareApp`, and assert the welcome title is visible. Add a returning-user test with:

```dart
SharedPreferences.setMockInitialValues({
  'has_completed_onboarding': true,
});
```

Assert `Accueil` is visible and the onboarding title is absent. Add a completion test that taps `Passer`, calls `pumpAndSettle()`, and expects `Accueil`.

- [ ] **Step 2: Run routing tests and confirm the expected failure**

Run:

```bash
flutter test test/app/router_test.dart
```

Expected: compilation fails because `FoursquareApp` and `appRouterProvider` do not exist.

- [ ] **Step 3: Implement the temporary home and router**

Create a minimal `HomePage` with a `Scaffold`, an app bar containing the official logo and `Foursquare Côte d'Ivoire`, and centered text `Accueil`. Do not implement final home content.

Define `appRouterProvider` by watching `onboardingControllerProvider`. Configure `/onboarding` and `/home`; redirect incomplete users from `/home` to `/onboarding`, and completed users from `/onboarding` to `/home`. The onboarding route calls `ref.read(onboardingControllerProvider.notifier).complete`.

- [ ] **Step 4: Implement the root application**

Create `FoursquareApp extends ConsumerWidget`. Watch `appRouterProvider` and return:

```dart
MaterialApp.router(
  title: "Foursquare Côte d'Ivoire",
  debugShowCheckedModeBanner: false,
  theme: AppTheme.light,
  routerConfig: router,
)
```

Ensure `main.dart` runs `FoursquareApp` inside the previously configured `ProviderScope`.

Replace `main.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/app.dart';
import 'features/onboarding/presentation/providers/onboarding_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
      ],
      child: const FoursquareApp(),
    ),
  );
}
```

- [ ] **Step 5: Replace the generated counter test**

Replace `test/widget_test.dart` with an app smoke test that uses mocked preferences, pumps `FoursquareApp`, and asserts the onboarding logo and welcome title are present. Remove every counter-specific assertion and import.

- [ ] **Step 6: Add a small-screen overflow test**

In `onboarding_page_test.dart`, set:

```dart
tester.view.physicalSize = const Size(320, 568);
tester.view.devicePixelRatio = 1;
addTearDown(tester.view.resetPhysicalSize);
addTearDown(tester.view.resetDevicePixelRatio);
```

Pump the page, move through all three slides, and verify `tester.takeException()` is `null` after each `pumpAndSettle()`.

- [ ] **Step 7: Format and run the full verification suite**

Run:

```bash
dart format lib test
flutter analyze
flutter test
```

Expected: formatting completes, analysis reports no issues, and all tests pass.

- [ ] **Step 8: Launch on an available device for visual verification**

Run:

```bash
flutter devices
flutter run
```

Verify the logo is not cropped, photographs remain legible, controls do not overlap system insets, swipe and `Suivant` stay synchronized, and `Passer`/`Commencer` open the temporary home.

- [ ] **Step 9: Commit the integrated onboarding**

```bash
git add lib test pubspec.yaml pubspec.lock
git commit -m "feat: integrate first-launch onboarding"
```
