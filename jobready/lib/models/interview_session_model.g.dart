// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interview_session_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InterviewSessionModelAdapter extends TypeAdapter<InterviewSessionModel> {
  @override
  final int typeId = 6;

  @override
  InterviewSessionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InterviewSessionModel(
      id: fields[0] as String,
      sessionDate: fields[1] as DateTime,
      jobDescriptionSnippet: fields[2] as String,
      questions: (fields[3] as List).cast<String>(),
      userAnswers: (fields[4] as List).cast<String>(),
      answerScores: (fields[5] as List).cast<int>(),
      answerFeedback: (fields[6] as List).cast<String>(),
      overallScore: fields[7] as int,
      overallSummary: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, InterviewSessionModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.sessionDate)
      ..writeByte(2)
      ..write(obj.jobDescriptionSnippet)
      ..writeByte(3)
      ..write(obj.questions)
      ..writeByte(4)
      ..write(obj.userAnswers)
      ..writeByte(5)
      ..write(obj.answerScores)
      ..writeByte(6)
      ..write(obj.answerFeedback)
      ..writeByte(7)
      ..write(obj.overallScore)
      ..writeByte(8)
      ..write(obj.overallSummary);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InterviewSessionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
