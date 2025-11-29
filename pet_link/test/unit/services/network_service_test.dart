import 'package:flutter_test/flutter_test.dart';
import 'package:petfolio/services/network_service.dart';

void main() {
  group('NetworkService', () {
    test('getNetworkErrorMessage returns user-friendly message', () {
      // Act
      final message = NetworkService.getNetworkErrorMessage();

      // Assert
      expect(message, isNotEmpty);
      expect(message.toLowerCase(), contains('internet'));
    });
  });
}


