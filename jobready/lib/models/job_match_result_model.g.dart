// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_match_result_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class JobMatchResultModelAdapter extends TypeAdapter<JobMatchResultModel> {
  @override
  final int typeId = 5;

  @override
  JobMatchResultModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return JobMatchResultModel(
      id: fields[0] as String,
      analyzedAt: fields[1] as DateTime,
      matchScore: fields[2] as int,
      matchedKeywords: (fields[3] as List).cast<String>(),
      missingKeywords: (fields[4] as List).cast<String>(),
      roleFitSummary: fields[5] as String,
      jobDescriptionSnippet: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, JobMatchResultModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.analyzedAt)
      ..writeByte(2)
      ..write(obj.matchScore)
      ..writeByte(3)
      ..write(obj.matchedKeywords)
      ..writeByte(4)
      ..write(obj.missingKeywords)
      ..writeByte(5)
      ..write(obj.roleFitSummary)
      ..writeByte(6)
      ..write(obj.jobDescriptionSnippet);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JobMatchResultModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
