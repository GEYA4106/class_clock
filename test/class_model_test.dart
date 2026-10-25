import 'package:class_clock/models/class_model.dart';
import 'package:class_clock/services/conflict_service.dart';
import 'package:flutter_test/flutter_test.dart';

ClassModel _class({
  String id = 'class-1',
  int day = DateTime.monday,
  String classSection = 'CSE 3A',
  int startTime = 10 * 60,
  int endTime = 11 * 60,
}) {
  return ClassModel(
    id: id,
    subject: 'Computing',
    faculty: 'Dr. Rao',
    room: 'A-204',
    classSection: classSection,
    day: day,
    startTime: startTime,
    endTime: endTime,
    colorValue: 0xFF4C7C72,
  );
}

void main() {
  group('ClassModel', () {
    test('round trips its serializable fields', () {
      final classModel = _class();

      expect(
        ClassModel.fromJson(classModel.toJson()).toJson(),
        classModel.toJson(),
      );
      expect(classModel.copyWith(room: 'B-101').room, 'B-101');
    });

    test('loads old records without classSection as General', () {
      final json = _class().toJson()..remove('classSection');
      expect(ClassModel.fromJson(json).classSection, 'General');
    });
  });

  group('ConflictService', () {
    test('rejects overlapping times on the same day', () {
      final existing = _class();

      expect(
        ConflictService.hasConflict(
          _class(
            id: 'candidate',
            startTime: 10 * 60 + 30,
            endTime: 11 * 60 + 30,
          ),
          [existing],
        ),
        isTrue,
      );
      expect(
        ConflictService.hasConflict(
          _class(
            id: 'candidate',
            startTime: 9 * 60 + 30,
            endTime: 10 * 60 + 30,
          ),
          [existing],
        ),
        isTrue,
      );
    });

    test('allows adjacent classes and different days', () {
      expect(
        ConflictService.hasConflict(
          _class(id: 'candidate', startTime: 11 * 60, endTime: 12 * 60),
          [_class()],
        ),
        isFalse,
      );
      expect(
        ConflictService.hasConflict(
          _class(id: 'candidate', day: DateTime.tuesday),
          [_class()],
        ),
        isFalse,
      );
      expect(
        ConflictService.hasConflict(
          _class(
            id: 'candidate',
            classSection: 'CSE 3B',
            startTime: 10 * 60 + 30,
            endTime: 11 * 60 + 30,
          ),
          [_class()],
        ),
        isFalse,
      );
    });

    test('can ignore the class being edited', () {
      expect(
        ConflictService.hasConflict(_class(), [
          _class(),
        ], ignoreClassId: 'class-1'),
        isFalse,
      );
    });
  });
}
