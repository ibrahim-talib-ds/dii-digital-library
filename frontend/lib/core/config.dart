/// Runtime configuration.
///
/// The backend base URL is compile-time configurable:
///   flutter run --dart-define=API_BASE=http://192.168.1.5:8002
/// Defaults to localhost so mobile emulators + desktop web work out of the box.
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE',
    defaultValue: 'http://localhost:8002',
  );

  static const Duration requestTimeout = Duration(seconds: 20);
  static const Duration streamTimeout  = Duration(minutes: 30);
}
