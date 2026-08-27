import 'package:freezed_annotation/freezed_annotation.dart';

part 'tutorial_model.freezed.dart';
part 'tutorial_model.g.dart';

/// Tutorial step type
enum TutorialStepType {
  gameIntro,
  stackingMechanic,
  scoringSystem,
  doorwaySelection,
  multiplayerMode,
  cosmeticShop,
  achievements,
  settings,
}

/// Tutorial step
@freezed
class TutorialStep with _$TutorialStep {
  const factory TutorialStep({
    required int stepNumber,
    required TutorialStepType type,
    required String title,
    required String description,
    required String? imageAsset,
    required List<String> highlightTargets,  // UI elements to highlight
    required bool isSkippable,
    required String? nextButtonText,
    required String? previousButtonText,
  }) = _TutorialStep;

  factory TutorialStep.fromJson(Map<String, dynamic> json) =>
      _$TutorialStepFromJson(json);
}

/// Onboarding screen
@freezed
class OnboardingScreen with _$OnboardingScreen {
  const factory OnboardingScreen({
    required int screenNumber,
    required String title,
    required String description,
    required String imageAsset,
    required String actionButtonText,
    required bool isLastScreen,
  }) = _OnboardingScreen;

  factory OnboardingScreen.fromJson(Map<String, dynamic> json) =>
      _$OnboardingScreenFromJson(json);
}
