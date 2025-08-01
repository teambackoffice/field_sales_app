import 'dart:async';

import 'package:flutter/material.dart';
import 'package:location_tracker_app/controller/invoice_list_controller.dart';
import 'package:location_tracker_app/modal/invoice_list_modal.dart';
import 'package:location_tracker_app/view/mainscreen/invoice/payment_entry.dart'
    hide Invoice;
import 'package:location_tracker_app/view/mainscreen/invoice/payment_page.dart';
import 'package:provider/provider.dart';

// Add this to your existing InvoicePage class
class InvoicePage extends StatefulWidget {
  const InvoicePage({super.key});

  @override
  _InvoicePageState createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InvoiceListController>(
        context,
        listen: false,
      ).fetchInvoiceList();

      // Start auto-refresh timer
      _startAutoRefresh();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    // Refresh every 30 seconds to check for backend updates
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        final controller = Provider.of<InvoiceListController>(
          context,
          listen: false,
        );

        // Only refresh if there are pending payments to avoid unnecessary API calls
        controller.refreshIfNeeded();
      }
    });
  }

  void _makePayment(Invoice invoice) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          invoice: invoice,
          onPaymentSuccess: (double amount, String method) {
            // Update the specific invoice's draft state
            final controller = Provider.of<InvoiceListController>(
              context,
              listen: false,
            );
            controller.updateInvoiceDraftState(
              invoice.invoiceId,
              amount,
              method,
            );
          },
        ),
      ),
    );
  }

  // Add manual refresh functionality
  Future<void> _onRefresh() async {
    final controller = Provider.of<InvoiceListController>(
      context,
      listen: false,
    );
    await controller.refreshAndClearPendingPayments();
  }

  // Method to get status color based on invoice state
  Color _getStatusColor(Invoice invoice) {
    if (invoice.hasPendingPayment) {
      return const Color(0xFF9333EA); // Purple for processing
    } else if (invoice.status == "Paid") {
      return const Color(0xFF10B981); // Green for paid
    } else {
      return const Color(0xFFF59E0B); // Amber for pending
    }
  }

  // Method to get status icon based on invoice state
  IconData _getStatusIcon(Invoice invoice) {
    if (invoice.hasPendingPayment) {
      return Icons.hourglass_empty_rounded; // Processing icon
    } else if (invoice.status == "Paid") {
      return Icons.check_circle_rounded; // Paid icon
    } else {
      return Icons.schedule_rounded; // Pending icon
    }
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
              Consumer<InvoiceListController>(
                builder: (context, controller, child) {
                  if (controller.isLoading) {
                    return Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: 4,
                        itemBuilder: (context, index) {
                          return _buildShimmerItem();
                        },
                      ),
                    );
                  }

                  if (controller.invoiceList == null ||
                      controller.invoiceList!.message.invoices.isEmpty) {
                    return const Expanded(
                      child: Center(child: Text("No Invoices found!")),
                    );
                  }

                  final invoicesList =
                      controller.invoiceList?.message.invoices ?? [];

                  return Expanded(
                    child: RefreshIndicator(
                      onRefresh: _onRefresh,
                      color: Color(0xFF667EEA),
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: ListView.builder(
                          itemCount: invoicesList.length,
                          itemBuilder: (context, index) {
                            final invoice = invoicesList[index];
                            final statusColor = _getStatusColor(invoice);
                            final statusIcon = _getStatusIcon(invoice);

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
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    statusIcon,
                                    color: statusColor,
                                    size: 28,
                                  ),
                                ),
                                title: Text(
                                  invoice.invoiceId,
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
                                      invoice.customer,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Total: ₹${invoice.grandTotal.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF059669),
                                          ),
                                        ),
                                        Text(
                                          'Due: ₹${invoice.outstandingAmount.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFFF59E0B),
                                          ),
                                        ),
                                        // Show pending payment info if exists
                                        if (invoice.hasPendingPayment) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            'Processing: ₹${invoice.pendingPaymentAmount.toStringAsFixed(2)} (${invoice.pendingPaymentMethod})',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF9333EA),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: _buildTrailingWidget(invoice),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerItem() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 16, width: 80, color: Colors.grey[300]),
                const SizedBox(height: 8),
                Container(height: 14, width: 140, color: Colors.grey[300]),
                const SizedBox(height: 8),
                Container(height: 18, width: 60, color: Colors.grey[300]),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 36,
            width: 80,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrailingWidget(Invoice invoice) {
    if (invoice.status == "Paid") {
      return Container(
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
      );
    } else if (invoice.hasPendingPayment) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Color(0xFF9333EA).withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'PROCESSING',
          style: TextStyle(
            color: Color(0xFF9333EA),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      );
    } else {
      return ElevatedButton(
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
      );
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
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
              // Show pending payments indicator
              Consumer<InvoiceListController>(
                builder: (context, controller, child) {
                  final pendingCount = controller.pendingPaymentsCount;
                  return Stack(
                    children: [
                      PopupMenuButton(
                        icon: Icon(Icons.filter_list, color: Colors.black),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onSelected: (value) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentEntryPage(),
                            ),
                          );
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
                      if (pendingCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Color(0xFF9333EA),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '$pendingCount',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
