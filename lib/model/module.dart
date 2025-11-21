import 'lesson.dart';

class Module {
  final String moduleId;
  final String title;
  final List<Lesson> lessons;

  Module({
    required this.moduleId,
    required this.title,
    required this.lessons,
  });

  factory Module.fromJson(Map<String, dynamic> json) {
    var list = json['lessons'] as List;
    List<Lesson> lessonsList = list.map((i) => Lesson.fromJson(i)).toList();

    return Module(
      moduleId: json['module_id'] as String,
      title: json['title'] as String,
      lessons: lessonsList,
    );
  }
}