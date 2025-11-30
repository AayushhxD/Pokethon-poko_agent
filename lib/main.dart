import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'utils/theme.dart';
import 'services/wallet_service.dart';
import 'services/battle_service.dart';
import 'services/firebase_auth_service.dart';
import 'services/user_stats_service.dart';
import 'services/trading_service.dart';
import 'services/daily_challenge_service.dart';
import 'services/leaderboard_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  final prefs = await SharedPreferences.getInstance();
  runApp(MainApp(prefs: prefs));
}

class MainApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MainApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WalletService(prefs)),
        ChangeNotifierProvider(create: (_) => BattleService(prefs)),
        ChangeNotifierProvider(create: (_) => FirebaseAuthService()),
        ChangeNotifierProvider(create: (_) => UserStatsService(prefs)),
        ChangeNotifierProvider(create: (_) => TradingService(prefs)),
        ChangeNotifierProvider(create: (_) => DailyChallengeService(prefs)),
        ChangeNotifierProvider(create: (_) => LeaderboardService()),
      ],
      child: MaterialApp(
        title: 'PokeAgent',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  }
}
