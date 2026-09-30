/// GST transaction type, which decides how tax is split.
enum GstType {
  /// Supplier and place of supply are in the same state: CGST + SGST.
  intraState,

  /// Supplier and place of supply are in different states: IGST.
  interState,
}
