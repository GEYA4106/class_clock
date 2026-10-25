import 'package:flutter/material.dart';

@immutable
class ClassModel {
  const ClassModel({
    required this.id,
    required this.subject,
    required this.faculty,
    required this.room,
    this.classSection = 'General',
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.colorValue,
  });

  final String id;
  final String subject;
  final String faculty;
  final String room;
  final String classSection;

  /// Weekday from `DateTime.monday` through `DateTime.sunday`.
  final int day;

  /// Minutes after midnight.
  final int startTime;

  /// Minutes after midnight.
  final int endTime;

  final int colorValue;

  Color get color => Color(colorValue);

  ClassModel copyWith({
    String? id,
    String? subject,
    String? faculty,
    String? room,
    String? classSection,
    int? day,
    int? startTime,
    int? endTime,
    int? colorValue,
  }) {
    return ClassModel(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      faculty: faculty ?? this.faculty,
      room: room ?? this.room,
      classSection: classSection ?? this.classSection,
      day: day ?? this.day,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      colorValue: colorValue ?? this.colorValue,
    );
  }

  Map<String, Object> toJson() => {
    'id': id,
    'subject': subject,
    'faculty': faculty,
    'room': room,
    'classSection': classSection,
    'day': day,
    'startTime': startTime,
    'endTime': endTime,
    'colorValue': colorValue,
  };

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    final classModel = ClassModel(
      id: json['id'] as String,
      subject: json['subject'] as String,
      faculty: json['faculty'] as String,
      room: json['room'] as String,
      classSection: json['classSection'] as String? ?? 'General',
      day: (json['day'] as num).toInt(),
      startTime: (json['startTime'] as num).toInt(),
      endTime: (json['endTime'] as num).toInt(),
      colorValue: (json['colorValue'] as num).toInt(),
    );
    if (classModel.id.isEmpty ||
        classModel.subject.trim().isEmpty ||
        classModel.faculty.trim().isEmpty ||
        classModel.room.trim().isEmpty ||
        classModel.classSection.trim().isEmpty ||
        classModel.day < DateTime.monday ||
        classModel.day > DateTime.sunday ||
        classModel.startTime < 0 ||
        classModel.startTime >= 24 * 60 ||
        classModel.endTime <= classModel.startTime ||
        classModel.endTime >= 24 * 60 ||
        classModel.colorValue < 0 ||
        classModel.colorValue > 0xFFFFFFFF) {
      throw const FormatException('Invalid class data.');
    }
    return classModel;
  }
}
