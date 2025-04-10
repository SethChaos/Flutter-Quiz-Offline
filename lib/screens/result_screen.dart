import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizz/models/topic.dart';
import 'package:quizz/providers/quiz_provider.dart';
import 'package:quizz/providers/progress_provider.dart';
import 'package:quizz/screens/incorrect_answers_screen.dart';
import 'package:quizz/screens/welcome_screen.dart';

class ResultScreen extends StatelessWidget {
  final Topic topic;

  const ResultScreen({
    super.key,
    required this.topic,
  });

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);
    final score = quizProvider.score;
    final totalQuestions = quizProvider.totalQuestions;
    final percentage = (score / totalQuestions) * 100;

    String resultMessage;
    IconData resultIcon;
    Color resultColor;

    if (percentage >= 80) {
      resultMessage = 'Excellent!';
      resultIcon = Icons.emoji_events;
      resultColor = Colors.green;
    } else if (percentage >= 60) {
      resultMessage = 'Good Job!';
      resultIcon = Icons.thumb_up;
      resultColor = Colors.blue;
    } else if (percentage >= 40) {
      resultMessage = 'Not Bad!';
      resultIcon = Icons.sentiment_satisfied;
      resultColor = Colors.orange;
    } else {
      resultMessage = 'Keep Learning!';
      resultIcon = Icons.school;
      resultColor = Colors.red;
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              resultColor.withOpacity(0.7),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: const Text('Quiz Results'),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        resultIcon,
                        size: 80,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        resultMessage,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'You scored $score out of $totalQuestions',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Progress indicator
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 160,
                                height: 160,
                                child: CircularProgressIndicator(
                                  value: score / totalQuestions,
                                  strokeWidth: 12,
                                  backgroundColor: Colors.grey.withOpacity(0.2),
                                  valueColor: AlwaysStoppedAnimation<Color>(resultColor),
                                ),
                              ),
                              Text(
                                '${percentage.toInt()}%',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: resultColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Action buttons
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (percentage < 100)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                          Provider.of<ProgressProvider>(context, listen: false)
                              .loadIncorrectAnswers(topic.id)
                              .then((_) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => IncorrectAnswersScreen(
                                  topic: topic,
                                ),
                              ),
                            );
                          });
                        },
                        child: const Text(
                          'Review Incorrect Answers',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: resultColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        // Reset quiz and go back to welcome screen
                        quizProvider.resetQuiz();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const WelcomeScreen(),
                          ),
                              (Route<dynamic> route) => false,
                        );
                      },
                      child: const Text(
                        'Back to Home',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}