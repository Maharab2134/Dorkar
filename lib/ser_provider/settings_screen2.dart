import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/my_colors.dart';
import '../constants/animations.dart';

class SettingsScreen2 extends StatefulWidget {
  const SettingsScreen2({super.key});

  @override
  State<SettingsScreen2> createState() => _SettingsScreen2State();
}

class _SettingsScreen2State extends State<SettingsScreen2> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  SharedPreferences? prefObj;
  bool isLoading = false;
  bool isAvailable = true;
  bool notificationsEnabled = true;
  bool darkMode = false;
  String selectedLanguage = 'English';

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
    loadSettings();
  }

  Future<void> loadSettings() async {
    setState(() {
      isLoading = true;
    });

    try {
      prefObj = await SharedPreferences.getInstance();
      setState(() {
        isAvailable = prefObj?.getBool('is_available') ?? true;
        notificationsEnabled = prefObj?.getBool('notifications_enabled') ?? true;
        darkMode = prefObj?.getBool('dark_mode') ?? false;
        selectedLanguage = prefObj?.getString('language') ?? 'English';
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateAvailability(bool value) async {
    try {
      await prefObj?.setBool('is_available', value);
      setState(() {
        isAvailable = value;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(value ? 'You are now available' : 'You are now unavailable'),
            backgroundColor: value ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating availability: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> updateNotifications(bool value) async {
    try {
      await prefObj?.setBool('notifications_enabled', value);
      setState(() {
        notificationsEnabled = value;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(value ? 'Notifications enabled' : 'Notifications disabled'),
            backgroundColor: value ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating notifications: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> updateDarkMode(bool value) async {
    try {
      await prefObj?.setBool('dark_mode', value);
      setState(() {
        darkMode = value;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(value ? 'Dark mode enabled' : 'Light mode enabled'),
            backgroundColor: value ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating theme: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> updateLanguage(String value) async {
    try {
      await prefObj?.setString('language', value);
      setState(() {
        selectedLanguage = value;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Language changed to $value'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating language: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> logout() async {
    try {
      await prefObj?.clear();
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: vanilla,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: vanilla,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: vanilla,
                        ),
                      )
                    : SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: ListView(
                            padding: const EdgeInsets.all(24),
                            children: [
                              _buildSection(
                                'Availability',
                                [
                                  _buildSwitchTile(
                                    'Available for Bookings',
                                    'Toggle your availability status',
                                    isAvailable,
                                    updateAvailability,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              _buildSection(
                                'Notifications',
                                [
                                  _buildSwitchTile(
                                    'Enable Notifications',
                                    'Receive booking notifications',
                                    notificationsEnabled,
                                    updateNotifications,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              _buildSection(
                                'Appearance',
                                [
                                  _buildSwitchTile(
                                    'Dark Mode',
                                    'Enable dark theme',
                                    darkMode,
                                    updateDarkMode,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              _buildSection(
                                'Language',
                                [
                                  _buildDropdownTile(
                                    'Select Language',
                                    selectedLanguage,
                                    ['English', 'Spanish', 'French', 'German', 'Arabic'],
                                    updateLanguage,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              _buildSection(
                                'Account',
                                [
                                  _buildButtonTile(
                                    'Logout',
                                    'Sign out from your account',
                                    Icons.logout,
                                    Colors.red,
                                    logout,
                                  ),
                                ],
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
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: vanilla,
            ),
          ),
        ),
        Card(
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
                  vanilla,
                  vanilla.withOpacity(0.9),
                ],
              ),
            ),
            child: Column(
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: darkBlue,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: darkBlue.withOpacity(0.7),
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: softBlue,
      ),
    );
  }

  Widget _buildDropdownTile(
    String title,
    String value,
    List<String> items,
    Function(String) onChanged,
  ) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: darkBlue,
        ),
      ),
      trailing: DropdownButton<String>(
        value: value,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
        underline: Container(),
        icon: const Icon(
          Icons.arrow_drop_down,
          color: softBlue,
        ),
      ),
    );
  }

  Widget _buildButtonTile(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: darkBlue.withOpacity(0.7),
        ),
      ),
      trailing: Icon(
        icon,
        color: color,
      ),
      onTap: onPressed,
    );
  }
} 