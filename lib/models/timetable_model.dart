import 'package:hive/hive.dart';

// 🚨 Command to generate: flutter pub run build_runner build
part 'timetable_model.g.dart';

@HiveType(typeId: 0)
class TimetableModel extends HiveObject {
  @HiveField(0)
  String dayOfWeek;

  @HiveField(1)
  String startTime;

  @HiveField(2)
  String endTime;

  @HiveField(3)
  String subjectName;

  @HiveField(4)
  String roomNumber;

  @HiveField(5)
  String teacherName;

  @HiveField(6)
  String sectionName;

  @HiveField(7)
  String departmentName;

  @HiveField(8)
  bool isAnomaly;

  TimetableModel({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.subjectName,
    required this.roomNumber,
    required this.teacherName,
    required this.sectionName,
    required this.departmentName,
    this.isAnomaly = false,
  });

  // 🛠 HELPER: Data validate karne ke liye
  // Agar teacher name missing ho ya room number ajeeb ho toh anomaly mark karega
  void validate() {
    isAnomaly = teacherName.isEmpty ||
        teacherName.contains('TBA') ||
        roomNumber.isEmpty ||
        subjectName.length < 2;
  }
}