import 'package:flutter/material.dart';

import '../service/create_sales_order_service.dart';

class CreateSalesOrderController extends ChangeNotifier {
  final CreateSalesOrderService _service = CreateSalesOrderService();

  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _response;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get response => _response;

  Future<void> createSalesOrder({
    required String customer,
    required String deliveryDate,
    required List<Map<String, dynamic>> items,
    required BuildContext context,
  }) async {
    _isLoading = true;
    _error = null;
    _response = null;
    notifyListeners();

    try {
      print("✅ Creating sales order...");
      print("   Customer: $customer");
      print("   Delivery Date: $deliveryDate");
      print("   Items: $items");

      _response = await _service.createSalesOrder(
        customer: customer,
        deliveryDate: deliveryDate,
        items: items,
      );
    } catch (e) {
      print("❌ Error creating sales order: $e");
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
