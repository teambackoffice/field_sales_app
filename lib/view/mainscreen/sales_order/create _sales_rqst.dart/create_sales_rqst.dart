import 'package:flutter/material.dart';
import 'package:location_tracker_app/controller/create_sales_return_contoller.dart';
import 'package:location_tracker_app/controller/sales_invoice_details_controller.dart';
import 'package:location_tracker_app/controller/sales_invoice_id_controller.dart';
import 'package:location_tracker_app/controller/sales_return_controller.dart';
import 'package:provider/provider.dart';

class CreateSalesReturnPage extends StatefulWidget {
  const CreateSalesReturnPage({super.key});

  @override
  State<CreateSalesReturnPage> createState() => _CreateSalesReturnPageState();
}

class _CreateSalesReturnPageState extends State<CreateSalesReturnPage> {
  final _formKey = GlobalKey<FormState>();
  final _invoiceNameController = TextEditingController();
  final _productNameController = TextEditingController();
  final _qtyController = TextEditingController();
  final _buyingDateController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedReason;
  DateTime? _selectedBuyingDate;
  String? _selectedInvoiceId;
  final Map<String, int> _selectedItems = {}; // item_code -> return_quantity
  String _invoiceSearchQuery = ""; // Add search query state

  final List<String> _returnReasons = [
    'Damaged Product',
    'Wrong Product Delivered',
    'Quality Issue',
    'Size Mismatch',
    'Others',
  ];

  @override
  void initState() {
    super.initState();
    // Don't set default date - will be set when invoice is selected

    // Load invoice IDs when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SalesInvoiceIdsController>(
        context,
        listen: false,
      ).getSalesInvoiceIds();
    });
  }

  @override
  void dispose() {
    _invoiceNameController.dispose();
    _productNameController.dispose();
    _qtyController.dispose();
    _buyingDateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> _selectBuyingDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBuyingDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF764BA2),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedBuyingDate) {
      setState(() {
        _selectedBuyingDate = picked;
        _buyingDateController.text = _formatDate(picked);
      });
    }
  }

  // Method to handle invoice selection and fetch details
  void _onInvoiceSelected(String invoiceId) async {
    setState(() {
      _selectedInvoiceId = invoiceId;
      _invoiceNameController.text = invoiceId;
      _selectedItems.clear();
      _productNameController.clear();
      _qtyController.clear();
      // Clear purchase date until we get it from backend
      _buyingDateController.clear();
      _selectedBuyingDate = null;
    });

    // Fetch invoice details
    final detailController = Provider.of<SalesInvoiceDetailController>(
      context,
      listen: false,
    );
    await detailController.getSalesInvoiceDetail(invoiceId: invoiceId);

    // Update purchase date from backend data
    if (detailController.salesInvoiceDetail != null) {
      final postingDate =
          detailController.salesInvoiceDetail!.message.data.postingDate;
      setState(() {
        _selectedBuyingDate = postingDate;
        _buyingDateController.text = _formatDate(postingDate);
      });
    }

    Navigator.pop(context); // Close the selection sheet
  }

  // Helper method to highlight search text
  List<TextSpan> _highlightSearchText(
    String text,
    String query,
    bool isSelected,
  ) {
    if (query.isEmpty) {
      return [
        TextSpan(
          text: text,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isSelected
                ? const Color(0xFF764BA2)
                : const Color(0xFF2C3E50),
          ),
        ),
      ];
    }

    final List<TextSpan> spans = [];
    final String lowerText = text.toLowerCase();
    final String lowerQuery = query.toLowerCase();

    int start = 0;
    int index = lowerText.indexOf(lowerQuery, start);

    while (index >= 0) {
      // Add text before match
      if (index > start) {
        spans.add(
          TextSpan(
            text: text.substring(start, index),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? const Color(0xFF764BA2)
                  : const Color(0xFF2C3E50),
            ),
          ),
        );
      }

      // Add highlighted match
      spans.add(
        TextSpan(
          text: text.substring(index, index + query.length),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected
                ? const Color(0xFF764BA2)
                : const Color(0xFF2C3E50),
            backgroundColor: Colors.yellow[200],
          ),
        ),
      );

      start = index + query.length;
      index = lowerText.indexOf(lowerQuery, start);
    }

    // Add remaining text
    if (start < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(start),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isSelected
                ? const Color(0xFF764BA2)
                : const Color(0xFF2C3E50),
          ),
        ),
      );
    }

    return spans;
  }

  // Method to show invoice selection bottom sheet
  void _showInvoiceSelectionSheet() {
    // Reset search when opening
    _invoiceSearchQuery = "";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Consumer<SalesInvoiceIdsController>(
          builder: (context, invoiceController, child) {
            // Filter invoices based on search query
            List<String> filteredInvoices = [];
            if (invoiceController.salesInvoiceIds?.invoiceIds != null) {
              filteredInvoices = invoiceController.salesInvoiceIds!.invoiceIds
                  .where(
                    (invoice) => invoice.toLowerCase().contains(
                      _invoiceSearchQuery.toLowerCase(),
                    ),
                  )
                  .toList();
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.receipt_long,
                          color: Color(0xFF764BA2),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Select Invoice',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                              if (invoiceController
                                      .salesInvoiceIds
                                      ?.invoiceIds !=
                                  null)
                                Text(
                                  '${filteredInvoices.length} of ${invoiceController.salesInvoiceIds!.invoiceIds.length} invoices',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.grey[100],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Search Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      onChanged: (value) {
                        setModalState(() {
                          _invoiceSearchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search invoices...',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF764BA2),
                        ),
                        suffixIcon: _invoiceSearchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setModalState(() {
                                    _invoiceSearchQuery = "";
                                  });
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF764BA2),
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Divider(height: 1),

                  // Content
                  Expanded(
                    child: invoiceController.isLoading
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  color: Color(0xFF764BA2),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Loading invoices...',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : invoiceController.error != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: Colors.red[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Error loading invoices',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  invoiceController.error!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    invoiceController.getSalesInvoiceIds();
                                  },
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Retry'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF764BA2),
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : invoiceController
                                  .salesInvoiceIds
                                  ?.invoiceIds
                                  .isEmpty ??
                              true
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inbox_outlined,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No invoices found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'There are no invoices available at the moment.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : filteredInvoices.isEmpty &&
                              _invoiceSearchQuery.isNotEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No invoices found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try adjusting your search terms',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextButton.icon(
                                  onPressed: () {
                                    setModalState(() {
                                      _invoiceSearchQuery = "";
                                    });
                                  },
                                  icon: const Icon(Icons.clear_all),
                                  label: const Text('Clear Search'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: const Color(0xFF764BA2),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredInvoices.length,
                            itemBuilder: (context, index) {
                              final invoiceId = filteredInvoices[index];
                              final isSelected =
                                  _selectedInvoiceId == invoiceId;
                              final originalIndex = invoiceController
                                  .salesInvoiceIds!
                                  .invoiceIds
                                  .indexOf(invoiceId);

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF764BA2)
                                        : Colors.grey[300]!,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  color: isSelected
                                      ? const Color(0xFF764BA2).withOpacity(0.1)
                                      : Colors.white,
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  leading: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFF764BA2)
                                          : Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.receipt,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey[600],
                                      size: 20,
                                    ),
                                  ),
                                  title: RichText(
                                    text: TextSpan(
                                      children: _highlightSearchText(
                                        invoiceId,
                                        _invoiceSearchQuery,
                                        isSelected,
                                      ),
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Invoice #${originalIndex + 1}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                  trailing: isSelected
                                      ? const Icon(
                                          Icons.check_circle,
                                          color: Color(0xFF764BA2),
                                          size: 24,
                                        )
                                      : null,
                                  onTap: () => _onInvoiceSelected(invoiceId),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Helper method to highlight search text

  Widget _buildInvoiceItemsSection() {
    return Consumer<SalesInvoiceDetailController>(
      builder: (context, controller, child) {
        if (_selectedInvoiceId == null) {
          return const SizedBox.shrink();
        }

        if (controller.isLoading) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(color: Color(0xFF764BA2)),
                  SizedBox(height: 16),
                  Text(
                    'Loading invoice items...',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        if (controller.errorMessage != null) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
                const SizedBox(height: 16),
                Text(
                  'Error loading items',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.red[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  controller.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    controller.getSalesInvoiceDetail(
                      invoiceId: _selectedInvoiceId!,
                    );
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF764BA2),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        if (controller.salesInvoiceDetail == null) {
          return const SizedBox.shrink();
        }

        final items = controller.salesInvoiceDetail!.message.data.items;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF764BA2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.inventory_2,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Invoice Items',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Select items and quantities to return:',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ...items.map((item) => _buildItemTile(item)),
            ],
          ),
        );
      },
    );
  }

  // Widget to build individual item tile
  Widget _buildItemTile(dynamic item) {
    final itemCode = item.itemCode;
    final itemName = item.itemName;
    final maxQty = item.qty;
    final rate = item.rate;
    final isSelected = _selectedItems.containsKey(itemCode);
    final returnQty = _selectedItems[itemCode] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? const Color(0xFF764BA2) : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: isSelected
            ? const Color(0xFF764BA2).withOpacity(0.05)
            : Colors.grey[50],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        itemName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? const Color(0xFF764BA2)
                              : const Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Code: $itemCode',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Quantity: $maxQty • Rate: ₹$rate',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Checkbox(
                  value: isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _selectedItems[itemCode] = 1;
                      } else {
                        _selectedItems.remove(itemCode);
                      }
                    });
                  },
                  activeColor: const Color(0xFF764BA2),
                ),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text(
                    'Return Quantity:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: returnQty > 1
                              ? () {
                                  setState(() {
                                    _selectedItems[itemCode] = returnQty - 1;
                                  });
                                }
                              : null,
                          icon: const Icon(Icons.remove),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            foregroundColor: const Color(0xFF764BA2),
                            minimumSize: const Size(32, 32),
                          ),
                        ),
                        Container(
                          width: 60,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            returnQty.toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: returnQty < maxQty
                              ? () {
                                  setState(() {
                                    _selectedItems[itemCode] = returnQty + 1;
                                  });
                                }
                              : null,
                          icon: const Icon(Icons.add),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            foregroundColor: const Color(0xFF764BA2),
                            minimumSize: const Size(32, 32),
                          ),
                        ),
                      ],
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

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one item to return'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final controller = Provider.of<CreateSalesReturnController>(
        context,
        listen: false,
      );

      final detailController = Provider.of<SalesInvoiceDetailController>(
        context,
        listen: false,
      );

      // ✅ Build items list
      final items = _selectedItems.entries.map((entry) {
        final item = detailController.salesInvoiceDetail!.message.data.items
            .firstWhere((i) => i.itemCode == entry.key);

        return {
          "item_code": item.itemCode,
          "qty": entry.value,
          "rate": item.rate, // assuming your detail has rate
        };
      }).toList();

      await controller.createSalesReturn(
        returnAgainst: _invoiceNameController.text,
        returnDate: _buyingDateController.text,
        customer: detailController.salesInvoiceDetail!.message.data.customer,
        reason: _selectedReason!,
        buyingDate: _buyingDateController.text,
        notes: _notesController.text,
        items: items,
      );

      if (controller.errorMessage != null) {
        _showErrorDialog(controller.errorMessage!);
        return;
      }

      // ✅ Show success dialog
      if (mounted) {
        _showSuccessDialog();
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green.shade600,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Success!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Sales return has been created successfully.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.of(context).pop();
                      Provider.of<SalesReturnController>(
                        context,
                        listen: false,
                      ).fetchsalesreturn(); // Go back to previous screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF764BA2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error,
                    color: Colors.red.shade600,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Error!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close dialog
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF764BA2),
                          side: const BorderSide(color: Color(0xFF764BA2)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Try Again',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close dialog
                          Navigator.of(
                            context,
                          ).pop(); // Go back to previous screen
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    VoidCallback? onTap,
    bool readOnly = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          onTap: onTap,
          readOnly: readOnly,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF764BA2)),
            suffixIcon: onTap != null
                ? Icon(
                    readOnly ? Icons.arrow_drop_down : Icons.edit,
                    color: const Color(0xFF764BA2),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF764BA2), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: maxLines > 1 ? 16 : 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Return Reason',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedReason,
          hint: const Text('Select return reason'),
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.info_outline,
              color: Color(0xFF764BA2),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF764BA2), width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          items: _returnReasons.map((String reason) {
            return DropdownMenuItem<String>(value: reason, child: Text(reason));
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedReason = newValue;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a return reason';
            }
            return null;
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Sales Return"),
        backgroundColor: const Color(0xFF764BA2),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF764BA2),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Icon(
                        Icons.assignment_return,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'New Sales Return',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Fill in the details below',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Invoice Selection
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _buildTextField(
                  controller: _invoiceNameController,
                  label: 'Invoice Name',
                  hint: 'Select an invoice',
                  icon: Icons.receipt_long,
                  readOnly: true,
                  onTap: _showInvoiceSelectionSheet,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select an invoice';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Invoice Items Section (shows after invoice selection)
              _buildInvoiceItemsSection(),

              // Add spacing if items are shown
              Consumer<SalesInvoiceDetailController>(
                builder: (context, controller, child) {
                  if (_selectedInvoiceId != null &&
                      controller.salesInvoiceDetail != null &&
                      !controller.isLoading) {
                    return const SizedBox(height: 24);
                  }
                  return const SizedBox.shrink();
                },
              ),

              // Form Fields
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildDropdown(),

                    const SizedBox(height: 20),

                    _buildTextField(
                      controller: _buyingDateController,
                      label: 'Purchase Date',
                      hint: 'Will be auto-filled from selected invoice',
                      icon: Icons.calendar_today,
                      readOnly: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Purchase date will be set when you select an invoice';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    _buildTextField(
                      controller: _notesController,
                      label: 'Notes',
                      hint: 'Enter additional notes (optional)',
                      icon: Icons.note_alt,
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Submit Button with Loading State
              Consumer<CreateSalesReturnController>(
                builder: (context, controller, child) {
                  return ElevatedButton(
                    onPressed: controller.isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: controller.isLoading
                          ? Colors.grey[400]
                          : const Color(0xFF764BA2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: controller.isLoading ? 0 : 2,
                    ),
                    child: controller.isLoading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
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
                                'Creating Sales Return...',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.save, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Create Sales Return ${_selectedItems.isNotEmpty ? '(${_selectedItems.length} items)' : ''}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
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
}
