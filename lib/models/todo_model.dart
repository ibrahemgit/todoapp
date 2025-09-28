import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'todo_model.g.dart';

@HiveType(typeId: 0)
class TodoModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final DateTime? dueDate;

  @HiveField(5)
  final DateTime? reminderTime;

  @HiveField(6)
  final TodoPriority priority;

  @HiveField(7)
  final TodoStatus status;

  @HiveField(8)
  final String? category;

  @HiveField(9)
  final bool isRepeating;

  @HiveField(10)
  final RepeatingType? repeatingType;

  @HiveField(11)
  final List<String> tags;

  @HiveField(12)
  final DateTime? completedAt;

  TodoModel({
    String? id,
    required this.title,
    this.description,
    DateTime? createdAt,
    this.dueDate,
    this.reminderTime,
    this.priority = TodoPriority.medium,
    this.status = TodoStatus.pending,
    this.category,
    this.isRepeating = false,
    this.repeatingType,
    this.tags = const [],
    this.completedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  TodoModel copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    DateTime? reminderTime,
    TodoPriority? priority,
    TodoStatus? status,
    String? category,
    bool? isRepeating,
    RepeatingType? repeatingType,
    List<String>? tags,
    DateTime? completedAt,
  }) {
    return TodoModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt,
      dueDate: dueDate ?? this.dueDate,
      reminderTime: reminderTime ?? this.reminderTime,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      category: category ?? this.category,
      isRepeating: isRepeating ?? this.isRepeating,
      repeatingType: repeatingType ?? this.repeatingType,
      tags: tags ?? this.tags,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'reminderTime': reminderTime?.toIso8601String(),
      'priority': priority.toString().split('.').last,
      'status': status.toString().split('.').last,
      'category': category,
      'isRepeating': isRepeating,
      'repeatingType': repeatingType?.toString().split('.').last,
      'tags': tags,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      reminderTime: json['reminderTime'] != null ? DateTime.parse(json['reminderTime']) : null,
      priority: TodoPriority.values.firstWhere(
        (e) => e.toString().split('.').last == json['priority'],
        orElse: () => TodoPriority.medium,
      ),
      status: TodoStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => TodoStatus.pending,
      ),
      category: json['category'],
      isRepeating: json['isRepeating'] ?? false,
      repeatingType: json['repeatingType'] != null
          ? RepeatingType.values.firstWhere(
              (e) => e.toString().split('.').last == json['repeatingType'],
              orElse: () => RepeatingType.daily,
            )
          : null,
      tags: List<String>.from(json['tags'] ?? []),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
    );
  }

  @override
  String toString() {
    return 'TodoModel(id: $id, title: $title, status: $status, priority: $priority)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TodoModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

@HiveType(typeId: 1)
enum TodoPriority {
  @HiveField(0)
  low,
  @HiveField(1)
  medium,
  @HiveField(2)
  high,
  @HiveField(3)
  urgent,
}

@HiveType(typeId: 2)
enum TodoStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  inProgress,
  @HiveField(2)
  completed,
  @HiveField(3)
  cancelled,
}

@HiveType(typeId: 3)
enum RepeatingType {
  @HiveField(0)
  daily,
  @HiveField(1)
  weekly,
  @HiveField(2)
  monthly,
  @HiveField(3)
  yearly,
}
