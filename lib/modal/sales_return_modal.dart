// To parse this JSON data, do
//
//     final salesReturnModal = salesReturnModalFromJson(jsonString);

import 'dart:convert';

SalesReturnModal salesReturnModalFromJson(String str) =>
    SalesReturnModal.fromJson(json.decode(str));

String salesReturnModalToJson(SalesReturnModal data) =>
    json.encode(data.toJson());

class SalesReturnModal {
  Message message;

  SalesReturnModal({required this.message});

  factory SalesReturnModal.fromJson(Map<String, dynamic> json) =>
      SalesReturnModal(message: Message.fromJson(json["message"]));

  Map<String, dynamic> toJson() => {"message": message.toJson()};
}

class Message {
  String status;
  List<Datum> data;

  Message({required this.status, required this.data});

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    status: json["status"],
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  String name;
  dynamic salesInvoiceId;
  String productName;
  double qty;
  String reason;
  dynamic date;
  String notes;
  String status;

  Datum({
    required this.name,
    required this.salesInvoiceId,
    required this.productName,
    required this.qty,
    required this.reason,
    required this.date,
    required this.notes,
    required this.status,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    name: json["name"],
    salesInvoiceId: json["sales_invoice_id"],
    productName: json["product_name"],
    qty: json["qty"],
    reason: json["reason"],
    date: json["date"],
    notes: json["notes"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "sales_invoice_id": salesInvoiceId,
    "product_name": productName,
    "qty": qty,
    "reason": reason,
    "date": date,
    "notes": notes,
    "status": status,
  };
}
