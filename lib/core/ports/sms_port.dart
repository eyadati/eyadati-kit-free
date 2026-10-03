/// SMS sending port.
///
/// Free tier ships a [MockSmsAdapter] (logs to console).
/// Swap for any SMS gateway by implementing this interface.
abstract class SmsPort {
  /// Sends an SMS. Phone number in international format (+213...).
  Future<void> send({required String to, required String body});
}
