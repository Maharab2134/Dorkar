import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'ip_address.dart';
import 'select_user.dart';
import 'constants/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dorkar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/ip-setup': (context) => const IpAddressScreen(),
        '/select-user': (context) => const SelectUserScreen(),
      },
    );
  }
}
