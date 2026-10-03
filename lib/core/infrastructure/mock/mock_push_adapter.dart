import '../../ports/push_port.dart';

/// Development push adapter: does nothing.
class MockPushAdapter implements PushPort {
  const MockPushAdapter();

  @override
  Future<void> init() async {}

  @override
  Future<void> dispose() async {}
}
