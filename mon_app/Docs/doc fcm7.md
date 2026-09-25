 Integration des notifications FCM cote Flutter#

Cette documentation explique comment integrer et tester les notifications push Firebase Cloud Messaging dans l'application Flutter Oriente Moi.

## 1. Objectif

Le front Flutter doit :

- demander la permission d'envoyer des notifications ;
- recuperer le token FCM du telephone ;
- envoyer ce token au backend ;
- afficher les notifications quand l'application est ouverte ;
- reagir quand l'utilisateur ouvre une notification ;
- relier le token FCM au compte utilisateur apres connexion.

Dans ce projet, la logique principale est deja centralisee dans :

- `lib/core/services/push_notification_service.dart`
- `lib/main.dart`
- `lib/features/auth/providers/auth_provider.dart`

## 2. Dependances Flutter

Verifier que ces dependances existent dans `pubspec.yaml` :

```yaml
dependencies:
  firebase_core: ^3.13.1
  firebase_messaging: ^15.2.5
  flutter_local_notifications: ^18.0.1
```

Puis installer les packages :

```bash
flutter pub get
```

## 3. Configuration Firebase

### Android

Verifier que le fichier suivant existe :

```text
android/app/google-services.json
```

Ce fichier vient de Firebase Console et doit correspondre au package Android de l'application.

### iOS

Pour iOS, ajouter le fichier Firebase suivant dans le projet iOS :

```text
ios/Runner/GoogleService-Info.plist
```

Il faut aussi activer les capacites suivantes dans Xcode :

- Push Notifications
- Background Modes > Remote notifications

## 4. Initialisation dans `main.dart`

Firebase et le service de notifications doivent etre initialises avant `runApp`.

Exemple deja utilise dans le projet :

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    await PushNotificationService.instance.initialize();
  } catch (e, stack) {
    debugPrint('[Firebase] Erreur initialisation: $e');
    debugPrint(stack.toString());
  }

  runApp(const OrienteMoiApp());
}
```

## 5. Service de notifications

Le fichier `push_notification_service.dart` gere :

- la demande de permission ;
- la creation du canal Android ;
- l'ecoute des messages en foreground ;
- l'ecoute du clic sur notification ;
- la recuperation du token FCM ;
- l'envoi du token au backend ;
- le rafraichissement automatique du token.

Le service est appele une seule fois au demarrage :

```dart
await PushNotificationService.instance.initialize();
```

## 6. Envoi du token au backend

Quand le token FCM est recupere, le front l'envoie au backend sur :

```http
POST /push-tokens
```

Payload envoye en mode invite :

```json
{
  "token": "FCM_TOKEN",
  "platform": "android",
  "guest_key": "GUEST_KEY"
}
```

Payload envoye apres connexion :

```json
{
  "token": "FCM_TOKEN",
  "platform": "android"
}
```

Le champ `platform` vaut :

- `android` sur Android ;
- `ios` sur iOS.

Quand l'utilisateur se connecte, le front appelle :

```dart
PushNotificationService.instance.onUserLoggedIn().ignore();
```

Cela permet de rattacher le token FCM au compte utilisateur connecte.

## 7. Format recommande d'une notification FCM

Pour une notification simple :

```json
{
  "message": {
    "token": "FCM_TOKEN",
    "notification": {
      "title": "Nouvelle alerte",
      "body": "Une nouvelle opportunite est disponible."
    },
    "data": {
      "type": "alert",
      "id": "123"
    }
  }
}
```

Le bloc `notification` permet a Firebase d'afficher automatiquement la notification quand l'app est en arriere-plan.

Le bloc `data` permet au front de savoir quoi ouvrir quand l'utilisateur clique sur la notification.

## 8. Reception des notifications

### App ouverte

Quand l'application est ouverte, Firebase ne montre pas toujours la notification automatiquement.

Le service utilise donc `flutter_local_notifications` pour afficher une notification locale :

```dart
FirebaseMessaging.onMessage.listen(_onForegroundMessage);
```

### App en arriere-plan

Quand l'application est en arriere-plan, Firebase affiche automatiquement la notification si le payload contient un bloc `notification`.

### App fermee

Quand l'application est fermee et ouverte via une notification, le service recupere le message initial :

```dart
final initialMessage = await _messaging.getInitialMessage();
```

## 9. Navigation au clic sur une notification

Le point d'entree est :

```dart
void _onNotificationTap(RemoteMessage message) {
  debugPrint('[FCM] Notification ouverte: ${message.messageId}');
}
```

Pour naviguer vers un ecran precis, utiliser les donnees de `message.data`.

Exemple de donnees :

```json
{
  "type": "alert",
  "id": "123"
}
```

Logique recommandee :

- si `type == alert`, ouvrir l'ecran des alertes ;
- si `type == school`, ouvrir la fiche ecole ;
- si `type == internship`, ouvrir l'offre de stage ;
- sinon, ouvrir l'accueil.

## 10. Permissions importantes

### Android 13+

Android 13 demande une permission runtime pour les notifications. Elle est demandee par :

```dart
await FirebaseMessaging.instance.requestPermission();
```

### Android 8+

Android 8 et plus demandent un canal de notification.

Le projet cree deja le canal :

```dart
static const _channelId = 'orientemoi_alerts';
static const _channelName = 'Alertes Oriente Moi';
```

Le backend peut utiliser ce `channel_id` si necessaire.

## 11. Checklist de test

Avant de valider l'integration, tester :

- l'app demande bien la permission de notification ;
- un token FCM apparait dans les logs Flutter ;
- le backend recoit bien `POST /push-tokens` ;
- une notification arrive quand l'app est ouverte ;
- une notification arrive quand l'app est en arriere-plan ;
- une notification arrive quand l'app est fermee ;
- le clic sur notification est detecte dans les logs ;
- apres connexion, le token est renvoye au backend en mode authentifie ;
- si Firebase renouvelle le token, le backend recoit le nouveau token.

## 12. Commandes utiles

Lancer l'application :

```bash
flutter run
```

Voir les logs Flutter :

```bash
flutter logs
```

Nettoyer puis relancer si Firebase semble mal configure :

```bash
flutter clean
flutter pub get
flutter run
```

## 13. Points d'attention

- Les notifications FCM doivent etre testees sur un vrai appareil pour un resultat fiable.
- Un emulateur Android peut fonctionner, mais il doit avoir Google Play Services.
- Sur iOS, les notifications push exigent une configuration Apple Developer correcte.
- Ne jamais commiter un fichier Firebase qui appartient a un autre projet.
- Le token FCM peut changer, il faut toujours ecouter `onTokenRefresh`.
- Pour les messages en arriere-plan, la fonction handler doit rester une fonction top-level.

