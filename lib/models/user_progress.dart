class UserProgress {
  final int id;
  final int questionId;
  final bool isCorrect;
  final DateTime attemptDate;

  UserProgress({
    required this.id,
    required this.questionId,
    required this.isCorrect,
    required this.attemptDate,
  });

  factory UserProgress.fromMap(Map<String, dynamic> map) {
    return UserProgress(
      id: map['id'],
      questionId: map['question_id'],
      isCorrect: map['is_correct'] == 1,
      attemptDate: DateTime.parse(map['attempt_date']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question_id': questionId,
      'is_correct': isCorrect ? 1 : 0,
      'attempt_date': attemptDate.toIso8601String(),
    };
  }
}