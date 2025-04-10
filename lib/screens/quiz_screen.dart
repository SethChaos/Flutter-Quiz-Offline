import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizz/models/topic.dart';
import 'package:quizz/providers/quiz_provider.dart';
import 'package:quizz/screens/result_screen.dart';
import 'package:quizz/widgets/option_button.dart';
import 'package:quizz/widgets/question_progress_bar.dart';

class QuizScreen extends StatefulWidget {
  final Topic topic;

  const QuizScreen({
    Key? key,
    required this.topic,
  }) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Load questions for the selected topic
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final quizProvider = Provider.of<QuizProvider>(context, listen: false);
      quizProvider.loadQuestions(widget.topic.id).then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Quit Quiz?'),
            content: const Text('Are you sure you want to quit? Your progress will be saved.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Provider.of<QuizProvider>(context, listen: false).resetQuiz();
                  Navigator.of(context).pop(true);
                },
                child: const Text('Quit'),
              ),
            ],
          ),
        );
        return shouldPop ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.topic.name),
          elevation: 0,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Consumer<QuizProvider>(
          builder: (context, quizProvider, child) {
            if (quizProvider.questions.isEmpty) {
              return const Center(
                child: Text('No questions found for this topic'),
              );
            }

            final currentQuestion = quizProvider.currentQuestion;
            final isAnswered = quizProvider.isCurrentQuestionAnswered;
            final selectedOption = quizProvider.getSelectedOption(currentQuestion.id);
            final isCorrect = quizProvider.getQuestionResult(currentQuestion.id);

            return Column(
              children: [
                // Question number and progress bar
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Question ${quizProvider.currentQuestionIndex + 1}/${quizProvider.totalQuestions}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Score: ${quizProvider.score}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      QuestionProgressBar(
                        currentQuestion: quizProvider.currentQuestionIndex + 1,
                        totalQuestions: quizProvider.totalQuestions,
                      ),
                    ],
                  ),
                ),

                // Question card
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Question Text
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              currentQuestion.questionText,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Options
                        ...List.generate(
                          currentQuestion.options.length,
                              (index) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: OptionButton(
                              text: currentQuestion.options[index].text,
                              isSelected: selectedOption == index,
                              isCorrect: currentQuestion.options[index].isCorrect,
                              isRevealed: isAnswered,
                              onTap: isAnswered
                                  ? null
                                  : () {
                                quizProvider.answerQuestion(index);
                              },
                            ),
                          ),
                        ),

                        // Explanation (shown after answering)
                        if (isAnswered && currentQuestion.explanation != null)
                          Container(
                            margin: const EdgeInsets.only(top: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isCorrect == true
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isCorrect == true
                                    ? Colors.green
                                    : Colors.red,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isCorrect == true
                                      ? 'Correct!'
                                      : 'Incorrect!',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isCorrect == true
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  currentQuestion.explanation!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Navigation buttons
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Previous button
                      quizProvider.currentQuestionIndex > 0
                          ? ElevatedButton(
                        onPressed: () {
                          quizProvider.previousQuestion();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black,
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.arrow_back),
                            SizedBox(width: 8),
                            Text('Previous'),
                          ],
                        ),
                      )
                          : const SizedBox(width: 100),

                      // Next/Finish button
                      ElevatedButton(
                        onPressed: isAnswered
                            ? () {
                          if (quizProvider.currentQuestionIndex ==
                              quizProvider.totalQuestions - 1) {
                            // Last question, go to results
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => ResultScreen(
                                  topic: widget.topic,
                                ),
                              ),
                            );
                          } else {
                            quizProvider.nextQuestion();
                          }
                        }
                            : null,
                        child: Row(
                          children: [
                            Text(
                              quizProvider.currentQuestionIndex ==
                                  quizProvider.totalQuestions - 1
                                  ? 'Finish'
                                  : 'Next',
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}