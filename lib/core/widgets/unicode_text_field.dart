import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// TextField with full Unicode support for Turkish characters
class UnicodeTextField extends StatelessWidget {
  const UnicodeTextField({
    super.key,
    this.controller,
    this.decoration,
    this.onChanged,
    this.onTap,
    this.minLines,
    this.maxLines,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.style,
    this.hintText,
    this.labelText,
    this.keyboardType,
    this.textInputAction,
    this.autocorrect = true,
    this.enableSuggestions = true,
  });

  final TextEditingController? controller;
  final InputDecoration? decoration;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final TextStyle? style;
  final String? hintText;
  final String? labelText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool autocorrect;
  final bool enableSuggestions;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: decoration ??
          InputDecoration(
            hintText: hintText,
            labelText: labelText,
          ),
      onChanged: onChanged,
      onTap: onTap,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
      enabled: enabled,
      readOnly: readOnly,
      style: style,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autocorrect: autocorrect,
      enableSuggestions: enableSuggestions,
      // Enable full Unicode support
      inputFormatters: [
        // Allow all Unicode characters including Turkish
        FilteringTextInputFormatter.allow(RegExp(r'[\s\S]')),
      ],
      // Ensure proper text rendering
      textCapitalization: TextCapitalization.sentences,
    );
  }
}

/// TextFormField with full Unicode support
class UnicodeTextFormField extends StatelessWidget {
  const UnicodeTextFormField({
    super.key,
    this.controller,
    this.decoration,
    this.validator,
    this.onChanged,
    this.onTap,
    this.minLines,
    this.maxLines,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.style,
    this.hintText,
    this.labelText,
    this.keyboardType,
    this.textInputAction,
    this.autocorrect = true,
    this.enableSuggestions = true,
  });

  final TextEditingController? controller;
  final InputDecoration? decoration;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final TextStyle? style;
  final String? hintText;
  final String? labelText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool autocorrect;
  final bool enableSuggestions;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: decoration ??
          InputDecoration(
            hintText: hintText,
            labelText: labelText,
          ),
      validator: validator,
      onChanged: onChanged,
      onTap: onTap,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
      enabled: enabled,
      readOnly: readOnly,
      style: style,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autocorrect: autocorrect,
      enableSuggestions: enableSuggestions,
      // Enable full Unicode support
      inputFormatters: [
        // Allow all Unicode characters including Turkish
        FilteringTextInputFormatter.allow(RegExp(r'[\s\S]')),
      ],
      // Ensure proper text rendering
      textCapitalization: TextCapitalization.sentences,
    );
  }
}

