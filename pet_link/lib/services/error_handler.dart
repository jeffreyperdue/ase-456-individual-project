import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

/// Centralized error handling service for user-friendly error messages
class ErrorHandler {
  /// Handle and display error to user via SnackBar
  static void handleError(BuildContext context, Object error, {String? customMessage}) {
    final message = customMessage ?? mapErrorToMessage(error);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Show success message to user
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Map error objects to user-friendly messages
  static String mapErrorToMessage(Object error) {
    // Firebase Auth errors
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return "No account found with this email.";
        case 'wrong-password':
          return "Incorrect password. Please try again.";
        case 'email-already-in-use':
          return "An account with this email already exists.";
        case 'weak-password':
          return "Password is too weak. Please use at least 6 characters.";
        case 'invalid-email':
          return "Invalid email address. Please check and try again.";
        case 'user-disabled':
          return "This account has been disabled. Please contact support.";
        case 'too-many-requests':
          return "Too many attempts. Please try again later.";
        case 'operation-not-allowed':
          return "This operation is not allowed. Please contact support.";
        default:
          return "Authentication failed. Please try again.";
      }
    }

    // Firestore errors
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return "You don't have permission to perform this action.";
        case 'unavailable':
          return "Service unavailable. Please check your internet connection and try again.";
        case 'deadline-exceeded':
          return "Request timed out. Please try again.";
        case 'not-found':
          return "The requested item was not found.";
        case 'already-exists':
          return "This item already exists.";
        case 'resource-exhausted':
          return "Service temporarily unavailable. Please try again later.";
        case 'failed-precondition':
          return "Operation cannot be completed. Please check your data and try again.";
        case 'aborted':
          return "Operation was cancelled. Please try again.";
        case 'out-of-range':
          return "Invalid data provided. Please check your input.";
        case 'unimplemented':
          return "This feature is not yet available.";
        case 'internal':
          return "An internal error occurred. Please try again.";
        case 'unauthenticated':
          return "Please sign in to continue.";
        default:
          return "Connection issue. Please try again.";
      }
    }

    // Timeout errors
    if (error is TimeoutException) {
      return "The request took too long. Please check your connection and try again.";
    }

    // Network errors (catch-all for connectivity issues)
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('network') || 
        errorString.contains('connection') ||
        errorString.contains('socket')) {
      return "Network error. Please check your internet connection and try again.";
    }

    // Default fallback
    return "Something went wrong. Please try again.";
  }

  /// Check if error is network-related
  static bool isNetworkError(Object error) {
    if (error is FirebaseException && error.code == 'unavailable') {
      return true;
    }
    if (error is TimeoutException) {
      return true;
    }
    final errorString = error.toString().toLowerCase();
    return errorString.contains('network') || 
           errorString.contains('connection') ||
           errorString.contains('socket');
  }
}

