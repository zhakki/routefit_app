import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const RouteFitApp());
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
