class Option {
  final int id;
  final int questionId;
  final String text;
  final bool isCorrect;

  Option({
    required this.id,
    required this.questionId,
    required this.text,
    required this.isCorrect,
  });

  factory Option.fromMap(Map<String, dynamic> map) {
    return Option(
      id: map['id'],
      questionId: map['question_id'],
      text: map['text'],
      isCorrect: map['is_correct'] == 1,
    );
  }
}
