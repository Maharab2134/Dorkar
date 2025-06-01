import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dorkar/constants/my_colors.dart';
import 'package:dorkar/models/data_models.dart';
import 'package:dorkar/user/feedback.dart';
import 'package:dorkar/user/payment_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../constants/my_theme.dart';
import '../constants/animations.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  SharedPreferences? prefObj;
  String ip = '';
  String userid = '';
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
    loadDetails();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              softBlue,
              darkBlue,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: vanilla.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: vanilla,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'My Bookings',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: vanilla,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Bookings>>(
                  future: getUserBookings(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: vanilla,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(color: vanilla),
                        ),
                      );
                    } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                      return Center(
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.event_busy_rounded,
                                size: 64,
                                color: vanilla.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No bookings available',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: vanilla.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final bookings = snapshot.data!;
                    return ListView.builder(
                      padding: const EdgeInsets.all(24),
                      itemCount: bookings.length,
                      itemBuilder: (context, index) {
                        final myBookings = bookings[index];
                        return SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: darkBlue,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: vanilla.withOpacity(0.1),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Booking #${myBookings.id}',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: vanilla,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: getStatusColor(
                                                    myBookings.status)
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                              color: getStatusColor(
                                                  myBookings.status),
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            myBookings.status.toUpperCase(),
                                            style: TextStyle(
                                              color: getStatusColor(
                                                  myBookings.status),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    _buildInfoRow(
                                      Icons.calendar_today_rounded,
                                      '${myBookings.dateOfBooking} at ${myBookings.timeOfBooking}',
                                    ),
                                    const SizedBox(height: 12),
                                    _buildInfoRow(
                                      Icons.work_rounded,
                                      myBookings.serviceName,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildInfoRow(
                                      Icons.person_rounded,
                                      myBookings.providerName,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildInfoRow(
                                      Icons.attach_money_rounded,
                                      '\$${myBookings.price}',
                                    ),
                                    const SizedBox(height: 16),
                                    if (myBookings.status == 'completed')
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    PaymentScreen(
                                                  bookingID: myBookings.id,
                                                ),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: vanilla,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Text(
                                            'Make Payment',
                                            style: TextStyle(
                                              color: darkBlue,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (myBookings.status == 'paid')
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        FeedbackScreen(
                                                      bookingID: myBookings.id,
                                                      userID: myBookings.userId,
                                                      providerID:
                                                          myBookings.providerId,
                                                    ),
                                                  ),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: vanilla,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 12),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: const Text(
                                                'Give Feedback',
                                                style: TextStyle(
                                                  color: darkBlue,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: vanilla.withOpacity(0.8),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: vanilla.withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }
}
