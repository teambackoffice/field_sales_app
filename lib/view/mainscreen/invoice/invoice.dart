import 'package:flutter/material.dart';
import 'package:location_tracker_app/controller/invoice_list_controller.dart';
import 'package:location_tracker_app/modal/invoice_list_modal.dart';
import 'package:location_tracker_app/view/mainscreen/invoice/payment_entry.dart'
    hide Invoice;
import 'package:location_tracker_app/view/mainscreen/invoice/payment_page.dart'
    hide Invoice;
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class InvoicePage extends StatefulWidget {
  const InvoicePage({super.key});

  @override
  _InvoicePageState createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InvoiceListController>(
        context,
        listen: false,
      ).fetchInvoiceList();
    });
  }

  void _makePayment(Invoice invoice) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          invoice: invoice,
          onPaymentSuccess: (amount, method) {
            setState(() {
              invoice.status = "Paid";
              // You can also store the amount/method if needed
              print("Paid Amount: $amount, Method: $method");
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
              Consumer<InvoiceListController>(
                builder: (context, controller, child) {
                  if (controller.isLoading) {
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: ListView.builder(
                          itemCount: 6, // Number of shimmer items
                          itemBuilder: (context, index) {
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
                              child: Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Row(
                                    children: [
                                      // Leading icon shimmer
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 16),

                                      // Content section shimmer
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Invoice ID shimmer
                                            Container(
                                              width: double.infinity * 0.6,
                                              height: 16,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                            ),
                                            SizedBox(height: 8),

                                            // Customer name shimmer
                                            Container(
                                              width: double.infinity * 0.4,
                                              height: 14,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                            ),
                                            SizedBox(height: 12),

                                            // Total amount shimmer
                                            Container(
                                              width: double.infinity * 0.5,
                                              height: 16,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                            ),
                                            SizedBox(height: 4),

                                            // Due amount shimmer
                                            Container(
                                              width: double.infinity * 0.45,
                                              height: 16,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      SizedBox(width: 12),

                                      // Trailing button/badge shimmer
                                      Container(
                                        width: 80,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }
                  if (controller.invoiceList == null ||
                      controller.invoiceList!.message.invoices.isEmpty) {
                    return const Center(child: Text("No Invoices found!"));
                  }

                  final invoicesList =
                      controller.invoiceList?.message.invoices ?? [];

                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: ListView.builder(
                        itemCount: invoicesList.length,
                        itemBuilder: (context, index) {
                          final invoice = invoicesList[index];
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
                                  color: invoice.status == "Paid"
                                      ? Color(0xFF10B981).withOpacity(0.1)
                                      : Color(0xFFF59E0B).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  invoice.status == "Paid"
                                      ? Icons.check_circle_rounded
                                      : Icons.schedule_rounded,
                                  color: invoice.status == "Paid"
                                      ? Color(0xFF10B981)
                                      : Color(0xFFF59E0B),
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
                                          color: Color(
                                            0xFFF59E0B,
                                          ), // Amber for due
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: invoice.status == "Paid"
                                  ? Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Color(
                                          0xFF10B981,
                                        ).withOpacity(0.1),
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
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
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
                  );
                },
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
                        builder: (context) => PaymentEntryPage(),
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
