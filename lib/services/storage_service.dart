import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/class_model.dart';
import '../models/subject_model.dart';

class StorageService {
  const StorageService();

  static const _classesKey = 'class_clock_classes';
  static const _subjectsKey = 'class_clock_subjects';

  Future<List<ClassModel>> loadClasses() async {
    final preferences = await SharedPreferences.getInstance();
    return _decodeList(
      preferences.getString(_classesKey),
      ClassModel.fromJson,
      _classesKey,
    );
  }

  Future<void> saveClasses(List<ClassModel> classes) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      _classesKey,
      jsonEncode(classes.map((classModel) => classModel.toJson()).toList()),
    );
    if (!saved) {
      throw StateError('Could not save timetable classes.');
    }
  }

  Future<void> addClass(ClassModel classModel) async {
    final classes = await loadClasses();
    await saveClasses([...classes, classModel]);
  }

  Future<void> updateClass(ClassModel classModel) async {
    final classes = await loadClasses();
    final index = classes.indexWhere((item) => item.id == classModel.id);
    if (index == -1) {
      throw StateError('The class to update could not be found.');
    }
    classes[index] = classModel;
    await saveClasses(classes);
  }

  Future<void> deleteClass(String id) async {
    final classes = await loadClasses();
    await saveClasses(classes.where((item) => item.id != id).toList());
  }

  Future<List<SubjectModel>> loadSubjects() async {
    final preferences = await SharedPreferences.getInstance();
    return _decodeList(
      preferences.getString(_subjectsKey),
      SubjectModel.fromJson,
      _subjectsKey,
    );
  }

  Future<void> saveSubjects(List<SubjectModel> subjects) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      _subjectsKey,
      jsonEncode(subjects.map((subject) => subject.toJson()).toList()),
    );
    if (!saved) {
      throw StateError('Could not save subjects.');
    }
  }

  Future<void> addSubject(SubjectModel subject) async {
    final subjects = await loadSubjects();
    if (subjects.any((item) => item.id == subject.id)) {
      throw StateError('A subject with this ID already exists.');
    }
    await saveSubjects([...subjects, subject]);
  }

  Future<void> updateSubject(SubjectModel subject) async {
    final subjects = await loadSubjects();
    final index = subjects.indexWhere((item) => item.id == subject.id);
    if (index == -1) {
      throw StateError('The subject to update could not be found.');
    }
    subjects[index] = subject;
    await saveSubjects(subjects);
  }

  Future<void> deleteSubject(String id) async {
    final subjects = await loadSubjects();
    await saveSubjects(subjects.where((item) => item.id != id).toList());
  }

  List<T> _decodeList<T>(
    String? stored,
    T Function(Map<String, dynamic>) fromJson,
    String storageKey,
  ) {
    if (stored == null) return [];

    final Object? decoded;
    try {
      decoded = jsonDecode(stored);
    } on FormatException catch (error) {
      debugPrint('Ignoring invalid saved data for $storageKey: $error');
      return [];
    }

    if (decoded is! List) {
      debugPrint('Ignoring invalid saved data for $storageKey: expected a list.');
      return [];
    }

    final result = <T>[];
    for (final item in decoded) {
      if (item is! Map<String, dynamic>) {
        debugPrint('Ignoring an invalid entry in $storageKey.');
        continue;
      }
      try {
        result.add(fromJson(item));
      } on FormatException catch (error) {
        debugPrint('Ignoring an invalid entry in $storageKey: $error');
      } on TypeError catch (error) {
        debugPrint('Ignoring an invalid entry in $storageKey: $error');
      } on ArgumentError catch (error) {
        debugPrint('Ignoring an invalid entry in $storageKey: $error');
      }
    }
    return result;
  }
}
