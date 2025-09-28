import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo_model.dart';
import '../services/hive_service.dart';
import '../services/enhanced_notification_service.dart';
import '../services/notification_log_service.dart';
import '../services/repeating_todo_service.dart';
import '../models/notification_log_model.dart';

// Todo List Provider
final todoListProvider = StateNotifierProvider<TodoListNotifier, List<TodoModel>>((ref) {
  return TodoListNotifier();
});

// Filtered Todo List Provider
final filteredTodoListProvider = Provider<List<TodoModel>>((ref) {
  final todos = ref.watch(todoListProvider);
  final filter = ref.watch(todoFilterProvider);
  final priorityFilter = ref.watch(todoPriorityFilterProvider);
  final sortBy = ref.watch(todoSortProvider);
  final searchQuery = ref.watch(todoSearchProvider);

  List<TodoModel> filteredTodos = todos;

  // Apply search filter
  if (searchQuery.isNotEmpty) {
    filteredTodos = filteredTodos.where((todo) {
      final query = searchQuery.toLowerCase();
      return todo.title.toLowerCase().contains(query) ||
             (todo.description?.toLowerCase().contains(query) ?? false) ||
             todo.tags.any((tag) => tag.toLowerCase().contains(query));
    }).toList();
  }

  // Apply status filter
  if (filter != TodoFilter.all) {
    filteredTodos = filteredTodos.where((todo) {
      switch (filter) {
        case TodoFilter.pending:
          return todo.status == TodoStatus.pending;
        case TodoFilter.inProgress:
          return todo.status == TodoStatus.inProgress;
        case TodoFilter.completed:
          return todo.status == TodoStatus.completed;
        case TodoFilter.cancelled:
          return todo.status == TodoStatus.cancelled;
        case TodoFilter.overdue:
          final effectiveDateTime = _getEffectiveDateTime(todo);
          return effectiveDateTime.isBefore(DateTime.now()) && 
                 todo.status != TodoStatus.completed;
        case TodoFilter.today:
          final today = DateTime.now();
          final effectiveDateTime = _getEffectiveDateTime(todo);
          return effectiveDateTime.year == today.year &&
                 effectiveDateTime.month == today.month &&
                 effectiveDateTime.day == today.day;
        case TodoFilter.thisWeek:
          final now = DateTime.now();
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          final endOfWeek = startOfWeek.add(const Duration(days: 6));
          final effectiveDateTime = _getEffectiveDateTime(todo);
          return effectiveDateTime.isAfter(startOfWeek) && 
                 effectiveDateTime.isBefore(endOfWeek);
        case TodoFilter.all:
          return true;
      }
    }).toList();
  }

  // Apply priority filter
  if (priorityFilter != null) {
    filteredTodos = filteredTodos.where((todo) {
      return todo.priority == priorityFilter;
    }).toList();
  }

  // Apply sorting
  switch (sortBy) {
    case TodoSort.title:
      filteredTodos.sort((a, b) => a.title.compareTo(b.title));
      break;
    case TodoSort.dueDate:
      filteredTodos.sort((a, b) {
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });
      break;
    case TodoSort.priority:
      filteredTodos.sort((a, b) => b.priority.index.compareTo(a.priority.index));
      break;
    case TodoSort.createdDate:
      filteredTodos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      break;
    case TodoSort.status:
      filteredTodos.sort((a, b) => a.status.index.compareTo(b.status.index));
      break;
  }

  return filteredTodos;
});

// Todo Filter Provider
final todoFilterProvider = StateProvider<TodoFilter>((ref) => TodoFilter.all);

// Todo Priority Filter Provider
final todoPriorityFilterProvider = StateProvider<TodoPriority?>((ref) => null);

// Todo Sort Provider
final todoSortProvider = StateProvider<TodoSort>((ref) => TodoSort.dueDate);

// Todo Search Provider
final todoSearchProvider = StateProvider<String>((ref) => '');

// Selected Todo Provider
final selectedTodoProvider = StateProvider<TodoModel?>((ref) => null);

// Helper function to get effective date/time for a todo
DateTime _getEffectiveDateTime(TodoModel todo) {
  // If reminderTime exists, use it (it already contains the correct date and time)
  if (todo.reminderTime != null) {
    return todo.reminderTime!;
  }
  // Otherwise, use dueDate (it might only have date, time will be 00:00)
  if (todo.dueDate != null) {
    return todo.dueDate!;
  }
  // Fallback to current time (shouldn't happen due to the if condition above)
  return DateTime.now();
}

// Todo Statistics Provider
final todoStatsProvider = Provider<TodoStats>((ref) {
  final todos = ref.watch(todoListProvider);
  
  return TodoStats(
    total: todos.length,
    pending: todos.where((todo) => todo.status == TodoStatus.pending).length,
    inProgress: todos.where((todo) => todo.status == TodoStatus.inProgress).length,
    completed: todos.where((todo) => todo.status == TodoStatus.completed).length,
    cancelled: todos.where((todo) => todo.status == TodoStatus.cancelled).length,
    overdue: todos.where((todo) => 
      _getEffectiveDateTime(todo).isBefore(DateTime.now()) && 
      todo.status != TodoStatus.completed
    ).length,
  );
});

// Todo List Notifier
class TodoListNotifier extends StateNotifier<List<TodoModel>> {
  final EnhancedNotificationService _notificationService = EnhancedNotificationService();
  final RepeatingTodoService _repeatingService = RepeatingTodoService();
  
  TodoListNotifier() : super([]) {
    _loadTodos();
    _initializeNotificationService();
  }

  /// تهيئة خدمة الإشعارات
  Future<void> _initializeNotificationService() async {
    try {
      await _notificationService.initializeNotifications();
      print('تم تهيئة خدمة الإشعارات في TodoProvider');
    } catch (e) {
      print('خطأ في تهيئة خدمة الإشعارات: $e');
    }
  }

  /// تعيين ProviderContainer لخدمة الإشعارات
  void setNotificationProviderContainer(ProviderContainer container) {
    _notificationService.setProviderContainer(container);
    _repeatingService.initialize(container);
    
    // تعيين callbacks للتفاعل مع الإشعارات
    _notificationService.setTaskCompletedCallback((taskId) {
      toggleTodoStatus(taskId);
    });
    
    _notificationService.setTaskTappedCallback((taskId) {
      // فتح تفاصيل المهمة
      final task = state.firstWhere((todo) => todo.id == taskId);
      container.read(selectedTodoProvider.notifier).state = task;
    });
  }

  Future<void> _loadTodos() async {
    try {
      final todos = HiveService.getAllTodos();
      state = todos;
    } catch (e) {
      // Handle error
      state = [];
    }
  }

  /// جدولة إشعار للمهمة (نفس النظام المستخدم في إضافة المهام)
  Future<void> _scheduleNotificationForTodo(TodoModel todo) async {
    try {
      // التأكد من وجود موعد للمهمة
      if (todo.reminderTime != null) {
        await _notificationService.scheduleTaskNotification(
          taskTitle: todo.title,
          taskDescription: todo.description ?? 'تذكير مهم: يرجى إنجاز مهامك في الوقت المحدد',
          taskId: todo.id,
          taskDueTime: todo.reminderTime!,
        );
        print('✅ تم جدولة إشعار للمهمة: ${todo.title} في ${todo.reminderTime}');
      } else if (todo.dueDate != null) {
        // إذا لم يكن هناك reminderTime، استخدم dueDate
        await _notificationService.scheduleTaskNotification(
          taskTitle: todo.title,
          taskDescription: todo.description ?? 'تذكير مهم: يرجى إنجاز مهامك في الوقت المحدد',
          taskId: todo.id,
          taskDueTime: todo.dueDate!,
        );
        print('✅ تم جدولة إشعار للمهمة: ${todo.title} في ${todo.dueDate}');
      } else {
        print('⚠️ لا يمكن جدولة إشعار للمهمة ${todo.title} - لا يوجد موعد محدد');
      }
    } catch (e) {
      print('❌ خطأ في جدولة إشعار المهمة: $e');
      
      // تسجيل الخطأ في سجل الإشعارات
      await NotificationLogService.addQuickLog(
        title: 'خطأ في جدولة إشعار',
        description: 'فشل في جدولة إشعار للمهمة: ${todo.title} - $e',
        type: NotificationLogType.error,
        taskId: todo.id,
        taskTitle: todo.title,
      );
    }
  }

  /// إلغاء إشعار المهمة
  Future<void> _cancelNotificationForTodo(String todoId) async {
    try {
      await _notificationService.cancelTaskNotification(todoId);
      print('تم إلغاء إشعار المهمة: $todoId');
    } catch (e) {
      print('خطأ في إلغاء إشعار المهمة: $e');
    }
  }

  Future<void> addTodo(TodoModel todo) async {
    try {
      // حفظ المهمة أولاً وتحديث الـ state فوراً
      await HiveService.saveTodo(todo);
      state = [...state, todo];
      
      // تنفيذ العمليات الأخرى في الخلفية (غير متزامن)
      _handleTodoCreationInBackground(todo);
    } catch (e) {
      // Handle error
      await NotificationLogService.addQuickLog(
        title: 'خطأ في إنشاء مهمة',
        description: 'فشل في إنشاء مهمة: ${todo.title} - $e',
        type: NotificationLogType.error,
        taskId: todo.id,
        taskTitle: todo.title,
      );
    }
  }

  /// معالجة إنشاء المهمة في الخلفية
  void _handleTodoCreationInBackground(TodoModel todo) async {
    try {
      // تسجيل الحدث في سجل الإشعارات
      await NotificationLogService.addQuickLog(
        title: 'تم إنشاء مهمة جديدة',
        description: 'تم إنشاء مهمة جديدة: ${todo.title}',
        type: NotificationLogType.taskCreated,
        taskId: todo.id,
        taskTitle: todo.title,
        metadata: {
          'priority': todo.priority.name,
          'dueDate': todo.dueDate?.toIso8601String(),
          'reminderTime': todo.reminderTime?.toIso8601String(),
        },
      );
      
      // جدولة إشعار للمهمة الجديدة
      await _scheduleNotificationForTodo(todo);
    } catch (e) {
      print('خطأ في معالجة المهمة في الخلفية: $e');
    }
  }

  Future<void> updateTodo(TodoModel todo) async {
    try {
      // حفظ المهمة أولاً وتحديث الـ state فوراً
      await HiveService.updateTodo(todo);
      state = state.map((t) => t.id == todo.id ? todo : t).toList();
      
      // تنفيذ العمليات الأخرى في الخلفية (غير متزامن)
      _handleTodoUpdateInBackground(todo);
    } catch (e) {
      // Handle error
      await NotificationLogService.addQuickLog(
        title: 'خطأ في تحديث مهمة',
        description: 'فشل في تحديث مهمة: ${todo.title} - $e',
        type: NotificationLogType.error,
        taskId: todo.id,
        taskTitle: todo.title,
      );
    }
  }

  /// معالجة تحديث المهمة في الخلفية مع إعادة جدولة الإشعارات
  void _handleTodoUpdateInBackground(TodoModel todo) async {
    try {
      // تسجيل الحدث في سجل الإشعارات
      await NotificationLogService.addQuickLog(
        title: 'تم تحديث مهمة',
        description: 'تم تحديث مهمة: ${todo.title}',
        type: NotificationLogType.taskUpdated,
        taskId: todo.id,
        taskTitle: todo.title,
        metadata: {
          'priority': todo.priority.name,
          'status': todo.status.name,
          'dueDate': todo.dueDate?.toIso8601String(),
          'reminderTime': todo.reminderTime?.toIso8601String(),
        },
      );
      
      // إلغاء الإشعار القديم أولاً
      await _cancelNotificationForTodo(todo.id);
      print('🗑️ تم إلغاء الإشعار القديم للمهمة: ${todo.title}');
      
      // جدولة إشعار جديد بنفس الطريقة المستخدمة في إضافة المهام
      // يستخدم نفس دالة scheduleTaskNotification مع نفس الإعدادات
      await _scheduleNotificationForTodo(todo);
      print('🔄 تم جدولة إشعار جديد للمهمة المحدثة: ${todo.title}');
      
      // التأكد من أن الإشعار الجديد يستخدم الإعدادات الصحيحة
      print('✅ تم تطبيق نفس نظام الإشعارات المستخدم في إضافة المهام');
      
    } catch (e) {
      print('❌ خطأ في معالجة تحديث المهمة في الخلفية: $e');
      
      // تسجيل الخطأ في سجل الإشعارات
      await NotificationLogService.addQuickLog(
        title: 'خطأ في تحديث إشعار المهمة',
        description: 'فشل في تحديث إشعار المهمة: ${todo.title} - $e',
        type: NotificationLogType.error,
        taskId: todo.id,
        taskTitle: todo.title,
      );
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      // الحصول على معلومات المهمة قبل الحذف
      final todo = state.firstWhere((t) => t.id == id);
      
      await HiveService.deleteTodo(id);
      state = state.where((todo) => todo.id != id).toList();
      
      // تسجيل الحدث في سجل الإشعارات
      await NotificationLogService.addQuickLog(
        title: 'تم حذف مهمة',
        description: 'تم حذف مهمة: ${todo.title}',
        type: NotificationLogType.taskDeleted,
        taskId: id,
        taskTitle: todo.title,
        metadata: {
          'priority': todo.priority.name,
          'status': todo.status.name,
        },
      );
      
      // إلغاء إشعار المهمة المحذوفة
      await _cancelNotificationForTodo(id);
    } catch (e) {
      // Handle error
      await NotificationLogService.addQuickLog(
        title: 'خطأ في حذف مهمة',
        description: 'فشل في حذف مهمة: $id - $e',
        type: NotificationLogType.error,
        taskId: id,
      );
    }
  }

  Future<void> deleteTodos(List<String> ids) async {
    try {
      await HiveService.deleteTodos(ids);
      state = state.where((todo) => !ids.contains(todo.id)).toList();
      
      // إلغاء إشعارات المهام المحذوفة
      for (final id in ids) {
        await _cancelNotificationForTodo(id);
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> toggleTodoStatus(String id) async {
    try {
      final todo = state.firstWhere((t) => t.id == id);
      final updatedTodo = todo.copyWith(
        status: todo.status == TodoStatus.completed 
            ? TodoStatus.pending 
            : TodoStatus.completed,
        completedAt: todo.status == TodoStatus.completed 
            ? null 
            : DateTime.now(),
      );
      
      // تسجيل الحدث في سجل الإشعارات
      await NotificationLogService.addQuickLog(
        title: updatedTodo.status == TodoStatus.completed 
            ? 'تم إتمام مهمة' 
            : 'تم إلغاء إتمام مهمة',
        description: updatedTodo.status == TodoStatus.completed 
            ? 'تم إتمام مهمة: ${todo.title}' 
            : 'تم إلغاء إتمام مهمة: ${todo.title}',
        type: NotificationLogType.taskCompleted,
        taskId: id,
        taskTitle: todo.title,
        metadata: {
          'oldStatus': todo.status.name,
          'newStatus': updatedTodo.status.name,
          'completedAt': updatedTodo.completedAt?.toIso8601String(),
        },
      );
      
      // إذا تم إتمام المهمة، ألغ الإشعار
      if (updatedTodo.status == TodoStatus.completed) {
        await _cancelNotificationForTodo(id);
        
        // معالجة المهام المتكررة
        await _repeatingService.handleRepeatingTodoCompletion(updatedTodo);
      } else {
        // إذا تم إلغاء الإتمام، أعد جدولة الإشعار
        await _scheduleNotificationForTodo(updatedTodo);
      }
      
      await HiveService.updateTodo(updatedTodo);
      state = state.map((t) => t.id == id ? updatedTodo : t).toList();
    } catch (e) {
      // Handle error
      await NotificationLogService.addQuickLog(
        title: 'خطأ في تغيير حالة مهمة',
        description: 'فشل في تغيير حالة مهمة: $id - $e',
        type: NotificationLogType.error,
        taskId: id,
      );
    }
  }

  Future<void> refreshTodos() async {
    await _loadTodos();
  }

  Future<void> clearCompletedTodos() async {
    try {
      final completedIds = state
          .where((todo) => todo.status == TodoStatus.completed)
          .map((todo) => todo.id)
          .toList();
      await deleteTodos(completedIds);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> clearAllTodos() async {
    try {
      // إلغاء جميع الإشعارات قبل حذف المهام
      await _notificationService.cancelAllNotifications();
      
      await HiveService.clearAllTodos();
      state = [];
    } catch (e) {
      // Handle error
    }
  }

  /// الحصول على إحصائيات المهام المتكررة
  Map<String, int> getRepeatingTodoStats() {
    return _repeatingService.getRepeatingTodoStats();
  }

  /// فحص يدوي للمهام المتكررة
  Future<void> checkRepeatingTodos() async {
    await _repeatingService.manualCheck();
  }
}

// Enums
enum TodoFilter {
  all,
  pending,
  inProgress,
  completed,
  cancelled,
  overdue,
  today,
  thisWeek,
}

enum TodoSort {
  title,
  dueDate,
  priority,
  createdDate,
  status,
}

// Todo Statistics Model
class TodoStats {
  final int total;
  final int pending;
  final int inProgress;
  final int completed;
  final int cancelled;
  final int overdue;

  TodoStats({
    required this.total,
    required this.pending,
    required this.inProgress,
    required this.completed,
    required this.cancelled,
    required this.overdue,
  });

  double get completionRate {
    if (total == 0) return 0.0;
    return completed / total;
  }

  double get progressRate {
    if (total == 0) return 0.0;
    return (completed + inProgress) / total;
  }

  Map<String, int> toMap() {
    return {
      'total': total,
      'pending': pending,
      'inProgress': inProgress,
      'completed': completed,
      'cancelled': cancelled,
      'overdue': overdue,
    };
  }
}
