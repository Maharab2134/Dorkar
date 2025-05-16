import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen2 extends StatefulWidget {
  // ... (existing code)
  @override
  _LoginScreen2State createState() => _LoginScreen2State();
}

class _LoginScreen2State extends State<LoginScreen2> {
  // ... (existing code)

  void login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      isLoading = true;
    });

    String url = 'http://$ip/dorkar/providerlogin.php';
    print('Attempting to login at URL: $url');
    print('Email: $email');

    try {
      var response = await http.post(
        Uri.parse(url),
        body: {
          'email': email,
          'password': password,
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.body.isEmpty) {
        throw Exception('Empty response from server');
      }

      var jsonString = jsonDecode(response.body);
      print('Decoded JSON response: $jsonString');

      if (jsonString['message'] == 'success' && jsonString['providerInfo'] != null) {
        var providerInfo = jsonString['providerInfo'];
        
        // Safely get values with null checks
        var id = providerInfo['id']?.toString() ?? '';
        var name = providerInfo['name']?.toString() ?? '';
        var email = providerInfo['email']?.toString() ?? '';
        var phone = providerInfo['phone']?.toString() ?? '';
        var service = providerInfo['service']?.toString() ?? '';

        // Only proceed if we have the essential data
        if (id.isNotEmpty && name.isNotEmpty && email.isNotEmpty) {
          SharedPreferences user = await SharedPreferences.getInstance();
          await user.setString('providerid', id);
          await user.setString('providername', name);
          await user.setString('provideremail', email);
          await user.setString('providerphone', phone);
          await user.setString('providerservice', service);

          noLoading();

          if (!mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen2()),
            (Route<dynamic> route) => false,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login Successful'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw Exception('Missing required user data');
        }
      } else {
        String errorMessage = jsonString['error']?.toString() ?? 'Login Failed';
        noLoading();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Login error: $e');
      noLoading();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... (existing code)
  }
} 