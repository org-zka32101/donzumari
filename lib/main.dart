import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/play_screen.dart';
import 'presentation/screens/result_screen.dart';
import 'presentation/screens/visit_selection_screen.dart';
import 'presentation/screens/ranking_screen.dart';
import 'presentation/screens/shop_screen.dart';
import 'presentation/screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: DonzumariApp(),
    ),
  );
}

class DonzumariApp extends ConsumerWidget {
  const DonzumariApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/play': (context) => const PlayScreen(),
        '/result': (context) => const ResultScreen(),
        '/visit-selection': (context) => const VisitSelectionScreen(),
        '/ranking': (context) => const RankingScreen(),
        '/shop': (context) => const ShopScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
