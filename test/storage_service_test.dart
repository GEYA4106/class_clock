import 'package:class_clock/models/class_model.dart';
import 'package:class_clock/models/subject_model.dart';
import 'package:class_clock/services/storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StorageService storage;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    storage = const StorageService();
  });

  test('loads empty collections when nothing has been saved', () async {
    expect(await storage.loadClasses(), isEmpty);
    expect(await storage.loadSubjects(), isEmpty);
  });

  test('supports class and subject add, update, and delete', () async {
    const classModel = ClassModel(
      id: 'class-1',
      subject: 'Computing',
      faculty: 'Dr. Rao',
      room: 'A-204',
      day: DateTime.monday,
      startTime: 9 * 60,
      endTime: 10 * 60,
      colorValue: 0xFF4C7C72,
    );
    const subject = SubjectModel(
      id: 'subject-1',
      name: 'Computing',
      faculty: 'Dr. Rao',
      colorValue: 0xFF4C7C72,
    );

    await storage.addClass(classModel);
    expect((await storage.loadClasses()).single.toJson(), classModel.toJson());
    final updatedClass = classModel.copyWith(room: 'B-108');
    await storage.updateClass(updatedClass);
    expect((await storage.loadClasses()).single.room, 'B-108');
    await storage.deleteClass(classModel.id);
    expect(await storage.loadClasses(), isEmpty);

    await storage.addSubject(subject);
    expect((await storage.loadSubjects()).single.toJson(), subject.toJson());
    final updatedSubject = subject.copyWith(name: 'Algorithms');
    await storage.updateSubject(updatedSubject);
    expect((await storage.loadSubjects()).single.name, 'Algorithms');
    await storage.deleteSubject(subject.id);
    expect(await storage.loadSubjects(), isEmpty);
  });

  test('ignores invalid stored JSON without throwing', () async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('class_clock_classes', '{invalid');

    expect(await storage.loadClasses(), isEmpty);
  });

  test('does not allow duplicate subject IDs', () async {
    const subject = SubjectModel(
      id: 'subject-1',
      name: 'Computing',
      faculty: 'Dr. Rao',
      colorValue: 0xFF4C7C72,
    );
    await storage.addSubject(subject);

    await expectLater(storage.addSubject(subject), throwsStateError);
    expect(await storage.loadSubjects(), hasLength(1));
  });
}
