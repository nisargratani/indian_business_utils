## 0.0.4

This release makes invoice tax match the printed CGST/SGST split, makes `IndianCurrencyFormatter.format` agree with `formatToWords`, and tightens the GSTIN and PAN validators. Some fixes change results for inputs that were previously handled incorrectly; see **Behaviour changes** before upgrading.

### Fixed

* **Intra-state invoice tax matches CGST + SGST.** `InvoiceCalculator.calculate` rounds the tax at the full rate, while `GstCalculator.splitGST` rounds CGST and SGST separately at half the rate, so about half of all intra-state invoices printed a taxable amount, CGST and SGST that did not add up to the total (for example `subtotal: 100.05` gave tax `18.01`, but CGST + SGST was `9.00 + 9.00`). Pass the new `type:` argument and the tax is CGST + SGST, calculated by `splitGST` itself. Without `type`, the result is unchanged.
* `IndianCurrencyFormatter.format` rounds half-up to the nearest paisa, decimal-safe, like `formatToWords`. It rounded the binary value, so the same amount could show different paise in figures and in words: `2.675` printed `₹2.67` but read "Sixty Eight Paise".
* `format` no longer prints `-₹0.00` for `-0.0` or for negative amounts that round to zero, such as `-0.004`.
* `format` throws an `ArgumentError` for amounts of 2^63 or more instead of printing a different number: `1e20` printed `₹9,22,33,72,03,68,54,77,58,070.00`.
* `GstinValidator.isValid` and `PanValidator.isValid` reject non-ASCII letters. Upper-casing turned `ı` (dotless i) into `I` and `ſ` (long s) into `S`, so values such as `ıBCPE1234F` were accepted.
* `GstinValidator.isValid` checks the embedded PAN (characters 3–12) with `PanValidator`, so a GSTIN whose PAN has an invalid holder type, such as `D`, is rejected even when its check character is correct.
* `InvoiceCalculator.calculate` reports a negative `subtotal` as an `ArgumentError` on `subtotal`. It was reported as a bad `discount` ("Must not exceed subtotal").

### Behaviour changes

* `IndianCurrencyFormatter.format` output changes for amounts exactly halfway between two paise whose binary value is just below the half: `1.005` gives `₹1.01` (was `₹1.00`), `2.675` gives `₹2.68` (was `₹2.67`). `-0.0` and tiny negatives give `₹0.00` (was `-₹0.00`).
* `IndianCurrencyFormatter.format` throws an `ArgumentError` for a `double` whose absolute value is `IndianCurrencyFormatter.maxAmount` (2^63) or more. It returned wrong digits.
* `GstinValidator.isValid` returns `false` for GSTINs with non-ASCII letters or with an embedded PAN that `PanValidator` rejects. `PanValidator.isValid` returns `false` for PANs with non-ASCII letters.
* The `ArgumentError` for a negative `subtotal` in `InvoiceCalculator.calculate` names `subtotal` instead of `discount`.

### Added

* `InvoiceCalculator.calculate(type: …)`: with `GstType.intraState` the tax is CGST + SGST; with `GstType.interState` it is IGST. Without `type` the tax is rounded as IGST, as before.
* `InvoiceResult.gst`, the CGST/SGST or IGST split, set when `type` is passed. It is included in `==`, `hashCode` and, when set, `toString`.
* `IndianCurrencyFormatter.maxAmount`, the limit for `format`.

### Other

* Documentation: `GstTypeDetector.detect` and the README note that SEZ supplies and exports are inter-state whatever the GSTINs say. The GSTIN checksum is described as GSTN's Luhn mod-36 algorithm rather than ISO 7064. The `intl` constraint comment no longer says Flutter always pins an exact version.

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
