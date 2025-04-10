import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizz/models/aircraft.dart';
import 'package:quizz/models/crew_type.dart';
import 'package:quizz/models/topic.dart';
import 'package:quizz/providers/progress_provider.dart';
import 'package:quizz/services/database_service.dart';
import 'package:quizz/screens/quiz_screen.dart';
import 'package:quizz/widgets/progress_indicator.dart';

class TopicsScreen extends StatefulWidget {
  final Aircraft aircraft;
  final CrewType crewType;

  const TopicsScreen({
    super.key,
    required this.aircraft,
    required this.crewType,
  });

  @override
  _TopicsScreenState createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> {
  final DatabaseService _databaseService = DatabaseService.instance;
  late Future<List<Topic>> _topicsFuture;

  @override
  void initState() {
    super.initState();
    _topicsFuture = _databaseService.getTopics(
      widget.crewType.id,
      widget.aircraft.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.crewType.name} Topics'),
        elevation: 0,
      ),
      body: FutureBuilder<List<Topic>>(
        future: _topicsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No topics found'),
            );
          }

          final topics = snapshot.data!;

          // Load completion percentages for topics
          Provider.of<ProgressProvider>(context, listen: false)
              .loadTopicCompletions(topics);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.aircraft.name} - ${widget.crewType.name}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Select a topic to start the quiz',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.builder(
                    itemCount: topics.length,
                    itemBuilder: (context, index) {
                      return TopicCard(
                        topic: topics[index],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuizScreen(
                                topic: topics[index],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class TopicCard extends StatelessWidget {
  final Topic topic;
  final VoidCallback onTap;

  const TopicCard({
    Key? key,
    required this.topic,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progressProvider = Provider.of<ProgressProvider>(context);
    final completion = progressProvider.getCompletionForTopic(topic.id);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topic.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TopicProgressIndicator(
                        progress: completion,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${(completion * 100).toInt()}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}