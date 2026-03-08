import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'features/auth/providers/auth_provider.dart';
import 'core/network/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase initialisation — real config from firebase_options.dart
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF13131A),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const LustMeterApp(),
    ),
  );
}

class LustMeterApp extends StatelessWidget {
  const LustMeterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Lust Meter',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0F),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE63950),
          secondary: Color(0xFF9B30FF),
          surface: Color(0xFF13131A),
          error: Color(0xFFFF4D6D),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Color(0xFFF0F0F5),
        ),
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A0A0F),
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: Color(0xFFF0F0F5)),
          titleTextStyle: TextStyle(
            color: Color(0xFFF0F0F5),
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }
}
