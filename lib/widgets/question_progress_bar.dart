import 'package:flutter/material.dart';

class QuestionProgressBar extends StatelessWidget {
  final int currentQuestion;
  final int totalQuestions;

  const QuestionProgressBar({
    super.key,
    required this.currentQuestion,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 10,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Flexible(
            flex: currentQuestion,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          Flexible(
            flex: totalQuestions - currentQuestion,
            child: Container(),
          ),
        ],
      ),
    );
  }
}