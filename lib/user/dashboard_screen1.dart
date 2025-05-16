import 'package:flutter/material.dart';
import 'package:dorkar/select_user.dart';
import 'package:dorkar/user/my_bookings_screen.dart';
import 'package:dorkar/user/available_service_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dorkar/widgets/dashboardcard.dart';
import 'profile_screen1.dart';

class DashboardScreen1 extends StatefulWidget {
  const DashboardScreen1({super.key});

  @override
  State<DashboardScreen1> createState() => _DashboardScreen1State();
}

class _DashboardScreen1State extends State<DashboardScreen1> with SingleTickerProviderStateMixin {
  SharedPreferences? prefObj;
  String ip = '';
  String username = '';
  String id = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _loadPref();
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

  Future<void> _loadPref() async {
    prefObj = await SharedPreferences.getInstance();
    setState(() {
      ip = prefObj?.getString('ip') ?? 'No IP Address';
      id = prefObj?.getString('userid') ?? 'No user ID';
      username = prefObj?.getString('username') ?? 'No user name';
    });
  }

  void logOut(BuildContext context) async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => SelectUserScreen()),
      (route) => false,
    );
    print('$username(general user) log out');
    print('-----------------------------------------------');
  }

  @override
  void dispose() {
    _animationController.dispose();
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
              Colors.blue.shade900,
              Colors.blue.shade500,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(25, 0, 25, 25),
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
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              username,
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'General User',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
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
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        children: [
                          _buildAnimatedCard(
                            icon: Icons.person_rounded,
                            title: 'My Profile',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ProfileScreen1()),
                            ),
                            delay: 0,
                          ),
                          _buildAnimatedCard(
                            icon: Icons.view_list_rounded,
                            title: 'Available Services',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AvailableServiceScreen()),
                            ),
                            delay: 1,
                          ),
                          _buildAnimatedCard(
                            icon: Icons.book,
                            title: 'My Bookings',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => MyBookingsScreen()),
                            ),
                            delay: 2,
                          ),
                          _buildAnimatedCard(
                            icon: Icons.logout_rounded,
                            title: 'Logout',
                            onTap: () => logOut(context),
                            delay: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
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