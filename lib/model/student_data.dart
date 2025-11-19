import 'module.dart';

class StudentData {
  final String studentId;
  final String? courseId;
  final List<Module> modules;

  StudentData({
    required this.studentId,
    this.courseId,
    required this.modules,
  });

  factory StudentData.fromJson(Map<String, dynamic> json) {

    final modulesList = json['modules'] as List;

    List<Module> modules = modulesList.map((i) =>
        Module.fromJson(i as Map<String, dynamic>)
    ).toList();

    return StudentData(
      studentId: json['student_id'] as String,
      courseId: json['course_id'] as String?, // 🔑 Mapeando course_id
      modules: modules,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'course_id': courseId,
      'modulos': modules.map((m) => m?.toJson()).toList(),
    };
  }
}