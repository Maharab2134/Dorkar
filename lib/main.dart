import 'package:flutter/material.dart';
import 'screens/ip_setup_screen.dart';
import 'utils/ip_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dorkar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkIP();
  }

  Future<void> _checkIP() async {
    final isIPSet = await IPManager.isIPSet();
    if (mounted) {
      if (isIPSet) {
        // Navigate to your main app screen
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Show IP setup screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const IPSetupScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

