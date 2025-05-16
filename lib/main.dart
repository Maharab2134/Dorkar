import 'package:flutter/material.dart';
import 'package:dorkar/constants/my_theme.dart';
import 'package:dorkar/ip_address.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: MyTheme.lightTheme,
      home: IpAddressScreen(),
    );
  }
}

