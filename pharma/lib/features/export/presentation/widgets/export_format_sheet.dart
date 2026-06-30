import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/export_repository.dart';
import '../viewmodels/export_viewmodel.dart';

/// Bottom sheet for choosing PDF or Excel export.
/// Usage:
/// ```dart
/// showExportSheet(context, onFormat: (fmt) => vm.exportSalesReport(report, fmt));
/// ```
void showExportSheet(
  BuildContext context, {
  required void Function(ExportFormat) onFormat,
}) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => ExportFormatSheet(onFormat: onFormat),
  );
}

class ExportFormatSheet extends ConsumerWidget {
  const ExportFormatSheet({super.key, required this.onFormat});
  final void Function(ExportFormat) onFormat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(exportViewModelProvider);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Export format',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          _FormatTile(
            icon: Icons.table_chart_rounded,
            label: 'Excel (.xlsx)',
            subtitle: 'Open in Microsoft Excel or Google Sheets',
            color: const Color(0xFF2E7D32),
            loading: state.isExporting,
            onTap: () { Navigator.pop(context); onFormat(ExportFormat.excel); },
          ),
          const SizedBox(height: 10),
          _FormatTile(
            icon: Icons.picture_as_pdf_rounded,
            label: 'PDF (.pdf)',
            subtitle: 'Print-ready, shareable format',
            color: const Color(0xFFE53935),
            loading: state.isExporting,
            onTap: () { Navigator.pop(context); onFormat(ExportFormat.pdf); },
          ),
        ],
      ),
    );
  }
}

class _FormatTile extends StatelessWidget {
  const _FormatTile({
    required this.icon, required this.label, required this.subtitle,
    required this.color, required this.loading, required this.onTap,
  });
  final IconData icon;
  final String label, subtitle;
  final Color color;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: loading ? null : onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
            color: color.withOpacity(0.05),
          ),
          child: Row(children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 14),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700, color: color)),
                Text(subtitle, style: const TextStyle(
                    fontSize: 11, color: Color(0xFF888888))),
              ],
            )),
            if (loading)
              SizedBox(width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: color)),
          ]),
        ),
      );
}