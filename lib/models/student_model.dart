class StudentModel {
  const StudentModel({required this.rollNumber});

  final String rollNumber;

  Map<String, String> toJson() => {'rollNumber': rollNumber};

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(rollNumber: json['rollNumber'] as String);
  }
}
