import 'package:flutter/foundation.dart';

import '../../ports/sms_port.dart';

/// Development SMS adapter: logs messages to the debug console.
class MockSmsAdapter implements SmsPort {
  const MockSmsAdapter();

  @override
  Future<void> send({required String to, required String body}) async {
    debugPrint('[MockSmsAdapter] to=$to\n$body');
  }
}
