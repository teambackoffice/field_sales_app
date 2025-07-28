import 'package:flutter/material.dart';

class SalesOrderCreatePage extends StatefulWidget {
  const SalesOrderCreatePage({super.key});

  @override
  _SalesOrderCreatePageState createState() => _SalesOrderCreatePageState();
}

class _SalesOrderCreatePageState extends State<SalesOrderCreatePage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _orderNumberController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Form data
  DateTime _postingDate = DateTime.now();
  String? _selectedCustomer;
  final List<OrderItem> _orderItems = [];
  double _totalAmount = 0.0;

  // Mock data - replace with backend API calls
  final List<Customer> _customers = [
    Customer(id: '1', name: 'ABC Corporation', email: 'abc@corp.com'),
    Customer(id: '2', name: 'XYZ Ltd', email: 'xyz@ltd.com'),
    Customer(id: '3', name: 'Tech Solutions Inc', email: 'tech@solutions.com'),
  ];

  final List<Product> _products = [
    Product(id: '1', name: 'Laptop Dell XPS', price: 1200.00, unit: 'pcs'),
    Product(id: '2', name: 'Wireless Mouse', price: 25.00, unit: 'pcs'),
    Product(id: '3', name: 'USB Cable', price: 15.00, unit: 'pcs'),
    Product(id: '4', name: 'Monitor 24"', price: 300.00, unit: 'pcs'),
  ];

  @override
  void initState() {
    super.initState();
    _generateOrderNumber();
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

  void _addItem() {
    showDialog(context: context, builder: (context) => _buildAddItemDialog());
  }

  void _createNewItem() {
    showDialog(
      context: context,
      builder: (context) => _buildCreateItemDialog(),
    );
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
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Header Card
              _buildHeaderCard(),

              SizedBox(height: 16),

              // Customer Selection Card
              _buildCustomerCard(),

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
              'Posting Date ',
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
                                  'Posting Date',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                Text(
                                  '${_postingDate.day}/${_postingDate.month}/${_postingDate.year}',
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

  Widget _buildCustomerCard() {
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
              items: _customers.map((customer) {
                return DropdownMenuItem<String>(
                  value: customer.id,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
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
                if (value == null) {
                  return 'Please select a customer';
                }
                return null;
              },
            ),
          ],
        ),
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
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: _createNewItem,
                      icon: Icon(Icons.add_circle, color: Color(0xFF667EEA)),
                      label: Text(
                        'Create Item',
                        style: TextStyle(color: Color(0xFF667EEA)),
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _addItem,
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
                  item.productName,
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                ),
                Text(
                  '\$${item.unitPrice.toStringAsFixed(2)} per ${item.unit}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${item.quantity}',
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
            colors: [Color(0xFF764BA2), Color(0xFF667EEA)],
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
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _saveSalesOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF764BA2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.save, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Save Sales Order',
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

  Widget _buildAddItemDialog() {
    TextEditingController itemNameController = TextEditingController();
    TextEditingController priceController = TextEditingController();
    TextEditingController quantityController = TextEditingController(text: '1');
    TextEditingController unitController = TextEditingController(text: 'pcs');

    return StatefulBuilder(
      builder: (context, setDialogState) {
        return AlertDialog(
          title: Text('Add Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: itemNameController,
                  decoration: InputDecoration(
                    labelText: 'Item Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: Icon(
                      Icons.inventory_2,
                      color: Color(0xFF764BA2),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: priceController,
                  decoration: InputDecoration(
                    labelText: 'Unit Price',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: Icon(
                      Icons.attach_money,
                      color: Color(0xFF764BA2),
                    ),
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: quantityController,
                        decoration: InputDecoration(
                          labelText: 'Quantity',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(
                            Icons.numbers,
                            color: Color(0xFF764BA2),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: unitController,
                        decoration: InputDecoration(
                          labelText: 'Unit',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          hintText: 'pcs, kg, lbs',
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // Quick select from existing products (optional)
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Select from Existing Products:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _products.take(3).map((product) {
                          return InkWell(
                            onTap: () {
                              setDialogState(() {
                                itemNameController.text = product.name;
                                priceController.text = product.price.toString();
                                unitController.text = product.unit;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xFF764BA2).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Color(0xFF764BA2).withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                product.name,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF764BA2),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Validate fields
                if (itemNameController.text.isEmpty ||
                    priceController.text.isEmpty ||
                    quantityController.text.isEmpty ||
                    unitController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please fill all fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                double? unitPrice = double.tryParse(priceController.text);
                int? quantity = int.tryParse(quantityController.text);

                if (unitPrice == null || unitPrice <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter a valid price'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                if (quantity == null || quantity <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter a valid quantity'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                OrderItem newItem = OrderItem(
                  productId: DateTime.now().millisecondsSinceEpoch.toString(),
                  productName: itemNameController.text,
                  unitPrice: unitPrice,
                  quantity: quantity,
                  unit: unitController.text,
                );

                setState(() {
                  _orderItems.add(newItem);
                  _calculateTotal();
                });

                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF764BA2),
              ),
              child: Text('Add Item', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCreateItemDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController priceController = TextEditingController();
    TextEditingController unitController = TextEditingController();

    return AlertDialog(
      title: Text('Create New Item'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Product Name',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: priceController,
            decoration: InputDecoration(
              labelText: 'Price',
              border: OutlineInputBorder(),
              prefixText: '\$',
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: unitController,
            decoration: InputDecoration(
              labelText: 'Unit (e.g., pcs, kg, lbs)',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (nameController.text.isNotEmpty &&
                priceController.text.isNotEmpty &&
                unitController.text.isNotEmpty) {
              Product newProduct = Product(
                id: (_products.length + 1).toString(),
                name: nameController.text,
                price: double.tryParse(priceController.text) ?? 0.0,
                unit: unitController.text,
              );

              setState(() {
                _products.add(newProduct);
              });

              Navigator.pop(context);

              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Product "${newProduct.name}" created successfully!',
                  ),
                  backgroundColor: Color(0xFF764BA2),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF667EEA)),
          child: Text('Create', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _postingDate,
      firstDate: DateTime(2020),
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

    if (picked != null && picked != _postingDate) {
      setState(() {
        _postingDate = picked;
      });
    }
  }

  void _saveSalesOrder() {
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

      // Here you would typically send the data to your backend
      Map<String, dynamic> salesOrderData = {
        'orderNumber': _orderNumberController.text,
        'postingDate': _postingDate.toIso8601String(),
        'customerId': _selectedCustomer,
        'items': _orderItems.map((item) => item.toJson()).toList(),
        'totalAmount': _totalAmount,
        'notes': _notesController.text,
      };

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sales Order created successfully!'),
          backgroundColor: Color(0xFF764BA2),
        ),
      );

      print('Sales Order Data: $salesOrderData');

      // Navigate back or to order list
      Navigator.pop(context);
    }
  }
}

// Data Models
class Customer {
  final String id;
  final String name;
  final String email;

  Customer({required this.id, required this.name, required this.email});
}

class Product {
  final String id;
  final String name;
  final double price;
  final String unit;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.unit,
  });
}

class OrderItem {
  final String productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final String unit;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.unit,
  });

  double get totalPrice => unitPrice * quantity;

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'unit': unit,
      'totalPrice': totalPrice,
    };
  }
}
