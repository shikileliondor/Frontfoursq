import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../domain/models/news_article.dart';

const newsArticles = [
  NewsArticle(
    id: 'assemblee-generale-2025',
    title: 'Assemblee Generale Nationale Foursquare 2025',
    summary:
        'Reunion annuelle de tous les pasteurs et responsables du mouvement Foursquare en Cote dIvoire.',
    body:
        'La Foursquare Cote dIvoire organise son Assemblee Generale Nationale 2025 avec les pasteurs, les responsables de departements et les representants des eglises locales. Ce temps permettra de faire le point sur la vision, les projets missionnaires, la formation des leaders et les actions communautaires a venir.',
    date: '12 Oct 2025',
    imagePath: AppAssets.nationalNews,
    category: NewsCategory.national,
    badgeLabel: 'NATIONAL',
    badgeColor: Color(0xFFE31E2D),
    typeLabel: 'Annonce',
    imageUrl: null,
  ),
  NewsArticle(
    id: 'seminaire-leaders-abidjan-sud',
    title: 'Seminaire de formation des leaders - District Abidjan Sud',
    summary:
        'Le district Abidjan Sud organise un seminaire de formation intensive pour ses leaders.',
    body:
        'Le district Abidjan Sud organise un seminaire de formation intensive pour ses leaders. Au programme : gestion pastorale, communication evangelique et developpement communautaire. Intervenants de renom confirmes. Les inscriptions sont ouvertes jusquau 20 septembre.',
    date: '28 Sep 2025',
    imagePath: AppAssets.districtNews,
    category: NewsCategory.district,
    badgeLabel: 'DISTRICT',
    badgeColor: Color(0xFF3154C7),
    typeLabel: 'Formation',
    imageUrl: null,
  ),
  NewsArticle(
    id: 'zones-priere',
    title: 'Rencontre de priere des zones pastorales',
    summary:
        'Les zones pastorales se reunissent pour une soiree de priere et dintercession.',
    body:
        'Les zones pastorales se reunissent pour une soiree de priere et dintercession consacree aux familles, aux eglises locales et aux projets de developpement du mouvement Foursquare.',
    date: '05 Oct 2025',
    imagePath: AppAssets.community,
    category: NewsCategory.zone,
    badgeLabel: 'ZONE',
    badgeColor: Color(0xFF0E9F6E),
    typeLabel: 'Priere',
    imageUrl: null,
  ),
];
