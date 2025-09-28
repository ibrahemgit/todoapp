// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_log_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotificationLogModelAdapter extends TypeAdapter<NotificationLogModel> {
  @override
  final int typeId = 5;

  @override
  NotificationLogModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationLogModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      type: fields[3] as NotificationLogType,
      timestamp: fields[4] as DateTime,
      taskId: fields[5] as String?,
      taskTitle: fields[6] as String?,
      metadata: (fields[7] as Map?)?.cast<String, dynamic>(),
      isRead: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, NotificationLogModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.taskId)
      ..writeByte(6)
      ..write(obj.taskTitle)
      ..writeByte(7)
      ..write(obj.metadata)
      ..writeByte(8)
      ..write(obj.isRead);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationLogModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NotificationLogTypeAdapter extends TypeAdapter<NotificationLogType> {
  @override
  final int typeId = 6;

  @override
  NotificationLogType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return NotificationLogType.taskCreated;
      case 1:
        return NotificationLogType.taskCompleted;
      case 2:
        return NotificationLogType.taskUpdated;
      case 3:
        return NotificationLogType.taskDeleted;
      case 4:
        return NotificationLogType.notificationScheduled;
      case 5:
        return NotificationLogType.error;
      case 6:
        return NotificationLogType.info;
      case 7:
        return NotificationLogType.warning;
      default:
        return NotificationLogType.taskCreated;
    }
  }

  @override
  void write(BinaryWriter writer, NotificationLogType obj) {
    switch (obj) {
      case NotificationLogType.taskCreated:
        writer.writeByte(0);
        break;
      case NotificationLogType.taskCompleted:
        writer.writeByte(1);
        break;
      case NotificationLogType.taskUpdated:
        writer.writeByte(2);
        break;
      case NotificationLogType.taskDeleted:
        writer.writeByte(3);
        break;
      case NotificationLogType.notificationScheduled:
        writer.writeByte(4);
        break;
      case NotificationLogType.error:
        writer.writeByte(5);
        break;
      case NotificationLogType.info:
        writer.writeByte(6);
        break;
      case NotificationLogType.warning:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationLogTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
