// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timetable_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TimetableModelAdapter extends TypeAdapter<TimetableModel> {
  @override
  final int typeId = 0;

  @override
  TimetableModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimetableModel(
      dayOfWeek: fields[0] as String,
      startTime: fields[1] as String,
      endTime: fields[2] as String,
      subjectName: fields[3] as String,
      roomNumber: fields[4] as String,
      teacherName: fields[5] as String,
      sectionName: fields[6] as String,
      departmentName: fields[7] as String,
      isAnomaly: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, TimetableModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.dayOfWeek)
      ..writeByte(1)
      ..write(obj.startTime)
      ..writeByte(2)
      ..write(obj.endTime)
      ..writeByte(3)
      ..write(obj.subjectName)
      ..writeByte(4)
      ..write(obj.roomNumber)
      ..writeByte(5)
      ..write(obj.teacherName)
      ..writeByte(6)
      ..write(obj.sectionName)
      ..writeByte(7)
      ..write(obj.departmentName)
      ..writeByte(8)
      ..write(obj.isAnomaly);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimetableModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
