import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';

final class OnboardingPageData {
  const OnboardingPageData({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.icon,
  });

  final String title;
  final String description;
  final String imagePath;
  final IconData icon;
}

const onboardingPages = [
  OnboardingPageData(
    title: "Bienvenue chez Foursquare Côte d'Ivoire",
    description: "Actualités, événements et vie de l'Église réunis simplement.",
    imagePath: AppAssets.welcome,
    icon: Icons.church_outlined,
  ),
  OnboardingPageData(
    title: 'Reste informe',
    description: 'Suis les annonces officielles et les temps forts du réseau.',
    imagePath: AppAssets.community,
    icon: Icons.notifications_none_rounded,
  ),
  OnboardingPageData(
    title: 'Trouve ton eglise',
    description: 'Repère une communauté, ses contacts et ses rendez-vous.',
    imagePath: AppAssets.events,
    icon: Icons.travel_explore_rounded,
  ),
];
