import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:location_tracker_app/service/create_sales_return_service.dart';

class CreateSalesReturnController with ChangeNotifier {
  final CreateSalesReturnService _salesReturnService =
      CreateSalesReturnService();

  bool isLoading = false;
  String? errorMessage;
  Map<String, dynamic>? responseData;

  Future<void> createSalesReturn({
    required String invoiceName,
    required String productName,
    required int qty,
    required String reason,
    required String buyingDate,
    String? notes,
  }) async {
    isLoading = true;
    errorMessage = null;
    responseData = null;
    notifyListeners();

    try {
      final response = await _salesReturnService.createSalesReturn(
        invoiceName: invoiceName,
        productName: productName,
        qty: qty,
        reason: reason,
        buyingDate: buyingDate,
        notes: notes,
      );

      if (response.statusCode == 200) {
        responseData = json.decode(response.body);
      } else {
        errorMessage = "Error: ${response.reasonPhrase}";
      }
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
}
