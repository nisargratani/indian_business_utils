# indian_business_utils

Utility package for Indian ERP, accounting, and billing apps.

## Features

• GST calculator  
• GSTIN validator  
• PAN validator  
• HSN validator  
• Invoice calculator  
• Invoice number generator  
• Financial year helper  
• Indian currency formatter  

## Installation

dependencies:
  indian_business_utils: ^0.0.1

## Usage

import 'package:indian_business_utils/indian_business_utils.dart';

final gst = GstCalculator.splitGST(
  amount: 1000,
  rate: 18,
  type: GstType.intraState,
);

print(gst.cgst);