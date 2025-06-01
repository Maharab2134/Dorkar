import 'package:flutter/material.dart';
import '../utils/ip_manager.dart';

class IPSetupScreen extends StatefulWidget {
  const IPSetupScreen({super.key});

  @override
  State<IPSetupScreen> createState() => _IPSetupScreenState();
}

class _IPSetupScreenState extends State<IPSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ipController = TextEditingController();
  bool _isLoading = false;

  Future<void> _saveIP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await IPManager.saveIP(_ipController.text);
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving IP: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Server Setup'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Enter Server IP Address',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _ipController,
                decoration: const InputDecoration(
                  labelText: 'IP Address',
                  hintText: 'e.g., 192.168.1.100',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter IP address';
                  }
                  // Basic IP validation
                  final ipRegex = RegExp(
                    r'^(\d{1,3}\.){3}\d{1,3}$',
                  );
                  if (!ipRegex.hasMatch(value)) {
                    return 'Please enter a valid IP address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveIP,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Save IP Address'),
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
    _ipController.dispose();
    super.dispose();
  }
} 