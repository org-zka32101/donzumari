import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/play_result_model.dart';
import './firestore_repository_provider.dart';

// Get play results for a doorway
final getDoorwayResultsProvider =
    FutureProvider.family<List<PlayResultModel>, String>((ref, doorwayId) async {
  final repository = ref.watch(firestoreRepositoryProvider);
  return await repository.getDoorwayResults(doorwayId);
});

// Get user's play results
final getUserResultsProvider = FutureProvider.family<List<PlayResultModel>, String>((ref, uid) async {
  final repository = ref.watch(firestoreRepositoryProvider);
  return await repository.getUserResults(uid);
});

// Save play result
final savePlayResultProvider = FutureProvider.family<PlayResultModel, (String, String, double, bool, String?)>(
  (ref, params) async {
    final (uid, doorwayId, height, collapsed, gifRef) = params;
    final repository = ref.watch(firestoreRepositoryProvider);
    return await repository.savePlayResult(uid, doorwayId, height, collapsed, gifRef);
  },
);
