import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:donzumari/domain/services/tutorial_service.dart';

void main() {
  group('TutorialService', () {
    setUpAll(() async {
      SharedPreferences.setMockInitialValues({});
    });

    setUp(() async {
      await TutorialService.initialize();
    });

    tearDown(() async {
      await TutorialService.resetTutorial();
    });

    test('initializes tutorial service', () {
      expect(
        TutorialService.getDebugInfo(),
        contains('initialized=true'),
      );
    });

    test('tutorial is incomplete by default', () {
      expect(TutorialService.isTutorialComplete(), isFalse);
    });

    test('onboarding is incomplete by default', () {
      expect(TutorialService.isOnboardingComplete(), isFalse);
    });

    test('tutorial step is 0 by default', () {
      expect(TutorialService.getCurrentTutorialStep(), equals(0));
    });

    test('marks tutorial as complete', () async {
      final success = await TutorialService.completeTutorial();
      expect(success, isTrue);
      expect(TutorialService.isTutorialComplete(), isTrue);
    });

    test('marks onboarding as complete', () async {
      final success = await TutorialService.completeOnboarding();
      expect(success, isTrue);
      expect(TutorialService.isOnboardingComplete(), isTrue);
    });

    test('updates tutorial step', () async {
      final success = await TutorialService.updateTutorialStep(5);
      expect(success, isTrue);
      expect(TutorialService.getCurrentTutorialStep(), equals(5));
    });

    test('increments tutorial step progressively', () async {
      for (int i = 0; i < 10; i++) {
        await TutorialService.updateTutorialStep(i);
        expect(TutorialService.getCurrentTutorialStep(), equals(i));
      }
    });

    test('completes both tutorial and onboarding independently', () async {
      await TutorialService.completeTutorial();
      expect(TutorialService.isTutorialComplete(), isTrue);
      expect(TutorialService.isOnboardingComplete(), isFalse);

      await TutorialService.completeOnboarding();
      expect(TutorialService.isTutorialComplete(), isTrue);
      expect(TutorialService.isOnboardingComplete(), isTrue);
    });

    test('resets tutorial state', () async {
      await TutorialService.completeTutorial();
      await TutorialService.updateTutorialStep(3);

      final success = await TutorialService.resetTutorial();
      expect(success, isTrue);
      expect(TutorialService.isTutorialComplete(), isFalse);
      expect(TutorialService.getCurrentTutorialStep(), equals(0));
    });

    test('resets only tutorial, not onboarding', () async {
      await TutorialService.completeTutorial();
      await TutorialService.completeOnboarding();
      await TutorialService.updateTutorialStep(5);

      await TutorialService.resetTutorial();
      expect(TutorialService.isTutorialComplete(), isFalse);
      expect(TutorialService.getCurrentTutorialStep(), equals(0));
      // Onboarding should still be complete
      expect(TutorialService.isOnboardingComplete(), isTrue);
    });

    test('handles large tutorial step numbers', () async {
      final success = await TutorialService.updateTutorialStep(999);
      expect(success, isTrue);
      expect(TutorialService.getCurrentTutorialStep(), equals(999));
    });

    test('persists tutorial state across re-initialization', () async {
      await TutorialService.completeTutorial();
      await TutorialService.updateTutorialStep(7);

      final step1 = TutorialService.getCurrentTutorialStep();
      final complete1 = TutorialService.isTutorialComplete();

      await TutorialService.initialize();

      expect(TutorialService.getCurrentTutorialStep(), equals(step1));
      expect(TutorialService.isTutorialComplete(), equals(complete1));
    });

    test('returns accurate debug info', () {
      final debugInfo = TutorialService.getDebugInfo();
      expect(debugInfo, isNotEmpty);
      expect(debugInfo, contains('Tutorial'));
      expect(debugInfo, contains('initialized=true'));
      expect(debugInfo, contains('complete=false'));
      expect(debugInfo, contains('step=0'));
    });

    test('debug info reflects current state after updates', () async {
      await TutorialService.completeTutorial();
      await TutorialService.updateTutorialStep(4);

      final debugInfo = TutorialService.getDebugInfo();
      expect(debugInfo, contains('complete=true'));
      expect(debugInfo, contains('step=4'));
    });

    test('completes onboarding multiple times safely', () async {
      for (int i = 0; i < 5; i++) {
        final success = await TutorialService.completeOnboarding();
        expect(success, isTrue);
        expect(TutorialService.isOnboardingComplete(), isTrue);
      }
    });

    test('tutorial step can be reset to 0', () async {
      await TutorialService.updateTutorialStep(10);
      expect(TutorialService.getCurrentTutorialStep(), equals(10));

      await TutorialService.updateTutorialStep(0);
      expect(TutorialService.getCurrentTutorialStep(), equals(0));
    });
  });
}
