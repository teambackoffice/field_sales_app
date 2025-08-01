import 'package:flutter/widgets.dart';
import 'package:location_tracker_app/modal/invoice_list_modal.dart';
import 'package:location_tracker_app/service/invoice_list_service.dart';

class InvoiceListController extends ChangeNotifier {
  final InvoiceListService _service = InvoiceListService();
  bool _isLoading = false;
  String? _error;
  InvoiceListModal? invoiceList;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchInvoiceList() async {
    setLoading(true);
    notifyListeners();
    try {
      invoiceList = await _service.getinvoiceList();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? value) {
    _error = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ========== DRAFT PAYMENT MANAGEMENT METHODS ==========

  /// Refresh invoice list and clear any pending payment states
  /// Call this method periodically to sync with backend
  Future<void> refreshAndClearPendingPayments() async {
    setLoading(true);
    try {
      invoiceList = await _service.getinvoiceList();
      _error = null;

      // Clear pending payment states for all invoices after refresh
      if (invoiceList != null) {
        for (var invoice in invoiceList!.message.invoices) {
          invoice.clearPendingPayment();
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  /// Find invoice by ID and update its draft state
  void updateInvoiceDraftState(String invoiceId, double amount, String method) {
    if (invoiceList != null) {
      try {
        final invoice = invoiceList!.message.invoices.firstWhere(
          (inv) => inv.invoiceId == invoiceId,
        );
        invoice.markPaymentAsPending(amount, method);
        notifyListeners();
      } catch (e) {
        // Invoice not found - handle gracefully
        debugPrint('Invoice with ID $invoiceId not found');
      }
    }
  }

  /// Clear draft state for a specific invoice
  void clearInvoiceDraftState(String invoiceId) {
    if (invoiceList != null) {
      try {
        final invoice = invoiceList!.message.invoices.firstWhere(
          (inv) => inv.invoiceId == invoiceId,
        );
        invoice.clearPendingPayment();
        notifyListeners();
      } catch (e) {
        // Invoice not found - handle gracefully
        debugPrint('Invoice with ID $invoiceId not found');
      }
    }
  }

  /// Get count of invoices with pending payments
  int get pendingPaymentsCount {
    if (invoiceList == null) return 0;
    return invoiceList!.message.invoices
        .where((invoice) => invoice.hasPendingPayment)
        .length;
  }

  /// Get list of invoices with pending payments
  List<Invoice> get invoicesWithPendingPayments {
    if (invoiceList == null) return [];
    return invoiceList!.message.invoices
        .where((invoice) => invoice.hasPendingPayment)
        .toList();
  }

  /// Check if a specific invoice has pending payment
  bool hasInvoicePendingPayment(String invoiceId) {
    if (invoiceList == null) return false;
    try {
      final invoice = invoiceList!.message.invoices.firstWhere(
        (inv) => inv.invoiceId == invoiceId,
      );
      return invoice.hasPendingPayment;
    } catch (e) {
      return false;
    }
  }

  /// Get pending payment details for a specific invoice
  Map<String, dynamic>? getPendingPaymentDetails(String invoiceId) {
    if (invoiceList == null) return null;
    try {
      final invoice = invoiceList!.message.invoices.firstWhere(
        (inv) => inv.invoiceId == invoiceId,
      );
      if (invoice.hasPendingPayment) {
        return {
          'amount': invoice.pendingPaymentAmount,
          'method': invoice.pendingPaymentMethod,
        };
      }
    } catch (e) {
      debugPrint('Invoice with ID $invoiceId not found');
    }
    return null;
  }

  /// Mark all pending payments as processed (useful for bulk operations)
  void clearAllPendingPayments() {
    if (invoiceList != null) {
      for (var invoice in invoiceList!.message.invoices) {
        invoice.clearPendingPayment();
      }
      notifyListeners();
    }
  }

  /// Update invoice status locally (useful when you get confirmation from backend)
  void updateInvoiceStatus(String invoiceId, String newStatus) {
    if (invoiceList != null) {
      try {
        final invoice = invoiceList!.message.invoices.firstWhere(
          (inv) => inv.invoiceId == invoiceId,
        );
        invoice.status = newStatus;
        // Clear pending payment if status is now "Paid"
        if (newStatus.toLowerCase() == "paid") {
          invoice.clearPendingPayment();
        }
        notifyListeners();
      } catch (e) {
        debugPrint('Invoice with ID $invoiceId not found');
      }
    }
  }

  /// Refresh only if there are pending payments (optimization)
  Future<void> refreshIfNeeded() async {
    if (pendingPaymentsCount > 0) {
      await refreshAndClearPendingPayments();
    }
  }
}
