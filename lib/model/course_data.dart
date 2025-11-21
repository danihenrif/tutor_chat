import 'module.dart';

class CourseData {
  final String courseId;
  final String title;
  final String description;
  final List<Module> modules;

  CourseData({
    required this.courseId,
    required this.title,
    required this.description,
    required this.modules,
  });

  factory CourseData.fromJson(Map<String, dynamic> json) {
    var list = json['modules'] as List;
    List<Module> modulesList = list.map((i) => Module.fromJson(i)).toList();

    return CourseData(
      courseId: json['course_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      modules: modulesList,
    );
  }
}