import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:routefit_app/providers/tracking_provider.dart';
import 'package:routefit_app/screens/map_screen.dart';

import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => TrackingProvider())],
      child: const RouteFitApp(),
    ),
  );
}

class RouteFitApp extends StatelessWidget {
  const RouteFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RouteFit',
      theme: buildRouteFitTheme(),
      home: const LoginScreen(),
    );
  }
}
