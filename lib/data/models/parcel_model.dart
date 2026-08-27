import 'package:freezed_annotation/freezed_annotation.dart';

part 'parcel_model.freezed.dart';
part 'parcel_model.g.dart';

enum StabilityTier {
  stable,      // 安定
  moderate,    // 中間
  unstable,    // 不安定
}

enum ParcelRarity {
  common,    // 普通
  rare,      // 珍しい（ミーム用）
}

@freezed
class ParcelShape with _$ParcelShape {
  const factory ParcelShape({
    required List<Map<String, double>> vertices, // [{x, y}, ...]
    required double centerOfMass_x,
    required double centerOfMass_y,
  }) = _ParcelShape;

  factory ParcelShape.fromJson(Map<String, dynamic> json) =>
      _$ParcelShapeFromJson(json);
}

@freezed
class ParcelModel with _$ParcelModel {
  const factory ParcelModel({
    required String parcelId,
    required ParcelShape shape,
    required StabilityTier stabilityTier,
    required double weight,
    required ParcelRarity rarity,
    String? seasonTag,
    required String spriteRef,
  }) = _ParcelModel;

  factory ParcelModel.fromJson(Map<String, dynamic> json) =>
      _$ParcelModelFromJson(json);
}
