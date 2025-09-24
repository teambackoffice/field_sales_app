import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:location_tracker_app/controller/create_sales_order_controller.dart';
import 'package:location_tracker_app/controller/customer_list_controller.dart';
import 'package:location_tracker_app/controller/item_list_controller.dart';
import 'package:location_tracker_app/controller/item_tax_controller.dart'; // Add this import
import 'package:location_tracker_app/controller/sales_order_controller.dart';
import 'package:location_tracker_app/controller/specialOffer/get_special_offer_controller.dart';
import 'package:location_tracker_app/controller/specialOffer/post_special_offer_controller.dart';
import 'package:location_tracker_app/modal/customer_list_modal.dart';
import 'package:location_tracker_app/modal/item_tax_modal.dart'; // Add this import
import 'package:provider/provider.dart';

// Enhanced OrderItem class with tax information
class OrderItem {
  final String item_code;
  final double rate;
  final int qty;
  final String taxTemplate;
  final double taxRate;

  OrderItem({
    required this.item_code,
    required this.rate,
    required this.qty,
    required this.taxTemplate,
    required this.taxRate,
  });

  double get subtotal => rate * qty;
  double get taxAmount => subtotal * (taxRate / 100);
  double get totalPrice => subtotal + taxAmount;

  Map<String, dynamic> toJson() {
    return {
      'item_code': item_code,
      'rate': rate,
      'qty': qty,
      'tax_template': taxTemplate,
      'tax_rate': taxRate,
    };
  }
}

class InventoryItem {
  final String name;
  final double price;
  final String unit;
  final String description;
  final String taxTemplate; // Add tax template

  InventoryItem({
    required this.name,
    required this.price,
    required this.unit,
    required this.taxTemplate, // Add this
    this.description = '',
  });
}

class CreateSalesOrder extends StatefulWidget {
  const CreateSalesOrder({super.key});

  @override
  _CreateSalesOrderState createState() => _CreateSalesOrderState();
}

class _CreateSalesOrderState extends State<CreateSalesOrder> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _orderNumberController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool isSpecialOrder = false;
  bool isSpecialOrderLoading = false; // Add this for loading state
  bool isInitialized = false;
  // Form data
  DateTime delvery_date = DateTime.now();
  String? _selectedCustomer;
  final List<OrderItem> _orderItems = [];
  double _subtotalAmount = 0.0;
  double _totalTaxAmount = 0.0;
  double _totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _generateOrderNumber();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GetCustomerListController>(
        context,
        listen: false,
      ).fetchCustomerList();
      Provider.of<ItemListController>(context, listen: false).fetchItemList();
      Provider.of<ItemTaxController>(
        context,
        listen: false,
      ).getItemTaxes(); // Load tax data
      _initializeSpecialOfferSettings();
    });
  }

  Future<void> _initializeSpecialOfferSettings() async {
    final getController = Provider.of<GetSpecialOfferController>(
      context,
      listen: false,
    );
    await getController.fetchChundakadanSettings();

    if (getController.settings != null && mounted) {
      setState(() {
        // Access nested data structure and invert the logic
        final data = getController.settings?['message']?['data'];
        bool backendValue = data?['enable_stock_validation'] ?? false;
        isSpecialOrder =
            !backendValue; // Invert: backend true = switch OFF, backend false = switch ON
        isInitialized = true;
      });
    }
  }

  Future<void> _updateSpecialOffer(bool value) async {
    if (!mounted) return;

    setState(() {
      isSpecialOrderLoading = true;
    });

    try {
      final updateController = Provider.of<SpecialOfferController>(
        context,
        listen: false,
      );

      // Invert the logic: switch ON = backend false, switch OFF = backend true
      bool backendValue = !value;
      await updateController.updateSpecialOfferSettings(backendValue);

      if (updateController.error != null) {
        // Show error message
        Flushbar(
          messageText: Text(
            'Failed to update setting: ${updateController.error}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.red.shade500,
          icon: const Icon(Icons.error, color: Colors.white),
          margin: const EdgeInsets.all(12),
          borderRadius: BorderRadius.circular(12),
          duration: const Duration(seconds: 4),
          flushbarPosition: FlushbarPosition.BOTTOM,
          animationDuration: const Duration(milliseconds: 400),
        ).show(context);
      } else {
        // Success - update the local state
        setState(() {
          isSpecialOrder = value;
        });

        Flushbar(
          messageText: Text(
            'Special offer setting updated successfully',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.green.shade500,
          icon: const Icon(Icons.check_circle, color: Colors.white),
          margin: const EdgeInsets.all(12),
          borderRadius: BorderRadius.circular(12),
          duration: const Duration(seconds: 3),
          flushbarPosition: FlushbarPosition.BOTTOM,
          animationDuration: const Duration(milliseconds: 400),
        ).show(context);
      }
    } catch (e) {
      Flushbar(
        messageText: Text(
          'Error: $e',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.red.shade500,
        icon: const Icon(Icons.error, color: Colors.white),
        margin: const EdgeInsets.all(12),
        borderRadius: BorderRadius.circular(12),
        duration: const Duration(seconds: 4),
        flushbarPosition: FlushbarPosition.BOTTOM,
        animationDuration: const Duration(milliseconds: 400),
      ).show(context);
    } finally {
      if (mounted) {
        setState(() {
          isSpecialOrderLoading = false;
        });
      }
    }
  }

  void _generateOrderNumber() {
    String dateStr = DateTime.now()
        .toString()
        .substring(0, 10)
        .replaceAll('-', '');
    _orderNumberController.text = 'SO-$dateStr-001';
  }

  Future<void> _saveSalesOrder() async {
    final controller = Provider.of<CreateSalesOrderController>(
      context,
      listen: false,
    );

    if (_formKey.currentState!.validate()) {
      if (_orderItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add at least one item to the order'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await controller.createSalesOrder(
        context: context,
        customer: _selectedCustomer ?? "",
        deliveryDate: DateFormat('yyyy-MM-dd').format(delvery_date),
        items: _orderItems.map((item) => item.toJson()).toList(),
      );

      if (controller.error != null) {
        Flushbar(
          messageText: Text(
            controller.error!,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.orange.shade500,
          icon: const Icon(Icons.error, color: Colors.white),
          margin: const EdgeInsets.all(12),
          borderRadius: BorderRadius.circular(12),
          duration: const Duration(seconds: 4),
          flushbarPosition: FlushbarPosition.BOTTOM,
          animationDuration: const Duration(milliseconds: 400),
        ).show(context);
        return;
      }

      // 🔄 If special offer switch was ON, turn it OFF after successful order (do this FIRST)
      if (isSpecialOrder) {
        // Update silently without showing additional messages
        _updateSpecialOfferSilently(false);
      }

      // 🎯 SUCCESS: Sales order created successfully
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Sales Order created successfully!'),
          backgroundColor: Color(0xFF764BA2),
        ),
      );

      // Navigate and refresh
      Navigator.pop(context);
      Provider.of<SalesOrderController>(
        context,
        listen: false,
      ).fetchsalesorder();
    }
  }

  void _updateSpecialOfferSilently(bool value) {
    if (!mounted) return;

    // Update locally immediately
    setState(() {
      isSpecialOrder = value;
    });

    // Update backend asynchronously without blocking UI
    _updateBackendSilently(value);
  }

  Future<void> _updateBackendSilently(bool value) async {
    try {
      final updateController = Provider.of<SpecialOfferController>(
        context,
        listen: false,
      );

      // Invert the logic: switch ON = backend false, switch OFF = backend true
      bool backendValue = !value;
      await updateController.updateSpecialOfferSettings(backendValue);

      if (updateController.error != null) {
        print(
          'Failed to update special offer setting: ${updateController.error}',
        );
      }
    } catch (e) {
      print('Error updating special offer setting: $e');
    }
  }

  void _calculateTotal() {
    _subtotalAmount = _orderItems.fold(0.0, (sum, item) => sum + item.subtotal);
    _totalTaxAmount = _orderItems.fold(
      0.0,
      (sum, item) => sum + item.taxAmount,
    );
    _totalAmount = _subtotalAmount + _totalTaxAmount;
    setState(() {});
  }

  // Helper method to get tax rate from tax template
  double _getTaxRate(String taxTemplate, List<ItemTax> taxList) {
    try {
      final tax = taxList.firstWhere(
        (tax) => tax.name.toLowerCase() == taxTemplate.toLowerCase(),
        orElse: () => ItemTax(name: '', title: '', gstRate: 0.0),
      );
      return tax.gstRate;
    } catch (e) {
      return 0.0; // Default to 0 if tax template not found
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F6FA),
      appBar: AppBar(
        title: Text(
          'Create Sales Order',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Color(0xFF764BA2),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child:
            Consumer3<
              GetCustomerListController,
              ItemTaxController,
              ItemListController
            >(
              builder:
                  (
                    context,
                    customerController,
                    taxController,
                    itemController,
                    child,
                  ) {
                    if (customerController.isLoading ||
                        taxController.isLoading) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (customerController.error != null) {
                      return Center(
                        child: Text('Error: ${customerController.error}'),
                      );
                    }

                    final customers =
                        customerController.customerlist?.message.message ?? [];
                    final taxList = taxController.itemTaxes;

                    return SingleChildScrollView(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeaderCard(),
                          SizedBox(height: 16),
                          _buildCustomerCard(customers: customers),
                          SizedBox(height: 16),
                          _buildItemsCard(taxList),
                          SizedBox(height: 16),
                          _buildSpecialOrderSwitch(), // Add this line
                          SizedBox(height: 16),
                          _buildTotalCard(),
                          SizedBox(height: 16),
                          _buildSaveButton(),
                          SizedBox(height: 20),
                        ],
                      ),
                    );
                  },
            ),
      ),
    );
  }

  Widget _buildSpecialOrderSwitch() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSpecialOrder
              ? LinearGradient(
                  colors: [
                    Color(0xFF667EEA).withOpacity(0.1),
                    Color(0xFF764BA2).withOpacity(0.1),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: isSpecialOrder
                    ? LinearGradient(
                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSpecialOrder ? null : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                boxShadow: isSpecialOrder
                    ? [
                        BoxShadow(
                          color: Color(0xFF764BA2).withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child:
                  isSpecialOrderLoading // Show loading indicator
                  ? Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isSpecialOrder ? Colors.white : Color(0xFF764BA2),
                        ),
                      ),
                    )
                  : Icon(
                      isSpecialOrder
                          ? Icons.stars_rounded
                          : Icons.star_border_rounded,
                      color: isSpecialOrder
                          ? Colors.white
                          : Colors.grey.shade400,
                      size: 24,
                    ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Special Order',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isSpecialOrder
                          ? Color(0xFF764BA2)
                          : Color(0xFF2D3436),
                    ),
                  ),
                  if (isSpecialOrderLoading)
                    Text(
                      'Updating...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Switch(
                value: isSpecialOrder,
                onChanged: isSpecialOrderLoading
                    ? null
                    : _updateSpecialOffer, // Updated this line
                activeColor: Colors.white,
                activeTrackColor: Color(0xFF764BA2),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.grey.shade300,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // Subtotal row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                Text(
                  '₹${_subtotalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),

            SizedBox(height: 8),

            // Tax row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Tax',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                Text(
                  '₹${_totalTaxAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),

            Divider(color: Colors.white.withOpacity(0.5), thickness: 1),

            // Total row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '₹${_totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    final controller = Provider.of<CreateSalesOrderController>(context);
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: controller.isLoading ? null : _saveSalesOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF764BA2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: controller.isLoading
            ? CircularProgressIndicator(color: Colors.white)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Create Sales Order',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delivery Date ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3436),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: Color(0xFF764BA2)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${delvery_date.day}/${delvery_date.month}/${delvery_date.year}',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ],
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
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: delvery_date,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: Color(0xFF764BA2)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != delvery_date) {
      setState(() {
        delvery_date = picked;
      });
    }
  }

  Widget _buildCustomerCard({required List<MessageElement> customers}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3436),
              ),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select Customer',
                prefixIcon: Icon(Icons.person, color: Color(0xFF764BA2)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Color(0xFF764BA2)),
                ),
              ),
              value: _selectedCustomer,
              isExpanded: true,
              items: customers.map((customer) {
                return DropdownMenuItem<String>(
                  value: customer.name,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          customer.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: customer.hasGstin == true
                                ? [Color(0xFF667EEA), Color(0xFF764BA2)]
                                : [Color(0xFFF59E0B), Color(0xFFD97706)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              customer.hasGstin == true
                                  ? Icons.verified_rounded
                                  : Icons.warning_rounded,
                              size: 12,
                              color: Colors.white,
                            ),
                            SizedBox(width: 3),
                            Text(
                              customer.hasGstin == true ? 'GST' : 'No GST',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCustomer = value;
                });
              },
              validator: (value) {
                if (value == null) return 'Please select a customer';
                return null;
              },
            ),
            if (_selectedCustomer != null) ...[
              SizedBox(height: 12),
              _buildSelectedCustomerInfo(customers),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedCustomerInfo(List<MessageElement> customers) {
    final selectedCustomer = customers.firstWhere(
      (customer) => customer.name == _selectedCustomer,
      orElse: () => customers.first,
    );

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                selectedCustomer.hasGstin == true
                    ? Icons.verified_user
                    : Icons.info_outline,
                size: 16,
                color: selectedCustomer.hasGstin == true
                    ? Colors.green[600]
                    : Colors.orange[600],
              ),
              SizedBox(width: 8),
              Text(
                selectedCustomer.hasGstin == true
                    ? 'GST Registered Customer'
                    : 'Non-GST Registered Customer',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: selectedCustomer.hasGstin == true
                      ? Colors.green[700]
                      : Colors.orange[700],
                ),
              ),
            ],
          ),
          if (selectedCustomer.hasGstin == true &&
              selectedCustomer.gstin != null) ...[
            SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'GST No: ',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  selectedCustomer.gstin!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3436),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItemsCard(List<ItemTax> taxList) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order Items',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3436),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddItemBottomSheet(taxList),
                  icon: Icon(Icons.add),
                  label: Text('Add Item'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF764BA2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _orderItems.isEmpty
                ? Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            color: Colors.grey.shade400,
                            size: 32,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'No items added yet',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _orderItems.length,
                    itemBuilder: (context, index) {
                      return _buildOrderItemTile(
                        _orderItems[index],
                        index,
                        taxList,
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  void _showAddItemBottomSheet(List<ItemTax> taxList) {
    final TextEditingController searchController = TextEditingController();
    String searchText = "";
    final FocusNode searchFocusNode = FocusNode();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Consumer<ItemListController>(
                builder: (context, controller, child) {
                  if (controller.isLoading) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final itemlist = controller.itemlist?.message ?? [];
                  final filteredList = itemlist.where((item) {
                    return item.itemName.toLowerCase().contains(
                          searchText.toLowerCase(),
                        ) ||
                        item.itemCode.toLowerCase().contains(
                          searchText.toLowerCase(),
                        );
                  }).toList();

                  return Column(
                    children: [
                      // Header
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Add Item to Order',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(Icons.close),
                            ),
                          ],
                        ),
                      ),

                      // Search Field
                      Container(
                        margin: EdgeInsets.fromLTRB(16, 16, 16, 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: searchFocusNode.hasFocus
                                ? Color(0xFF764BA2).withOpacity(0.3)
                                : Colors.grey.shade200,
                            width: 1.5,
                          ),
                        ),
                        child: TextField(
                          controller: searchController,
                          focusNode: searchFocusNode,
                          decoration: InputDecoration(
                            hintText: "Search by name or code...",
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: Color(0xFF764BA2),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              searchText = value;
                            });
                          },
                        ),
                      ),

                      // Item List
                      Expanded(
                        child: filteredList.isEmpty
                            ? Center(child: Text('No items found'))
                            : ListView.builder(
                                padding: EdgeInsets.all(16),
                                itemCount: filteredList.length,
                                itemBuilder: (context, index) {
                                  final product = filteredList[index];
                                  final taxRate = _getTaxRate(
                                    product.taxTemplate,
                                    taxList,
                                  );
                                  final inventoryItem = InventoryItem(
                                    name: product.itemCode,
                                    price: product.price,
                                    unit: product.uom,
                                    taxTemplate: product.taxTemplate,
                                  );

                                  return Card(
                                    margin: EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      contentPadding: EdgeInsets.all(12),
                                      leading: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.inventory_2,
                                          color: Color(0xFF764BA2),
                                          size: 20,
                                        ),
                                      ),
                                      title: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.itemName,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            product.itemCode,
                                            style: TextStyle(
                                              color: Colors.grey.shade700,
                                              fontSize: 12,
                                            ),
                                          ),
                                          // Show tax information
                                          if (taxRate > 0) ...[
                                            SizedBox(height: 4),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.green.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                border: Border.all(
                                                  color: Colors.green.shade200,
                                                ),
                                              ),
                                              child: Text(
                                                'GST: ${taxRate.toStringAsFixed(1)}%',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.green.shade700,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      subtitle: Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          '₹${product.price.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      trailing: ElevatedButton(
                                        onPressed: () {
                                          _showQuantityDialog(
                                            inventoryItem,
                                            taxList,
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF764BA2),
                                          foregroundColor: Colors.white,
                                          minimumSize: Size(60, 36),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        child: Text('Add'),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  void _showQuantityDialog(
    InventoryItem item,
    List<ItemTax> taxList, {
    int? editIndex,
  }) {
    final quantityController = TextEditingController(
      text: editIndex != null ? _orderItems[editIndex].qty.toString() : '1',
    );
    final taxRate = _getTaxRate(item.taxTemplate, taxList);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Color(0xFF764BA2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Text(
                    editIndex != null
                        ? "Edit ${item.name}"
                        : "Add ${item.name}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Price and Tax Info
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Price per ${item.unit}:',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '₹${item.price.toStringAsFixed(2)}',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    if (taxRate > 0) ...[
                      SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'GST Rate:',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '${taxRate.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Quantity Input
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                style: TextStyle(fontSize: 18),
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  labelStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixText: item.unit,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),

              SizedBox(height: 30),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Color(0xFF764BA2), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF764BA2),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final quantity =
                            double.tryParse(quantityController.text) ?? 0;
                        if (quantity > 0) {
                          final orderItem = OrderItem(
                            item_code: item.name,
                            rate: item.price,
                            qty: quantity.toInt(),
                            taxTemplate: item.taxTemplate,
                            taxRate: taxRate,
                          );

                          setState(() {
                            if (editIndex != null) {
                              _orderItems[editIndex] = orderItem;
                            } else {
                              _orderItems.add(orderItem);
                            }
                            _calculateTotal();
                          });

                          Navigator.pop(context); // Close dialog
                          if (editIndex == null) {
                            Navigator.pop(
                              context,
                            ); // Close bottom sheet for add
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF764BA2),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        editIndex != null ? 'Update' : 'Add',
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
      ),
    );
  }

  Widget _buildOrderItemTile(OrderItem item, int index, List<ItemTax> taxList) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Main item row
            Row(
              children: [
                // Item icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(0xFF764BA2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.inventory_2,
                    color: Color(0xFF764BA2),
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),

                // Item details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.item_code,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xFF2D3436),
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '₹${item.rate.toStringAsFixed(2)} × ${item.qty}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                          if (item.taxRate > 0) ...[
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: Colors.green.shade200,
                                ),
                              ),
                              child: Text(
                                'GST: ${item.taxRate.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Price breakdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${item.subtotal.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    if (item.taxAmount > 0) ...[
                      Text(
                        '+₹${item.taxAmount.toStringAsFixed(2)} tax',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    Container(
                      margin: EdgeInsets.only(top: 4),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFF764BA2).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '₹${item.totalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Color(0xFF764BA2),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 12),

            // Action buttons row
            Row(
              children: [
                // Quantity badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.inventory,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Qty: ${item.qty}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),

                Spacer(),

                // Edit button
                InkWell(
                  onTap: () => _editOrderItem(index, taxList),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit_rounded,
                          size: 16,
                          color: Colors.blue.shade600,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Edit',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(width: 8),

                // Delete button
                InkWell(
                  onTap: () => _showDeleteConfirmation(index),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.delete_rounded,
                          size: 16,
                          color: Colors.red.shade600,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Remove',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.red.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Method to edit an order item
  void _editOrderItem(int index, List<ItemTax> taxList) {
    final item = _orderItems[index];
    final inventoryItem = InventoryItem(
      name: item.item_code,
      price: item.rate,
      unit: 'unit', // You might want to store this in OrderItem
      taxTemplate: item.taxTemplate,
    );

    _showQuantityDialog(inventoryItem, taxList, editIndex: index);
  }

  // Method to show delete confirmation
  void _showDeleteConfirmation(int index) {
    final item = _orderItems[index];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_rounded,
                  color: Colors.red.shade600,
                  size: 30,
                ),
              ),

              SizedBox(height: 16),

              // Title
              Text(
                'Remove Item',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3436),
                ),
              ),

              SizedBox(height: 8),

              // Message
              Text(
                'Are you sure you want to remove "${item.item_code}" from your order?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),

              SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _orderItems.removeAt(index);
                          _calculateTotal();
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Remove',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
