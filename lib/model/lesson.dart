class Lesson {
  final String lessonId;
  final String title;
  final String videoUrl;
  final int pedagogicalId;

  Lesson({
    required this.lessonId,
    required this.title,
    required this.videoUrl,
    required this.pedagogicalId,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      lessonId: json['lesson_id'] as String,
      title: json['title'] as String,
      videoUrl: json['video_url'] as String,
      pedagogicalId: json['pedagogical_id'] as int,
    );
  }
}