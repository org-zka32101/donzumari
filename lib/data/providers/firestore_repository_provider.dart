import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../repositories/firestore_repository.dart';
import './firebase_provider.dart';

// Firestore repository provider
final firestoreRepositoryProvider = Provider<FirestoreRepository>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return FirestoreRepository(firestore: firestore);
});
