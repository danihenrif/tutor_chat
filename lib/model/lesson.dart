class Lesson {
  final String lessonId;
  final String lessonName;
  final String videoLink;
  int viewStatus;

  Lesson({
    required this.lessonId,
    required this.lessonName,
    required this.videoLink,
    required this.viewStatus,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      lessonId: json['lesson_id'] ?? '',
      lessonName: json['lesson_name'] as String,
      videoLink: json['video_link'] as String,
      viewStatus: json['view_status'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lesson_id': lessonId,
      'nome_aula': lessonName,
      'visto': viewStatus,
    };
  }
}