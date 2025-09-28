import 'package:hive/hive.dart';

part 'notification_log_model.g.dart';

/// نموذج بيانات سجل الإشعارات
@HiveType(typeId: 5)
class NotificationLogModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final NotificationLogType type;

  @HiveField(4)
  final DateTime timestamp;

  @HiveField(5)
  final String? taskId;

  @HiveField(6)
  final String? taskTitle;

  @HiveField(7)
  final Map<String, dynamic>? metadata;

  @HiveField(8)
  final bool isRead;

  NotificationLogModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.timestamp,
    this.taskId,
    this.taskTitle,
    this.metadata,
    this.isRead = false,
  });

  /// إنشاء سجل إشعار جديد
  factory NotificationLogModel.create({
    required String title,
    required String description,
    required NotificationLogType type,
    String? taskId,
    String? taskTitle,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationLogModel(
      id: 'log_${DateTime.now().millisecondsSinceEpoch}_${type.name}',
      title: title,
      description: description,
      type: type,
      timestamp: DateTime.now(),
      taskId: taskId,
      taskTitle: taskTitle,
      metadata: metadata,
    );
  }

  /// نسخ السجل مع تحديثات
  NotificationLogModel copyWith({
    String? id,
    String? title,
    String? description,
    NotificationLogType? type,
    DateTime? timestamp,
    String? taskId,
    String? taskTitle,
    Map<String, dynamic>? metadata,
    bool? isRead,
  }) {
    return NotificationLogModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      taskId: taskId ?? this.taskId,
      taskTitle: taskTitle ?? this.taskTitle,
      metadata: metadata ?? this.metadata,
      isRead: isRead ?? this.isRead,
    );
  }

  /// تحويل إلى Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'taskId': taskId,
      'taskTitle': taskTitle,
      'metadata': metadata,
      'isRead': isRead,
    };
  }

  /// إنشاء من Map
  factory NotificationLogModel.fromMap(Map<String, dynamic> map) {
    return NotificationLogModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: NotificationLogType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => NotificationLogType.info,
      ),
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      taskId: map['taskId'],
      taskTitle: map['taskTitle'],
      metadata: map['metadata'] != null ? Map<String, dynamic>.from(map['metadata']) : null,
      isRead: map['isRead'] ?? false,
    );
  }

  @override
  String toString() {
    return 'NotificationLogModel(id: $id, title: $title, type: $type, timestamp: $timestamp, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationLogModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// أنواع سجل الإشعارات
@HiveType(typeId: 6)
enum NotificationLogType {
  @HiveField(0)
  taskCreated, // تم إنشاء مهمة

  @HiveField(1)
  taskCompleted, // تم إتمام مهمة

  @HiveField(2)
  taskUpdated, // تم تحديث مهمة

  @HiveField(3)
  taskDeleted, // تم حذف مهمة

  @HiveField(4)
  notificationScheduled, // تم جدولة إشعار (عند النقر على الإشعار فقط)

  @HiveField(5)
  error, // خطأ

  @HiveField(6)
  info, // معلومات عامة

  @HiveField(7)
  warning, // تحذير
}

/// امتدادات لـ NotificationLogType
extension NotificationLogTypeExtension on NotificationLogType {
  /// الحصول على الأيقونة المناسبة
  String get icon {
    switch (this) {
      case NotificationLogType.taskCreated:
        return '📝';
      case NotificationLogType.taskCompleted:
        return '✅';
      case NotificationLogType.taskUpdated:
        return '✏️';
      case NotificationLogType.taskDeleted:
        return '🗑️';
      case NotificationLogType.notificationScheduled:
        return '⏰';
      case NotificationLogType.error:
        return '❌';
      case NotificationLogType.info:
        return 'ℹ️';
      case NotificationLogType.warning:
        return '⚠️';
    }
  }

  /// الحصول على اللون المناسب
  String get colorHex {
    switch (this) {
      case NotificationLogType.taskCreated:
        return '#4CAF50'; // أخضر
      case NotificationLogType.taskCompleted:
        return '#8BC34A'; // أخضر فاتح
      case NotificationLogType.taskUpdated:
        return '#FF9800'; // برتقالي
      case NotificationLogType.taskDeleted:
        return '#F44336'; // أحمر
      case NotificationLogType.notificationScheduled:
        return '#2196F3'; // أزرق
      case NotificationLogType.error:
        return '#F44336'; // أحمر
      case NotificationLogType.info:
        return '#2196F3'; // أزرق
      case NotificationLogType.warning:
        return '#FF9800'; // برتقالي
    }
  }

  /// الحصول على التسمية العربية
  String get arabicLabel {
    switch (this) {
      case NotificationLogType.taskCreated:
        return 'إنشاء مهمة';
      case NotificationLogType.taskCompleted:
        return 'إتمام مهمة';
      case NotificationLogType.taskUpdated:
        return 'تحديث مهمة';
      case NotificationLogType.taskDeleted:
        return 'حذف مهمة';
      case NotificationLogType.notificationScheduled:
        return 'جدولة إشعار';
      case NotificationLogType.error:
        return 'خطأ';
      case NotificationLogType.info:
        return 'معلومات';
      case NotificationLogType.warning:
        return 'تحذير';
    }
  }
}
