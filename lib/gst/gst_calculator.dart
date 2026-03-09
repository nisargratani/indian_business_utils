import '../models/gst_split_result.dart';
import 'gst_type.dart';

/// Utility class for calculating GST values.
class GstCalculator {
  /// Splits GST into CGST/SGST or IGST depending on transaction type.
  static GstSplitResult splitGST({
    required double amount,
    required int rate,
    required GstType type,
  }) {
    final tax = amount * rate / 100;

    if (type == GstType.intraState) {
      return GstSplitResult(
        cgst: tax / 2,
        sgst: tax / 2,
      );
    } else {
      return GstSplitResult(
        igst: tax,
      );
    }
  }
}
