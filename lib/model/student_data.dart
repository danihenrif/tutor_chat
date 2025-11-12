import 'package:tutor_chat/model/module.dart';

class StudentData {
  final String studentId;
  final List<Module> modules;

  StudentData({
    required this.studentId,
    required this.modules,
  });

  factory StudentData.fromJson(Map<String, dynamic> json) {

    final modulesList = json['modules'] as List;

    List<Module> modules = modulesList.map((i) =>
        Module.fromJson(i as Map<String, dynamic>)
    ).toList();

    return StudentData(
      studentId: json['student_id'] as String,
      modules: modules,
    );
  }
}