import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  // ... (existing code)
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ... (existing code)

  Future<void> updateUser() async {
    setState(() {
      isLoading = true;
    });

    String url = 'http://$ip/dorkar/updateuser.php';
    print('Attempting to update user at URL: $url');
    print('User ID: $id');
    print('Data being sent:');
    print('Username: ${usernameController.text}');
    print('Email: ${emailController.text}');
    print('Phone: ${phoneController.text}');
    print('Address: ${addressController.text}');

    try {
      var response = await http.post(
        Uri.parse(url),
        body: {
          'id': id,
          'username': usernameController.text,
          'email': emailController.text,
          'phone_no': phoneController.text,
          'address': addressController.text,
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.body.isEmpty) {
        throw Exception('Empty response from server');
      }

      var jsonBody = jsonDecode(response.body);
      print('Decoded JSON response: $jsonBody');
      
      if (jsonBody['message'] == 'success') {
        await userPrefs?.setString('username', usernameController.text);
        await userPrefs?.setString('useremail', emailController.text);
        await userPrefs?.setString('userphone', phoneController.text);
        await userPrefs?.setString('useraddress', addressController.text);

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Profile updated successfully')));
        }
      } else {
        String errorMessage = jsonBody['error'] ?? 'Unknown error occurred';
        print('Update failed with error: $errorMessage');
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Update failed: $errorMessage')));
        }
      }
    } catch (e) {
      print('Update error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... (existing code)
  }
} 