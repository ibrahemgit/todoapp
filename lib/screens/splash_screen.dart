import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../utils/app_router.dart';
import '../constants/app_constants.dart';
import '../services/enhanced_notification_service.dart';
import '../services/background_service.dart';
import '../providers/todo_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeApp();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _animationController.forward();
  }

  Future<void> _initializeApp() async {
    try {
      // Wait for minimum splash duration
      await Future.delayed(const Duration(seconds: 2));

      // التحقق من الإشعارات المعلقة ومعالجتها
      await _handlePendingNotifications();

      // Check if first launch
      final prefs = await SharedPreferences.getInstance();
      final isFirstLaunch = prefs.getBool('first_launch') ?? true;
      
      if (isFirstLaunch) {
        // Set first launch to false
        await prefs.setBool('first_launch', false);
        // Navigate to onboarding or home
        if (mounted) {
          AppRouter.goToHome(context);
        }
      } else {
        // Navigate to home
        if (mounted) {
          AppRouter.goToHome(context);
        }
      }
    } catch (e) {
      // Handle initialization error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Initialization error: $e'),
            backgroundColor: Colors.red,
          ),
        );
        // Still navigate to home after error
        AppRouter.goToHome(context);
      }
    }
  }

  /// التحقق من الإشعارات المعلقة ومعالجتها بسرعة
  Future<void> _handlePendingNotifications() async {
    try {
      print('🔍 التحقق من الإشعارات المعلقة...');
      
      // الحصول على تفاصيل الإشعار الذي فتح التطبيق
      final FlutterLocalNotificationsPlugin notifications = FlutterLocalNotificationsPlugin();
      final NotificationAppLaunchDetails? notificationAppLaunchDetails =
          await notifications.getNotificationAppLaunchDetails();

      if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
        final String? payload = notificationAppLaunchDetails!.notificationResponse?.payload;
        final String? actionId = notificationAppLaunchDetails.notificationResponse?.actionId;
        
        if (payload != null && actionId != null) {
          print('📱 تم فتح التطبيق من إشعار: $payload, action: $actionId');
          
          // معالجة الإشعار حسب نوع الإجراء بسرعة
          await _processNotificationAction(payload, actionId);
          
          // إغلاق الإشعار فوراً (يتم تلقائياً في handleNotificationActionFast)
          // await _dismissNotification(payload);
        }
      }
      
      // معالجة المهام المحفوظة من الإشعارات السابقة
      await _processPendingTasks();
      
      // معالجة المهام من الخدمة الخلفية
      final backgroundService = BackgroundService();
      await backgroundService.processBackgroundTasks();
      
    } catch (e) {
      print('❌ خطأ في معالجة الإشعارات المعلقة: $e');
    }
  }

  /// معالجة إجراء الإشعار بسرعة
  Future<void> _processNotificationAction(String payload, String actionId) async {
    try {
      // استخدام الدوال المحسنة من خدمة الإشعارات
      final enhancedService = EnhancedNotificationService();
      
      // تعيين ProviderContainer للخدمة
      final container = ProviderScope.containerOf(context);
      enhancedService.setProviderContainer(container);
      
      await enhancedService.handleNotificationActionFast(payload, actionId);
      
      print('⚡ تم معالجة إجراء الإشعار بسرعة: $actionId للمهمة: $payload');
      
      // عدم فتح التطبيق - فقط معالجة الإجراء في الخلفية
      // إذا كان المستخدم يريد فتح التطبيق، يمكنه النقر على أيقونة التطبيق
      
    } catch (e) {
      print('❌ خطأ في معالجة إجراء الإشعار: $e');
      
      // fallback للطرق القديمة في حالة الخطأ
      if (actionId == 'complete_task') {
        await _completeTaskFromNotification(payload);
      } else if (actionId == 'snooze_task') {
        await _snoozeTaskFromNotification(payload);
      } else if (actionId == 'tap_task') {
        await _openTaskFromNotification(payload);
      }
    }
  }

  /// إتمام المهمة من الإشعار
  Future<void> _completeTaskFromNotification(String taskId) async {
    try {
      // تحديث حالة المهمة مباشرة
      final todoNotifier = ref.read(todoListProvider.notifier);
      await todoNotifier.toggleTodoStatus(taskId);
      
      // حفظ في SharedPreferences للتحقق لاحقاً
      final prefs = await SharedPreferences.getInstance();
      final completedTasks = prefs.getStringList('completed_from_notification') ?? [];
      if (!completedTasks.contains(taskId)) {
        completedTasks.add(taskId);
        await prefs.setStringList('completed_from_notification', completedTasks);
      }
    } catch (e) {
      print('❌ خطأ في إتمام المهمة: $e');
    }
  }

  /// تأجيل المهمة من الإشعار
  Future<void> _snoozeTaskFromNotification(String taskId) async {
    try {
      // الحصول على مدة التأجيل الافتراضية
      final prefs = await SharedPreferences.getInstance();
      final snoozeMinutes = prefs.getInt('snooze_minutes') ?? 15;
      
      // حفظ المهمة المؤجلة
      final snoozedTasks = prefs.getStringList('snoozed_tasks') ?? [];
      if (!snoozedTasks.contains(taskId)) {
        snoozedTasks.add(taskId);
        await prefs.setStringList('snoozed_tasks', snoozedTasks);
      }
      
      // جدولة إشعار جديد
      final enhancedService = EnhancedNotificationService();
      await enhancedService.scheduleSnoozeNotification(taskId, snoozeMinutes);
      
    } catch (e) {
      print('❌ خطأ في تأجيل المهمة: $e');
    }
  }

  /// فتح المهمة من الإشعار
  Future<void> _openTaskFromNotification(String taskId) async {
    try {
      // حفظ معرف المهمة للفتح لاحقاً
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('task_to_open', taskId);
    } catch (e) {
      print('❌ خطأ في فتح المهمة: $e');
    }
  }


  /// معالجة المهام المحفوظة من الإشعارات السابقة
  Future<void> _processPendingTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // معالجة المهام المكتملة
      final completedTasks = prefs.getStringList('completed_from_notification') ?? [];
      if (completedTasks.isNotEmpty) {
        final todoNotifier = ref.read(todoListProvider.notifier);
        for (String taskId in completedTasks) {
          await todoNotifier.toggleTodoStatus(taskId);
        }
        await prefs.remove('completed_from_notification');
      }
      
      // معالجة المهام المؤجلة
      final snoozedTasks = prefs.getStringList('snoozed_tasks') ?? [];
      if (snoozedTasks.isNotEmpty) {
        // يمكن إضافة منطق إضافي هنا إذا لزم الأمر
        print('📋 تم العثور على ${snoozedTasks.length} مهمة مؤجلة');
      }
      
      // فتح المهمة المحددة
      final taskToOpen = prefs.getString('task_to_open');
      if (taskToOpen != null) {
        try {
          final todos = ref.read(todoListProvider);
          final task = todos.firstWhere((todo) => todo.id == taskToOpen);
          ref.read(selectedTodoProvider.notifier).state = task;
          await prefs.remove('task_to_open');
        } catch (e) {
          print('❌ خطأ في فتح المهمة المحفوظة: $e');
          await prefs.remove('task_to_open');
        }
      }
      
    } catch (e) {
      print('❌ خطأ في معالجة المهام المحفوظة: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo/Icon
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.checklist_rtl,
                        size: 64,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // App Name
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    AppConstants.appName,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),

            const SizedBox(height: 8),

            // App Description
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    AppConstants.appDescription,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),

            const SizedBox(height: 48),

            // Loading Indicator
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: const SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 3,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Loading Text
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'Initializing...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
