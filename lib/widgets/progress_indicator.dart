import 'package:flutter/material.dart';

class TopicProgressIndicator extends StatelessWidget {
  final double progress;

  const TopicProgressIndicator({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    Color progressColor;

    if (progress < 0.3) {
      progressColor = Colors.red;
    } else if (progress < 0.7) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.green;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 10,
        backgroundColor: Colors.grey[300],
        valueColor: AlwaysStoppedAnimation<Color>(progressColor),
      ),
    );
  }
}