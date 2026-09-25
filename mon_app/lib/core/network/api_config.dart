abstract final class ApiConfig {
  /// Surchargeable au build, sans toucher au code :
  /// `flutter run --dart-define=API_BASE_URL=http://192.168.1.12:8000/api/v1`
  ///
  /// La valeur par defaut reste la production : un build sans option pointe
  /// toujours la ou il doit pointer.
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.studiobeyam.net/api/v1',
  );
}
