import 'package:flutter/material.dart';
import '../../domain/entities/purchase_order_entity.dart';

class POStatusBadge extends StatelessWidget {
  const POStatusBadge({super.key, required this.status});
  final POStatus status;

  @override
  Widget build(BuildContext context) {
    final cfg = _config(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cfg.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: cfg.fg,
        ),
      ),
    );
  }

  _BadgeConfig _config(POStatus s) => switch (s) {
        POStatus.draft => _BadgeConfig(
            const Color(0xFFF5F5F5), const Color(0xFF666666)),
        POStatus.sent => _BadgeConfig(
            const Color(0xFFE3F2FD), const Color(0xFF1565C0)),
        POStatus.partial => _BadgeConfig(
            const Color(0xFFFFF8E1), const Color(0xFFE65100)),
        POStatus.received => _BadgeConfig(
            const Color(0xFFE8F5E9), const Color(0xFF2E7D32)),
        POStatus.cancelled => _BadgeConfig(
            const Color(0xFFFFF3F3), const Color(0xFFE53935)),
      };
}

class _BadgeConfig {
  const _BadgeConfig(this.bg, this.fg);
  final Color bg;
  final Color fg;
}