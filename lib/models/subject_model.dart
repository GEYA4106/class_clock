import 'package:flutter/material.dart';

@immutable
class SubjectModel {
  const SubjectModel({
    required this.id,
    required this.name,
    required this.faculty,
    required this.colorValue,
  });

  final String id;
  final String name;
  final String faculty;
  final int colorValue;

  Color get color => Color(colorValue);

  SubjectModel copyWith({
    String? id,
    String? name,
    String? faculty,
    int? colorValue,
  }) {
    return SubjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      faculty: faculty ?? this.faculty,
      colorValue: colorValue ?? this.colorValue,
    );
  }

  Map<String, Object> toJson() => {
    'id': id,
    'name': name,
    'faculty': faculty,
    'colorValue': colorValue,
  };

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    final subject = SubjectModel(
      id: json['id'] as String,
      name: json['name'] as String,
      faculty: json['faculty'] as String,
      colorValue: (json['colorValue'] as num).toInt(),
    );
    if (subject.id.isEmpty ||
        subject.name.trim().isEmpty ||
        subject.faculty.trim().isEmpty ||
        subject.colorValue < 0 ||
        subject.colorValue > 0xFFFFFFFF) {
      throw const FormatException('Invalid subject data.');
    }
    return subject;
  }
}
