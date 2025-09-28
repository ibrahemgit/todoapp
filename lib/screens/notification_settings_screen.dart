import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants/app_theme.dart';
import '../constants/app_localizations.dart';
import '../utils/app_router.dart';
import '../services/enhanced_notification_service.dart';
import '../providers/notification_settings_provider.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends ConsumerState<NotificationSettingsScreen> {
  PermissionStatus _notificationPermission = PermissionStatus.denied;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final status = await Permission.notification.status;
    setState(() {
      _notificationPermission = status;
    });
  }

  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.request();
    setState(() {
      _notificationPermission = status;
    });
    
    if (status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).permissionGranted),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).permissionDenied),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }


  Future<void> _refreshNotifications() async {
    try {
      // استيراد خدمة الإشعارات المحسنة
      final enhancedService = EnhancedNotificationService();
      
      // تعيين ProviderContainer قبل تحديث الإشعارات
      final container = ProviderScope.containerOf(context);
      enhancedService.setProviderContainer(container);
      
      await enhancedService.refreshNotificationsWithNewSettings();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تحديث الإشعارات بالإعدادات الجديدة'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تحديث الإشعارات: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  // دوال اختبار الإشعارات
  Future<void> _testEnhancedOngoingNotification() async {
    try {
      final notificationService = EnhancedNotificationService();
      await notificationService.testOngoingNotification();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إرسال إشعار مستمر محسن للاختبار - يجب أن يبقى ظاهراً بشكل دائم'),
          backgroundColor: AppTheme.successColor,
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في اختبار الإشعار المستمر المحسن: $e'),
          backgroundColor: AppTheme.errorColor,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _testSimpleNotification() async {
    try {
      final notificationService = EnhancedNotificationService();
      await notificationService.testSimpleNotification();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إرسال إشعار بسيط للاختبار'),
          backgroundColor: AppTheme.successColor,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في اختبار الإشعار البسيط: $e'),
          backgroundColor: AppTheme.errorColor,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _testPersistentNotification() async {
    try {
      final notificationService = EnhancedNotificationService();
      await notificationService.testPersistentNotification();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إرسال إشعار مستمر محسن للاختبار - يجب أن يبقى ظاهراً بشكل دائم'),
          backgroundColor: AppTheme.successColor,
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في إرسال الإشعار المستمر المحسن: $e'),
          backgroundColor: AppTheme.errorColor,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _showSettingsSavedMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  List<int> _getSnoozeOptions() {
    return [1, 2, 5, 10, 15, 30, 60];
  }

  List<int> _getReminderOptions() {
    return [5, 10, 15, 30, 60, 120, 240];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(notificationSettingsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationSettings),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => AppRouter.goToSettings(context),
        ),
        actions: [],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Permission Status Card
          _buildPermissionStatusCard(l10n),
          const SizedBox(height: 24),

          // Basic Settings
          _buildSectionHeader(l10n, 'Basic Settings'),
          _buildSwitchTile(
            l10n,
            'Enable Notifications',
            'Allow the app to send notifications',
            Icons.notifications,
            settings.notificationsEnabled,
            (value) async {
              await ref.read(notificationSettingsProvider.notifier).setNotificationsEnabled(value);
              _showSettingsSavedMessage('تم تحديث إعدادات الإشعارات');
            },
          ),
          _buildSwitchTile(
            l10n,
            'Sound',
            'Play sound for notifications',
            Icons.volume_up,
            settings.soundEnabled,
            (value) async {
              await ref.read(notificationSettingsProvider.notifier).setSoundEnabled(value);
              _showSettingsSavedMessage('تم تحديث إعدادات الصوت');
            },
          ),
          _buildSwitchTile(
            l10n,
            'Vibration',
            'Vibrate for notifications',
            Icons.vibration,
            settings.vibrationEnabled,
            (value) async {
              await ref.read(notificationSettingsProvider.notifier).setVibrationEnabled(value);
              _showSettingsSavedMessage('تم تحديث إعدادات الاهتزاز');
            },
          ),
          _buildSwitchTile(
            l10n,
            'Show on Lock Screen',
            'Display notifications on lock screen',
            Icons.lock,
            settings.showOnLockScreen,
            (value) async {
              await ref.read(notificationSettingsProvider.notifier).setShowOnLockScreen(value);
              _showSettingsSavedMessage('تم تحديث إعدادات شاشة القفل');
            },
          ),
          const SizedBox(height: 24),

          // Timing Settings
          _buildSectionHeader(l10n, 'Timing Settings'),
          _buildDropdownTile(
            l10n,
            'Snooze Duration',
            'Minutes to snooze notifications',
            Icons.snooze,
            settings.snoozeMinutes,
            _getSnoozeOptions(),
            (value) async {
              await ref.read(notificationSettingsProvider.notifier).setSnoozeMinutes(value);
              _showSettingsSavedMessage('تم تحديث مدة التأجيل: $value دقيقة');
            },
          ),
          _buildDropdownTile(
            l10n,
            'Reminder Before Due',
            'Minutes before due date to send reminder',
            Icons.schedule,
            settings.reminderBeforeDueMinutes,
            _getReminderOptions(),
            (value) async {
              await ref.read(notificationSettingsProvider.notifier).setReminderBeforeDueMinutes(value);
              _showSettingsSavedMessage('تم تحديث توقيت التذكير: $value دقيقة');
            },
          ),
          const SizedBox(height: 24),

          // Action Section
          _buildSectionHeader(l10n, 'Actions'),
          _buildActionTile(
            l10n,
            'Request Permissions',
            'Request notification permissions',
            Icons.security,
            _requestNotificationPermission,
          ),
          // زر اختبار الإشعارات المستمرة المحسنة
          _buildActionTile(
            l10n,
            'Test Enhanced Ongoing Notification',
            'Test improved persistent notification that stays visible permanently',
            Icons.notifications_active,
            _testEnhancedOngoingNotification,
          ),
          // زر اختبار الإشعارات البسيطة
          _buildActionTile(
            l10n,
            'Test Simple Notification',
            'Test basic notification functionality',
            Icons.notifications,
            _testSimpleNotification,
          ),
          _buildActionTile(
            l10n,
            'Test Persistent Notification',
            'Test enhanced persistent notification that stays visible',
            Icons.notifications_active,
            _testPersistentNotification,
          ),
          _buildActionTile(
            l10n,
            'Refresh Notifications',
            'Update existing notifications with new settings',
            Icons.refresh,
            _refreshNotifications,
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionStatusCard(AppLocalizations l10n) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (_notificationPermission) {
      case PermissionStatus.granted:
        statusColor = AppTheme.successColor;
        statusText = 'Permission Granted';
        statusIcon = Icons.check_circle;
        break;
      case PermissionStatus.denied:
        statusColor = AppTheme.errorColor;
        statusText = 'Permission Denied';
        statusIcon = Icons.cancel;
        break;
      case PermissionStatus.permanentlyDenied:
        statusColor = AppTheme.warningColor;
        statusText = 'Permission Permanently Denied';
        statusIcon = Icons.block;
        break;
      default:
        statusColor = AppTheme.textSecondary;
        statusText = 'Unknown Status';
        statusIcon = Icons.help;
    }

    return Card(
      color: statusColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(statusIcon, color: statusColor, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notification Permission',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    statusText,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
            if (_notificationPermission != PermissionStatus.granted)
              ElevatedButton(
                onPressed: _requestNotificationPermission,
                child: const Text('Request'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(AppLocalizations l10n, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    AppLocalizations l10n,
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        secondary: Icon(icon, color: AppTheme.primaryColor),
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryColor,
      ),
    );
  }


  Widget _buildDropdownTile(
    AppLocalizations l10n,
    String title,
    String subtitle,
    IconData icon,
    int currentValue,
    List<int> options,
    ValueChanged<int> onChanged,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                  ),
                  child: DropdownButton<int>(
                    value: currentValue,
                    underline: const SizedBox(),
                    icon: Icon(Icons.arrow_drop_down, color: AppTheme.primaryColor),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                    items: options.map((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text('$value دقيقة'),
                      );
                    }).toList(),
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        onChanged(newValue);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(
    AppLocalizations l10n,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        leading: Icon(icon, color: AppTheme.primaryColor),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}