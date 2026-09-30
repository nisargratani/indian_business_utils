import '../src/numeric.dart';

/// GST amounts split into central, state and integrated components.
///
/// Intra-state supplies have [cgst] and [sgst] set and [igst] zero.
/// Inter-state supplies have only [igst] set.
class GstSplitResult {
  /// Central GST.
  final double cgst;

  /// State (or Union Territory) GST.
  final double sgst;

  /// Integrated GST.
  final double igst;

  /// Creates a result. Components that do not apply default to zero.
  const GstSplitResult({
    this.cgst = 0,
    this.sgst = 0,
    this.igst = 0,
  });

  /// Total tax: `cgst + sgst + igst`, without floating point noise.
  double get total => normalize(cgst + sgst + igst);

  @override
  bool operator ==(Object other) =>
      other is GstSplitResult &&
      other.cgst == cgst &&
      other.sgst == sgst &&
      other.igst == igst;

  @override
  int get hashCode => Object.hash(cgst, sgst, igst);

  @override
  String toString() => 'GstSplitResult(cgst: $cgst, sgst: $sgst, igst: $igst)';
}
