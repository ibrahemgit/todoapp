import 'package:hive_flutter/hive_flutter.dart';
import '../models/todo_model.dart';
import '../models/notification_log_model.dart';
import '../constants/app_constants.dart';

class HiveService {
  static late Box<TodoModel> _todoBox;
  static late Box<Map> _settingsBox;
  static bool _isInitialized = false;

  // Initialize Hive
  static Future<void> init() async {
    if (_isInitialized) return;
    
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(TodoModelAdapter());
    Hive.registerAdapter(TodoPriorityAdapter());
    Hive.registerAdapter(TodoStatusAdapter());
    Hive.registerAdapter(RepeatingTypeAdapter());
    Hive.registerAdapter(NotificationLogModelAdapter());
    Hive.registerAdapter(NotificationLogTypeAdapter());
    
    // Open boxes
    _todoBox = await Hive.openBox<TodoModel>(AppConstants.todoBoxName);
    _settingsBox = await Hive.openBox<Map>(AppConstants.settingsBoxName);
    
    _isInitialized = true;
  }

  // Todo Operations
  static Future<void> saveTodo(TodoModel todo) async {
    await _todoBox.put(todo.id, todo);
  }

  static Future<void> saveTodos(List<TodoModel> todos) async {
    final Map<String, TodoModel> todoMap = {
      for (var todo in todos) todo.id: todo
    };
    await _todoBox.putAll(todoMap);
  }

  static TodoModel? getTodo(String id) {
    return _todoBox.get(id);
  }

  static List<TodoModel> getAllTodos() {
    return _todoBox.values.toList();
  }

  static List<TodoModel> getTodosByStatus(TodoStatus status) {
    return _todoBox.values.where((todo) => todo.status == status).toList();
  }

  static List<TodoModel> getTodosByPriority(TodoPriority priority) {
    return _todoBox.values.where((todo) => todo.priority == priority).toList();
  }

  static List<TodoModel> getTodosByCategory(String category) {
    return _todoBox.values.where((todo) => todo.category == category).toList();
  }

  static List<TodoModel> getTodosByDateRange(DateTime startDate, DateTime endDate) {
    return _todoBox.values.where((todo) {
      if (todo.dueDate == null) return false;
      return todo.dueDate!.isAfter(startDate) && todo.dueDate!.isBefore(endDate);
    }).toList();
  }

  static List<TodoModel> getTodosByTag(String tag) {
    return _todoBox.values.where((todo) => todo.tags.contains(tag)).toList();
  }

  static List<TodoModel> searchTodos(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _todoBox.values.where((todo) {
      return todo.title.toLowerCase().contains(lowercaseQuery) ||
             (todo.description?.toLowerCase().contains(lowercaseQuery) ?? false) ||
             todo.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  static Future<void> updateTodo(TodoModel todo) async {
    await _todoBox.put(todo.id, todo);
  }

  static Future<void> deleteTodo(String id) async {
    await _todoBox.delete(id);
  }

  static Future<void> deleteTodos(List<String> ids) async {
    await _todoBox.deleteAll(ids);
  }

  static Future<void> clearAllTodos() async {
    await _todoBox.clear();
  }

  // Settings Operations
  static Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, {'value': value, 'timestamp': DateTime.now().millisecondsSinceEpoch});
  }

  static T? getSetting<T>(String key, {T? defaultValue}) {
    final setting = _settingsBox.get(key);
    if (setting == null) return defaultValue;
    return setting['value'] as T? ?? defaultValue;
  }

  static Future<void> deleteSetting(String key) async {
    await _settingsBox.delete(key);
  }

  static Future<void> clearAllSettings() async {
    await _settingsBox.clear();
  }

  // Statistics
  static int getTotalTodosCount() {
    return _todoBox.length;
  }

  static int getCompletedTodosCount() {
    return _todoBox.values.where((todo) => todo.status == TodoStatus.completed).length;
  }

  static int getPendingTodosCount() {
    return _todoBox.values.where((todo) => todo.status == TodoStatus.pending).length;
  }

  static int getInProgressTodosCount() {
    return _todoBox.values.where((todo) => todo.status == TodoStatus.inProgress).length;
  }

  static int getCancelledTodosCount() {
    return _todoBox.values.where((todo) => todo.status == TodoStatus.cancelled).length;
  }

  static Map<TodoPriority, int> getTodosCountByPriority() {
    final Map<TodoPriority, int> counts = {};
    for (final priority in TodoPriority.values) {
      counts[priority] = _todoBox.values.where((todo) => todo.priority == priority).length;
    }
    return counts;
  }

  static Map<String, int> getTodosCountByCategory() {
    final Map<String, int> counts = {};
    for (final todo in _todoBox.values) {
      final category = todo.category ?? 'Uncategorized';
      counts[category] = (counts[category] ?? 0) + 1;
    }
    return counts;
  }

  // Backup and Restore
  static Map<String, dynamic> exportData() {
    return {
      'todos': _todoBox.values.map((todo) => todo.toJson()).toList(),
      'settings': _settingsBox.toMap(),
      'exportDate': DateTime.now().toIso8601String(),
      'version': AppConstants.appVersion,
    };
  }

  static Future<void> importData(Map<String, dynamic> data) async {
    // Import todos
    if (data['todos'] != null) {
      final List<dynamic> todosJson = data['todos'] as List<dynamic>;
      for (final todoJson in todosJson) {
        final todo = TodoModel.fromJson(todoJson as Map<String, dynamic>);
        await saveTodo(todo);
      }
    }

    // Import settings
    if (data['settings'] != null) {
      final Map<String, dynamic> settings = data['settings'] as Map<String, dynamic>;
      for (final entry in settings.entries) {
        await _settingsBox.put(entry.key, entry.value);
      }
    }
  }

  // Cleanup
  static Future<void> close() async {
    await _todoBox.close();
    await _settingsBox.close();
    _isInitialized = false;
  }

  // Health Check
  static bool isHealthy() {
    return _isInitialized && _todoBox.isOpen && _settingsBox.isOpen;
  }

  // Get Box Info
  static Map<String, dynamic> getBoxInfo() {
    return {
      'isInitialized': _isInitialized,
      'todoBoxIsOpen': _todoBox.isOpen,
      'settingsBoxIsOpen': _settingsBox.isOpen,
      'todoBoxLength': _todoBox.length,
      'settingsBoxLength': _settingsBox.length,
    };
  }
}
