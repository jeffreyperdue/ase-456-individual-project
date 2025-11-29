import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petfolio/services/error_handler.dart';

void main() {
  group('ErrorHandler.mapErrorToMessage', () {
    test('maps FirebaseAuthException codes to friendly messages', () {
      final cases = <String, String>{
        'user-not-found': 'No account found with this email.',
        'wrong-password': 'Incorrect password. Please try again.',
        'email-already-in-use': 'An account with this email already exists.',
        'weak-password': 'Password is too weak. Please use at least 6 characters.',
        'invalid-email': 'Invalid email address. Please check and try again.',
        'user-disabled': 'This account has been disabled. Please contact support.',
        'too-many-requests': 'Too many attempts. Please try again later.',
        'operation-not-allowed': 'This operation is not allowed. Please contact support.',
      };

      cases.forEach((code, expected) {
        final error = FirebaseAuthException(code: code, message: 'test');
        final message = ErrorHandler.mapErrorToMessage(error);
        expect(message, expected);
      });
    });

    test('maps unknown FirebaseAuthException to generic auth message', () {
      final error = FirebaseAuthException(code: 'unknown', message: 'test');
      final message = ErrorHandler.mapErrorToMessage(error);
      expect(message, 'Authentication failed. Please try again.');
    });

    test('maps FirebaseException codes to friendly messages', () {
      final cases = <String, String>{
        'permission-denied': "You don't have permission to perform this action.",
        'unavailable': 'Service unavailable. Please check your internet connection and try again.',
        'deadline-exceeded': 'Request timed out. Please try again.',
        'not-found': 'The requested item was not found.',
        'already-exists': 'This item already exists.',
        'resource-exhausted': 'Service temporarily unavailable. Please try again later.',
        'failed-precondition': 'Operation cannot be completed. Please check your data and try again.',
        'aborted': 'Operation was cancelled. Please try again.',
        'out-of-range': 'Invalid data provided. Please check your input.',
        'unimplemented': 'This feature is not yet available.',
        'internal': 'An internal error occurred. Please try again.',
        'unauthenticated': 'Please sign in to continue.',
      };

      cases.forEach((code, expected) {
        final error = FirebaseException(plugin: 'firestore', code: code, message: 'test');
        final message = ErrorHandler.mapErrorToMessage(error);
        expect(message, expected);
      });
    });

    test('maps unknown FirebaseException to generic connection message', () {
      final error = FirebaseException(plugin: 'firestore', code: 'unknown', message: 'test');
      final message = ErrorHandler.mapErrorToMessage(error);
      expect(message, 'Connection issue. Please try again.');
    });

    test('maps TimeoutException to timeout message', () {
      final error = TimeoutException('test');
      final message = ErrorHandler.mapErrorToMessage(error);
      expect(
        message,
        'The request took too long. Please check your connection and try again.',
      );
    });

    test('maps generic network-like errors to network message', () {
      final networkErrors = [
        Exception('Network error occurred'),
        Exception('connection lost'),
        Exception('socket closed'),
      ];

      for (final error in networkErrors) {
        final message = ErrorHandler.mapErrorToMessage(error);
        expect(
          message,
          'Network error. Please check your internet connection and try again.',
        );
      }
    });

    test('falls back to default message for unknown errors', () {
      final error = Exception('Some random error');
      final message = ErrorHandler.mapErrorToMessage(error);
      expect(message, 'Something went wrong. Please try again.');
    });
  });

  group('ErrorHandler.isNetworkError', () {
    test('returns true for FirebaseException with unavailable code', () {
      final error = FirebaseException(plugin: 'firestore', code: 'unavailable');
      expect(ErrorHandler.isNetworkError(error), isTrue);
    });

    test('returns true for TimeoutException', () {
      final error = TimeoutException('test');
      expect(ErrorHandler.isNetworkError(error), isTrue);
    });

    test('returns true for generic network-like error strings', () {
      final errors = [
        Exception('Network error'),
        Exception('connection lost'),
        Exception('socket closed'),
      ];

      for (final error in errors) {
        expect(ErrorHandler.isNetworkError(error), isTrue);
      }
    });

    test('returns false for non-network errors', () {
      final error = Exception('Some other error');
      expect(ErrorHandler.isNetworkError(error), isFalse);
    });
  });

  group('ErrorHandler SnackBar helpers', () {
    testWidgets('showSuccess shows a SnackBar with message', (tester) async {
      const message = 'Success!';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox.shrink(),
          ),
        ),
      );

      // Act
      ErrorHandler.showSuccess(
        tester.element(find.byType(SizedBox)),
        message,
      );

      await tester.pump(); // show SnackBar

      // Assert
      expect(find.text(message), findsOneWidget);
    });

    testWidgets('handleError shows a SnackBar for given error', (tester) async {
      const customMessage = 'Custom error';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox.shrink(),
          ),
        ),
      );

      // Act
      ErrorHandler.handleError(
        tester.element(find.byType(SizedBox)),
        Exception('test'),
        customMessage: customMessage,
      );

      await tester.pump(); // show SnackBar

      // Assert
      expect(find.text(customMessage), findsOneWidget);
    });
  });
}


