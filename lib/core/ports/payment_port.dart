/// Payment processing port (checkout redirect flow).
///
/// Free tier ships with a [MockPaymentAdapter] for local development.
/// Premium ships real provider adapters — or implement your
/// own and register it in your DI container.
abstract class PaymentPort {
  /// Creates a hosted checkout session and returns its URL to redirect the
  /// user to. The backend (webhook) is responsible for activating the
  /// subscription after payment confirmation.
  Future<String> createCheckout({
    required String planId,
    required String successUrl,
    required String failureUrl,
    Map<String, String>? metadata,
  });
}
