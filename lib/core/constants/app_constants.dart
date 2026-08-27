/// Application-wide constants
class AppConstants {
  // Collections
  static const String usersCollection = 'users';
  static const String doorwaysCollection = 'doorways';
  static const String playResultsCollection = 'playResults';
  static const String rankingsCollection = 'rankings';

  // Firestore document fields
  static const String uidField = 'uid';
  static const String displayNameField = 'displayName';
  static const String doorwayIdField = 'doorwayId';
  static const String streakField = 'streak';
  static const String ownedSkinsField = 'ownedSkins';
  static const String createdAtField = 'createdAt';
  static const String lastActivityAtField = 'lastActivityAt';

  // Game constants
  static const double screenWidth = 375;
  static const double screenHeight = 667;
  static const double doorwayWidth = 300;
  static const double doorwayHeight = 400;

  // Physics
  static const double gravity = 9.81;
  static const double defaultDamping = 0.3;

  // Stability tiers
  static const String stabilityStable = 'stable';
  static const String stabilityModerate = 'moderate';
  static const String stabilityUnstable = 'unstable';

  // Parcel rarity
  static const String rarityCommon = 'common';
  static const String rarityRare = 'rare';

  // Time gates
  static const int maxNewDoorwaysPerDay = 5;
  static const Duration doorwayRefreshPeriod = Duration(hours: 24);

  // Retention
  static const Duration day1 = Duration(hours: 24);
  static const Duration day7 = Duration(days: 7);
  static const Duration day30 = Duration(days: 30);

  // Animation durations
  static const Duration collapseAnimationDuration = Duration(milliseconds: 1000);
  static const Duration successAnimationDuration = Duration(milliseconds: 800);
  static const Duration transitionDuration = Duration(milliseconds: 300);
}
