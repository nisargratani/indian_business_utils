## 0.0.1

* **GST Utilities**: Added `GstCalculator` with rounding precision, `GstTypeDetector`, and `GstSlabHelper`.
* **Validators**: Enhanced validation for GSTIN (checksum & state codes), PAN (status & normalization), and HSN/SAC codes.
* **Currency Formatting**: Added `IndianCurrencyFormatter` with `formatToWords()` support (Lakhs/Crores) and symbol formatting.
* **Financial Year**: Improved `FinancialYearHelper` to calculate FY for any given `DateTime`.
* **Invoice Tools**: Added `InvoiceCalculator` and `InvoiceNumberGenerator` with custom padding support.
* **Models**: Structured data models for `InvoiceResult` and `GstSplitResult`.
