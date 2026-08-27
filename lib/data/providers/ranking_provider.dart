import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ranking_model.dart';
import './firestore_repository_provider.dart';

// Get ranking for a doorway
final getDoorwayRankingProvider =
    FutureProvider.family<RankingModel?, String>((ref, doorwayId) async {
  final repository = ref.watch(firestoreRepositoryProvider);
  return await repository.getDoorwayRanking(doorwayId);
});
