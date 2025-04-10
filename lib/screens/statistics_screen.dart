// lib/screens/statistics_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizz/models/aircraft.dart';
import 'package:quizz/models/crew_type.dart';
import 'package:quizz/models/topic.dart';
import 'package:quizz/services/database_service.dart';
import 'package:quizz/providers/progress_provider.dart';
import 'package:quizz/screens/aircraft_selection_screen.dart';
import 'package:quizz/screens/incorrect_answers_screen.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final DatabaseService _databaseService = DatabaseService.instance;
  late Future<List<Aircraft>> _aircraftFuture;
  Aircraft? _selectedAircraft;
  CrewType? _selectedCrewType;
  List<CrewType> _crewTypes = [];
  List<Topic> _topics = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _aircraftFuture = _databaseService.getAircraft();
  }

  Future<void> _loadCrewTypes(Aircraft aircraft) async {
    setState(() {
      _isLoading = true;
      _selectedAircraft = aircraft;
      _selectedCrewType = null;
      _topics = [];
    });

    final crewTypes = await _databaseService.getCrewTypes(aircraft.id);

    setState(() {
      _crewTypes = crewTypes;
      _isLoading = false;
    });
  }

  Future<void> _loadTopics(CrewType crewType) async {
    if (_selectedAircraft == null) return;

    setState(() {
      _isLoading = true;
      _selectedCrewType = crewType;
    });

    final topics = await _databaseService.getTopics(
        crewType.id,
        _selectedAircraft!.id
    );

    // Load progress for these topics
    await Provider.of<ProgressProvider>(context, listen: false)
        .loadTopicCompletions(topics);

    setState(() {
      _topics = topics;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Statistics'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Learning Progress',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Track your progress across different aircraft and topics',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),

            // Aircraft Selection
            const Text(
              'Select Aircraft:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<Aircraft>>(
              future: _aircraftFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No aircraft found'),
                  );
                }

                final aircraft = snapshot.data!;

                return SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: aircraft.length,
                    itemBuilder: (context, index) {
                      final isSelected = _selectedAircraft?.id == aircraft[index].id;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(aircraft[index].name),
                          selected: isSelected,
                          onSelected: (_) => _loadCrewTypes(aircraft[index]),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            // Crew Type Selection (if aircraft is selected)
            if (_selectedAircraft != null) ...[
              const SizedBox(height: 24),
              const Text(
                'Select Crew Type:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _isLoading && _selectedCrewType == null
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _crewTypes.length,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedCrewType?.id == _crewTypes[index].id;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(_crewTypes[index].name),
                        selected: isSelected,
                        onSelected: (_) => _loadTopics(_crewTypes[index]),
                      ),
                    );
                  },
                ),
              ),
            ],

            // Topics and Progress (if crew type is selected)
            if (_selectedCrewType != null) ...[
              const SizedBox(height: 24),
              const Text(
                'Topic Progress:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _isLoading && _topics.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : Expanded(
                child: _topics.isEmpty
                    ? const Center(child: Text('No topics found'))
                    : Consumer<ProgressProvider>(
                  builder: (context, progressProvider, _) {
                    return ListView.builder(
                      itemCount: _topics.length,
                      itemBuilder: (context, index) {
                        final topic = _topics[index];
                        final progress = progressProvider.getCompletionForTopic(topic.id);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  topic.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: LinearProgressIndicator(
                                          value: progress,
                                          minHeight: 10,
                                          backgroundColor: Colors.grey[300],
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            progress < 0.3
                                                ? Colors.red
                                                : progress < 0.7
                                                ? Colors.orange
                                                : Colors.green,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      '${(progress * 100).toInt()}%',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: () {
                                    progressProvider.loadIncorrectAnswers(topic.id).then((_) {
                                      if (progressProvider.incorrectAnswers.isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('No incorrect answers to review!'),
                                          ),
                                        );
                                      } else {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => IncorrectAnswersScreen(
                                              topic: topic,
                                            ),
                                          ),
                                        );
                                      }
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                    foregroundColor: Theme.of(context).primaryColor,
                                  ),
                                  child: const Text('Review Incorrect Answers'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AircraftSelectionScreen()),
          );
        },
        label: const Text('Take a Quiz'),
        icon: const Icon(Icons.play_arrow),
      ),
    );
  }
}

