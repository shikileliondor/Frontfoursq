import '../../../../core/constants/app_assets.dart';

final class OnboardingPageData {
  const OnboardingPageData({
    required this.title,
    required this.description,
    required this.imagePath,
  });

  final String title;
  final String description;
  final String imagePath;
}

const onboardingPages = [
  OnboardingPageData(
    title: 'Bienvenue',
    description: 'Toute la vie Foursquare CI dans une seule application.',
    imagePath: AppAssets.welcome,
  ),
  OnboardingPageData(
    title: 'Reste informe',
    description: 'Actualites, evenements et annonces officielles.',
    imagePath: AppAssets.community,
  ),
  OnboardingPageData(
    title: 'Trouve ton eglise',
    description: 'Annuaire, horaires, contacts et formations pres de toi.',
    imagePath: AppAssets.events,
  ),
];
