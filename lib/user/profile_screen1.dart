import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ProfileScreen1 extends StatefulWidget {
  const ProfileScreen1({super.key});

  @override
  State<ProfileScreen1> createState() => _ProfileScreen1State();
}

class _ProfileScreen1State extends State<ProfileScreen1> {
  final _updateKey = GlobalKey<FormState>();
  SharedPreferences? userPrefs;

  String ip = '';
  String id = '';
  bool isLoading = false;

  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;

  late String initialUsername;
  late String initialEmail;
  late String initialPhone;
  late String initialAddress;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    userDetails();
    loadIP();
  }

  Future<void> loadIP() async {
    userPrefs = await SharedPreferences.getInstance();
    setState(() {
      ip = userPrefs?.getString('ip') ?? 'No IP Address';
    });
  }

  void _initializeControllers() {
    usernameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    addressController = TextEditingController();
  }

  Future<void> userDetails() async {
    setState(() {
      isLoading = true;
    });

    try {
      userPrefs = await SharedPreferences.getInstance();

      setState(() {
        id = userPrefs?.getString('userid') ?? '';
        initialUsername = userPrefs?.getString('username') ?? '';
        initialEmail = userPrefs?.getString('useremail') ?? '';
        initialPhone = userPrefs?.getString('userphone') ?? '';
        initialAddress = userPrefs?.getString('useraddress') ?? '';

        usernameController.text = initialUsername;
        emailController.text = initialEmail;
        phoneController.text = initialPhone;
        addressController.text = initialAddress;
      });
    } catch (e) {
      print('Error loading user details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateUser() async {
    if (!_updateKey.currentState!.validate()) {
      return;
    }

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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        String errorMessage = jsonBody['error'] ?? 'Unknown error occurred';
        print('Update failed with error: $errorMessage');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Update failed: $errorMessage'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Update error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
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
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  bool hasChanges() {
    return usernameController.text != initialUsername ||
        emailController.text != initialEmail ||
        phoneController.text != initialPhone ||
        addressController.text != initialAddress;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _updateKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: addressController,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (hasChanges()) {
                            updateUser();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('No changes made'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Update Profile',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
