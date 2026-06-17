// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resume_result_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ResumeResultModelAdapter extends TypeAdapter<ResumeResultModel> {
  @override
  final int typeId = 4;

  @override
  ResumeResultModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ResumeResultModel(
      id: fields[0] as String,
      analyzedAt: fields[1] as DateTime,
      overallScore: fields[2] as int,
      atsScore: fields[3] as int,
      sectionFeedback: fields[4] as String,
      keywordGaps: (fields[5] as List).cast<String>(),
      resumeTextSnippet: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ResumeResultModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.analyzedAt)
      ..writeByte(2)
      ..write(obj.overallScore)
      ..writeByte(3)
      ..write(obj.atsScore)
      ..writeByte(4)
      ..write(obj.sectionFeedback)
      ..writeByte(5)
      ..write(obj.keywordGaps)
      ..writeByte(6)
      ..write(obj.resumeTextSnippet);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResumeResultModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
