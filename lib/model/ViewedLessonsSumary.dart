class ViewedLessonsSummary {
  final int viewedCount;
  final List<String> viewedLessons;

  ViewedLessonsSummary({required this.viewedCount, required this.viewedLessons});

  factory ViewedLessonsSummary.fromJson(Map<String, dynamic> json) {
    final List<dynamic> lessonsListDynamic = json['viewed_lessons'] as List<dynamic>? ?? [];

    final List<String> lessonsListString =
    lessonsListDynamic.map((item) => item.toString()).toList();

    return ViewedLessonsSummary(
        viewedCount: json['viewed_count'] as int? ?? 0,
        viewedLessons: lessonsListString
    );
  }
}
