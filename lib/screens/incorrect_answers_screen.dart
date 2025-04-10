import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizz/models/topic.dart';
import 'package:quizz/providers/progress_provider.dart';
import 'package:quizz/widgets/option_button.dart';

class IncorrectAnswersScreen extends StatelessWidget {
  final Topic topic;

  const IncorrectAnswersScreen({
    super.key,
    required this.topic,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Review - ${topic.name}'),
      ),
      body: Consumer<ProgressProvider>(
        builder: (context, progressProvider, _) {
          final incorrectAnswers = progressProvider.incorrectAnswers;

          if (incorrectAnswers.isEmpty) {
            return const Center(
              child: Text(
                'No incorrect answers to review',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: incorrectAnswers.length,
            itemBuilder: (context, index) {
              final entry = incorrectAnswers.entries.elementAt(index);
              final question = entry.key;

              return Card(
                margin: const EdgeInsets.only(bottom: 20),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Question number badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Question ${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Question text
                      Text(
                        question.questionText,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Options
                      ...question.options.map((option) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: OptionButton(
                            text: option.text,
                            isSelected: false,
                            isCorrect: option.isCorrect,
                            isRevealed: true,
                            onTap: null,
                          ),
                        );
                      }).toList(),

                      // Explanation
                      if (question.explanation != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.blue.shade300,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Explanation',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                question.explanation!,
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}