## 0.0.3

This release fixes calculation bugs and makes the package installable in more Flutter apps. Some fixes change results for inputs that were previously handled incorrectly; see **Behaviour changes** before upgrading.

### Fixed

* **Installable alongside `flutter_localizations`.** The `intl` constraint was `^0.20.3`, which requires Dart 3.9 and conflicts with the exact `intl` version Flutter pins (0.18.x–0.20.2 in Flutter 3.10–3.35). It is now `>=0.18.0 <0.21.0`. The SDK constraint now matches reality: `>=3.0.0 <4.0.0`.
* `IndianCurrencyFormatter.formatToWords` no longer sets `Intl.defaultLocale` for the whole app.
* `formatToWords` rounds to the nearest paisa first: `1.999` gave "One and One Hundred Paise Only", and now gives "Two Only".
* `formatToWords` for amounts below ₹1 no longer adds a leading space and " and": `0.5` gives "Fifty Paise Only".
* `formatToWords` no longer crashes on negative amounts ("Minus …"). It throws an `ArgumentError` for NaN, infinity and amounts of `1e13` or more, instead of crashing or returning nonsense.
* GST rounding is decimal-safe half-up: 18% of ₹0.25 gave `0.04` and now gives `0.05`.
* `GstTypeDetector.detect` throws a descriptive `ArgumentError` instead of a `RangeError` for inputs without a state code, and ignores surrounding whitespace.
* `FinancialYearHelper.getFY` no longer throws for years before 1000.

### Behaviour changes

* `InvoiceCalculator.calculate` rounds `tax` and `total` to paise (`precision`, default 2). Previously `subtotal: 1000.55` gave `tax: 180.099`; it now gives `180.1`.
* `InvoiceCalculator.calculate` throws an `ArgumentError` for a negative discount, a discount above the subtotal, a negative rate or non-finite values. Previously these produced negative totals.
* `GstCalculator.splitGST` calculates CGST and SGST each at half the rate, rather than halving the rounded total. It throws an `ArgumentError` for a negative rate or non-finite amount, and a `RangeError` for `precision` outside `0..10`.
* `HsnValidator.isValidHSN` accepts only 4, 6 or 8 digits (5 and 7 digit codes were accepted). `HsnValidator` ignores surrounding whitespace.
* `GstinValidator.isValid` ignores surrounding whitespace and accepts lowercase (as `PanValidator` already did), and accepts state code 97 (Other Territory).
* `FinancialYearHelper.currentFY` (and `InvoiceNumberGenerator.generate` without a date) uses Indian Standard Time, so it no longer returns the previous year between 00:00 and 05:30 IST on 1 April on servers running in UTC.
* `InvoiceNumberGenerator.generate` throws an `ArgumentError` for a negative `sequence`.
* `GstSlabHelper.isValidSlab(40)` returns `true`.

### Added

* Date-aware GST slabs for the September 2025 rate rationalisation: `GstSlabHelper.currentSlabs`, `legacySlabs`, `transitionSlabs`, `allSlabs`, `specialRates`, `slabsOn(date)`, `isValidSlab(rate, on: date)` and `isValidRate`.
* `GstTypeDetector.fromStateCodes` for B2C sales and place-of-supply based detection.
* `InvoiceNumberGenerator.generate(date: …)` for back-dated invoices and deterministic output, and `InvoiceNumberGenerator.isGstCompliant` for the 16-character rule.
* `FinancialYearHelper.getFYStartDate` and `getFYEndDate`.
* `InvoiceResult.taxableAmount`, `GstSplitResult.total`, and value equality (`==`/`hashCode`) and `toString` on both result classes.
* Amount parameters (`splitGST`'s `amount`/`rate`, `calculate`'s `subtotal`/`discount`/`gstRate`, `formatToWords`'s `amount`, `isValidSlab`'s `rate`) accept `num` instead of `double`/`int`, so `int` variables and fractional rates such as `0.25` can be passed directly.

### Deprecated

* `GstSlabHelper.slabs`: it lists the pre-September-2025 slabs. Use `currentSlabs`, `legacySlabs` or `slabsOn(date)`. The value is unchanged.

### Other

* The `NumberFormat` used by `IndianCurrencyFormatter.format` is created once instead of on every call.
* API documentation for all public members, a complete README, a full example, lints (`package:lints/recommended`), and a GitHub Actions workflow that tests on Dart 3.0 and stable, on the VM and in the browser.

## 0.0.2

* Updated `intl` and `test` dependencies to latest versions.

## 0.0.1

* **GST Utilities**: Added `GstCalculator` with rounding precision, `GstTypeDetector`, and `GstSlabHelper`.
* **Validators**: Enhanced validation for GSTIN (checksum & state codes), PAN (status & normalization), and HSN/SAC codes.
* **Currency Formatting**: Added `IndianCurrencyFormatter` with `formatToWords()` support (Lakhs/Crores) and symbol formatting.
* **Financial Year**: Improved `FinancialYearHelper` to calculate FY for any given `DateTime`.
* **Invoice Tools**: Added `InvoiceCalculator` and `InvoiceNumberGenerator` with custom padding support.
* **Models**: Structured data models for `InvoiceResult` and `GstSplitResult`.
