import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class PremiumPaymentEntryPage extends StatefulWidget {
  const PremiumPaymentEntryPage({super.key});

  @override
  _PremiumPaymentEntryPageState createState() =>
      _PremiumPaymentEntryPageState();
}

class _PremiumPaymentEntryPageState extends State<PremiumPaymentEntryPage>
    with TickerProviderStateMixin {
  Customer? selectedCustomer;
  TextEditingController paymentController = TextEditingController();
  Map<String, TextEditingController> invoiceControllers = {};
  Map<String, double> invoiceAllocations = {};
  double totalAllocated = 0.0;
  double advanceAmount = 0.0;
  bool isProcessing = false;

  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  // Mock customer data
  List<Customer> customers = [
    Customer(
      id: 1,
      name: "ABC Corporation",
      totalOutstanding: 250000.0,
      invoices: [
        Invoice(
          id: "INV-001",
          date: DateTime(2024, 6, 15),
          amount: 80000.0,
          outstanding: 80000.0,
        ),
        Invoice(
          id: "INV-002",
          date: DateTime(2024, 6, 20),
          amount: 120000.0,
          outstanding: 120000.0,
        ),
        Invoice(
          id: "INV-003",
          date: DateTime(2024, 7, 1),
          amount: 50000.0,
          outstanding: 50000.0,
        ),
      ],
    ),
    Customer(
      id: 2,
      name: "Tech Innovations Pvt Ltd",
      totalOutstanding: 175000.0,
      invoices: [
        Invoice(
          id: "INV-004",
          date: DateTime(2024, 6, 10),
          amount: 95000.0,
          outstanding: 95000.0,
        ),
        Invoice(
          id: "INV-005",
          date: DateTime(2024, 6, 25),
          amount: 80000.0,
          outstanding: 80000.0,
        ),
      ],
    ),
    Customer(
      id: 3,
      name: "Global Systems Ltd",
      totalOutstanding: 320000.0,
      invoices: [
        Invoice(
          id: "INV-006",
          date: DateTime(2024, 5, 28),
          amount: 150000.0,
          outstanding: 150000.0,
        ),
        Invoice(
          id: "INV-007",
          date: DateTime(2024, 6, 12),
          amount: 170000.0,
          outstanding: 170000.0,
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.5), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
        );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    paymentController.addListener(_calculateTotals);
    _slideController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
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

    if (customer != null) {
      _slideController.reset();
      _slideController.forward();
    }
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

  void _autoAllocate() async {
    if (selectedCustomer == null || paymentController.text.isEmpty) return;

    HapticFeedback.mediumImpact();

    setState(() {
      isProcessing = true;
    });

    await Future.delayed(Duration(milliseconds: 500));

    double remainingAmount = double.tryParse(paymentController.text) ?? 0.0;

    for (var invoice in selectedCustomer!.invoices) {
      if (remainingAmount <= 0) break;

      final allocation = remainingAmount > invoice.outstanding
          ? invoice.outstanding
          : remainingAmount;
      if (allocation > 0) {
        invoiceControllers[invoice.id]?.text = allocation.toStringAsFixed(2);
        remainingAmount -= allocation;
      } else {
        invoiceControllers[invoice.id]?.clear();
      }
    }

    setState(() {
      isProcessing = false;
    });
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'hi_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F0F23),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    _buildGlassmorphicCard(child: _buildCustomerSelection()),

                    if (selectedCustomer != null) ...[
                      SizedBox(height: 20),
                      _buildCustomerSummaryCard(),

                      SizedBox(height: 20),
                      _buildPaymentEntryCard(),

                      if (paymentController.text.isNotEmpty) ...[
                        SizedBox(height: 20),
                        _buildPaymentSummaryCard(),
                      ],

                      SizedBox(height: 20),
                      _buildInvoiceListCard(),

                      SizedBox(height: 20),
                      _buildActionButtons(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Color(0xFF1A1A2E),
      flexibleSpace: FlexibleSpaceBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.payment, color: Colors.white, size: 20),
            ),
            SizedBox(width: 12),
            Text(
              'Payment Center',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F0F23)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassmorphicCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(padding: EdgeInsets.all(20), child: child),
        ),
      ),
    );
  }

  Widget _buildCustomerSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.person_outline, color: Colors.white, size: 20),
            ),
            SizedBox(width: 12),
            Text(
              'Select Customer',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Customer>(
              value: selectedCustomer,
              hint: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Text(
                  'Choose a customer...',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
              ),
              isExpanded: true,
              dropdownColor: Color(0xFF1A1A2E),
              onChanged: _onCustomerSelected,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white.withOpacity(0.7),
              ),
              items: customers.map((customer) {
                return DropdownMenuItem<Customer>(
                  value: customer,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Outstanding: ${_formatCurrency(customer.totalOutstanding)}',
                          style: TextStyle(color: Colors.orange, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerSummaryCard() {
    return _buildGlassmorphicCard(
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Color(0xFF667EEA),
                child: Text(
                  selectedCustomer!.name[0],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedCustomer!.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${selectedCustomer!.invoices.length} Outstanding Invoices',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF6B6B), Color(0xFFEE5A24)],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Outstanding',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                Text(
                  _formatCurrency(selectedCustomer!.totalOutstanding),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentEntryCard() {
    return _buildGlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF00C9FF), Color(0xFF92FE9D)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.currency_rupee,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Payment Amount',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: TextField(
                    controller: paymentController,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    decoration: InputDecoration(
                      hintText: 'Enter payment amount',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      prefixText: '₹ ',
                      prefixStyle: TextStyle(
                        color: Colors.green,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: paymentController.text.isEmpty
                        ? 1.0
                        : _pulseAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isProcessing
                              ? [Colors.grey[600]!, Colors.grey[500]!]
                              : [Color(0xFF00C9FF), Color(0xFF92FE9D)],
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: paymentController.text.isEmpty || isProcessing
                              ? null
                              : _autoAllocate,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            child: isProcessing
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.auto_fix_high,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Auto',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummaryCard() {
    return _buildGlassmorphicCard(
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryItem(
              'Payment',
              _formatCurrency(double.tryParse(paymentController.text) ?? 0.0),
              Color(0xFF667EEA),
              Icons.account_balance_wallet,
            ),
          ),
          Container(width: 1, height: 60, color: Colors.white.withOpacity(0.2)),
          Expanded(
            child: _buildSummaryItem(
              'Allocated',
              _formatCurrency(totalAllocated),
              Color(0xFF00C9FF),
              Icons.assignment_turned_in,
            ),
          ),
          Container(width: 1, height: 60, color: Colors.white.withOpacity(0.2)),
          Expanded(
            child: _buildSummaryItem(
              'Advance',
              _formatCurrency(advanceAmount),
              advanceAmount > 0 ? Color(0xFF92FE9D) : Colors.grey[600]!,
              Icons.savings,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    String title,
    String amount,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
        ),
        SizedBox(height: 4),
        Text(
          amount,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInvoiceListCard() {
    return _buildGlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF6B6B), Color(0xFFEE5A24)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.receipt_long, color: Colors.white, size: 20),
              ),
              SizedBox(width: 12),
              Text(
                'Outstanding Invoices',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          ...selectedCustomer!.invoices.map(
            (invoice) => _buildInvoiceCard(invoice),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard(Invoice invoice) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invoice.id,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _formatDate(invoice.date),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatCurrency(invoice.outstanding),
                      style: TextStyle(
                        color: Color(0xFFFF6B6B),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Outstanding',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: TextField(
              controller: invoiceControllers[invoice.id],
              style: TextStyle(color: Colors.white, fontSize: 14),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              decoration: InputDecoration(
                hintText: 'Allocation amount',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                prefixText: '₹ ',
                prefixStyle: TextStyle(color: Colors.green, fontSize: 14),
              ),
              enabled: paymentController.text.isNotEmpty,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () {
                  HapticFeedback.lightImpact();
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
                },
                child: Center(
                  child: Text(
                    'Clear All',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors:
                    paymentController.text.isEmpty ||
                        (double.tryParse(paymentController.text) ?? 0.0) <= 0
                    ? [Colors.grey[600]!, Colors.grey[500]!]
                    : [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap:
                    paymentController.text.isEmpty ||
                        (double.tryParse(paymentController.text) ?? 0.0) <= 0
                    ? null
                    : () {
                        HapticFeedback.heavyImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Payment processed successfully!'),
                            backgroundColor: Color(0xFF92FE9D),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Process Payment',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
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

// To use this page, add it to your app like this:
class PaymentApp extends StatelessWidget {
  const PaymentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Premium Payment Entry',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: PremiumPaymentEntryPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
