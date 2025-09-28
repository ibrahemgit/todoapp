import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_theme.dart';
import '../constants/app_localizations.dart';
import '../utils/app_router.dart';
import '../providers/app_settings_provider.dart';

class ThemeSettingsScreen extends ConsumerStatefulWidget {
  const ThemeSettingsScreen({super.key});

  @override
  ConsumerState<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends ConsumerState<ThemeSettingsScreen> {

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.themeSettings),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => AppRouter.goToSettings(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildThemeOption(l10n.systemMode, 'system', Icons.brightness_auto),
          _buildThemeOption(l10n.lightMode, 'light', Icons.light_mode),
          _buildThemeOption(l10n.darkMode, 'dark', Icons.dark_mode),
        ],
      ),
    );
  }

  Widget _buildThemeOption(String title, String value, IconData icon) {
    final l10n = AppLocalizations.of(context);
    final currentTheme = ref.watch(themeModeProvider);
    final isSelected = currentTheme == value;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(title),
        trailing: isSelected ? const Icon(Icons.check, color: AppTheme.primaryColor) : null,
        onTap: () async {
          // Update theme using provider
          await ref.read(themeModeProvider.notifier).setThemeMode(value);
          
          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${l10n.themeSettings} $title'),
                backgroundColor: AppTheme.successColor,
                duration: const Duration(seconds: 1),
              ),
            );
            
            // Navigate back to settings
            await Future.delayed(const Duration(milliseconds: 500));
            if (mounted) {
              AppRouter.goToSettings(context);
            }
          }
        },
      ),
    );
  }
}
