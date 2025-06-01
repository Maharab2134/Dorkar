import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../utils/ip_manager.dart';
import '../constants/my_colors.dart';
import '../widgets/gradient_background.dart';

class AvailableServiceScreen extends StatefulWidget {
  const AvailableServiceScreen({super.key});

  @override
  State<AvailableServiceScreen> createState() => _AvailableServiceScreenState();
}

class _AvailableServiceScreenState extends State<AvailableServiceScreen> {
  @override
  void initState() {
    super.initState();
    loadPref().then((_) {
      fetchServices();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String ip = '';
  String userID = '';
  bool _isLoading = false;
  List<Map<String, dynamic>> _services = [];
  final PageController _pageController = PageController(viewportFraction: 0.9);

  Future<void> loadPref() async {
    ip = await IPManager.getIP();
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userID = prefs.getString('userid') ?? 'No user ID';
    });
  }

  Future<void> fetchServices() async {
    setState(() => _isLoading = true);

    try {
      final response =
          await http.get(Uri.parse('http://$ip/dorkar/getservices.php'));
      final jsonString = jsonDecode(response.body);

      if (jsonString['message'] == 'success') {
        setState(() {
          _services = List<Map<String, dynamic>>.from(jsonString['services']);
        });
      } else {
        showMessage('Failed to load services', isError: true);
      }
    } catch (e) {
      showMessage('Error fetching services: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<bool> checkExistingBookings() async {
    try {
      final response = await http.get(
        Uri.parse('http://$ip/dorkar/usermybookings.php?uid=$userID'),
      );

      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);

        // Handle empty response
        if (responseData == null || responseData.toString().isEmpty) {
          return false;
        }

        // Convert response to List if it's not already
        List<dynamic> bookings;
        if (responseData is Map) {
          if (responseData.containsKey('bookings')) {
            bookings = responseData['bookings'] as List<dynamic>;
          } else {
            bookings = [responseData];
          }
        } else if (responseData is List) {
          bookings = responseData;
        } else {
          print('Unexpected response format: $responseData');
          return false;
        }

        // Check for any active bookings
        bool hasActiveBooking = bookings.any((booking) {
          if (booking is! Map) return false;
          String status = (booking['status'] ?? '').toString().toLowerCase();
          return status == 'pending' || status == 'confirmed';
        });

        if (hasActiveBooking) {
          final activeBooking = bookings.firstWhere((booking) {
            if (booking is! Map) return false;
            String status = (booking['status'] ?? '').toString().toLowerCase();
            return status == 'pending' || status == 'confirmed';
          });

          showMessage(
              'You already have an active booking (ID: ${activeBooking['id']}) with status: ${activeBooking['status']}. '
              'Please complete or cancel it before booking a new service.',
              isError: true);
          return true;
        }

        return false;
      }
      return false;
    } catch (e) {
      print('Error checking existing bookings: $e');
      showMessage('Error checking existing bookings. Please try again.',
          isError: true);
      return true;
    }
  }

  Future<void> bookService(Map<String, dynamic> service) async {
    if (_isLoading) {
      showMessage('Please wait while we process your request...',
          isError: true);
      return;
    }

    // Check for existing bookings first
    final hasExistingBooking = await checkExistingBookings();
    if (hasExistingBooking) {
      return; // Early return if there's an existing booking
    }

    // Validate service data
    if (service['id'] == null || service['id'].toString().isEmpty) {
      showMessage('Invalid service selected', isError: true);
      return;
    }

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (selectedDate == null) return;

    // Validate selected date
    if (selectedDate.isBefore(DateTime.now())) {
      showMessage('Please select a future date', isError: true);
      return;
    }

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime == null) return;

    // Validate selected time
    final now = DateTime.now();
    final selectedDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    if (selectedDateTime.isBefore(now)) {
      showMessage('Please select a future time', isError: true);
      return;
    }

    final bookingDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    final bookingTime =
        '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}:00';

    // Check for bookings at the same time
    try {
      final response = await http.get(
        Uri.parse(
            'http://$ip/dorkar/check_booking_time.php?date=$bookingDate&time=$bookingTime&user_id=$userID'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['has_booking'] == true) {
          showMessage(
              'You already have a booking at this time. Please choose a different time.',
              isError: true);
          return;
        }
      }
    } catch (e) {
      print('Error checking booking time: $e');
      showMessage('Error checking booking time. Please try again.',
          isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://$ip/dorkar/bookservice.php'),
        body: {
          'service_id': service['id'].toString(),
          'user_id': userID,
          'booking_date': bookingDate,
          'booking_time': bookingTime,
        },
      );

      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['message'] == 'success') {
        showMessage('Service booked successfully');
        // Refresh the services list after successful booking
        await fetchServices();
      } else {
        showMessage(jsonResponse['error'] ?? 'Failed to book service',
            isError: true);
      }
    } catch (e) {
      showMessage('Booking error: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _services.isEmpty
              ? const Center(child: Text('No services available'))
              : CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 200,
                      floating: false,
                      pinned: true,
                      flexibleSpace: FlexibleSpaceBar(
                        centerTitle: true,
                        titlePadding: const EdgeInsets.only(
                            top: 48, bottom: 8, left: 16, right: 16),
                        title: Container(
                          padding: const EdgeInsets.only(
                              top: 24, bottom: 8, left: 16, right: 16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Simple Icon
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.miscellaneous_services,
                                  color: Colors.white,
                                  size: 36,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Available Services',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        background: Container(
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
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 200,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount:
                              _services.length > 3 ? 3 : _services.length,
                  itemBuilder: (context, index) {
                    final service = _services[index];
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
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
                                        softBlue.withOpacity(0.8),
                                        darkBlue,
                                      ],
                                    ),
                                  ),
                      child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                        child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              service['name'] ?? '',
                              style: const TextStyle(
                                            fontSize: 24,
                                fontWeight: FontWeight.bold,
                                            color: vanilla,
                              ),
                            ),
                            const SizedBox(height: 8),
                                        Text(
                                          service['description'] ?? '',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: vanilla.withOpacity(0.8),
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const Spacer(),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '\$${service['price'] ?? '0'}',
                                  style: const TextStyle(
                                                fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                                color: vanilla,
                                              ),
                                            ),
                                            ElevatedButton(
                                              onPressed: () =>
                                                  bookService(service),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: vanilla,
                                                foregroundColor: darkBlue,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: const Text('Book Now'),
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
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.9,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final service = _services[index];
                            return Card(
                              elevation: 4,
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
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 70,
                                        decoration: BoxDecoration(
                                          color: softBlue.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.miscellaneous_services,
                                            size: 28,
                                            color: softBlue,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        service['name'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: darkBlue,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        service['description'] ?? '',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: darkBlue.withOpacity(0.7),
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const Spacer(),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '\$${service['price'] ?? '0'}',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: softBlue,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 24,
                                            child: ElevatedButton(
                                              onPressed: () =>
                                                  bookService(service),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: softBlue,
                                                foregroundColor: vanilla,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 0,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                              ),
                                              child: const Text(
                                                'Book',
                                                style: TextStyle(fontSize: 11),
                                              ),
                                            ),
                                ),
                              ],
                            ),
                          ],
                                  ),
                        ),
                      ),
                    );
                  },
                          childCount: _services.length,
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
