/// GST rate slab utilities.
///
/// GST slabs have changed over time:
///
/// | Period                     | Standard slabs            |
/// | -------------------------- | ------------------------- |
/// | 1 Jul 2017 – 21 Sep 2025   | 0, 5, 12, 18, 28          |
/// | 22 Sep 2025 – 31 Jan 2026  | 0, 5, 18, 40 (28 for tobacco and pan masala) |
/// | 1 Feb 2026 onwards         | 0, 5, 18, 40              |
///
/// 12% stopped being a standard slab on 22 Sep 2025, but it still applies
/// to bricks and tiles (Notification 14/2025-Central Tax (Rate)), so it
/// remains one of the [specialRates] accepted by [isValidRate].
///
/// Invoices, credit notes and amendments for older supplies still use the
/// slabs that applied then, so pass the supply date to [slabsOn] or
/// [isValidSlab] when you validate historical data.
class GstSlabHelper {
  /// The slabs in force before 22 September 2025.
  @Deprecated(
    'These are the pre-22-Sep-2025 slabs. '
    'Use currentSlabs, legacySlabs or slabsOn(date) instead.',
  )
  static const List<int> slabs = legacySlabs;

  /// Standard slabs from 1 July 2017 until 21 September 2025.
  static const List<int> legacySlabs = [0, 5, 12, 18, 28];

  /// Standard slabs from 22 September 2025 until 31 January 2026. The 28%
  /// rate still applied to tobacco and pan masala.
  static const List<int> transitionSlabs = [0, 5, 18, 28, 40];

  /// Standard slabs in force from 1 February 2026.
  static const List<int> currentSlabs = [0, 5, 18, 40];

  /// Every standard slab that has been in force at any time.
  static const List<int> allSlabs = [0, 5, 12, 18, 28, 40];

  /// Rates outside the current standard slabs that apply to specific goods
  /// or supplies:
  ///
  /// * 0.1%: supplies to merchant exporters (CGST 0.05% + SGST 0.05% under
  ///   Notification 40/2017-Central Tax (Rate), or IGST 0.1% under
  ///   Notification 41/2017-Integrated Tax (Rate)).
  /// * 0.25%: rough precious and semi-precious stones.
  /// * 1.5%: cut and polished diamonds.
  /// * 3%: gold, silver and jewellery.
  /// * 6%: bricks under the special composition scheme, without input tax
  ///   credit.
  /// * 12%: bricks and tiles (fly ash bricks, aggregates and blocks, bricks
  ///   of fossil meals, building bricks, earthen or roofing tiles), CGST 6% +
  ///   SGST 6% under Notification 14/2025-Central Tax (Rate) from
  ///   22 Sep 2025; also the bricks composition scheme with input tax
  ///   credit.
  ///
  /// These rates are not checked against a date.
  static const List<double> specialRates = [0.1, 0.25, 1.5, 3, 6, 12];

  /// Date from which the rationalised slabs (5%, 18%, 40%) apply.
  static final DateTime rationalisationDate = DateTime(2025, 9, 22);

  /// Date from which tobacco and pan masala moved from 28% to 40%.
  static final DateTime tobaccoTransitionDate = DateTime(2026, 2, 1);

  /// Returns the standard slabs in force on [date].
  ///
  /// Only the calendar date of [date] is used. Dates before GST was
  /// introduced return [legacySlabs].
  static List<int> slabsOn(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    if (day.isBefore(rationalisationDate)) return legacySlabs;
    if (day.isBefore(tobaccoTransitionDate)) return transitionSlabs;
    return currentSlabs;
  }

  /// Returns true if [rate] is a standard GST slab.
  ///
  /// Without [on], any slab that has ever been in force is accepted (see
  /// [allSlabs]). With [on], only the slabs in force on that date are
  /// accepted (see [slabsOn]).
  ///
  /// ```dart
  /// GstSlabHelper.isValidSlab(12);                         // true
  /// GstSlabHelper.isValidSlab(12, on: DateTime(2026, 4)); // false
  /// GstSlabHelper.isValidSlab(40, on: DateTime(2026, 4)); // true
  /// ```
  static bool isValidSlab(num rate, {DateTime? on}) =>
      (on == null ? allSlabs : slabsOn(on)).contains(rate);

  /// Returns true if [rate] is a standard slab (see [isValidSlab]) or one of
  /// the [specialRates].
  ///
  /// [on] only restricts the standard slabs, so
  /// `isValidRate(12, on: DateTime(2026, 4))` is true (bricks and tiles)
  /// while `isValidSlab(12, on: DateTime(2026, 4))` is false.
  static bool isValidRate(num rate, {DateTime? on}) =>
      isValidSlab(rate, on: on) || specialRates.contains(rate);
}
