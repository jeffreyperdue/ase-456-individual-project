// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // <-- add this
import 'firebase_options.dart';

import 'package:provider/provider.dart';
import 'app/app.dart';
import 'features/pets/presentation/state/pet_list_provider.dart';

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

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => PetListProvider())],
      child: const PetLinkApp(),
    ),
  );
}
