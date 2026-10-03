import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eyadati_kit/core/infrastructure/mock/mock_payment_adapter.dart';
import 'package:eyadati_kit/core/infrastructure/mock/mock_push_adapter.dart';
import 'package:eyadati_kit/core/infrastructure/mock/mock_sms_adapter.dart';
import 'package:eyadati_kit/core/providers/ports_providers.dart';

void main() {
  late ProviderContainer container;

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  test('free tier wires every port to its mock', () {
    expect(container.read(paymentPortProvider), isA<MockPaymentAdapter>());
    expect(container.read(smsPortProvider), isA<MockSmsAdapter>());
    expect(container.read(pushPortProvider), isA<MockPushAdapter>());
  });

  test('mock checkout returns the success URL untouched', () async {
    final url = await container.read(paymentPortProvider).createCheckout(
          planId: 'whatever',
          successUrl: 'https://example.com/payment/success',
          failureUrl: 'https://example.com/payment/failure',
        );
    expect(url, 'https://example.com/payment/success');
  });

  test('mock SMS send completes without network', () async {
    await container
        .read(smsPortProvider)
        .send(to: '+213555123456', body: 'Votre rendez-vous est confirmé.');
  });

  test('mock push init/dispose complete without side effects', () async {
    final push = container.read(pushPortProvider);
    await push.init();
    await push.dispose();
  });
}
