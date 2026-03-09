/// Provides GST slab utilities.
class GstSlabHelper {
  /// Standard GST rates used in India.
  static const List<int> slabs = [0, 5, 12, 18, 28];

  /// Checks if a GST rate is valid.
  static bool isValidSlab(int rate) {
    return slabs.contains(rate);
  }
}
