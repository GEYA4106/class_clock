class FacultyModel {
  const FacultyModel({required this.email});

  final String email;

  Map<String, String> toJson() => {'email': email};

  factory FacultyModel.fromJson(Map<String, dynamic> json) {
    return FacultyModel(email: json['email'] as String);
  }
}
