import 'package:freezed_annotation/freezed_annotation.dart';

part 'ranking_model.freezed.dart';
part 'ranking_model.g.dart';

@freezed
class RankingEntry with _$RankingEntry {
  const factory RankingEntry({
    required String uid,
    required double height,
    required int rank,
  }) = _RankingEntry;

  factory RankingEntry.fromJson(Map<String, dynamic> json) =>
      _$RankingEntryFromJson(json);
}

@freezed
class RankingModel with _$RankingModel {
  const factory RankingModel({
    required String doorwayId,
    @Default([]) List<RankingEntry> entries,
  }) = _RankingModel;

  factory RankingModel.fromJson(Map<String, dynamic> json) =>
      _$RankingModelFromJson(json);
}
