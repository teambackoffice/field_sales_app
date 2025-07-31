import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:location_tracker_app/controller/create_sales_order_controller.dart';
import 'package:location_tracker_app/controller/customer_list_controller.dart';
import 'package:location_tracker_app/controller/item_list_controller.dart';
import 'package:location_tracker_app/controller/sales_order_controller.dart';
import 'package:location_tracker_app/modal/customer_list_modal.dart';
import 'package:provider/provider.dart';

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

  // Form data
  DateTime delvery_date = DateTime.now();
  String? _selectedCustomer;
  final List<OrderItem> _orderItems = [];
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
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ItemListController>(context, listen: false).fetchItemList();
    });
  }

  void _generateOrderNumber() {
    // Generate order number based on current date
    String dateStr = DateTime.now()
        .toString()
        .substring(0, 10)
        .replaceAll('-', '');
    _orderNumberController.text = 'SO-$dateStr-001';
  }

  void _calculateTotal() {
    _totalAmount = _orderItems.fold(0.0, (sum, item) => sum + item.totalPrice);
    setState(() {});
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
        child: Consumer<GetCustomerListController>(
          builder: (context, controller, child) {
            if (controller.isLoading)
              return Center(child: CircularProgressIndicator());
            if (controller.error != null)
              return Text('Error: ${controller.error}');
            final customers = controller.customerlist!.message.message;
            return SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Header Card
                  _buildHeaderCard(),

                  SizedBox(height: 16),

                  // Customer Selection Card
                  _buildCustomerCard(customers: customers),

                  SizedBox(height: 16),

                  // Items Section
                  _buildItemsCard(),

                  SizedBox(height: 16),

                  // Total Amount Card
                  _buildTotalCard(),

                  SizedBox(height: 16),

                  // Save Button
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
                  value: customer.name, // assuming `id` is unique
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
                if (value == null) {
                  return 'Please select a customer';
                }
                return null;
              },
            ),

            // Display selected customer's GST info
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
          // Row(
          //   children: [
          //     Icon(
          //       selectedCustomer.isGstRegistered
          //           ? Icons.verified_user
          //           : Icons.info_outline,
          //       size: 16,
          //       color: selectedCustomer.isGstRegistered
          //           ? Colors.green[600]
          //           : Colors.orange[600],
          //     ),
          //     SizedBox(width: 8),
          //     Text(
          //       selectedCustomer.isGstRegistered
          //           ? 'GST Registered Customer'
          //           : 'Non-GST Registered Customer',
          //       style: TextStyle(
          //         fontSize: 13,
          //         fontWeight: FontWeight.w500,
          //         color: selectedCustomer.isGstRegistered
          //             ? Colors.green[700]
          //             : Colors.orange[700],
          //       ),
          //     ),
          //   ],
          // ),
          // if (selectedCustomer.isGstRegistered &&
          //     selectedCustomer.gstNumber != null) ...[
          //   SizedBox(height: 8),
          //   Row(
          //     children: [
          //       Text(
          //         'GST No: ',
          //         style: TextStyle(
          //           fontSize: 12,
          //           fontWeight: FontWeight.w500,
          //           color: Colors.grey[600],
          //         ),
          //       ),
          //       Text(
          //         selectedCustomer.gstNumber!,
          //         style: TextStyle(
          //           fontSize: 12,
          //           fontWeight: FontWeight.w600,
          //           color: Color(0xFF2D3436),
          //         ),
          //       ),
          //     ],
          //   ),
          // ],
        ],
      ),
    );
  }

  Widget _buildItemsCard() {
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
                  onPressed: _showAddItemBottomSheet,
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
                      border: Border.all(
                        color: Colors.grey.shade300,
                        style: BorderStyle.solid,
                      ),
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
                      return _buildOrderItemTile(_orderItems[index], index);
                    },
                  ),
          ],
        ),
      ),
    );
  }

  // Bottom Sheet approach - shows existing items and option to create new
  void _showAddItemBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Consumer<ItemListController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return SizedBox();
            }
            final itemlist = controller.itemlist!.message ?? [];
            return Column(
              children: [
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
                      Row(
                        children: [
                          // TextButton.icon(
                          //   onPressed: () {
                          //     Navigator.pop(context);
                          //     _showCreateNewItemPage();
                          //   },
                          //   icon: Icon(Icons.add_circle_outline, size: 20),
                          //   label: Text('Create New'),
                          //   style: TextButton.styleFrom(
                          //     foregroundColor: Color(0xFF667EEA),
                          //   ),
                          // ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.close),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child:
                      itemlist
                          .isEmpty // ✅ Correct - checking products list
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inventory_outlined,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No items available',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Create your first item to get started',
                                style: TextStyle(color: Colors.grey.shade500),
                              ),
                              SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  // _showCreateNewItemPage();
                                },
                                icon: Icon(Icons.add),
                                label: Text('Create Item'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF764BA2),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: itemlist.length,
                          itemBuilder: (context, index) {
                            final product = itemlist[index];
                            final inventoryItem = InventoryItem(
                              name: product.itemCode,
                              price: product.price,
                              unit: product.uom,
                            );
                            return Card(
                              margin: EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: Container(
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
                                title: Text(
                                  product.itemCode,
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                subtitle: Text(
                                  '₹${product.price.toStringAsFixed(2)}',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                                trailing: ElevatedButton(
                                  onPressed: () {
                                    _showQuantityDialog(inventoryItem);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF764BA2),
                                    foregroundColor: Colors.white,
                                    minimumSize: Size(60, 36),
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
      ),
    );
  }

  // Dialog to enter quantity when adding existing item
  void _showQuantityDialog(InventoryItem item) {
    final quantityController = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Container(
          padding: EdgeInsets.all(20),
          width: double.infinity,
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
                    "Add ${item.name}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Price Info
              Text(
                'Price: ₹${item.price.toStringAsFixed(2)} per ${item.unit}',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
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
                          );

                          setState(() {
                            _orderItems.add(orderItem);
                            _calculateTotal();
                          });

                          Navigator.pop(context); // Close dialog
                          Navigator.pop(context); // Close bottom sheet
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
                        'Add',
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

  Widget _buildOrderItemTile(OrderItem item, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.item_code,
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                ),
                Text(
                  '₹${item.rate.toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${item.qty}',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '₹${item.totalPrice.toStringAsFixed(2)}',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF764BA2),
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _orderItems.removeAt(index);
                _calculateTotal();
              });
            },
            icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
          ),
        ],
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
        child: Row(
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

  Future<void> _saveSalesOrder() async {
    final controller = Provider.of<CreateSalesOrderController>(
      context,
      listen: false,
    );

    if (_formKey.currentState!.validate()) {
      if (_orderItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please add at least one item to the order'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Call API
      await controller.createSalesOrder(
        customer: _selectedCustomer ?? "anupam",
        deliveryDate: DateFormat('yyyy-MM-dd').format(delvery_date),
        items: _orderItems.map((item) => item.toJson()).toList(),
      );

      if (controller.error != null) {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${controller.error}'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // On success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sales Order created successfully!'),
          backgroundColor: Color(0xFF764BA2),
        ),
      );

      // Optional: Print or use response

      Navigator.pop(context);
      Provider.of<SalesOrderController>(
        context,
        listen: false,
      ).fetchsalesorder();
    }
  }
}

class OrderItem {
  final String item_code;
  final double rate;
  final int qty;

  OrderItem({required this.item_code, required this.rate, required this.qty});

  double get totalPrice => rate * qty;

  Map<String, dynamic> toJson() {
    return {'item_code': item_code, 'rate': rate, 'qty': qty};
  }
}

class InventoryItem {
  final String name;
  final double price;
  final String unit;
  final String description;

  InventoryItem({
    required this.name,
    required this.price,
    required this.unit,
    this.description = '',
  });
}
