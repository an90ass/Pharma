import 'package:flutter/material.dart';

class MedicineSearchBar extends StatefulWidget {
  const MedicineSearchBar({
    super.key,
    required this.onChanged,
    this.hintText = 'Search by name, generic, barcode…',
  });
  final ValueChanged<String> onChanged;
  final String hintText;

  @override
  State<MedicineSearchBar> createState() => _MedicineSearchBarState();
}

class _MedicineSearchBarState extends State<MedicineSearchBar> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.08)),
      ),
      child: TextField(
        controller: _ctrl,
        onChanged: widget.onChanged,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            fontSize: 13,
            color: Colors.grey.withOpacity(0.6),
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 20,
            color: Color(0xFF1565C0),
          ),
          suffixIcon: _ctrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: () {
                    _ctrl.clear();
                    widget.onChanged('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        ),
      ),
    );
  }
}