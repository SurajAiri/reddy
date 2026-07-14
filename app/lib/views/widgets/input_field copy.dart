import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  const InputField({
    super.key,
    this.hintText,
    this.labelText,
    this.controller,
    this.maxLength,
    this.keyboardType,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.contentPadding,
    this.onChanged,
    this.style,
    this.maxLines = 1,
    this.enabled = true,
    this.obscureText = false,
    this.focusNode,
  });
  final FocusNode? focusNode;
  final bool obscureText;
  final String? labelText;
  final TextEditingController? controller;
  final String? hintText;
  final int? maxLength;
  final int maxLines;
  final TextInputType? keyboardType;
  final bool enabled;
  final EdgeInsets? contentPadding;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final TextStyle? style;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: focusNode,
      style: style,
      enabled: enabled,
      validator: validator,
      maxLength: maxLength,
      maxLines: maxLines,
      keyboardType: keyboardType,
      controller: controller,
      onChanged: onChanged,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        contentPadding: contentPadding,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
