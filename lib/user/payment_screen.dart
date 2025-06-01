import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:flutter_application_7/user/feedback.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../utils/ip_manager.dart';
import '../constants/my_colors.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key, required this.bookingID});

  final String bookingID;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  @override
  void initState() {
    super.initState();
    loadPref();
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final agreedAmount = TextEditingController();
  bool isProcessing = false;

  String ip = '';
  String userID = '';
  

  String? selectedPaymentMethod;
  final List<Map<String, dynamic>> paymentMethods = [
    {
      'name': 'bKash',
      'icon': Icons.phone_android_rounded,
      'color': const Color(0xFFE2136E),
    },
    {
      'name': 'Nagad',
      'icon': Icons.phone_android_rounded,
      'color': const Color(0xFF1E88E5),
    },
    {
      'name': 'Rocket',
      'icon': Icons.phone_android_rounded,
      'color': const Color(0xFF4CAF50),
    },
    {
      'name': 'Upay',
      'icon': Icons.phone_android_rounded,
      'color': const Color(0xFF9C27B0),
    },
    {
      'name': 'Cash',
      'icon': Icons.money_rounded,
      'color': const Color(0xFF795548),
    },
  ];

  Future<void> loadPref() async {
    ip = await IPManager.getIP();
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userID = prefs.getString('userid') ?? 'No user ID';
    });
  }

  Future<void> paymentDetails(String bookingID) async {
    setState(() {
      isProcessing = true;
    });

    try {
      String url = 'http://$ip/dorkar/payment.php';

      var response = await http.post(
        Uri.parse(url),
        body: {
          'booking_id': bookingID,
          'agreed_amount': agreedAmount.text,
          'payment_method': selectedPaymentMethod,
          'payment_status': 'success',
        },
      );

      var jsonBody = jsonDecode(response.body);
      var jsonString = jsonBody['message'];

      if (jsonString == 'success') {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: darkBlue,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: vanilla.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: vanilla,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Working Now...',
                      style: TextStyle(
                        color: vanilla.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
          
          await Future.delayed(const Duration(seconds: 2));
          
          if (mounted) {
            Navigator.pop(context); // Close loading dialog
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Payment Successful'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context); // Close payment screen
            Navigator.pop(context); // Close booking screen
          }
        }
      } else {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: darkBlue,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: vanilla.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: vanilla,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Working Now...',
                      style: TextStyle(
                        color: vanilla.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
          
          await Future.delayed(const Duration(seconds: 2));
          
          if (mounted) {
            Navigator.pop(context); // Close loading dialog
            Navigator.pop(context); // Close payment screen
          }
        }
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: darkBlue,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: vanilla.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    color: vanilla,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Working Now...',
                    style: TextStyle(
                      color: vanilla.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        
        await Future.delayed(const Duration(seconds: 2));
        
        if (mounted) {
          Navigator.pop(context); // Close loading dialog
          Navigator.pop(context); // Close payment screen
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
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
                      'Payment',
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
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
                                const Text(
                                  'Amount',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: vanilla,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: agreedAmount,
                                  style: const TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                    hintText: 'Enter amount',
                                    hintStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
                                    prefixIcon: const Icon(Icons.attach_money_rounded, color: Colors.black),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: vanilla.withOpacity(0.2)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: vanilla.withOpacity(0.2)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: vanilla),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter the amount';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Select Payment Method',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: vanilla,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 2,
                          ),
                          itemCount: paymentMethods.length,
                          itemBuilder: (context, index) {
                            final method = paymentMethods[index];
                            final isSelected = selectedPaymentMethod == method['name'];
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  selectedPaymentMethod = method['name'];
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected ? method['color'].withOpacity(0.2) : darkBlue,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected ? method['color'] : vanilla.withOpacity(0.1),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      method['icon'],
                                      color: isSelected ? method['color'] : vanilla,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      method['name'],
                                      style: TextStyle(
                                        color: isSelected ? method['color'] : vanilla,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isProcessing
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate() && selectedPaymentMethod != null) {
                                      paymentDetails(widget.bookingID);
                                    } else if (selectedPaymentMethod == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Please select a payment method'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: vanilla,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: isProcessing
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: darkBlue,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Pay Now',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: darkBlue,
                                    ),
                                  ),
                          ),
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

  @override
  void dispose() {
    agreedAmount.dispose();
    super.dispose();
  }
}
