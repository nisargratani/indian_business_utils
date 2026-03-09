/// Result object containing GST split values.
class GstSplitResult {
  final double cgst;
  final double sgst;
  final double igst;

  const GstSplitResult({
    this.cgst = 0,
    this.sgst = 0,
    this.igst = 0,
  });
}
