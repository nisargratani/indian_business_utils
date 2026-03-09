import '../models/gst_split_result.dart';
import 'gst_type.dart';

/// Utility class for calculating GST values.
class GstCalculator {
  /// Splits GST into CGST/SGST or IGST depending on transaction type.
  /// [precision] specifies decimal places to round to (default is 2).
  static GstSplitResult splitGST({
    required double amount,
    required int rate,
    required GstType type,
    int precision = 2,
  }) {
    double tax = amount * rate / 100;

    // Apply rounding
    tax = double.parse(tax.toStringAsFixed(precision));

    if (type == GstType.intraState) {
      final split = tax / 2;
      return GstSplitResult(
        cgst: double.parse(split.toStringAsFixed(precision)),
        sgst: double.parse(split.toStringAsFixed(precision)),
      );
    } else {
      return GstSplitResult(
        igst: tax,
      );
    }
  }
}
