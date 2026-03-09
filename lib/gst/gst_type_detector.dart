import 'gst_type.dart';

/// Detects GST transaction type using GSTIN state codes.
class GstTypeDetector {
  static GstType detect({
    required String sellerGSTIN,
    required String buyerGSTIN,
  }) {
    final sellerState = sellerGSTIN.substring(0, 2);
    final buyerState = buyerGSTIN.substring(0, 2);

    if (sellerState == buyerState) {
      return GstType.intraState;
    }

    return GstType.interState;
  }
}
