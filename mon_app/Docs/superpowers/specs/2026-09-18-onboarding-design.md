# Onboarding Flutter - Conception

## Objectif

Créer le premier parcours de l'application Foursquare Côte d'Ivoire. L'onboarding présente l'identité de l'Église et les principaux usages de l'application, puis redirige vers l'accueil. Il ne doit apparaître qu'au premier lancement, sauf réinitialisation explicite des données locales.

## Parcours

L'onboarding comporte trois pages horizontales :

1. **Bienvenue chez Foursquare Côte d'Ivoire**
   - Image : `assets/images/WhatsApp Image 2026-09-18 at a.jpeg`
   - Message : découvrir la communauté nationale et rester proche de la vie de l'Église.
2. **Une communauté vivante**
   - Image : `assets/images/image 2 .jpg`
   - Message : suivre les activités de la jeunesse, des assemblées, des zones et des districts.
3. **Vivez nos événements**
   - Image : `assets/images/image 6.jpg`
   - Message : retrouver les événements et les actualités importantes au même endroit.

Le logo officiel `assets/images/LOGO DE.jpeg` est visible sur chaque page. Les pages 1 et 2 proposent `Passer` et `Suivant`. La page 3 remplace `Suivant` par `Commencer`. `Passer` et `Commencer` terminent le parcours et ouvrent l'accueil.

## Direction visuelle

L'interface utilise le bleu institutionnel comme couleur principale, le rouge comme accent d'action et un fond blanc. Chaque page présente :

- une zone supérieure compacte contenant le logo ;
- une photographie principale avec un recadrage adaptatif et un léger voile lorsque nécessaire ;
- une zone de contenu blanche avec un titre, un court texte et l'indicateur de progression ;
- une action principale clairement identifiable et une action secondaire discrète.

Les photographies gardent un ratio stable afin d'éviter les sauts de mise en page. Le texte reste lisible sur les petits téléphones, les grands téléphones et en présence d'une taille de police système accrue. Les zones tactiles respectent une hauteur minimale de 48 pixels logiques.

## Architecture

La fonctionnalité suit une Clean Architecture pragmatique par fonctionnalité :

```text
lib/
  app/
    app.dart
    router.dart
    theme/
  core/
    constants/
  features/
    onboarding/
      data/
        datasources/
        repositories/
      domain/
        repositories/
        usecases/
      presentation/
        pages/
        widgets/
        models/
    home/
      presentation/pages/
```

Le domaine expose un contrat permettant de savoir si l'onboarding est terminé et de marquer sa complétion. La couche data implémente ce contrat avec `shared_preferences`. La présentation ne dépend pas directement du stockage local.

Le routeur choisit l'onboarding ou l'accueil au démarrage. La première version de l'accueil est un écran temporaire minimal, destiné à être remplacé par la fonctionnalité `home` connectée à l'API.

## État et données

Les contenus des trois pages sont des données locales immuables. Un contrôleur de présentation conserve uniquement l'index courant et déclenche la complétion du parcours. La clé locale est `has_completed_onboarding` et vaut `true` après `Passer` ou `Commencer`.

Une erreur de lecture du stockage est traitée comme un premier lancement afin de ne pas bloquer l'utilisateur. Une erreur d'écriture n'empêche pas l'accès à l'accueil, mais l'onboarding pourra réapparaître au lancement suivant.

## Navigation

Le démarrage affiche un écran neutre très court pendant la lecture de la préférence locale. Le routeur redirige ensuite :

- vers `/onboarding` lorsque la préférence est absente ou fausse ;
- vers `/home` lorsqu'elle vaut vrai.

La route d'accueil remplace l'onboarding dans la pile de navigation afin que le bouton retour ne le réouvre pas.

## Dépendances

- `shared_preferences` pour la persistance locale ;
- `flutter_riverpod` pour l'injection des dépendances et l'état ;
- `go_router` pour la navigation et la redirection initiale.

Les assets nécessaires sont déclarés dans `pubspec.yaml`. Aucun asset distant n'est utilisé.

## Tests

Les tests couvrent :

- l'affichage du premier écran et du logo ;
- le passage aux pages suivantes ;
- la présence de `Commencer` uniquement sur la dernière page ;
- le comportement de `Passer` ;
- l'enregistrement de la complétion ;
- la redirection vers l'accueil après complétion ;
- l'ouverture directe de l'accueil lors d'un lancement ultérieur ;
- l'absence de débordement sur une petite taille d'écran.

## Hors périmètre

La connexion à l'API, l'écran d'accueil définitif, les notifications push et la localisation des assemblées seront développés dans des fonctionnalités séparées. L'onboarding ne demande aucune permission système.
