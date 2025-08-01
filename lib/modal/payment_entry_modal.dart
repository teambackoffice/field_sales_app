// To parse this JSON data, do
//
//     final paymentEntryModal = paymentEntryModalFromJson(jsonString);

import 'dart:convert';

PaymentEntryModal paymentEntryModalFromJson(String str) =>
    PaymentEntryModal.fromJson(json.decode(str));

String paymentEntryModalToJson(PaymentEntryModal data) =>
    json.encode(data.toJson());

class PaymentEntryModal {
  Message message;

  PaymentEntryModal({required this.message});

  factory PaymentEntryModal.fromJson(Map<String, dynamic> json) =>
      PaymentEntryModal(message: Message.fromJson(json["message"]));

  Map<String, dynamic> toJson() => {"message": message.toJson()};
}

class Message {
  String status;
  String customer;
  int invoiceCount;
  int totalOutstandingAmount;
  List<Invoice> invoices;

  Message({
    required this.status,
    required this.customer,
    required this.invoiceCount,
    required this.totalOutstandingAmount,
    required this.invoices,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    status: json["status"],
    customer: json["customer"],
    invoiceCount: json["invoice_count"],
    totalOutstandingAmount: json["total_outstanding_amount"],
    invoices: List<Invoice>.from(
      json["invoices"].map((x) => Invoice.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "customer": customer,
    "invoice_count": invoiceCount,
    "total_outstanding_amount": totalOutstandingAmount,
    "invoices": List<dynamic>.from(invoices.map((x) => x.toJson())),
  };
}

class Invoice {
  String invoiceName;
  DateTime postingDate;
  DateTime dueDate;
  int grandTotal;
  int outstandingAmount;
  List<Item> items;

  Invoice({
    required this.invoiceName,
    required this.postingDate,
    required this.dueDate,
    required this.grandTotal,
    required this.outstandingAmount,
    required this.items,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
    invoiceName: json["invoice_name"],
    postingDate: DateTime.parse(json["posting_date"]),
    dueDate: DateTime.parse(json["due_date"]),
    grandTotal: json["grand_total"],
    outstandingAmount: json["outstanding_amount"],
    items: List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "invoice_name": invoiceName,
    "posting_date":
        "${postingDate.year.toString().padLeft(4, '0')}-${postingDate.month.toString().padLeft(2, '0')}-${postingDate.day.toString().padLeft(2, '0')}",
    "due_date":
        "${dueDate.year.toString().padLeft(4, '0')}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}",
    "grand_total": grandTotal,
    "outstanding_amount": outstandingAmount,
    "items": List<dynamic>.from(items.map((x) => x.toJson())),
  };
}

class Item {
  String itemCode;
  String itemName;
  int qty;
  int rate;
  int amount;

  Item({
    required this.itemCode,
    required this.itemName,
    required this.qty,
    required this.rate,
    required this.amount,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    itemCode: json["item_code"],
    itemName: json["item_name"],
    qty: json["qty"],
    rate: json["rate"],
    amount: json["amount"],
  );

  Map<String, dynamic> toJson() => {
    "item_code": itemCode,
    "item_name": itemName,
    "qty": qty,
    "rate": rate,
    "amount": amount,
  };
}
