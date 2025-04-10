import 'option.dart';

class Question {
  final int id;
  final int topicId;
  final String questionText;
  final String? explanation;
  final List<Option> options;

  Question({
    required this.id,
    required this.topicId,
    required this.questionText,
    this.explanation,
    required this.options,
  });

  factory Question.fromMap(Map<String, dynamic> map, List<Option> options) {
    return Question(
      id: map['id'],
      topicId: map['topic_id'],
      questionText: map['question_text'],
      explanation: map['explanation'],
      options: options,
    );
  }
}
