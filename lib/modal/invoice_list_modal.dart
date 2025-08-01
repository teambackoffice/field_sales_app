// To parse this JSON data, do
//
//     final invoiceListModal = invoiceListModalFromJson(jsonString);

import 'dart:convert';

InvoiceListModal invoiceListModalFromJson(String str) =>
    InvoiceListModal.fromJson(json.decode(str));

String invoiceListModalToJson(InvoiceListModal data) =>
    json.encode(data.toJson());

class InvoiceListModal {
  Message message;

  InvoiceListModal({required this.message});

  factory InvoiceListModal.fromJson(Map<String, dynamic> json) =>
      InvoiceListModal(message: Message.fromJson(json["message"]));

  Map<String, dynamic> toJson() => {"message": message.toJson()};
}

class Message {
  List<Invoice> invoices;

  Message({required this.invoices});

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    invoices: List<Invoice>.from(
      json["invoices"].map((x) => Invoice.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "invoices": List<dynamic>.from(invoices.map((x) => x.toJson())),
  };
}

// Updated Invoice class with local draft state management
class Invoice {
  String invoiceId;
  String customer;
  DateTime postingDate;
  DateTime dueDate;
  double grandTotal;
  double outstandingAmount;
  String status;
  List<Item> items;

  // Local state management for draft payments
  bool _hasPendingPayment = false;
  double _pendingPaymentAmount = 0.0;
  String _pendingPaymentMethod = '';

  Invoice({
    required this.invoiceId,
    required this.customer,
    required this.postingDate,
    required this.dueDate,
    required this.grandTotal,
    required this.outstandingAmount,
    required this.status,
    required this.items,
  });

  // Getters for draft state
  bool get hasPendingPayment => _hasPendingPayment;
  double get pendingPaymentAmount => _pendingPaymentAmount;
  String get pendingPaymentMethod => _pendingPaymentMethod;

  // Computed property for display status
  String get displayStatus {
    if (_hasPendingPayment) {
      return "Processing";
    }
    return status;
  }

  // Method to mark payment as pending
  void markPaymentAsPending(double amount, String method) {
    _hasPendingPayment = true;
    _pendingPaymentAmount = amount;
    _pendingPaymentMethod = method;
  }

  // Method to clear pending payment (when invoice is refreshed from backend)
  void clearPendingPayment() {
    _hasPendingPayment = false;
    _pendingPaymentAmount = 0.0;
    _pendingPaymentMethod = '';
  }

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
    invoiceId: json["invoice_id"],
    customer: json["customer"],
    postingDate: DateTime.parse(json["posting_date"]),
    dueDate: DateTime.parse(json["due_date"]),
    grandTotal: json["grand_total"]?.toDouble() ?? 0.0,
    outstandingAmount: json["outstanding_amount"]?.toDouble() ?? 0.0,
    status: json["status"],
    items: List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "invoice_id": invoiceId,
    "customer": customer,
    "posting_date":
        "${postingDate.year.toString().padLeft(4, '0')}-${postingDate.month.toString().padLeft(2, '0')}-${postingDate.day.toString().padLeft(2, '0')}",
    "due_date":
        "${dueDate.year.toString().padLeft(4, '0')}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}",
    "grand_total": grandTotal,
    "outstanding_amount": outstandingAmount,
    "status": status,
    "items": List<dynamic>.from(items.map((x) => x.toJson())),
  };
}

class Item {
  String itemCode;
  String itemName;
  double qty;
  double rate;
  double amount;
  String description;

  Item({
    required this.itemCode,
    required this.itemName,
    required this.qty,
    required this.rate,
    required this.amount,
    required this.description,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    itemCode: json["item_code"],
    itemName: json["item_name"],
    qty: json["qty"],
    rate: json["rate"],
    amount: json["amount"],
    description: json["description"],
  );

  Map<String, dynamic> toJson() => {
    "item_code": itemCode,
    "item_name": itemName,
    "qty": qty,
    "rate": rate,
    "amount": amount,
    "description": description,
  };
}
