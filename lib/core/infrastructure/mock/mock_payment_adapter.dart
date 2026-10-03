import 'package:flutter/foundation.dart';

import '../../ports/payment_port.dart';

/// Development payment adapter: simulates an instantly successful checkout.
///
/// It returns the success URL directly so the app flow can be tested
/// end-to-end without any payment provider configured.
class MockPaymentAdapter implements PaymentPort {
  const MockPaymentAdapter();

  @override
  Future<String> createCheckout({
    required String planId,
    required String successUrl,
    required String failureUrl,
    Map<String, String>? metadata,
  }) async {
    debugPrint('[MockPaymentAdapter] checkout for plan="$planId" -> $successUrl');
    return successUrl;
  }
}
