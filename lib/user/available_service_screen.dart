import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AvailableServiceScreen extends StatefulWidget {
  const AvailableServiceScreen({super.key});

  @override
  State<AvailableServiceScreen> createState() => _AvailableServiceScreenState();
}

class _AvailableServiceScreenState extends State<AvailableServiceScreen> {
  SharedPreferences? _prefObj;
  String _ip = '';
  String _userId = '';
  bool isLoading = true;
  List<Map<String, dynamic>> _services = [];

  @override
  void initState() {
    super.initState();
    _loadPreferencesAndFetchServices();
  }

  Future<void> _loadPreferencesAndFetchServices() async {
    try {
      _prefObj = await SharedPreferences.getInstance();
      _ip = _prefObj?.getString('ip') ?? '';
      _userId = _prefObj?.getString('userid') ?? '';

      if (_ip.isEmpty || _userId.isEmpty) {
        showMessage('Missing configuration data', isError: true);
        setState(() => isLoading = false);
        return;
      }

      await fetchServices();
    } catch (e) {
      showMessage('Error loading preferences: $e', isError: true);
    }
  }

  Future<void> fetchServices() async {
    setState(() => isLoading = true);

    try {
      final response = await http.get(Uri.parse('http://$_ip/dorkar/getservices.php'));
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
      setState(() => isLoading = false);
    }
  }

  Future<void> bookService(Map<String, dynamic> service) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (selectedDate == null) return;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime == null) return;

    final bookingDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    final bookingTime = '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}:00';

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://$_ip/dorkar/bookservice.php'),
        body: {
          'service_id': service['id'].toString(),
          'user_id': _userId,
          'booking_date': bookingDate,
          'booking_time': bookingTime,
        },
      );

      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['message'] == 'success') {
        showMessage('Service booked successfully');
      } else {
        showMessage(jsonResponse['error'] ?? 'Failed to book service', isError: true);
      }
    } catch (e) {
      showMessage('Booking error: $e', isError: true);
    } finally {
      setState(() => isLoading = false);
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
      body: isLoading
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
