// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_queue_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SyncQueueModelAdapter extends TypeAdapter<SyncQueueModel> {
  @override
  final int typeId = 6;

  @override
  SyncQueueModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SyncQueueModel(
      action: fields[0] as String,
      collection: fields[1] as String,
      docId: fields[2] as String,
      data: (fields[3] as Map?)?.cast<String, dynamic>(),
      timestamp: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SyncQueueModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.action)
      ..writeByte(1)
      ..write(obj.collection)
      ..writeByte(2)
      ..write(obj.docId)
      ..writeByte(3)
      ..write(obj.data)
      ..writeByte(4)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncQueueModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
