import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dorkar/constants/my_colors.dart';
import 'package:dorkar/models/data_models.dart';
import 'package:dorkar/user/feedback.dart';
import 'package:dorkar/user/payment_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../constants/my_theme.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  SharedPreferences? prefObj;
  String ip = '';
  String userid = '';

  @override
  void initState() {
    super.initState();
    loadDetails();
  }

  Future<void> loadDetails() async {
    prefObj = await SharedPreferences.getInstance();
    setState(() {
      ip = prefObj?.getString('ip') ?? '';
      userid = prefObj?.getString('userid') ?? '';
    });
    
    if (ip.isEmpty || userid.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session expired. Please login again.'),
            backgroundColor: Colors.red,
          ),
        );
        // Navigate to login screen
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/select_user',
          (route) => false,
        );
      }
      return;
    }
    
    print('User ID: $userid');
    print('IP Address: $ip');
  }

  Future<void> logout() async {
    try {
      // Clear all user data
      await prefObj?.remove('userid');
      await prefObj?.remove('username');
      await prefObj?.remove('useremail');
      await prefObj?.remove('userphone');
      // Don't clear IP address as it's needed for login
      
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/select_user',
          (route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logged out successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logging out: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<List<Bookings>> getUserBookings() async {
    String url = 'http://$ip/dorkar/usermybookings.php?uid=$userid';
    print('Fetching bookings from: $url'); // Debug print

    try {
      var response = await http.get(Uri.parse(url));
      print('Response status code: ${response.statusCode}'); // Debug print
      print('Response body: ${response.body}'); // Debug print

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          print('Empty response received'); // Debug print
          return [];
        }

        try {
          final List<dynamic> data = jsonDecode(response.body);
          print('Decoded data: $data'); // Debug print

          if (data.isEmpty) {
            print('No bookings found in data'); // Debug print
            return [];
          }

          return data.map((booking) {
            print('Processing booking: $booking'); // Debug print
            return Bookings.fromJson(booking);
          }).toList();
        } catch (e) {
          print('Error decoding JSON: $e'); // Debug print
          return [];
        }
      } else {
        print('Error status code: ${response.statusCode}'); // Debug print
        throw Exception('Failed to load bookings');
      }
    } catch (e) {
      print('Exception occurred: $e'); // Debug print
      return [];
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'requested':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      case 'paid':
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          ),
        ],
      ),
      body: FutureBuilder<List<Bookings>>(
        future: getUserBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(child: Text('No bookings available'));
          }

          final bookings = snapshot.data!;
          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final myBookings = bookings[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: vanillaShade,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Booking ID: ${myBookings.id}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  MyTheme.lightTheme.textTheme.bodyLarge?.color,
                            ),
                          ),
                          Icon(
                            Icons.access_time,
                            color: getStatusColor(myBookings.status),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(
                        'Date: ${myBookings.dateOfBooking}',
                        style: TextStyle(
                          color: MyTheme.lightTheme.textTheme.bodySmall?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Time: ${myBookings.timeOfBooking}',
                        style: TextStyle(
                          color: MyTheme.lightTheme.textTheme.bodySmall?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Service: ${myBookings.serviceName}',
                        style: TextStyle(
                          color: MyTheme.lightTheme.textTheme.bodySmall?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Provider: ${myBookings.providerName}',
                        style: TextStyle(
                          color: MyTheme.lightTheme.textTheme.bodySmall?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Price: \$${myBookings.price}',
                        style: TextStyle(
                          color: MyTheme.lightTheme.textTheme.bodySmall?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          Text(
                            'Booking Status: ',
                            style: TextStyle(
                              color:
                                  MyTheme.lightTheme.textTheme.bodySmall?.color,
                            ),
                          ),
                          Text(
                            myBookings.status,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: getStatusColor(myBookings.status),
                            ),
                          ),
                          if (myBookings.status == 'paid')
                            Row(
                              children: [
                                const Icon(Icons.check_circle_outline_rounded,
                                    color: Colors.cyan),
                                const SizedBox(width: 145),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FeedbackScreen(
                                          bookingID: myBookings.id,
                                          userID: myBookings.userId,
                                          providerID: myBookings.providerId,
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text('Feedback'),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (myBookings.status == 'completed')
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PaymentScreen(
                                  bookingID: myBookings.id,
                                ),
                              ),
                            );
                          },
                          child: const Text('Make Payment'),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
