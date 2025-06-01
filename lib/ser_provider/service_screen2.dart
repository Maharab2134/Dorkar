import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/my_colors.dart';
import '../constants/animations.dart';
import '../select_user.dart';

class ServiceScreen2 extends StatefulWidget {
  const ServiceScreen2({super.key});

  @override
  State<ServiceScreen2> createState() => _ServiceScreen2State();
}

class _ServiceScreen2State extends State<ServiceScreen2> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  SharedPreferences? prefObj;
  String ip = '';
  String providerId = '';
  bool isLoading = false;
  List<Map<String, dynamic>> services = [];
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();

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
    prefObj = await SharedPreferences.getInstance();
    setState(() {
      ip = prefObj?.getString('ip') ?? 'No IP Address';
      providerId = prefObj?.getString('providerid') ?? '';
    });
    fetchServices();
  }

  Future<void> fetchServices() async {
    setState(() {
      isLoading = true;
    });

    String url = 'http://$ip/dorkar/getproviderservices.php';

    try {
      var response = await http.post(
        Uri.parse(url),
        body: {
          'provider_id': providerId,
        },
      );

      var jsonString = jsonDecode(response.body);
      if (jsonString['message'] == 'success') {
        setState(() {
          services = List<Map<String, dynamic>>.from(jsonString['services']);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load services'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> addService() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    String url = 'http://$ip/dorkar/addservice.php';

    try {
      var response = await http.post(
        Uri.parse(url),
        body: {
          'provider_id': providerId,
          'name': _nameController.text,
          'description': _descriptionController.text,
          'price': _priceController.text,
          'duration': _durationController.text,
        },
      );

      var jsonString = jsonDecode(response.body);
      if (jsonString['message'] == 'success') {
        _nameController.clear();
        _descriptionController.clear();
        _priceController.clear();
        _durationController.clear();
        fetchServices();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Service added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add service'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> deleteService(String serviceId) async {
    setState(() {
      isLoading = true;
    });

    String url = 'http://$ip/dorkar/deleteservice.php';

    try {
      var response = await http.post(
        Uri.parse(url),
        body: {
          'service_id': serviceId,
        },
      );

      var jsonString = jsonDecode(response.body);
      if (jsonString['message'] == 'success') {
        fetchServices();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Service deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete service'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAddServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Service'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Service Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter service name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter service description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    border: OutlineInputBorder(),
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter service price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid price';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _durationController,
                  decoration: const InputDecoration(
                    labelText: 'Duration (minutes)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter service duration';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid duration';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: addService,
            style: ElevatedButton.styleFrom(
              backgroundColor: softBlue,
            ),
            child: const Text('Add Service'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
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
                      'My Services',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: vanilla,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        color: vanilla.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.refresh_rounded,
                          color: vanilla,
                        ),
                        onPressed: fetchServices,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: vanilla.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                      icon: const Icon(
                          Icons.logout_rounded,
                        color: vanilla,
                      ),
                        onPressed: () async {
                          try {
                            await prefObj?.clear();
                            if (mounted) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SelectUserScreen(),
                                ),
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
                        },
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
                    : services.isEmpty
                        ? Center(
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.work_off_rounded,
                                    size: 64,
                                    color: vanilla.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                'No services added yet',
                                style: TextStyle(
                                      fontSize: 18,
                                      color: vanilla.withOpacity(0.8),
                                    ),
                                ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(24),
                            itemCount: services.length,
                            itemBuilder: (context, index) {
                              final service = services[index];
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
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  service['name'],
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: vanilla,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.red.withOpacity(0.1),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: IconButton(
                                                icon: const Icon(
                                                    Icons.delete_outline_rounded,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () => showDialog(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(20),
                                                      ),
                                                    title: const Text('Delete Service'),
                                                    content: const Text(
                                                      'Are you sure you want to delete this service?',
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.pop(context),
                                                        child: const Text('Cancel'),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                          deleteService(service['id'].toString());
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: Colors.red,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(12),
                                                            ),
                                                        ),
                                                        child: const Text('Delete'),
                                                      ),
                                                    ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            service['description'],
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: vanilla.withOpacity(0.8),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              _buildInfoChip(
                                                Icons.attach_money_rounded,
                                                '${service['price']}',
                                              ),
                                              _buildInfoChip(
                                                Icons.access_time_rounded,
                                                '${service['duration']} min',
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
                          ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddServiceDialog,
        backgroundColor: vanilla,
        elevation: 0,
        child: const Icon(
          Icons.add_rounded,
          color: darkBlue,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: vanilla.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: vanilla.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: vanilla,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: vanilla,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
} 
