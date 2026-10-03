/// Push notification port.
///
/// Free tier ships a [MockPushAdapter] (no-op).
/// Premium ships a real implementation — or write your own
/// and register it in your DI container.
abstract class PushPort {
  /// Requests permission, starts token registration and handles incoming
  /// messages. Called once at app startup.
  Future<void> init();

  /// Stops token registration and releases resources.
  Future<void> dispose();
}
