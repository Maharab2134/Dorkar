import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignUpScreen2 extends StatefulWidget {
  // ... (existing code)
  @override
  _SignUpScreen2State createState() => _SignUpScreen2State();
}

class _SignUpScreen2State extends State<SignUpScreen2> {
  // ... (existing code)

  void signUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final service = _serviceController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      isLoading = true;
    });

    String url = 'http://$ip/dorkar/providersignup.php';
    print('Attempting to sign up at URL: $url');
    print('Data being sent:');
    print('Name: $name');
    print('Email: $email');
    print('Phone: $phone');
    print('Service: $service');

    try {
      var response = await http.post(
        Uri.parse(url),
        body: {
          'name': name,
          'email': email,
          'phone': phone,
          'service': service,
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

      if (jsonString['message'] == 'success') {
        noLoading();
        Navigator.pushReplacement(
          context,
          FadePageRoute(
            page: const LoginScreen2(),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sign Up Successful'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        String errorMessage = jsonString['error'] ?? 'Sign Up Failed';
        noLoading();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Sign up error: $e');
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