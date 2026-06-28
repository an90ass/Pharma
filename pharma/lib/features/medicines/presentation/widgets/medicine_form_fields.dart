import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/medicine_entity.dart';

// ── App-level reusable input style ────────────────────────────────────────────

InputDecoration appInputDecoration({
  required String label,
  String? hint,
  IconData? prefixIcon,
  Widget? suffix,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: prefixIcon != null
        ? Icon(prefixIcon, size: 18, color: const Color(0xFF1565C0))
        : null,
    suffix: suffix,
    labelStyle:
        const TextStyle(fontSize: 13, color: Color(0xFF666666)),
    hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFBBBBBB)),
    filled: true,
    fillColor: const Color(0xFFF9FAFB),
    contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFF1565C0), width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFF44336)),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFF44336), width: 1.5),
    ),
  );
}

// ── Text field ─────────────────────────────────────────────────────────────────

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.prefixIcon,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.enabled = true,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      enabled: enabled,
      style: const TextStyle(fontSize: 14),
      decoration: appInputDecoration(
        label: label,
        hint: hint,
        prefixIcon: prefixIcon,
      ),
    );
  }
}

// ── Dropdown field ─────────────────────────────────────────────────────────────

class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.validator,
  });

  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;
  final String? Function(T?)? validator;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
      decoration: appInputDecoration(label: label),
      items: items
          .map((item) => DropdownMenuItem<T>(
                value: item,
                child: Text(itemLabel(item),
                    style: const TextStyle(fontSize: 14)),
              ))
          .toList(),
    );
  }
}

// ── Section header ─────────────────────────────────────────────────────────────

class FormSectionHeader extends StatelessWidget {
  const FormSectionHeader({super.key, required this.title, this.icon});
  final String title;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: const Color(0xFF1565C0)),
            const SizedBox(width: 6),
          ],
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1565C0),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }
}