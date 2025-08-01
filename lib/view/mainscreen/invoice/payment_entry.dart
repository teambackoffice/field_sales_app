import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:location_tracker_app/controller/customer_list_controller.dart';
import 'package:location_tracker_app/controller/payment_entry_controller.dart';
import 'package:location_tracker_app/modal/customer_list_modal.dart';
import 'package:location_tracker_app/modal/payment_entry_modal.dart';
import 'package:provider/provider.dart';

class PaymentEntryPage extends StatefulWidget {
  const PaymentEntryPage({super.key});

  @override
  _PaymentEntryPageState createState() => _PaymentEntryPageState();
}

class _PaymentEntryPageState extends State<PaymentEntryPage> {
  MessageElement? selectedCustomer;
  PaymentEntryModal? paymentEntryData;
  TextEditingController paymentController = TextEditingController();
  Map<String, TextEditingController> invoiceControllers = {};
  Map<String, double> invoiceAllocations = {};
  double totalAllocated = 0.0;
  double advanceAmount = 0.0;
  bool isLoadingPaymentData = false;

  @override
  void initState() {
    super.initState();
    paymentController.addListener(_calculateTotals);

    // Fetch customer list on page load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GetCustomerListController>(
        context,
        listen: false,
      ).fetchCustomerList();
    });
  }

  @override
  void dispose() {
    paymentController.dispose();
    for (var controller in invoiceControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onCustomerSelected(MessageElement? customer) async {
    if (customer == null) return;

    setState(() {
      selectedCustomer = customer;
      paymentController.clear();
      invoiceAllocations.clear();
      isLoadingPaymentData = true;
      paymentEntryData = null;

      // Clear existing controllers
      for (var controller in invoiceControllers.values) {
        controller.dispose();
      }
      invoiceControllers.clear();

      totalAllocated = 0.0;
      advanceAmount = 0.0;
    });

    try {
      // Fetch payment entry data for selected customer
      final paymentController = Provider.of<PaymentEntryController>(
        context,
        listen: false,
      );

      await paymentController.fetchPaymentEntry(customer: customer.name);

      setState(() {
        paymentEntryData = paymentController.paymentEntry;
        isLoadingPaymentData = false;

        // Initialize controllers for invoices
        if (paymentEntryData?.message.invoices != null) {
          for (var invoice in paymentEntryData!.message.invoices) {
            var controller = TextEditingController();
            controller.addListener(
              () => _onInvoiceAllocationChanged(invoice.invoiceName),
            );
            invoiceControllers[invoice.invoiceName] = controller;
          }
        }
      });
    } catch (e) {
      setState(() {
        isLoadingPaymentData = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load customer invoices: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onInvoiceAllocationChanged(String invoiceId) {
    final controller = invoiceControllers[invoiceId];
    if (controller != null && paymentEntryData != null) {
      final value = double.tryParse(controller.text) ?? 0.0;
      final invoice = paymentEntryData!.message.invoices.firstWhere(
        (inv) => inv.invoiceName == invoiceId,
      );
      final paymentAmount = double.tryParse(paymentController.text) ?? 0.0;

      final maxAllocation = [
        invoice.outstandingAmount.toDouble(),
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
      paymentEntryData = null;
      paymentController.clear();
      invoiceAllocations.clear();

      for (var controller in invoiceControllers.values) {
        controller.dispose();
      }
      invoiceControllers.clear();

      totalAllocated = 0.0;
      advanceAmount = 0.0;
      isLoadingPaymentData = false;
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
                    invoice.invoiceName,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Date: ${_formatDate(invoice.postingDate)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    'Due: ${_formatDate(invoice.dueDate)}',
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
                    _formatCurrency(invoice.outstandingAmount.toDouble()),
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
                _formatCurrency(invoice.grandTotal.toDouble()),
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
                  controller: invoiceControllers[invoice.invoiceName],
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
          // Show invoice items
          if (invoice.items.isNotEmpty) ...[
            SizedBox(height: 12),
            ExpansionTile(
              title: Text(
                'Items (${invoice.items.length})',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              children: invoice.items
                  .map(
                    (item) => Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${item.itemName} (${item.itemCode})',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          Text(
                            '${item.qty} x ₹${item.rate} = ₹${item.amount}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCustomerDetailsCard() {
    if (selectedCustomer == null) return SizedBox.shrink();

    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              selectedCustomer!.customerName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            SizedBox(height: 8),

            // Customer basic info
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customer Type:',
                        style: TextStyle(color: Colors.blue[600], fontSize: 12),
                      ),
                      Text(
                        selectedCustomer!.customerType,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue[800],
                        ),
                      ),
                    ],
                  ),
                ),
                if (selectedCustomer!.mobileNo != null &&
                    selectedCustomer!.mobileNo!.isNotEmpty)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mobile:',
                          style: TextStyle(
                            color: Colors.blue[600],
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          selectedCustomer!.mobileNo!,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue[800],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            SizedBox(height: 8),

            // Additional customer info
            if (selectedCustomer!.emailId != null &&
                selectedCustomer!.emailId!.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.email, size: 16, color: Colors.blue[600]),
                  SizedBox(width: 4),
                  Text(
                    selectedCustomer!.emailId!,
                    style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                  ),
                ],
              ),
            ],

            if (selectedCustomer!.gstin != null &&
                selectedCustomer!.gstin!.isNotEmpty) ...[
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.receipt_long, size: 16, color: Colors.blue[600]),
                  SizedBox(width: 4),
                  Text(
                    'GSTIN: ${selectedCustomer!.gstin!}',
                    style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                  ),
                ],
              ),
            ],

            SizedBox(height: 12),

            // Payment entry data summary
            if (paymentEntryData != null) ...[
              Divider(),
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
                            paymentEntryData!.message.totalOutstandingAmount
                                .toDouble(),
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
                          '${paymentEntryData!.message.invoiceCount}',
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

            if (isLoadingPaymentData) ...[
              SizedBox(height: 8),
              Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Loading customer invoices...',
                    style: TextStyle(color: Colors.blue[600]),
                  ),
                ],
              ),
            ],
          ],
        ),
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
        backgroundColor: Color(0xFF764BA2),
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
                    Consumer<GetCustomerListController>(
                      builder: (context, controller, child) {
                        if (controller.isLoading) {
                          return Container(
                            height: 56,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text('Loading customers...'),
                                ],
                              ),
                            ),
                          );
                        }

                        if (controller.error != null) {
                          return Container(
                            height: 56,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.red[300]!),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Error: ${controller.error}',
                                      style: TextStyle(color: Colors.red),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        if (controller.customerlist?.message.message == null ||
                            controller.customerlist!.message.message.isEmpty) {
                          return Container(
                            height: 56,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: Text(
                                'No customers found',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                          );
                        }

                        return DropdownButtonFormField<MessageElement>(
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
                          items: controller.customerlist!.message.message.map((
                            customer,
                          ) {
                            return DropdownMenuItem<MessageElement>(
                              value: customer,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    customer.customerName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (customer.mobileNo != null &&
                                      customer.mobileNo!.isNotEmpty)
                                    Text(
                                      customer.mobileNo!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            if (selectedCustomer != null) ...[
              SizedBox(height: 16),

              // Customer Summary with enhanced details
              _buildCustomerDetailsCard(),

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
                              enabled:
                                  paymentEntryData != null &&
                                  !isLoadingPaymentData,
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
              if (paymentEntryData != null && !isLoadingPaymentData) ...[
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
                        ...paymentEntryData!.message.invoices.map(
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
                                            'Total Allocated',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            _formatCurrency(totalAllocated),
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
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
              ],

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
                                  0 ||
                              isLoadingPaymentData ||
                              paymentEntryData == null
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
