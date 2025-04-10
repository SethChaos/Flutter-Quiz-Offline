import 'package:flutter/foundation.dart';
import 'package:quizz/models/question.dart';
import 'package:quizz/models/user_progress.dart';
import 'package:quizz/services/database_service.dart';

class QuizProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;

  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  int? _selectedTopicId;
  bool _isQuizActive = false;
  final List<int> _answeredQuestions = [];
  final Map<int, int> _selectedOptions = {};  // questionId -> selectedOptionIndex
  final Map<int, bool> _questionResults = {}; // questionId -> isCorrect

  List<Question> get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;
  Question get currentQuestion => _questions[_currentQuestionIndex];
  int get score => _score;
  bool get isQuizActive => _isQuizActive;
  int get totalQuestions => _questions.length;
  int? get selectedTopicId => _selectedTopicId;
  bool get isCurrentQuestionAnswered => _answeredQuestions.contains(currentQuestion.id);
  int? getSelectedOption(int questionId) => _selectedOptions[questionId];
  bool? getQuestionResult(int questionId) => _questionResults[questionId];

  Future<void> loadQuestions(int topicId) async {
    _selectedTopicId = topicId;
    _questions = await _databaseService.getQuestions(topicId);
    _questions.shuffle(); // Randomize questions

    // Limit to 10 questions for a session if there are more
    if (_questions.length > 10) {
      _questions = _questions.sublist(0, 10);
    }

    _currentQuestionIndex = 0;
    _score = 0;
    _answeredQuestions.clear();
    _selectedOptions.clear();
    _questionResults.clear();
    _isQuizActive = true;
    notifyListeners();
  }

  void answerQuestion(int selectedOptionIndex) {
    if (_answeredQuestions.contains(currentQuestion.id)) return;

    _answeredQuestions.add(currentQuestion.id);
    _selectedOptions[currentQuestion.id] = selectedOptionIndex;

    bool isCorrect = selectedOptionIndex ==
        currentQuestion.options.indexWhere((option) => option.isCorrect);
    _questionResults[currentQuestion.id] = isCorrect;

    if (isCorrect) {
      _score++;
    }

    // Save progress to database
    _databaseService.saveProgress(UserProgress(
      id: 0, // Will be auto-incremented
      questionId: currentQuestion.id,
      isCorrect: isCorrect,
      attemptDate: DateTime.now(),
    ));

    notifyListeners();
  }

  void nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  void endQuiz() {
    _isQuizActive = false;
    notifyListeners();
  }

  void resetQuiz() {
    _currentQuestionIndex = 0;
    _score = 0;
    _answeredQuestions.clear();
    _selectedOptions.clear();
    _questionResults.clear();
    _isQuizActive = false;
    notifyListeners();
  }
}