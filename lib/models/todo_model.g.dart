// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TodoModelAdapter extends TypeAdapter<TodoModel> {
  @override
  final int typeId = 0;

  @override
  TodoModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TodoModel(
      id: fields[0] as String?,
      title: fields[1] as String,
      description: fields[2] as String?,
      createdAt: fields[3] as DateTime?,
      dueDate: fields[4] as DateTime?,
      reminderTime: fields[5] as DateTime?,
      priority: fields[6] as TodoPriority,
      status: fields[7] as TodoStatus,
      category: fields[8] as String?,
      isRepeating: fields[9] as bool,
      repeatingType: fields[10] as RepeatingType?,
      tags: (fields[11] as List).cast<String>(),
      completedAt: fields[12] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, TodoModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.dueDate)
      ..writeByte(5)
      ..write(obj.reminderTime)
      ..writeByte(6)
      ..write(obj.priority)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.category)
      ..writeByte(9)
      ..write(obj.isRepeating)
      ..writeByte(10)
      ..write(obj.repeatingType)
      ..writeByte(11)
      ..write(obj.tags)
      ..writeByte(12)
      ..write(obj.completedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TodoPriorityAdapter extends TypeAdapter<TodoPriority> {
  @override
  final int typeId = 1;

  @override
  TodoPriority read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TodoPriority.low;
      case 1:
        return TodoPriority.medium;
      case 2:
        return TodoPriority.high;
      case 3:
        return TodoPriority.urgent;
      default:
        return TodoPriority.low;
    }
  }

  @override
  void write(BinaryWriter writer, TodoPriority obj) {
    switch (obj) {
      case TodoPriority.low:
        writer.writeByte(0);
        break;
      case TodoPriority.medium:
        writer.writeByte(1);
        break;
      case TodoPriority.high:
        writer.writeByte(2);
        break;
      case TodoPriority.urgent:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoPriorityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TodoStatusAdapter extends TypeAdapter<TodoStatus> {
  @override
  final int typeId = 2;

  @override
  TodoStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TodoStatus.pending;
      case 1:
        return TodoStatus.inProgress;
      case 2:
        return TodoStatus.completed;
      case 3:
        return TodoStatus.cancelled;
      default:
        return TodoStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, TodoStatus obj) {
    switch (obj) {
      case TodoStatus.pending:
        writer.writeByte(0);
        break;
      case TodoStatus.inProgress:
        writer.writeByte(1);
        break;
      case TodoStatus.completed:
        writer.writeByte(2);
        break;
      case TodoStatus.cancelled:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RepeatingTypeAdapter extends TypeAdapter<RepeatingType> {
  @override
  final int typeId = 3;

  @override
  RepeatingType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RepeatingType.daily;
      case 1:
        return RepeatingType.weekly;
      case 2:
        return RepeatingType.monthly;
      case 3:
        return RepeatingType.yearly;
      default:
        return RepeatingType.daily;
    }
  }

  @override
  void write(BinaryWriter writer, RepeatingType obj) {
    switch (obj) {
      case RepeatingType.daily:
        writer.writeByte(0);
        break;
      case RepeatingType.weekly:
        writer.writeByte(1);
        break;
      case RepeatingType.monthly:
        writer.writeByte(2);
        break;
      case RepeatingType.yearly:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RepeatingTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
