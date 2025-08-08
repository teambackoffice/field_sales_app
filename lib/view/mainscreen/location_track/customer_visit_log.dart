import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:location_tracker_app/controller/customer_log_visit_controller.dart';
import 'package:provider/provider.dart';

class CustomerVisitLogger extends StatefulWidget {
  const CustomerVisitLogger({super.key});

  @override
  _CustomerVisitLoggerState createState() => _CustomerVisitLoggerState();
}

class _CustomerVisitLoggerState extends State<CustomerVisitLogger> {
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _showSuccess = false;
  bool _isSubmitting = false; // Add local loading state

  @override
  void dispose() {
    _customerNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location services are disabled");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location permissions are denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permissions are permanently denied");
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> _logVisit() async {
    // Prevent multiple submissions
    if (_isSubmitting) return;

    final controller = context.read<LogCustomerVisitController>();

    setState(() {
      _showSuccess = false;
      _isSubmitting = true; // Set loading state immediately
    });

    if (_customerNameController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty) {
      setState(() => _isSubmitting = false); // Reset loading state
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in both customer name and description'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      Position position = await _getCurrentLocation();

      String date = DateFormat('yyyy-MM-dd').format(DateTime.now());
      String time = DateFormat('HH:mm:ss').format(DateTime.now());

      await controller.logCustomerVisit(
        date: date,
        time: time,
        longitude: position.longitude,
        latitude: position.latitude,
        customerName: _customerNameController.text.trim(),
        description: _descriptionController.text.trim(),
      );

      if (controller.errorMessage == null) {
        setState(() => _showSuccess = true);
        _clearForm();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(controller.errorMessage ?? 'Failed to log visit'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isSubmitting = false); // Always reset loading state
    }
  }

  void _clearForm() {
    _customerNameController.clear();
    _descriptionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LogCustomerVisitController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_outlined,
                color: Colors.black,
                size: 28,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 80),
            const Text(
              'Field Visit Logger',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (_showSuccess)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: Colors.green,
                  child: const Row(
                    children: [
                      Icon(Icons.check, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Visit logged successfully!',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),

              // Show progress indicator when submitting
              if (_isSubmitting || controller.isLoading)
                const LinearProgressIndicator(),

              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Customer Name *'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _customerNameController,
                      hint: 'Enter customer name',
                      icon: Icons.person,
                      enabled: !_isSubmitting, // Disable when submitting
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Visit Description *'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _descriptionController,
                      hint:
                          'Describe the purpose of visit, work done, or notes...',
                      maxLines: 4,
                      enabled: !_isSubmitting, // Disable when submitting
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting
                            ? null
                            : _logVisit, // Disable when submitting
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isSubmitting
                              ? Colors.grey[400]
                              : Colors.blue[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: _isSubmitting ? 0 : 2,
                        ),
                        child: _isSubmitting
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Logging Visit...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.check, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Log Visit',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(
    text,
    style: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Colors.grey[700],
    ),
  );

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    int maxLines = 1,
    bool enabled = true, // Add enabled parameter
  }) {
    return TextField(
      controller: controller,
      enabled: enabled, // Use enabled parameter
      onChanged: (_) {
        if (_showSuccess) {
          setState(() => _showSuccess = false);
        }
      },
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: icon != null
            ? Icon(icon, color: enabled ? Colors.grey[400] : Colors.grey[300])
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        filled: !enabled,
        fillColor: enabled ? null : Colors.grey[50],
      ),
      style: TextStyle(
        fontSize: 16,
        color: enabled ? Colors.black : Colors.grey[400],
      ),
    );
  }
}
