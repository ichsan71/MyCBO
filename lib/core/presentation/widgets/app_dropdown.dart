import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppDropdown<T> extends StatelessWidget {
  final String hintText;
  final String? labelText;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final bool isExpanded;
  final bool isDense;
  final EdgeInsetsGeometry? contentPadding;

  const AppDropdown({
    Key? key,
    required this.hintText,
    this.labelText,
    this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.isExpanded = true,
    this.isDense = false,
    this.contentPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: contentPadding ??
            const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
      ),
      hint: Text(
        hintText,
        style: GoogleFonts.poppins(fontSize: 14),
      ),
      value: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      isExpanded: isExpanded,
      isDense: isDense,
      icon: const Icon(Icons.arrow_drop_down),
      dropdownColor: Colors.white,
      style: GoogleFonts.poppins(
        fontSize: 14,
        color: Colors.black87,
      ),
    );
  }
}
