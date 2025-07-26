import 'package:flutter/material.dart';
import 'package:location_tracker_app/view/mainscreen/invoice/payment_page.dart';

class InvoicePage extends StatefulWidget {
  @override
  _InvoicePageState createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  final List<Invoice> _invoices = [
    Invoice('INV-001', 'Website Development', 1500.00, false),
    Invoice('INV-002', 'Mobile App Design', 2500.00, true),
    Invoice('INV-003', 'SEO Services', 800.00, false),
    Invoice('INV-004', 'Content Writing', 450.00, false),
    Invoice('INV-005', 'Logo Design', 300.00, true),
  ];

  void _makePayment(Invoice invoice) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          invoice: invoice,
          onPaymentSuccess: () {
            setState(() {
              invoice.isPaid = true;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount = _invoices.fold(0.0, (sum, invoice) => sum + invoice.amount);
    final paidCount = _invoices.where((i) => i.isPaid).length;

    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('Invoices', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Summary Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF667EEA).withOpacity(0.3),
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Revenue',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '\$${totalAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      _buildQuickStat('Paid', '$paidCount', Colors.white),
                      SizedBox(width: 24),
                      _buildQuickStat('Pending', '${_invoices.length - paidCount}', Colors.white70),
                    ],
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // Invoice List
            Expanded(
              child: ListView.builder(
                itemCount: _invoices.length,
                itemBuilder: (context, index) {
                  final invoice = _invoices[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(20),
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: invoice.isPaid ? Color(0xFF10B981).withOpacity(0.1) : Color(0xFFF59E0B).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          invoice.isPaid ? Icons.check_circle_rounded : Icons.schedule_rounded,
                          color: invoice.isPaid ? Color(0xFF10B981) : Color(0xFFF59E0B),
                          size: 28,
                        ),
                      ),
                      title: Text(
                        invoice.number,
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4),
                          Text(
                            invoice.description,
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '\$${invoice.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF059669),
                            ),
                          ),
                        ],
                      ),
                      trailing: invoice.isPaid
                          ? Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Color(0xFF10B981).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'PAID',
                                style: TextStyle(
                                  color: Color(0xFF10B981),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: () => _makePayment(invoice),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF667EEA),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                              child: Text('Pay Now', style: TextStyle(fontWeight: FontWeight.w600)),
                            ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: color.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
// Remove Invoice class from here; now imported from invoice_model.dart Invoice(this.number, this.description, this.amount, this.isPaid);
}
