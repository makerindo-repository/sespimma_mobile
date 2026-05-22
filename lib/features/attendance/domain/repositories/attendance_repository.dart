import '../entities/attendance_entity.dart';

abstract interface class AttendanceRepository {
  Future<List<AttendanceEntity>> getAttendances();
  Future<AttendanceEntity> getAttendanceDetail(String id);
  Future<void> submitAttendance(AttendanceEntity attendance);
}
