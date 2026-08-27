import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/doorway_model.dart';
import './firestore_repository_provider.dart';

// Get doorway by ID
final getDoorwayProvider = FutureProvider.family<DoorwayModel?, String>((ref, doorwayId) async {
  final repository = ref.watch(firestoreRepositoryProvider);
  return await repository.getDoorway(doorwayId);
});

// Get recent doorways for visit selection
final getRecentDoorwaysProvider = FutureProvider<List<DoorwayModel>>((ref) async {
  final repository = ref.watch(firestoreRepositoryProvider);
  return await repository.getRecentDoorways(10);
});

// Doorway visit selection candidates (3 candidates)
final doorwayVisitCandidatesProvider = FutureProvider<List<DoorwayModel>>((ref) async {
  final repository = ref.watch(firestoreRepositoryProvider);
  final recent = await repository.getRecentDoorways(3);
  return recent;
});
