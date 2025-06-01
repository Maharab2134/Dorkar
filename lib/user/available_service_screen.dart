import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../utils/ip_manager.dart';

class AvailableServiceScreen extends StatefulWidget {
  const AvailableServiceScreen({super.key});

  @override
  State<AvailableServiceScreen> createState() => _AvailableServiceScreenState();
}

class _AvailableServiceScreenState extends State<AvailableServiceScreen> {
  @override
  void initState() {
    super.initState();
    loadPref();
  }

  String ip = '';
  String userID = '';
  bool _isLoading = false;
  List<Map<String, dynamic>> _services = [];

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
      final response = await http.get(Uri.parse('http://$ip/dorkar/getservices.php'));
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
          // If response is a Map, check if it has a 'bookings' key
          if (responseData.containsKey('bookings')) {
            bookings = responseData['bookings'] as List<dynamic>;
          } else {
            // If no 'bookings' key, treat the entire response as a single booking
            bookings = [responseData];
          }
        } else if (responseData is List) {
          bookings = responseData;
        } else {
          print('Unexpected response format: $responseData');
          return false;
        }
        
        // Check for any active bookings with more detailed status checks
        bool hasActiveBooking = bookings.any((booking) {
          if (booking is! Map) return false;
          String status = (booking['status'] ?? '').toString().toLowerCase();
          // Match the filter categories from provider's booking screen
          return status == 'pending' || 
                 status == 'confirmed' || 
                 status == 'completed';
        });

        if (hasActiveBooking) {
          // Get the active booking details for better user feedback
          final activeBooking = bookings.firstWhere((booking) {
            if (booking is! Map) return false;
            String status = (booking['status'] ?? '').toString().toLowerCase();
            return status == 'pending' || 
                   status == 'confirmed' || 
                   status == 'completed';
          });

          showMessage(
            'You already have an active booking (ID: ${activeBooking['id']}) with status: ${activeBooking['status']}. '
            'Please complete or cancel it before booking a new service.',
            isError: true
          );
        }
        
        return hasActiveBooking;
      }
      return false;
    } catch (e) {
      print('Error checking existing bookings: $e');
      showMessage('Error checking existing bookings. Please try again.', isError: true);
      return true; // Return true to prevent booking in case of error
    }
  }

  Future<void> bookService(Map<String, dynamic> service) async {
    if (_isLoading) {
      showMessage('Please wait while we process your request...', isError: true);
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
    final bookingTime = '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}:00';

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
        showMessage(jsonResponse['error'] ?? 'Failed to book service', isError: true);
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
      appBar: AppBar(
        title: const Text('Available Services'),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _services.isEmpty
              ? const Center(child: Text('No services available'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _services.length,
                  itemBuilder: (context, index) {
                    final service = _services[index];
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service['name'] ?? '',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(service['description'] ?? ''),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Provider: ${service['provider_name'] ?? 'N/A'}',
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  '\$${service['price'] ?? '0'}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Duration: ${service['duration'] ?? '0'} mins'),
                                ElevatedButton(
                                  onPressed: () => bookService(service),
                                  child: const Text('Book Now'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
