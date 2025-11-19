import 'lesson.dart';

class Module {
  final String moduleId;
  final String moduleName;
  final List<Lesson> lessons;

  Module({
    required this.moduleId,
    required this.moduleName,
    required this.lessons,
  });

  factory Module.fromJson(Map<String, dynamic> json) {
    final lessonsList = json['lessons'] as List;

    List<Lesson> lessons = lessonsList.map((i) =>
        Lesson.fromJson(i as Map<String, dynamic>)
    ).toList();

    return Module(
      moduleId: json['module_id'] ?? '',
      moduleName: json['module_name'] as String,
      lessons: lessons,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'module_id': moduleId,
      'nome_modulo': moduleName,
      'aulas': lessons.map((l) => l.toJson()).toList(),
    };
  }
}