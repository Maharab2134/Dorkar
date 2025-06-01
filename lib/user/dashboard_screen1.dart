import 'package:flutter/material.dart';
import 'package:dorkar/select_user.dart';
import 'package:dorkar/user/my_bookings_screen.dart';
import 'package:dorkar/user/available_service_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dorkar/widgets/dashboardcard.dart';
import 'profile_screen1.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/ip_manager.dart';
import '../constants/my_colors.dart';
import '../widgets/gradient_background.dart';

class DashboardScreen1 extends StatefulWidget {
  const DashboardScreen1({super.key});

  @override
  State<DashboardScreen1> createState() => _DashboardScreen1State();
}

class _DashboardScreen1State extends State<DashboardScreen1> with SingleTickerProviderStateMixin {
  String ip = '';
  String username = '';
  String id = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isLoading = false;
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;

  final List<Map<String, dynamic>> _features = [
    {
      'title': 'Quick Booking',
      'description': 'Book services with just a few taps',
      'icon': Icons.rocket_launch_rounded,
      'color': Colors.orange,
    },
    {
      'title': 'Real-time Updates',
      'description': 'Track your service status live',
      'icon': Icons.update_rounded,
      'color': Colors.green,
    },
    {
      'title': 'Secure Payments',
      'description': 'Safe and easy payment options',
      'icon': Icons.security_rounded,
      'color': Colors.blue,
    },
  ];

  @override
  void initState() {
    super.initState();
    loadPref();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animationController.forward();
  }

  Future<void> loadPref() async {
    ip = await IPManager.getIP();
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      id = prefs.getString('userid') ?? 'No user ID';
      username = prefs.getString('username') ?? 'No user name';
    });
  }

  void logOut(BuildContext context) async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SelectUserScreen()),
      (route) => false,
    );
    print('$username(general user) log out');
    print('-----------------------------------------------');
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        isAppBar: true,
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(25, 40, 25, 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: vanilla,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    username,
                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      color: vanilla,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: vanilla.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.person_outline_rounded, color: vanilla, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      'General User',
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: vanilla,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Text(
                            'Here\'s your dashboard to manage services',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: vanilla,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        height: 180,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: _features.length,
                          onPageChanged: (index) {
                            setState(() => _currentPage = index);
                          },
                          itemBuilder: (context, index) {
                            final feature = _features[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              child: Card(
                                elevation: 8,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        feature['color'].withOpacity(0.8),
                                        feature['color'],
                                      ],
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          feature['icon'],
                                          size: 40,
                                          color: vanilla,
                                        ),
                                        const Spacer(),
                                        Text(
                                          feature['title'],
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: vanilla,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          feature['description'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: vanilla.withOpacity(0.8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _features.length,
                            (index) => Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentPage == index
                                    ? vanilla
                                    : vanilla.withOpacity(0.3),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                    childAspectRatio: 1.2,
                  ),
                  delegate: SliverChildListDelegate([
                    _buildAnimatedCard(
                      icon: Icons.person_rounded,
                      title: 'My Profile',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProfileScreen1()),
                      ),
                      delay: 0,
                    ),
                    _buildAnimatedCard(
                      icon: Icons.view_list_rounded,
                      title: 'Available Services',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AvailableServiceScreen()),
                      ),
                      delay: 1,
                    ),
                    _buildAnimatedCard(
                      icon: Icons.book,
                      title: 'My Bookings',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MyBookingsScreen()),
                      ),
                      delay: 2,
                    ),
                    _buildAnimatedCard(
                      icon: Icons.logout_rounded,
                      title: 'Logout',
                      onTap: () => logOut(context),
                      delay: 3,
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required int delay,
  }) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + (delay * 100)),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: DashboardCard(
            icon: icon,
            title: title,
            onTapping: onTap,
          ),
        );
      },
    );
  }
}