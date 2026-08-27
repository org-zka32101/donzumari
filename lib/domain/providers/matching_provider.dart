import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/matching_service.dart';
import '../../data/models/doorway_model.dart';
import '../../data/providers/firebase_provider.dart';

// Matching service provider
final matchingServiceProvider = Provider<MatchingService>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return MatchingService(firestore: firestore);
});

// Get matching candidates (requires userId and userHighScore)
final getMatchingCandidatesProvider = FutureProvider.family<
    List<DoorwayModel>,
    (String userId, double userHighScore)>((ref, params) async {
  final (userId, userHighScore) = params;
  final matchingService = ref.watch(matchingServiceProvider);
  return await matchingService.getMatchingCandidates(userId, userHighScore);
});

// Get candidates with NPC fallback
final getCandidatesWithFallbackProvider = FutureProvider.family<
    List<DoorwayModel>,
    (String userId, double userHighScore)>((ref, params) async {
  final (userId, userHighScore) = params;
  final matchingService = ref.watch(matchingServiceProvider);
  return await matchingService.getCandidatesWithFallback(userId, userHighScore);
});

// Get NPC doorways
final getNPCDoorwaysProvider = FutureProvider<List<DoorwayModel>>((ref) async {
  final matchingService = ref.watch(matchingServiceProvider);
  return await matchingService.getNPCDoorways();
});
