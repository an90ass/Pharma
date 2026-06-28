
enum AppThemeMode {
  light('Light', 'light'),
  dark('Dark', 'dark'),
  system('System default', 'system');

  const AppThemeMode(this.label, this.storageKey);

  final String label;

  final String storageKey;
  static AppThemeMode fromStorageKey(String? key) {
    return AppThemeMode.values.firstWhere(
      (e) => e.storageKey == key,
      orElse: () => AppThemeMode.system,
    );
  }
}