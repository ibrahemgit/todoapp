import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_theme.dart';
import '../constants/app_localizations.dart';
import '../utils/app_router.dart';
import '../providers/app_settings_provider.dart';

class LanguageSettingsScreen extends ConsumerStatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  ConsumerState<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends ConsumerState<LanguageSettingsScreen> {
  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
    {'code': 'ar', 'name': 'العربية', 'flag': '🇸🇦'},
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.languageSettings),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => AppRouter.goToSettings(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: _languages.map((language) => _buildLanguageOption(language)).toList(),
      ),
    );
  }

  Widget _buildLanguageOption(Map<String, String> language) {
    final l10n = AppLocalizations.of(context);
    final currentLanguage = ref.watch(languageProvider);
    final isSelected = currentLanguage == language['code'];
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Text(
          language['flag']!,
          style: const TextStyle(fontSize: 24),
        ),
        title: Text(language['name']!),
        trailing: isSelected ? const Icon(Icons.check, color: AppTheme.primaryColor) : null,
        onTap: () async {
          // Update language using provider
          await ref.read(languageProvider.notifier).setLanguage(language['code']!);
          
          if (mounted) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${l10n.languageSettings} ${language['name']}'),
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
