import 'package:flutter/material.dart';
import 'package:location_tracker_app/view/mainscreen/sales_order/create_sales_order/create_sales_order.dart';

class CreateItemPage extends StatefulWidget {
  final Function(InventoryItem) onItemCreated;
  final List<Product>? existingProducts;

  const CreateItemPage({
    super.key,
    required this.onItemCreated,
    this.existingProducts,
  });

  @override
  _CreateItemPageState createState() => _CreateItemPageState();
}

class _CreateItemPageState extends State<CreateItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _unitController = TextEditingController(text: '');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create New Item'),
        backgroundColor: Color(0xFF764BA2),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Item Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Item Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.inventory_2),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter item name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _priceController,
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Price',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.money),
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Enter price';
                              }
                              if (double.tryParse(value!) == null) {
                                return 'Invalid price';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            controller: _unitController,
                            decoration: InputDecoration(
                              labelText: 'Unit',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.straighten),
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Enter unit';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _createItem,
              icon: Icon(Icons.save),
              label: Text('Create Item'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF764BA2),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createItem() {
    if (_formKey.currentState?.validate() ?? false) {
      final newItem = InventoryItem(
        name: _nameController.text.trim(),
        price: double.parse(_priceController.text),
        unit: _unitController.text.trim(),
      );

      widget.onItemCreated(newItem);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item "${newItem.name}" created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
