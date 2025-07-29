import 'package:flutter/material.dart';
import 'package:location_tracker_app/view/mainscreen/invoice/payment_entry.dart'
    hide Invoice;
import 'package:location_tracker_app/view/mainscreen/invoice/payment_page.dart';

class InvoicePage extends StatefulWidget {
  const InvoicePage({super.key});

  @override
  _InvoicePageState createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  final List<Invoice> _invoices = [
    Invoice(
      number: 'INV-001',
      description: 'Website Development',
      amount: 1500.00,
      subtotal: 1275.00,
      tax: 225.00,
      isPaid: false,
      items: [
        InvoiceItem(
          name: 'Frontend Development',
          quantity: 1,
          unitPrice: 800.00,
          description: 'React.js UI development',
        ),
        InvoiceItem(
          name: 'Backend Development',
          quantity: 1,
          unitPrice: 475.00,
          description: 'Node.js API development',
        ),
      ],
    ),
    Invoice(
      number: 'INV-002',
      description: 'Mobile App Design',
      amount: 2500.00,
      subtotal: 2125.00,
      tax: 375.00,
      isPaid: true,
      items: [
        InvoiceItem(
          name: 'UI/UX Design',
          quantity: 1,
          unitPrice: 1200.00,
          description: 'Complete app design',
        ),
        InvoiceItem(
          name: 'Prototype Development',
          quantity: 1,
          unitPrice: 800.00,
          description: 'Interactive prototype',
        ),
        InvoiceItem(
          name: 'Design System',
          quantity: 1,
          unitPrice: 125.00,
          description: 'Component library',
        ),
      ],
    ),
    Invoice(
      number: 'INV-003',
      description: 'SEO Services',
      amount: 800.00,
      subtotal: 680.00,
      tax: 120.00,
      isPaid: false,
      items: [
        InvoiceItem(
          name: 'Keyword Research',
          quantity: 1,
          unitPrice: 200.00,
          description: 'Comprehensive keyword analysis',
        ),
        InvoiceItem(
          name: 'On-page Optimization',
          quantity: 1,
          unitPrice: 300.00,
          description: 'Content and meta optimization',
        ),
        InvoiceItem(
          name: 'Technical Audit',
          quantity: 1,
          unitPrice: 180.00,
          description: 'Site performance analysis',
        ),
      ],
    ),
    Invoice(
      number: 'INV-004',
      description: 'Content Writing',
      amount: 450.00,
      subtotal: 382.50,
      tax: 67.50,
      isPaid: false,
      items: [
        InvoiceItem(
          name: 'Blog Posts',
          quantity: 5,
          unitPrice: 60.00,
          description: '1000-word articles',
        ),
        InvoiceItem(
          name: 'Product Descriptions',
          quantity: 10,
          unitPrice: 8.25,
          description: 'E-commerce content',
        ),
      ],
    ),
    Invoice(
      number: 'INV-005',
      description: 'Logo Design',
      amount: 300.00,
      subtotal: 255.00,
      tax: 45.00,
      isPaid: true,
      items: [
        InvoiceItem(
          name: 'Logo Design',
          quantity: 1,
          unitPrice: 200.00,
          description: 'Primary logo with variations',
        ),
        InvoiceItem(
          name: 'Brand Guidelines',
          quantity: 1,
          unitPrice: 55.00,
          description: 'Usage documentation',
        ),
      ],
    ),
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
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8F6FA), Color(0xFFEDE7F6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(20),
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
                              color: invoice.isPaid
                                  ? Color(0xFF10B981).withOpacity(0.1)
                                  : Color(0xFFF59E0B).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              invoice.isPaid
                                  ? Icons.check_circle_rounded
                                  : Icons.schedule_rounded,
                              color: invoice.isPaid
                                  ? Color(0xFF10B981)
                                  : Color(0xFFF59E0B),
                              size: 28,
                            ),
                          ),
                          title: Text(
                            invoice.number,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 4),
                              Text(
                                invoice.description,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),

                              SizedBox(height: 8),
                              Text(
                                '₹${invoice.amount.toStringAsFixed(2)}',
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
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
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
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                  ),
                                  child: Text(
                                    'Pay Now',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          // Title Row
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF764BA2), Color(0xFF667EEA)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF764BA2).withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(Icons.receipt, color: Colors.white, size: 24),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Invoices',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D3436),
                  ),
                ),
              ),
              PopupMenuButton(
                icon: Icon(Icons.filter_list, color: Colors.black),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (value) {
                  setState(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PremiumPaymentEntryPage(),
                      ),
                    );
                  });
                },
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      value: 'Payment Entry',
                      child: Text('Payment Entry'),
                    ),
                  ];
                },
              ),
            ],
          ),

          // Summary Cards
        ],
      ),
    );
  }
}
