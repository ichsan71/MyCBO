import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class CustomConfirmationDialog extends StatefulWidget {
  final String title;
  final String message;
  final String? hintText;
  final bool showTextField;
  final String confirmText;
  final String cancelText;
  final Color? confirmColor;
  final bool isDestructive;
  final int? minLines;
  final int? maxLines;
  final int? minLength;
  final int? maxLength;

  const CustomConfirmationDialog({
    Key? key,
    required this.title,
    required this.message,
    this.hintText,
    this.showTextField = false,
    this.confirmText = 'Konfirmasi',
    this.cancelText = 'Batal',
    this.confirmColor,
    this.isDestructive = false,
    this.minLines,
    this.maxLines,
    this.minLength,
    this.maxLength,
  }) : super(key: key);

  @override
  State<CustomConfirmationDialog> createState() =>
      _CustomConfirmationDialogState();
}

class _CustomConfirmationDialogState extends State<CustomConfirmationDialog> {
  final TextEditingController _textController = TextEditingController();
  String _errorText = '';

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  bool get _isValid {
    if (!widget.showTextField) return true;
    if (widget.minLength != null &&
        _textController.text.length < widget.minLength!) {
      _errorText = 'Minimal ${widget.minLength} karakter';
      return false;
    }
    _errorText = '';
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  widget.isDestructive
                      ? Icons.warning_rounded
                      : Icons.help_rounded,
                  color: widget.isDestructive
                      ? AppTheme.errorColor
                      : AppTheme.primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.message,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            if (widget.showTextField) ...[
              const SizedBox(height: 20),
              TextField(
                controller: _textController,
                minLines: widget.minLines ?? 3,
                maxLines: widget.maxLines ?? 5,
                maxLength: widget.maxLength,
                decoration: InputDecoration(
                  hintText: widget.hintText ?? 'Tulis catatan...',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey[400],
                  ),
                  errorText: _errorText.isNotEmpty ? _errorText : null,
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.primaryColor),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.errorColor),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                style: GoogleFonts.poppins(),
                onChanged: (value) => setState(() {}),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    widget.cancelText,
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isValid
                      ? () => Navigator.pop(context, _textController.text)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.confirmColor ??
                        (widget.isDestructive
                            ? AppTheme.errorColor
                            : AppTheme.primaryColor),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    widget.confirmText,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
