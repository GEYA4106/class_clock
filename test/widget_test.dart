// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:convert';

import 'package:class_clock/models/class_model.dart';
import 'package:class_clock/models/subject_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:class_clock/main.dart';

void main() {
  testWidgets('any student roll number and valid faculty email can log in', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const ClassClockApp());

    expect(find.text('ClassClock'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'ABC123');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome, ABC123'), findsOneWidget);
    expect(find.text('My Timetable'), findsOneWidget);
    expect(find.text('No timetable available'), findsOneWidget);
    expect(find.byTooltip('Edit class'), findsNothing);

    await tester.tap(find.byTooltip('Log out'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Faculty'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'teacher@gmail.com');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome, Faculty'), findsOneWidget);
    expect(find.text('teacher@gmail.com'), findsOneWidget);
    await tester.tap(find.text('Manage Timetable').first);
    await tester.pumpAndSettle();
    expect(find.text('Manage Timetable'), findsOneWidget);
    expect(find.text('CSE 1A'), findsWidgets);

    await tester.tap(find.byTooltip('Log out'));
    await tester.pumpAndSettle();
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('saved classes are shown in the dashboard and timetable', (
    WidgetTester tester,
  ) async {
    final classModel = ClassModel(
      id: 'stored-class',
      subject: 'Saved Computing Class',
      faculty: 'Dr. Rao',
      room: 'A-204',
      classSection: 'CSE 3A',
      day: DateTime.now().weekday,
      startTime: 9 * 60,
      endTime: 10 * 60,
      colorValue: 0xFF4C7C72,
    );
    final otherSectionClass = classModel.copyWith(
      id: 'other-section',
      subject: 'Other Section Class',
      classSection: 'CSE 3B',
    );
    SharedPreferences.setMockInitialValues({
      'class_clock_classes': jsonEncode([
        classModel.toJson(),
        otherSectionClass.toJson(),
      ]),
    });

    await tester.pumpWidget(const ClassClockApp());
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '23CSE999');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('student-section-picker')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('CSE 3A').last);
    await tester.pumpAndSettle();
    expect(find.text('Saved Computing Class'), findsWidgets);
    expect(find.text('Other Section Class'), findsNothing);

    await tester.tap(find.byTooltip('Log out'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Faculty'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'faculty@anywhere.edu');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Timetable').last);
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('faculty-timetable-section-picker')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('CSE 3A').last);
    await tester.pumpAndSettle();
    expect(find.text('Saved Computing Class'), findsOneWidget);
    expect(find.text('Dr. Rao'), findsOneWidget);
    await tester.tap(
      find.byKey(const ValueKey('faculty-timetable-section-picker')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('CSE 3B').last);
    await tester.pumpAndSettle();
    expect(find.text('Other Section Class'), findsOneWidget);
    expect(find.text('Saved Computing Class'), findsNothing);
  });

  testWidgets('subjects can be added, edited, and deleted', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const ClassClockApp());

    await tester.tap(find.text('Faculty'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'faculty@anywhere.edu');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Subjects').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Subject'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Biology');
    await tester.enterText(find.byType(TextFormField).at(1), 'Dr. Sen');
    await tester.ensureVisible(find.byKey(const ValueKey('save-subject')));
    await tester.tap(find.byKey(const ValueKey('save-subject')));
    await tester.pumpAndSettle();

    expect(find.text('Subjects'), findsWidgets);
    expect(find.text('Biology'), findsOneWidget);
    expect(find.text('Dr. Sen'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Cell Biology');
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();
    expect(find.text('Cell Biology'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();
    expect(find.text('No subjects yet'), findsOneWidget);
  });

  testWidgets('selecting a saved subject fills its faculty in Add Class', (
    WidgetTester tester,
  ) async {
    const subject = SubjectModel(
      id: 'biology',
      name: 'Biology',
      faculty: 'Dr. Sen',
      colorValue: 0xFF356B61,
    );
    SharedPreferences.setMockInitialValues({
      'class_clock_subjects': jsonEncode([subject.toJson()]),
    });

    await tester.pumpWidget(const ClassClockApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Faculty'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'faculty@anywhere.edu');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Class'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('class-subject-dropdown-null')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Biology').last);
    await tester.pumpAndSettle();

    final facultyField = tester.widget<TextFormField>(
      find.byKey(const ValueKey('class-faculty-field')),
    );
    expect(facultyField.controller?.text, 'Dr. Sen');
  });

  testWidgets('empty roll numbers and invalid emails are rejected', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const ClassClockApp());

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    expect(find.text('Enter your roll number'), findsOneWidget);

    await tester.tap(find.text('Faculty'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'unknown@college.edu');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome, Faculty'), findsOneWidget);

    await tester.tap(find.byTooltip('Log out'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Faculty'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'not-an-email');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid email address'), findsOneWidget);
  });
}
