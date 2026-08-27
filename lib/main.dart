import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'domain/services/sprite_service.dart';
import 'domain/services/audio_service.dart';
import 'domain/services/performance_service.dart';
import 'domain/services/preferences_service.dart';
import 'domain/services/cosmetic_service.dart';
import 'domain/services/analytics_service.dart';
import 'domain/services/achievement_service.dart';
import 'domain/providers/preferences_providers.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/play_screen.dart';
import 'presentation/screens/result_screen.dart';
import 'presentation/screens/visit_selection_screen.dart';
import 'presentation/screens/ranking_screen.dart';
import 'presentation/screens/shop_screen.dart';
import 'presentation/screens/settings_screen.dart';
import 'presentation/screens/achievements_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firestore with seed data
  await _initializeFirestore();

  // Initialize Polish & QA services (Phase 6)
  await _initializePolishServices();

  runApp(
    const ProviderScope(
      child: DonzumariApp(),
    ),
  );
}

Future<void> _initializeFirestore() async {
  try {
    final firestore = FirebaseFirestore.instance;

    // Only seed on first app launch (check if parcels exist)
    final parcelsRef = firestore.collection('parcelPresets');
    final snapshot = await parcelsRef.limit(1).get();

    if (snapshot.docs.isEmpty) {
      print('🌱 First launch detected. Seeding initial data...');
      // TODO: Implement seeding here
      // For now, parcels should be created via Firebase Console or admin SDK
    }
  } catch (e) {
    print('ℹ️ Firestore initialization note: $e');
    // Don't block app startup if seeding fails
  }
}

Future<void> _initializePolishServices() async {
  try {
    print('🎨 Initializing Polish & QA services...');

    // Initialize performance monitoring
    PerformanceService.startMonitoring();
    print('📊 Performance monitoring enabled');

    // Initialize preferences service (settings persistence)
    await PreferencesService.initialize();
    print('💾 Preferences service initialized');

    // Initialize cosmetic service (monetization)
    await CosmeticService.initialize();
    print('🎁 Cosmetic service initialized');

    // Initialize analytics service (monitoring & insights)
    await AnalyticsService.initialize();
    print('📈 Analytics service initialized');

    // Initialize achievement service (progression & rewards)
    await AchievementService.initialize();
    print('🏆 Achievement service initialized');

    // Initialize sprite service (preload critical assets)
    await SpriteService.initialize();

    // Initialize audio service
    await AudioService.initialize();

    // Preload common assets
    await Future.wait([
      SpriteService.preloadTier('stable'),
      AudioService.preloadGameplaySounds(),
    ]);

    print('✅ All polish services initialized successfully');
  } catch (e) {
    print('⚠️ Polish services initialization warning: $e');
    // Don't block app startup if polish services fail
  }
}

class DonzumariApp extends ConsumerWidget {
  const DonzumariApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkModeEnabled = ref.watch(darkModeProvider);

    return MaterialApp(
      title: '宅配ドン詰まり',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: darkModeEnabled ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/play': (context) => const PlayScreen(),
        '/result': (context) => const ResultScreen(),
        '/visit-selection': (context) => const VisitSelectionScreen(),
        '/ranking': (context) => const RankingScreen(),
        '/shop': (context) => const ShopScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/achievements': (context) => const AchievementsScreen(),
      },
    );
  }
}
