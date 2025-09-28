import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettings {
  final bool notificationsEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool showOnLockScreen;
  final int snoozeMinutes;
  final int reminderBeforeDueMinutes;

  const NotificationSettings({
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.showOnLockScreen = true,
    this.snoozeMinutes = 5,
    this.reminderBeforeDueMinutes = 15,
  });

  NotificationSettings copyWith({
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? showOnLockScreen,
    int? snoozeMinutes,
    int? reminderBeforeDueMinutes,
  }) {
    return NotificationSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      showOnLockScreen: showOnLockScreen ?? this.showOnLockScreen,
      snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
      reminderBeforeDueMinutes: reminderBeforeDueMinutes ?? this.reminderBeforeDueMinutes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'showOnLockScreen': showOnLockScreen,
      'snoozeMinutes': snoozeMinutes,
      'reminderBeforeDueMinutes': reminderBeforeDueMinutes,
    };
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      soundEnabled: json['soundEnabled'] ?? true,
      vibrationEnabled: json['vibrationEnabled'] ?? true,
      showOnLockScreen: json['showOnLockScreen'] ?? true,
      snoozeMinutes: json['snoozeMinutes'] ?? 5,
      reminderBeforeDueMinutes: json['reminderBeforeDueMinutes'] ?? 15,
    );
  }
}

class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  NotificationSettingsNotifier() : super(const NotificationSettings()) {
    _loadSettings();
  }

  static const String _key = 'notification_settings';

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_key);
      if (settingsJson != null) {
        final settingsMap = Map<String, dynamic>.from(
          Uri.splitQueryString(settingsJson)
        );
        
        // تحويل القيم إلى الأنواع الصحيحة
        final convertedMap = <String, dynamic>{
          'notificationsEnabled': settingsMap['notificationsEnabled'] == 'true',
          'soundEnabled': settingsMap['soundEnabled'] == 'true',
          'vibrationEnabled': settingsMap['vibrationEnabled'] == 'true',
          'showOnLockScreen': settingsMap['showOnLockScreen'] == 'true',
          'snoozeMinutes': int.tryParse(settingsMap['snoozeMinutes'] ?? '5') ?? 5,
          'reminderBeforeDueMinutes': int.tryParse(settingsMap['reminderBeforeDueMinutes'] ?? '15') ?? 15,
        };
        
        state = NotificationSettings.fromJson(convertedMap);
      }
    } catch (e) {
      print('خطأ في تحميل إعدادات الإشعارات: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = Uri(queryParameters: state.toJson().map(
        (key, value) => MapEntry(key, value.toString()),
      )).query;
      await prefs.setString(_key, settingsJson);
    } catch (e) {
      print('خطأ في حفظ إعدادات الإشعارات: $e');
    }
  }

  Future<void> updateSettings(NotificationSettings newSettings) async {
    state = newSettings;
    await _saveSettings();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    state = state.copyWith(notificationsEnabled: enabled);
    await _saveSettings();
    print('تم تحديث إعدادات الإشعارات: notificationsEnabled = $enabled');
  }

  Future<void> setSoundEnabled(bool enabled) async {
    state = state.copyWith(soundEnabled: enabled);
    await _saveSettings();
    print('تم تحديث إعدادات الإشعارات: soundEnabled = $enabled');
  }

  Future<void> setVibrationEnabled(bool enabled) async {
    state = state.copyWith(vibrationEnabled: enabled);
    await _saveSettings();
    print('تم تحديث إعدادات الإشعارات: vibrationEnabled = $enabled');
  }

  Future<void> setShowOnLockScreen(bool enabled) async {
    state = state.copyWith(showOnLockScreen: enabled);
    await _saveSettings();
    print('تم تحديث إعدادات الإشعارات: showOnLockScreen = $enabled');
  }

  Future<void> setSnoozeMinutes(int minutes) async {
    state = state.copyWith(snoozeMinutes: minutes);
    await _saveSettings();
    print('تم تحديث إعدادات الإشعارات: snoozeMinutes = $minutes');
    print('سيتم تطبيق المدة الجديدة فوراً على الإشعارات التالية');
    
    // تحديث الإشعارات الموجودة بالإعدادات الجديدة
    try {
      // استيراد خدمة الإشعارات هنا لتجنب dependency cycle
      // سيتم تحديث الإشعارات في المرة القادمة التي يتم إنشاؤها
      print('تم حفظ إعدادات مدة التأجيل - ستُطبق على الإشعارات الجديدة');
    } catch (e) {
      print('خطأ في تحديث الإشعارات: $e');
    }
  }

  Future<void> setReminderBeforeDueMinutes(int minutes) async {
    state = state.copyWith(reminderBeforeDueMinutes: minutes);
    await _saveSettings();
    print('تم تحديث إعدادات الإشعارات: reminderBeforeDueMinutes = $minutes');
    print('سيتم تطبيق التوقيت الجديد فوراً على التذكيرات التالية');
  }
}

final notificationSettingsProvider = StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
  (ref) => NotificationSettingsNotifier(),
);
