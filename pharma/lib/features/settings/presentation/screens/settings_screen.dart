import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Main Settings screen.
/// Wire ThemeModeSelector, pharmacy config, and user info here.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text('Settings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        backgroundColor: const Color(0xFFF7F8FC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ── Appearance ──────────────────────────────────────────────
          _SectionHeader('Appearance'),
          // Drop in ThemeModeSelector from step11_dark_mode:
          // const ThemeModeSelector(),
          _SettingsTile(
            icon: Icons.dark_mode_rounded,
            label: 'Dark mode',
            subtitle: 'Light / Dark / System',
            color: const Color(0xFF1565C0),
            onTap: () {},
          ),
          const SizedBox(height: 16),

          // ── Pharmacy info ───────────────────────────────────────────
          _SectionHeader('Pharmacy info'),
          _SettingsTile(
            icon: Icons.local_pharmacy_rounded,
            label: 'Pharmacy name',
            subtitle: 'PharmaCare Pharmacy',
            color: const Color(0xFF2E7D32),
            onTap: () => _showPharmacyEditSheet(context),
          ),
          _SettingsTile(
            icon: Icons.location_on_rounded,
            label: 'Address',
            subtitle: 'Shop # 12, Main Market',
            color: const Color(0xFF2E7D32),
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.phone_rounded,
            label: 'Phone',
            subtitle: '+92-51-1234567',
            color: const Color(0xFF2E7D32),
            onTap: () {},
          ),
          const SizedBox(height: 16),

          // ── Branches ────────────────────────────────────────────────
          _SectionHeader('Branches'),
          _SettingsTile(
            icon: Icons.store_rounded,
            label: 'Manage branches',
            subtitle: 'Add, edit, switch branches',
            color: const Color(0xFF7B1FA2),
            onTap: () => Navigator.pushNamed(context, '/stores'),
          ),
          const SizedBox(height: 16),

          // ── Data ────────────────────────────────────────────────────
          _SectionHeader('Data'),
          _SettingsTile(
            icon: Icons.backup_rounded,
            label: 'Backup & restore',
            subtitle: 'Export all data to cloud',
            color: const Color(0xFF1565C0),
            onTap: () => Navigator.pushNamed(context, '/backup'),
          ),
          _SettingsTile(
            icon: Icons.file_download_rounded,
            label: 'Export reports',
            subtitle: 'PDF / Excel',
            color: const Color(0xFF1565C0),
            onTap: () => Navigator.pushNamed(context, '/reports'),
          ),
          const SizedBox(height: 16),

          // ── Account ─────────────────────────────────────────────────
          _SectionHeader('Account'),
          _SettingsTile(
            icon: Icons.logout_rounded,
            label: 'Sign out',
            subtitle: 'Logout from this device',
            color: const Color(0xFFE53935),
            onTap: () => _confirmLogout(context, ref),
          ),

          const SizedBox(height: 32),
          const Center(
            child: Text('PharmaCare v1.0.0',
                style: TextStyle(fontSize: 11, color: Color(0xFFBBBBBB))),
          ),
        ],
      ),
    );
  }

  void _showPharmacyEditSheet(BuildContext context) {
    final nameCtrl    = TextEditingController(text: 'PharmaCare Pharmacy');
    final addressCtrl = TextEditingController(text: 'Shop # 12, Main Market');
    final phoneCtrl   = TextEditingController(text: '+92-51-1234567');
    final ntnCtrl     = TextEditingController(text: '1234567-8');
    final licCtrl     = TextEditingController(text: 'DL-2024-ISB-00142');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
            16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Edit pharmacy info',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            _tf(nameCtrl, 'Pharmacy name'),
            const SizedBox(height: 10),
            _tf(addressCtrl, 'Address'),
            const SizedBox(height: 10),
            _tf(phoneCtrl, 'Phone', type: TextInputType.phone),
            const SizedBox(height: 10),
            _tf(ntnCtrl, 'NTN'),
            const SizedBox(height: 10),
            _tf(licCtrl, 'Drug license no'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0)),
                onPressed: () {
                  // TODO: save to Firestore /settings/pharmacy_config
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Pharmacy info updated'),
                    backgroundColor: Color(0xFF2E7D32),
                  ));
                },
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign out?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: const Text(
            'You will be returned to the login screen.',
            style: TextStyle(fontSize: 13)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE53935)),
            onPressed: () {
              Navigator.pop(context);
              // ref.read(authViewModelProvider.notifier).logout();
            },
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
  }

  Widget _tf(TextEditingController ctrl, String label,
      {TextInputType type = TextInputType.text}) =>
      TextField(
        controller: ctrl, keyboardType: type,
        decoration: InputDecoration(
          labelText: label, filled: true,
          fillColor: const Color(0xFFF9FAFB),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
        ),
      );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(title,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF888888),
                letterSpacing: 0.8)),
      );
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon, required this.label, required this.subtitle,
    required this.color, required this.onTap,
  });
  final IconData icon;
  final String label, subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: Colors.black.withOpacity(0.06), width: 0.8),
        ),
        child: ListTile(
          leading: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          title: Text(label,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600)),
          subtitle: Text(subtitle,
              style: const TextStyle(
                  fontSize: 11, color: Color(0xFF888888))),
          trailing: const Icon(Icons.chevron_right_rounded,
              size: 18, color: Color(0xFFCCCCCC)),
          onTap: onTap,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
}