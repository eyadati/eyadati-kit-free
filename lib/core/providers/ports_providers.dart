import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../infrastructure/mock/mock_payment_adapter.dart';
import '../infrastructure/mock/mock_push_adapter.dart';
import '../infrastructure/mock/mock_sms_adapter.dart';
import '../ports/payment_port.dart';
import '../ports/push_port.dart';
import '../ports/sms_port.dart';

/// DI registrations for the free tier: every external capability is mocked.
///
/// Replace these providers (or override them in `ProviderScope.overrides`)
/// to plug in a real implementation — no call sites need to change.
final paymentPortProvider = Provider<PaymentPort>((ref) => const MockPaymentAdapter());

final smsPortProvider = Provider<SmsPort>((ref) => const MockSmsAdapter());

final pushPortProvider = Provider<PushPort>((ref) => const MockPushAdapter());
