import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class PaymentEntryPage extends StatefulWidget {
  const PaymentEntryPage({super.key});

  @override
  _PaymentEntryPageState createState() => _PaymentEntryPageState();
}

class _PaymentEntryPageState extends State<PaymentEntryPage> {
  Customer? selectedCustomer;
  TextEditingController paymentController = TextEditingController();
  Map<String, TextEditingController> invoiceControllers = {};
  Map<String, double> invoiceAllocations = {};
  double totalAllocated = 0.0;
  double advanceAmount = 0.0;

  // Mock customer data
  List<Customer> customers = [
    Customer(
      id: 1,
      name: "ABC Corporation",
      totalOutstanding: 150000.0,
      invoices: [
        Invoice(
          id: "INV-001",
          date: DateTime(2024, 6, 15),
          amount: 50000.0,
          outstanding: 50000.0,
        ),
        Invoice(
          id: "INV-002",
          date: DateTime(2024, 6, 20),
          amount: 75000.0,
          outstanding: 75000.0,
        ),
        Invoice(
          id: "INV-003",
          date: DateTime(2024, 7, 1),
          amount: 25000.0,
          outstanding: 25000.0,
        ),
      ],
    ),
    Customer(
      id: 2,
      name: "XYZ Industries",
      totalOutstanding: 87500.0,
      invoices: [
        Invoice(
          id: "INV-004",
          date: DateTime(2024, 6, 10),
          amount: 37500.0,
          outstanding: 37500.0,
        ),
        Invoice(
          id: "INV-005",
          date: DateTime(2024, 6, 25),
          amount: 50000.0,
          outstanding: 50000.0,
        ),
      ],
    ),
    Customer(
      id: 3,
      name: "Tech Solutions Ltd",
      totalOutstanding: 123000.0,
      invoices: [
        Invoice(
          id: "INV-006",
          date: DateTime(2024, 5, 30),
          amount: 43000.0,
          outstanding: 43000.0,
        ),
        Invoice(
          id: "INV-007",
          date: DateTime(2024, 6, 15),
          amount: 80000.0,
          outstanding: 80000.0,
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    paymentController.addListener(_calculateTotals);
  }

  @override
  void dispose() {
    paymentController.dispose();
    for (var controller in invoiceControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onCustomerSelected(Customer? customer) {
    setState(() {
      selectedCustomer = customer;
      paymentController.clear();
      invoiceAllocations.clear();

      for (var controller in invoiceControllers.values) {
        controller.dispose();
      }
      invoiceControllers.clear();

      if (customer != null) {
        for (var invoice in customer.invoices) {
          var controller = TextEditingController();
          controller.addListener(() => _onInvoiceAllocationChanged(invoice.id));
          invoiceControllers[invoice.id] = controller;
        }
      }

      totalAllocated = 0.0;
      advanceAmount = 0.0;
    });
  }

  void _onInvoiceAllocationChanged(String invoiceId) {
    final controller = invoiceControllers[invoiceId];
    if (controller != null) {
      final value = double.tryParse(controller.text) ?? 0.0;
      final invoice = selectedCustomer!.invoices.firstWhere(
        (inv) => inv.id == invoiceId,
      );
      final paymentAmount = double.tryParse(paymentController.text) ?? 0.0;

      final maxAllocation = [
        invoice.outstanding,
        paymentAmount,
      ].reduce((a, b) => a < b ? a : b);
      final finalAmount = value > maxAllocation ? maxAllocation : value;

      if (finalAmount != value && finalAmount > 0) {
        controller.text = finalAmount.toStringAsFixed(2);
      }

      setState(() {
        invoiceAllocations[invoiceId] = finalAmount;
      });
    }
    _calculateTotals();
  }

  void _calculateTotals() {
    setState(() {
      totalAllocated = invoiceAllocations.values.fold(
        0.0,
        (sum, amount) => sum + amount,
      );
      final paymentAmount = double.tryParse(paymentController.text) ?? 0.0;
      advanceAmount = paymentAmount > totalAllocated
          ? paymentAmount - totalAllocated
          : 0.0;
    });
  }

  void _clearAll() {
    setState(() {
      selectedCustomer = null;
      paymentController.clear();
      invoiceAllocations.clear();

      for (var controller in invoiceControllers.values) {
        controller.dispose();
      }
      invoiceControllers.clear();

      totalAllocated = 0.0;
      advanceAmount = 0.0;
    });
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'hi_IN',
      symbol: '₹',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  Widget _buildInvoiceCard(Invoice invoice) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invoice.id,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Date: ${_formatDate(invoice.date)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Outstanding',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _formatCurrency(invoice.outstanding),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Total Amount: ',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              Text(
                _formatCurrency(invoice.amount),
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Payment Allocation: ',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: invoiceControllers[invoice.id],
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: InputDecoration(
                    hintText: '0.00',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    prefixText: '₹ ',
                  ),
                  enabled: paymentController.text.isNotEmpty,
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.payment),
            SizedBox(width: 8),
            Text('Payment Entry'),
          ],
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Selection
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Select Customer',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    DropdownButtonFormField<Customer>(
                      value: selectedCustomer,
                      hint: Text('Choose a customer...'),
                      isExpanded: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onChanged: _onCustomerSelected,
                      items: customers.map((customer) {
                        return DropdownMenuItem<Customer>(
                          value: customer,
                          child: Text(customer.name),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            if (selectedCustomer != null) ...[
              SizedBox(height: 16),

              // Customer Summary
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedCustomer!.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Outstanding:',
                                  style: TextStyle(color: Colors.blue[600]),
                                ),
                                Text(
                                  _formatCurrency(
                                    selectedCustomer!.totalOutstanding,
                                  ),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[800],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Invoices:',
                                  style: TextStyle(color: Colors.blue[600]),
                                ),
                                Text(
                                  '${selectedCustomer!.invoices.length}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[800],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Payment Amount Entry
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.currency_rupee, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            'Payment Amount',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: paymentController,
                              keyboardType: TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d*'),
                                ),
                              ],
                              decoration: InputDecoration(
                                hintText: 'Enter payment amount',
                                border: OutlineInputBorder(),
                                prefixText: '₹ ',
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Invoice List
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.receipt, color: Colors.orange),
                          SizedBox(width: 8),
                          Text(
                            'Outstanding Invoices',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      ...selectedCustomer!.invoices.map(
                        (invoice) => _buildInvoiceCard(invoice),
                      ),

                      // Payment Summary
                      Card(
                        color: Colors.grey[50],
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Payment Summary',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Text(
                                          'Advance Amount',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          _formatCurrency(advanceAmount),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: advanceAmount > 0
                                                ? Colors.green
                                                : Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (advanceAmount > 0) ...[
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info,
                                      size: 16,
                                      color: Colors.green,
                                    ),
                                    SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Extra payment of ${_formatCurrency(advanceAmount)} will be treated as advance.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.green[800],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clearAll,
                      child: Text('Clear All'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          paymentController.text.isEmpty ||
                              (double.tryParse(paymentController.text) ??
                                      0.0) <=
                                  0
                          ? null
                          : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Payment processed successfully!',
                                  ),
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Process Payment'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Data Models
class Customer {
  final int id;
  final String name;
  final double totalOutstanding;
  final List<Invoice> invoices;

  Customer({
    required this.id,
    required this.name,
    required this.totalOutstanding,
    required this.invoices,
  });
}

class Invoice {
  final String id;
  final DateTime date;
  final double amount;
  final double outstanding;

  Invoice({
    required this.id,
    required this.date,
    required this.amount,
    required this.outstanding,
  });
}

// Simple app to run the payment entry
class PaymentApp extends StatelessWidget {
  const PaymentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Payment Entry',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: PaymentEntryPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
