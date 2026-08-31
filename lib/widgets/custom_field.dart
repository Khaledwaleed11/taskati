import 'package:flutter/material.dart';

class CustomFormField extends StatelessWidget {
  final String hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const CustomFormField({
    super.key,
    required this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,

      style: TextStyle(
        color: theme.textTheme.bodyLarge?.color,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),

      cursorColor: colorScheme.primary,

      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,

        hintStyle: TextStyle(
          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.45),
          fontSize: 14,
        ),

        labelStyle: TextStyle(
          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.65),
        ),

        floatingLabelStyle: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),

        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                color: theme.iconTheme.color?.withValues(alpha: 0.65),
              )
            : null,

        suffixIcon: suffixIcon,

        filled: true,

        fillColor:
            theme.inputDecorationTheme.fillColor ??
            (theme.brightness == Brightness.dark
                ? Colors.grey.shade900
                : Colors.grey.shade100),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.12)
                : Colors.grey.shade300,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),

        errorStyle: const TextStyle(
          color: Colors.red,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
