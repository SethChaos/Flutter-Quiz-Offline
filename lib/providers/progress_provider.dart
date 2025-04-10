import 'package:flutter/foundation.dart';
import 'package:quizz/models/topic.dart';
import 'package:quizz/models/question.dart';
import 'package:quizz/models/user_progress.dart';
import 'package:quizz/services/database_service.dart';

class ProgressProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;

  Map<int, double> _topicCompletionPercentages = {};
  Map<Question, UserProgress> _incorrectAnswers = {};

  Map<int, double> get topicCompletionPercentages => _topicCompletionPercentages;
  Map<Question, UserProgress> get incorrectAnswers => _incorrectAnswers;

  Future<void> loadTopicCompletions(List<Topic> topics) async {
    _topicCompletionPercentages = {};

    for (var topic in topics) {
      double completion = await _databaseService.getTopicCompletion(topic.id);
      _topicCompletionPercentages[topic.id] = completion;
    }

    notifyListeners();
  }

  Future<void> loadIncorrectAnswers(int topicId) async {
    _incorrectAnswers = await _databaseService.getIncorrectAnswers(topicId);
    notifyListeners();
  }

  double getCompletionForTopic(int topicId) {
    return _topicCompletionPercentages[topicId] ?? 0.0;
  }
}
