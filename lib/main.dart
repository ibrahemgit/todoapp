import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'utils/app_router.dart';
import 'constants/app_theme.dart';
import 'constants/app_constants.dart';
import 'constants/app_localizations.dart';
import 'services/hive_service.dart';
import 'services/enhanced_notification_service.dart';
import 'services/notification_log_service.dart';
import 'providers/app_settings_provider.dart';
import 'providers/todo_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services before running app
  try {
    await HiveService.init();
    await NotificationLogService.init();
    // تأجيل تهيئة خدمة الإشعارات حتى بعد إنشاء ProviderScope
  } catch (e) {
    debugPrint('Error initializing services: $e');
  }
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // Listen to theme and language changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateApp();
      _initializeNotificationService();
    });
  }

  /// تهيئة خدمة الإشعارات بعد إنشاء ProviderScope
  Future<void> _initializeNotificationService() async {
    try {
      print('🔧 بدء تهيئة خدمة الإشعارات المحسنة...');
      
      // تهيئة خدمة الإشعارات المحسنة
      final enhancedService = EnhancedNotificationService();
      
      // تعيين ProviderContainer
      final container = ProviderScope.containerOf(context);
      enhancedService.setProviderContainer(container);
      
      // تعيين callbacks للتفاعل مع الإشعارات
      enhancedService.setTaskCompletedCallback((taskId) {
        final todoNotifier = container.read(todoListProvider.notifier);
        todoNotifier.toggleTodoStatus(taskId);
      });
      
      enhancedService.setTaskTappedCallback((taskId) {
        try {
          final todos = container.read(todoListProvider);
          final task = todos.firstWhere((todo) => todo.id == taskId);
          container.read(selectedTodoProvider.notifier).state = task;
        } catch (e) {
          print('خطأ في فتح تفاصيل المهمة: $e');
        }
      });
      
      // تهيئة خدمة الإشعارات
      await enhancedService.initializeNotifications();
      
      // ملاحظة: معالجة المهام المحفوظة تتم الآن في SplashScreen
      // لتحسين الأداء وتجنب التكرار
      
      print('✅ تم تهيئة خدمة الإشعارات المحسنة بنجاح مع طلب الإذونات');
      
    } catch (e) {
      print('❌ خطأ في تهيئة خدمة الإشعارات المحسنة: $e');
    }
  }

  // تم إزالة دالة اختبار الإشعارات غير المرغوبة

  void _updateApp() {
    if (mounted) {
      setState(() {});
    }
  }

  // Method to refresh the app when settings change
  void refreshApp() {
    if (mounted) {
      setState(() {});
    }
  }

  // Force refresh the app
  void forceRefresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final language = ref.watch(languageProvider);
    final locale = Locale(language);
    final isRTL = locale.languageCode == 'ar';
    
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _getThemeMode(themeMode),
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      routerConfig: AppRouter.router,
      builder: (context, child) {
        return Directionality(
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        );
      },
    );
  }

  ThemeMode _getThemeMode(String themeMode) {
    switch (themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
