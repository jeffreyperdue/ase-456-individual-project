import 'package:flutter_test/flutter_test.dart';
import 'package:petfolio/app/navigation_provider.dart';

void main() {
  group('NavIndexNotifier', () {
    test('initial state is 0', () {
      final notifier = NavIndexNotifier();
      expect(notifier.debugState, 0);
    });

    test('setIndex updates state', () {
      final notifier = NavIndexNotifier();
      notifier.setIndex(2);
      expect(notifier.debugState, 2);
    });
  });
}


