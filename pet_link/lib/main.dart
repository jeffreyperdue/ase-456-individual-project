// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // --- FIRESTORE SMOKE TEST: remove after verifying ---
  try {
    await FirebaseFirestore.instance.collection('users').doc('test-doc').set({
      'hello': 'world',
      'timestamp': FieldValue.serverTimestamp(),
    });
  } catch (e) {
    debugPrint('Firestore write failed: $e');
  }
  // ---------------------------------------------------

  runApp(const ProviderScope(child: PetLinkApp()));
}
