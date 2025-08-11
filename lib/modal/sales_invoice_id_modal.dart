class SalesInvoiceIdsModel {
  final String status;
  final int code;
  final String message;
  final List<String> invoiceIds;

  SalesInvoiceIdsModel({
    required this.status,
    required this.code,
    required this.message,
    required this.invoiceIds,
  });

  factory SalesInvoiceIdsModel.fromJson(Map<String, dynamic> json) {
    final msg = json['message'] ?? {};
    return SalesInvoiceIdsModel(
      status: msg['status'] ?? '',
      code: msg['code'] ?? 0,
      message: msg['message'] ?? '',
      invoiceIds: List<String>.from(msg['data'] ?? []),
    );
  }
}
