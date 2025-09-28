import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/app_router.dart';
import '../constants/app_theme.dart';
import '../constants/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => AppRouter.goToHome(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader(l10n, 'Appearance'),
          _buildSettingsTile(
            l10n,
            l10n.themeSettings,
            'Choose your preferred theme',
            Icons.palette,
            () => AppRouter.goToThemeSettings(context),
          ),
          _buildSettingsTile(
            l10n,
            l10n.languageSettings,
            'Select app language',
            Icons.language,
            () => AppRouter.goToLanguageSettings(context),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(l10n, 'Notifications'),
          _buildSettingsTile(
            l10n,
            l10n.notificationSettings,
            'Manage notification preferences',
            Icons.notifications,
            () => AppRouter.goToNotificationSettings(context),
          ),
          _buildSettingsTile(
            l10n,
            'Reminder Settings',
            'Configure reminder behavior',
            Icons.schedule,
            () => AppRouter.goToNotificationSettings(context),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(l10n, 'About'),
          _buildSettingsTile(
            l10n,
            l10n.about,
            'App version and information',
            Icons.info,
            () => AppRouter.goToAbout(context),
          ),
          _buildSettingsTile(
            l10n,
            'Privacy Policy',
            'Read our privacy policy',
            Icons.privacy_tip,
            () => _showPrivacyPolicy(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(AppLocalizations l10n, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    AppLocalizations l10n,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Privacy Policy\n\n'
            'This app respects your privacy and does not collect personal data. '
            'All your todos are stored locally on your device.\n\n'
            'Data Storage:\n'
            '• Todos are stored locally using Hive database\n'
            '• No data is sent to external servers\n'
            '• You have full control over your data\n\n'
            'Permissions:\n'
            '• Storage: To save your todos locally\n'
            '• Notifications: To remind you about due todos\n\n'
            'If you have any questions about this privacy policy, please contact us.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
