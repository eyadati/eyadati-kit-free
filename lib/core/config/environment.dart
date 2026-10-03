class Environment {
  final String name;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final bool enableLogging;
  final bool enableDebugMode;
  final String apiUrl;
  final String appBaseUrl;

  const Environment({
    required this.name,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    this.enableLogging = false,
    this.enableDebugMode = false,
    this.apiUrl = '',
    this.appBaseUrl = 'https://your-app.example.com',
  });

  bool get isProduction => name == 'production';
  bool get isStaging => name == 'staging';
  bool get isDevelopment => name == 'development';
}

class Environments {
  static const Environment development = Environment(
    name: 'development',
    supabaseUrl: 'http://localhost:54321',
    supabaseAnonKey: 'your-local-anon-key',
    enableLogging: true,
    enableDebugMode: true,
  );

  static const Environment staging = Environment(
    name: 'staging',
    supabaseUrl: const String.fromEnvironment('SUPABASE_URL', defaultValue: ''),
    supabaseAnonKey: 'your-staging-anon-key',
    enableLogging: true,
    enableDebugMode: false,
  );

  static const Environment production = Environment(
    name: 'production',
    supabaseUrl: const String.fromEnvironment('SUPABASE_URL', defaultValue: ''),
    supabaseAnonKey: const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: ''),
    enableLogging: true,
    enableDebugMode: false,
  );

  static Environment fromName(String name) {
    switch (name.toLowerCase()) {
      case 'production':
        return production;
      case 'staging':
        return staging;
      default:
        return development;
    }
  }
}
