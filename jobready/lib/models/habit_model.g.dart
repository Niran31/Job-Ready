// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitModelAdapter extends TypeAdapter<HabitModel> {
  @override
  final int typeId = 0;

  @override
  HabitModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HabitModel(
      name: fields[0] as String,
      emoji: fields[1] as String,
      category: fields[3] as String,
      completedDates: (fields[2] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, HabitModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.emoji)
      ..writeByte(2)
      ..write(obj.completedDates)
      ..writeByte(3)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class JobModelAdapter extends TypeAdapter<JobModel> {
  @override
  final int typeId = 1;

  @override
  JobModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return JobModel(
      company: fields[0] as String,
      role: fields[1] as String,
      status: fields[2] as String,
      appliedDate: fields[3] as String,
      notes: fields[4] as String?,
      jobUrl: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, JobModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.company)
      ..writeByte(1)
      ..write(obj.role)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.appliedDate)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.jobUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JobModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SkillLogModelAdapter extends TypeAdapter<SkillLogModel> {
  @override
  final int typeId = 2;

  @override
  SkillLogModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SkillLogModel(
      skill: fields[0] as String,
      hoursStudied: fields[1] as double,
      date: fields[2] as String,
      notes: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SkillLogModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.skill)
      ..writeByte(1)
      ..write(obj.hoursStudied)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SkillLogModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WeeklyReviewModelAdapter extends TypeAdapter<WeeklyReviewModel> {
  @override
  final int typeId = 3;

  @override
  WeeklyReviewModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WeeklyReviewModel(
      weekEndDate: fields[0] as String,
      grade: fields[1] as String,
      applicationsSent: fields[2] as int,
      interviewsReceived: fields[3] as int,
      skillHoursCompleted: fields[4] as double,
      habitCompletionRate: fields[5] as double,
      grindScoreChange: fields[6] as int,
      reflectionNotes: fields[7] as String,
      strengths: (fields[8] as List).cast<String>(),
      weaknesses: (fields[9] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, WeeklyReviewModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.weekEndDate)
      ..writeByte(1)
      ..write(obj.grade)
      ..writeByte(2)
      ..write(obj.applicationsSent)
      ..writeByte(3)
      ..write(obj.interviewsReceived)
      ..writeByte(4)
      ..write(obj.skillHoursCompleted)
      ..writeByte(5)
      ..write(obj.habitCompletionRate)
      ..writeByte(6)
      ..write(obj.grindScoreChange)
      ..writeByte(7)
      ..write(obj.reflectionNotes)
      ..writeByte(8)
      ..write(obj.strengths)
      ..writeByte(9)
      ..write(obj.weaknesses);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeeklyReviewModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
