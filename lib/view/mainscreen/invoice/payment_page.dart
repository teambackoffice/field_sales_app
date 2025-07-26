import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  final Invoice invoice;
  final VoidCallback onPaymentSuccess;

  PaymentPage({required this.invoice, required this.onPaymentSuccess});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String _selectedMethod = 'card'; // card or cash
  final _cardController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isProcessing = false;

  void _processPayment() async {
    setState(() => _isProcessing = true);

    await Future.delayed(Duration(seconds: 2)); // simulate payment

    setState(() => _isProcessing = false);

    widget.onPaymentSuccess();
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment successful! ✓'),
        backgroundColor: Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('Payment', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Invoice Summary
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Invoice Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(widget.invoice.number, style: TextStyle(color: Colors.grey[600])),
                      Text(
                        '${widget.invoice.amount.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(widget.invoice.description, style: TextStyle(fontSize: 16)),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Payment Methods
            Text('Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildPaymentMethod('card', 'Card', Icons.credit_card)),
                SizedBox(width: 12),
                Expanded(child: _buildPaymentMethod('cash', 'Cash', Icons.money)),
              ],
            ),

            SizedBox(height: 24),

            // Payment Form (only for card)
            

            SizedBox(height: 32),

            // Pay Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF667EEA),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isProcessing
                    ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    : Text(
                        'Pay ${widget.invoice.amount.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod(String method, String title, IconData icon) {
    bool isSelected = _selectedMethod == method;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = method),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF667EEA).withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Color(0xFF667EEA) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Color(0xFF667EEA) : Colors.grey[600], size: 28),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Color(0xFF667EEA) : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  
  Widget _buildTextField(TextEditingController controller, String label, IconData icon, [String? hint]) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF667EEA)),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  @override
  void dispose() {
    _cardController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}

class Invoice {
  final String number;
  final String description;
  final double amount;
  bool isPaid;

  Invoice(this.number, this.description, this.amount, this.isPaid);
}
