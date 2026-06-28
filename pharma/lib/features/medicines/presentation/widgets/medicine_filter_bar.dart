import 'package:flutter/material.dart';
import '../../domain/entities/medicine_entity.dart';

class MedicineFilterBar extends StatelessWidget {
  const MedicineFilterBar({
    super.key,
    required this.selectedCategory,
    required this.selectedForm,
    required this.controlledOnly,
    required this.onCategoryChanged,
    required this.onFormChanged,
    required this.onControlledToggled,
    required this.onClearAll,
    required this.hasActiveFilters,
  });

  final MedicineCategory? selectedCategory;
  final MedicineForm? selectedForm;
  final bool controlledOnly;
  final ValueChanged<MedicineCategory?> onCategoryChanged;
  final ValueChanged<MedicineForm?> onFormChanged;
  final VoidCallback onControlledToggled;
  final VoidCallback onClearAll;
  final bool hasActiveFilters;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Clear all
          if (hasActiveFilters) ...[
            _FilterChip(
              label: 'Clear all',
              icon: Icons.close_rounded,
              selected: false,
              isReset: true,
              onTap: onClearAll,
            ),
            const SizedBox(width: 8),
          ],
          // Category dropdown
          _DropdownChip<MedicineCategory>(
            label: selectedCategory?.label ?? 'Category',
            value: selectedCategory,
            items: MedicineCategory.values,
            itemLabel: (c) => c.label,
            onChanged: onCategoryChanged,
            isActive: selectedCategory != null,
          ),
          const SizedBox(width: 8),
          // Form dropdown
          _DropdownChip<MedicineForm>(
            label: selectedForm?.label ?? 'Form',
            value: selectedForm,
            items: MedicineForm.values,
            itemLabel: (f) => f.label,
            onChanged: onFormChanged,
            isActive: selectedForm != null,
          ),
          const SizedBox(width: 8),
          // Controlled toggle
          _FilterChip(
            label: 'Controlled',
            icon: Icons.warning_rounded,
            selected: controlledOnly,
            onTap: onControlledToggled,
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.isReset = false,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final bool isReset;

  @override
  Widget build(BuildContext context) {
    final activeColor = isReset
        ? const Color(0xFF666666)
        : const Color(0xFF1565C0);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? activeColor.withOpacity(0.12)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? activeColor : Colors.black.withOpacity(0.1),
            width: selected ? 1.2 : 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 13,
                color: selected ? activeColor : const Color(0xFF888888)),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: selected ? activeColor : const Color(0xFF555555),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DropdownChip<T> extends StatelessWidget {
  const _DropdownChip({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    required this.isActive,
  });
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF1565C0);
    return GestureDetector(
      onTap: () async {
        final selected = await showModalBottomSheet<T>(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => _PickerSheet<T>(
            title: label,
            items: items,
            itemLabel: itemLabel,
            selected: value,
          ),
        );
        if (selected != null) {
          onChanged(value == selected ? null : selected as T?);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withOpacity(0.12) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? activeColor : Colors.black.withOpacity(0.1),
            width: isActive ? 1.2 : 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value != null ? itemLabel(value as T) : label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isActive ? activeColor : const Color(0xFF555555),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 14,
              color: isActive ? activeColor : const Color(0xFF888888),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickerSheet<T> extends StatelessWidget {
  const _PickerSheet({
    required this.title,
    required this.items,
    required this.itemLabel,
    required this.selected,
  });
  final String title;
  final List<T> items;
  final String Function(T) itemLabel;
  final T? selected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            title,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
        const Divider(height: 1),
        ...items.map((item) => ListTile(
              title: Text(itemLabel(item), style: const TextStyle(fontSize: 14)),
              trailing: selected == item
                  ? const Icon(Icons.check_rounded,
                      color: Color(0xFF1565C0))
                  : null,
              onTap: () => Navigator.pop(context, item),
            )),
        const SizedBox(height: 16),
      ],
    );
  }
}