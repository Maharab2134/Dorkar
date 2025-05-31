import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/my_colors.dart';
import '../constants/animations.dart';
import 'profile_screen2.dart';
import 'booking_screen2.dart';
import 'service_screen2.dart';
import 'settings_screen2.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DashboardScreen2 extends StatefulWidget {
  const DashboardScreen2({super.key});

  @override
  State<DashboardScreen2> createState() => _DashboardScreen2State();
}

class _DashboardScreen2State extends State<DashboardScreen2> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  String providerName = '';
  String providerService = '';
  String ip = '';
  String providerId = '';
  Map<String, int> bookingStats = {
    'pending': 0,
    'completed': 0,
    'cancelled': 0,
  };
  bool isLoading = true;

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
    loadProviderData();
  }

  Future<void> loadProviderData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      providerName = prefs.getString('providername') ?? '';
      providerService = prefs.getString('providerservice') ?? '';
      ip = prefs.getString('ip') ?? '';
      providerId = prefs.getString('providerid') ?? '';
    });
    await fetchBookingStats();
  }

  Future<void> fetchBookingStats() async {
    if (ip.isEmpty || providerId.isEmpty) return;

    setState(() => isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('http://$ip/dorkar/providerbookingstats.php?pid=$providerId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Received booking stats: $data');
        
        setState(() {
          bookingStats = {
            'pending': int.tryParse(data['pending']?.toString() ?? '0') ?? 0,
            'completed': int.tryParse(data['completed']?.toString() ?? '0') ?? 0,
            'cancelled': int.tryParse(data['cancelled']?.toString() ?? '0') ?? 0,
          };
        });
        
        print('Updated booking stats: $bookingStats');
      }
    } catch (e) {
      print('Error fetching booking stats: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: TextStyle(
                                fontSize: 16,
                                color: vanilla.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              providerName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: vanilla,
                              ),
                            ),
                          ],
                        ),
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: vanilla,
                          child: IconButton(
                            icon: const Icon(
                              Icons.person_outline,
                              color: softBlue,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                SlidePageRoute(
                                  page: const ProfileScreen2(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'Service: $providerService',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: vanilla,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                vanilla,
                                vanilla.withOpacity(0.9),
                              ],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Quick Stats',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: darkBlue,
                                ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                height: 120,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    _buildStatCard(
                                      icon: Icons.pending_actions,
                                      title: 'Pending',
                                      value: isLoading ? '...' : bookingStats['pending'].toString(),
                                      color: Colors.orange,
                                    ),
                                    const SizedBox(width: 16),
                                    _buildStatCard(
                                      icon: Icons.check_circle,
                                      title: 'Completed',
                                      value: isLoading ? '...' : bookingStats['completed'].toString(),
                                      color: Colors.green,
                                    ),
                                    const SizedBox(width: 16),
                                    _buildStatCard(
                                      icon: Icons.cancel,
                                      title: 'Cancelled',
                                      value: isLoading ? '...' : bookingStats['cancelled'].toString(),
                                      color: Colors.red,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: vanilla,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        children: [
                          _buildActionCard(
                            icon: Icons.calendar_month,
                            title: 'Bookings',
                            onTap: () {
                              Navigator.push(
                                context,
                                SlidePageRoute(
                                  page: const BookingScreen2(),
                                ),
                              );
                            },
                          ),
                          _buildActionCard(
                            icon: Icons.work_outline,
                            title: 'Services',
                            onTap: () {
                              Navigator.push(
                                context,
                                SlidePageRoute(
                                  page: const ServiceScreen2(),
                                ),
                              );
                            },
                          ),
                          _buildActionCard(
                            icon: Icons.person_outline,
                            title: 'Profile',
                            onTap: () {
                              Navigator.push(
                                context,
                                SlidePageRoute(
                                  page: const ProfileScreen2(),
                                ),
                              );
                            },
                          ),
                          _buildActionCard(
                            icon: Icons.settings_outlined,
                            title: 'Settings',
                            onTap: () {
                              Navigator.push(
                                context,
                                SlidePageRoute(
                                  page: const SettingsScreen2(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: vanilla,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: darkBlue.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: softBlue,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: darkBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
