import 'package:freezed_annotation/freezed_annotation.dart';

part 'doorway_model.freezed.dart';
part 'doorway_model.g.dart';

@freezed
class ParcelPlacement with _$ParcelPlacement {
  const factory ParcelPlacement({
    required String parcelId,
    required double x,
    required double y,
    required double rotation,
  }) = _ParcelPlacement;

  factory ParcelPlacement.fromJson(Map<String, dynamic> json) =>
      _$ParcelPlacementFromJson(json);
}

@freezed
class DoorwayModel with _$DoorwayModel {
  const factory DoorwayModel({
    required String doorwayId,
    required String ownerUid,
    @Default([]) List<ParcelPlacement> currentStack,
    @Default(0) double topScore,
    String? lastVisitedBy,
    required DateTime lastActivityAt,
  }) = _DoorwayModel;

  factory DoorwayModel.fromJson(Map<String, dynamic> json) =>
      _$DoorwayModelFromJson(json);
}
