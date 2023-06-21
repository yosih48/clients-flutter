import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Remove any non-numeric or non-decimal point characters
    final filteredValue = newValue.text.replaceAll(RegExp(r'[^0-9.]'), '');

    // Split the value into the whole number and decimal parts
    final parts = filteredValue.split('.');

    // Format the whole number part
    String formattedValue = NumberFormat.currency(
      decimalDigits: 2,
      symbol: '', // Remove currency symbol
    ).format(int.parse(parts[0]));

    // Add the decimal part if available
    if (parts.length > 1) {
      formattedValue += '.' + parts[1];
    }

    return TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: formattedValue.length),
    );
  }
}
