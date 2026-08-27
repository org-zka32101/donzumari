import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/tutorial_model.dart';

/// Service for managing tutorial and onboarding
class TutorialService {
  static late SharedPreferences _prefs;
  static bool _initialized = false;

  // Storage keys
  static const String _tutorialCompleteKey = 'tutorial_complete';
  static const String _tutorialStepKey = 'tutorial_step';
  static const String _onboardingCompleteKey = 'onboarding_complete';

  /// Initialize tutorial service
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
      print('✅ Tutorial service initialized');
    } catch (e) {
      print('⚠️ Tutorial service initialization warning: $e');
    }
  }

  /// Check if tutorial is completed
  static bool isTutorialComplete() {
    _ensureInitialized();
    return _prefs.getBool(_tutorialCompleteKey) ?? false;
  }

  /// Check if onboarding is completed
  static bool isOnboardingComplete() {
    _ensureInitialized();
    return _prefs.getBool(_onboardingCompleteKey) ?? false;
  }

  /// Get current tutorial step
  static int getCurrentTutorialStep() {
    _ensureInitialized();
    return _prefs.getInt(_tutorialStepKey) ?? 0;
  }

  /// Set tutorial as complete
  static Future<bool> completeTutorial() async {
    _ensureInitialized();
    try {
      await _prefs.setBool(_tutorialCompleteKey, true);
      print('🎓 Tutorial marked as complete');
      return true;
    } catch (e) {
      print('⚠️ Failed to complete tutorial: $e');
      return false;
    }
  }

  /// Set onboarding as complete
  static Future<bool> completeOnboarding() async {
    _ensureInitialized();
    try {
      await _prefs.setBool(_onboardingCompleteKey, true);
      print('🎓 Onboarding marked as complete');
      return true;
    } catch (e) {
      print('⚠️ Failed to complete onboarding: $e');
      return false;
    }
  }

  /// Update tutorial step
  static Future<bool> updateTutorialStep(int step) async {
    _ensureInitialized();
    try {
      await _prefs.setInt(_tutorialStepKey, step);
      print('📚 Tutorial step updated to $step');
      return true;
    } catch (e) {
      print('⚠️ Failed to update tutorial step: $e');
      return false;
    }
  }

  /// Reset tutorial
  static Future<bool> resetTutorial() async {
    _ensureInitialized();
    try {
      await _prefs.remove(_tutorialCompleteKey);
      await _prefs.remove(_tutorialStepKey);
      print('🔄 Tutorial reset');
      return true;
    } catch (e) {
      print('⚠️ Failed to reset tutorial: $e');
      return false;
    }
  }

  /// Get debug info
  static String getDebugInfo() {
    return 'Tutorial: initialized=$_initialized, '
        'complete=${isTutorialComplete()}, '
        'step=${getCurrentTutorialStep()}';
  }

  static void _ensureInitialized() {
    if (!_initialized) {
      throw StateError(
        'TutorialService not initialized. Call initialize() first.',
      );
    }
  }
}
