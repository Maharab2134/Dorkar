import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/my_colors.dart';
import '../constants/animations.dart';

class BookingScreen2 extends StatefulWidget {
  const BookingScreen2({super.key});

  @override
  State<BookingScreen2> createState() => _BookingScreen2State();
}

class _BookingScreen2State extends State<BookingScreen2>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  SharedPreferences? prefObj;
  String ip = '';
  String providerId = '';
  bool isLoading = false;
  List<Map<String, dynamic>> bookings = [];
  String selectedFilter = 'All';

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
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    setState(() {
      isLoading = true;
    });

    String url = 'http://$ip/dorkar/getproviderbookings.php';
    print('Fetching bookings for provider: $providerId');
    print('Using IP: $ip');

    try {
      var response = await http.post(
        Uri.parse(url),
        body: {
          'provider_id': providerId,
        },
      );

      print('Response from server: ${response.body}');
      var jsonString = jsonDecode(response.body);
      if (jsonString['message'] == 'success') {
        setState(() {
          bookings = List<Map<String, dynamic>>.from(jsonString['bookings']);
          print('Number of bookings loaded: ${bookings.length}');
          for (var booking in bookings) {
            print('Booking ID: ${booking['id']}, Status: ${booking['status']}');
          }
          isLoading = false;
        });
      } else {
        print('Failed to load bookings: ${jsonString['message']}');
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load bookings: ${jsonString['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error fetching bookings: $e');
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

  Future<void> updateBookingStatus(String bookingId, String status) async {
    setState(() {
      isLoading = true;
    });

    String url;
    if (status == 'cancelled') {
      url = 'http://$ip/dorkar/providerrejected.php';
    } else if (status == 'completed') {
      url = 'http://$ip/dorkar/providercompleted.php';
    } else {
      url = 'http://$ip/dorkar/provideraccepted.php';
    }
    print('Updating booking $bookingId to status: $status');

    try {
      var response = await http.post(
        Uri.parse(url),
        body: {
          'id': bookingId,
        },
      );

      print('Response from server: ${response.body}');
      var jsonString = jsonDecode(response.body);
      if (jsonString['message'] == 'success') {
        print('Status update successful!');
        fetchBookings();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(status == 'cancelled'
                ? 'Booking cancelled'
                : status == 'completed'
                    ? 'Booking marked as completed'
                    : 'Booking confirmed'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        print('Status update failed: ${jsonString['error']}');
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Failed to update booking status: ${jsonString['error']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error updating status: $e');
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

  List<Map<String, dynamic>> getFilteredBookings() {
    if (selectedFilter == 'All') {
      return bookings;
    }
    var filtered = bookings
        .where((booking) => booking['status'] == selectedFilter)
        .toList();
    print('Filtered bookings count: ${filtered.length}');
    return filtered;
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
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Bookings',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: vanilla,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(
                        Icons.refresh,
                        color: vanilla,
                      ),
                      onPressed: fetchBookings,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All'),
                      _buildFilterChip('pending'),
                      _buildFilterChip('confirmed'),
                      _buildFilterChip('completed'),
                      _buildFilterChip('cancelled'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: vanilla,
                        ),
                      )
                    : getFilteredBookings().isEmpty
                        ? Center(
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: const Text(
                                'No bookings found',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: vanilla,
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(24),
                            itemCount: getFilteredBookings().length,
                            itemBuilder: (context, index) {
                              final booking = getFilteredBookings()[index];
                              return SlideTransition(
                                position: _slideAnimation,
                                child: FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: Card(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    elevation: 8,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Booking #${booking['id']}',
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: darkBlue,
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: _getStatusColor(
                                                      booking['status']),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  booking['status'],
                                                  style: const TextStyle(
                                                    color: vanilla,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          _buildInfoRow(
                                            Icons.person_outline,
                                            'Customer: ${booking['customer_name']}',
                                          ),
                                          const SizedBox(height: 8),
                                          _buildInfoRow(
                                            Icons.phone_outlined,
                                            'Phone: ${booking['customer_phone']}',
                                          ),
                                          const SizedBox(height: 8),
                                          _buildInfoRow(
                                            Icons.calendar_today,
                                            'Date: ${booking['date']}',
                                          ),
                                          const SizedBox(height: 8),
                                          _buildInfoRow(
                                            Icons.access_time,
                                            'Time: ${booking['time']}',
                                          ),
                                          const SizedBox(height: 16),
                                          if (booking['status'] == 'pending')
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      print(
                                                          'Accept button clicked for booking ${booking['id']}');
                                                      updateBookingStatus(
                                                        booking['id']
                                                            .toString(),
                                                        'confirmed',
                                                      );
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          Colors.green,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                    ),
                                                    child: const Text('Accept'),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      print(
                                                          'Cancel button clicked for booking ${booking['id']}');
                                                      updateBookingStatus(
                                                        booking['id']
                                                            .toString(),
                                                        'cancelled',
                                                      );
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          Colors.red,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                    ),
                                                    child: const Text('Cancel'),
                                                  ),
                                                ),
                                              ],
                                            )
                                          else if (booking['status'] ==
                                              'confirmed')
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      print(
                                                          'Complete button clicked for booking ${booking['id']}');
                                                      updateBookingStatus(
                                                        booking['id']
                                                            .toString(),
                                                        'completed',
                                                      );
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          Colors.green,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                    ),
                                                    child:
                                                        const Text('Complete'),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      print(
                                                          'Cancel button clicked for booking ${booking['id']}');
                                                      updateBookingStatus(
                                                        booking['id']
                                                            .toString(),
                                                        'cancelled',
                                                      );
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          Colors.red,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                    ),
                                                    child: const Text('Cancel'),
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
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        labelStyle: TextStyle(
          color: isSelected ? vanilla : darkBlue,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: vanilla,
        selectedColor: softBlue,
        onSelected: (selected) {
          setState(() {
            selectedFilter = label;
          });
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: softBlue,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: darkBlue,
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return softBlue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
} 
