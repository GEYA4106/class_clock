import '../models/class_model.dart';

abstract final class ConflictService {
  static bool hasConflict(
    ClassModel candidate,
    Iterable<ClassModel> classes, {
    String? ignoreClassId,
  }) {
    return classes.any((existing) {
      if (existing.id == ignoreClassId ||
          existing.classSection != candidate.classSection ||
          existing.day != candidate.day) {
        return false;
      }
      return candidate.startTime < existing.endTime &&
          candidate.endTime > existing.startTime;
    });
  }
}
