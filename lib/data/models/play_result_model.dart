import 'package:freezed_annotation/freezed_annotation.dart';

part 'play_result_model.freezed.dart';
part 'play_result_model.g.dart';

@freezed
class PlayResultModel with _$PlayResultModel {
  const factory PlayResultModel({
    required String resultId,
    required String uid,
    required String doorwayId,
    required double height,
    required bool collapsed,
    String? gifRef,
    required DateTime playedAt,
  }) = _PlayResultModel;

  factory PlayResultModel.fromJson(Map<String, dynamic> json) =>
      _$PlayResultModelFromJson(json);
}
