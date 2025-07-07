import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_cbo/core/presentation/theme/app_theme.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final int? maxLines;
  final bool enabled;
  final Function(String)? onChanged;
  final FocusNode? focusNode;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.inputFormatters,
    this.maxLength,
    this.maxLines = 1,
    this.enabled = true,
    this.onChanged,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      maxLines: maxLines,
      enabled: enabled,
      onChanged: onChanged,
      focusNode: focusNode,
      style: GoogleFonts.poppins(
        fontSize: 14,
        color: AppTheme.primaryTextColor,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppTheme.secondaryTextColor)
            : null,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppTheme.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppTheme.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppTheme.errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppTheme.errorColor, width: 2),
        ),
        labelStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: AppTheme.secondaryTextColor,
        ),
        hintStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: AppTheme.secondaryTextColor.withOpacity(0.7),
        ),
        errorStyle: GoogleFonts.poppins(
          fontSize: 12,
          color: AppTheme.errorColor,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        filled: true,
        fillColor: AppTheme.cardBackgroundColor,
      ),
    );
  }
}
