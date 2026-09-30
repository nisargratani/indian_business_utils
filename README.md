# indian_business_utils

Pure-Dart helpers for Indian billing, accounting and ERP apps. Works in Flutter apps (all platforms, including web) and in server-side Dart.

| Area | API |
| --- | --- |
| GST calculation | `GstCalculator.splitGST` (CGST/SGST or IGST, half-up rounding to paise) |
| GST type | `GstTypeDetector.detect`, `GstTypeDetector.fromStateCodes` |
| GST slabs | `GstSlabHelper` (date-aware, covers the September 2025 rate rationalisation) |
| Validation | `GstinValidator` (format, state code, check digit), `PanValidator`, `HsnValidator` |
| Invoices | `InvoiceCalculator.calculate`, `InvoiceNumberGenerator` |
| Financial year | `FinancialYearHelper` (`2025-26` labels, start/end dates) |
| Currency | `IndianCurrencyFormatter.format` (`₹12,34,567.00`), `formatToWords` |

## Installation

```sh
dart pub add indian_business_utils
# or
flutter pub add indian_business_utils
```

Requires Dart 3.0 or later (Flutter 3.10 or later). The only dependency is `intl`, and any version from 0.18 to 0.20 is accepted, so it works alongside `flutter_localizations`.

```dart
import 'package:indian_business_utils/indian_business_utils.dart';
```

## Quick start: a complete invoice

```dart
final invoice = InvoiceCalculator.calculate(
  subtotal: 5000,
  discount: 200,
  gstRate: 18,
);
// invoice.taxableAmount == 4800.0, invoice.tax == 864.0, invoice.total == 5664.0

final type = GstTypeDetector.detect(
  sellerGSTIN: '27AAPFU0939F1ZV', // Maharashtra
  buyerGSTIN: '27AAACR5055K1Z7',  // Maharashtra
); // GstType.intraState

final gst = GstCalculator.splitGST(
  amount: invoice.taxableAmount,
  rate: 18,
  type: type,
);
// gst.cgst == 432.0, gst.sgst == 432.0, gst.total == 864.0

final number = InvoiceNumberGenerator.generate(
  sequence: 1,
  date: DateTime(2025, 6, 1),
); // 'INV/2025-26/0001'

IndianCurrencyFormatter.format(invoice.total);        // '₹5,664.00'
IndianCurrencyFormatter.formatToWords(invoice.total); // 'Five Thousand Six Hundred Sixty Four Only'
```

## GST

### Calculating and splitting GST

```dart
final intra = GstCalculator.splitGST(
  amount: 1000,
  rate: 18,
  type: GstType.intraState,
);
// intra.cgst == 90.0, intra.sgst == 90.0, intra.igst == 0.0

final inter = GstCalculator.splitGST(
  amount: 1000.55,
  rate: 18,
  type: GstType.interState,
);
// inter.igst == 180.1
```

* Values are rounded **half-up** to `precision` decimal places (default `2`). The rounding is decimal-safe: 18% of ₹0.25 gives `0.05`, not `0.04`.
* CGST and SGST are each calculated at half the rate and rounded on their own, as the law requires.
* `rate` accepts fractional rates such as `0.25`, `1.5` and `3`.
* Negative amounts, such as credit-note adjustments, give negative tax.
* An `ArgumentError` is thrown for a NaN/infinite amount or a negative rate, and a `RangeError` for `precision` outside `0..10`.

### Intra-state or inter-state?

```dart
GstTypeDetector.detect(
  sellerGSTIN: '27AAPFU0939F1ZV',
  buyerGSTIN: '24AAACC1206D1ZM',
); // GstType.interState

// B2C sale, or a place of supply different from the buyer's state:
GstTypeDetector.fromStateCodes(
  supplierStateCode: '27',
  placeOfSupplyStateCode: '27',
); // GstType.intraState
```

`detect` only compares the two-digit state codes. It throws an `ArgumentError` if a value does not start with one. Validate the full GSTIN with `GstinValidator` first.

### GST slabs

GST slabs changed on 22 September 2025 (12% and 28% removed, 40% added) and again on 1 February 2026 (tobacco and pan masala moved from 28% to 40%). Invoices for older supplies still use the old rates, so validation can be date-aware:

```dart
GstSlabHelper.currentSlabs;                             // [0, 5, 18, 40]
GstSlabHelper.slabsOn(DateTime(2024, 5, 1));            // [0, 5, 12, 18, 28]
GstSlabHelper.isValidSlab(40, on: DateTime(2026, 4, 1)); // true
GstSlabHelper.isValidSlab(12, on: DateTime(2026, 4, 1)); // false
GstSlabHelper.isValidSlab(12);   // true: without a date, any slab ever in force
GstSlabHelper.isValidRate(3);    // true: special rate (gold, silver)
```

## Validators

```dart
GstinValidator.isValid('27AAPFU0939F1ZV'); // true
GstinValidator.isValid('27AAPFU0939F1ZW'); // false: wrong check digit

PanValidator.isValid('ABCPE1234F'); // true
PanValidator.isValid('ABCDE1234F'); // false: 'D' is not a holder type

HsnValidator.isValidHSN('8517');   // true (4, 6 or 8 digits)
HsnValidator.isValidSAC('998311'); // true (6 digits starting with 99)
HsnValidator.isValid('85171');     // false
```

* All validators ignore surrounding whitespace, and the GSTIN and PAN validators accept lowercase. Store the normalized value (`value.trim().toUpperCase()`).
* `GstinValidator` accepts PAN-based GSTINs with state codes 01–38 and 97. TDS/TCS, UIN, NRTP and OIDAR registrations are not supported.
* The validators check format only. They do not confirm that a number is registered or that an HSN code exists. Use the GST portal for that.

## Invoices

```dart
final invoice = InvoiceCalculator.calculate(subtotal: 1000.55); // gstRate defaults to 18
// invoice.tax == 180.1, invoice.total == 1180.65
```

`taxableAmount`, `tax` and `total` are rounded half-up to `precision` places (default `2`). An `ArgumentError` is thrown if a discount is negative or exceeds the subtotal, or if the rate is negative.

```dart
InvoiceNumberGenerator.generate(sequence: 42, date: DateTime(2025, 6, 1));
// 'INV/2025-26/0042'
InvoiceNumberGenerator.generate(sequence: 7, prefix: 'BILL', padding: 3);
// 'BILL/<current FY>/007'

InvoiceNumberGenerator.isGstCompliant('INV/2025-26/0001');   // true
InvoiceNumberGenerator.isGstCompliant('INV/2025-26/000001'); // false: over 16 characters
```

The generator formats numbers but does not track them. Store the last issued sequence per financial year in your database. GST requires invoice numbers of at most 16 characters, using only letters, digits, `-` and `/`, so check a custom prefix or padding with `isGstCompliant`.

## Financial year

```dart
FinancialYearHelper.getFY(DateTime(2025, 3, 31));          // '2024-25'
FinancialYearHelper.getFY(DateTime(2025, 4, 1));           // '2025-26'
FinancialYearHelper.getFYStartDate(DateTime(2026, 1, 15)); // 2025-04-01
FinancialYearHelper.getFYEndDate(DateTime(2026, 1, 15));   // 2026-03-31
FinancialYearHelper.currentFY();                           // based on IST
```

`currentFY()` (and `InvoiceNumberGenerator.generate` without a `date`) uses Indian Standard Time, so servers running in UTC switch financial year at midnight IST on 1 April.

## Currency

```dart
IndianCurrencyFormatter.format(1234567.891); // '₹12,34,567.89'
IndianCurrencyFormatter.format(-1234.5);     // '-₹1,234.50'

IndianCurrencyFormatter.formatToWords(1234.56);
// 'One Thousand Two Hundred Thirty Four and Fifty Six Paise Only'
IndianCurrencyFormatter.formatToWords(125000); // 'One Lakh Twenty Five Thousand Only'
IndianCurrencyFormatter.formatToWords(0.5);    // 'Fifty Paise Only'
IndianCurrencyFormatter.formatToWords(-25);    // 'Minus Twenty Five Only'
```

`formatToWords` rounds to the nearest paisa first. It throws an `ArgumentError` for NaN, infinity, or amounts of 10,00,000 crore (`1e13`) or more. Neither method reads or changes `Intl.defaultLocale`.

## Notes

* **Money as `double`.** Results are `double` values rounded to paise, which is precise for amounts well beyond typical invoice values. If you total many line items, round the final sum again (or keep amounts in paise as integers).
* **Error handling.** Invalid arguments throw `ArgumentError` (or its subclass `RangeError`) with the parameter name and reason. Validators never throw; they return `false`.
* **Platforms.** The package is pure Dart with no platform code. It is tested on the Dart VM, JavaScript (Chrome and Node) and WebAssembly.
* **Not tax advice.** Rates and rules change, so confirm with a tax professional for your use case.

## Contributing

Issues and pull requests are welcome at [GitHub](https://github.com/nisargratani/indian_business_utils/issues).
