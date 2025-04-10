import 'package:flutter/material.dart';
import 'package:quizz/models/aircraft.dart';
import 'package:quizz/models/crew_type.dart';
import 'package:quizz/services/database_service.dart';
import 'package:quizz/screens/topics_screen.dart';

class CrewSelectionScreen extends StatefulWidget {
  final Aircraft aircraft;

  const CrewSelectionScreen({
    super.key,
    required this.aircraft,
  });

  @override
  _CrewSelectionScreenState createState() => _CrewSelectionScreenState();
}

class _CrewSelectionScreenState extends State<CrewSelectionScreen> {
  final DatabaseService _databaseService = DatabaseService.instance;
  late Future<List<CrewType>> _crewTypesFuture;

  @override
  void initState() {
    super.initState();
    _crewTypesFuture = _databaseService.getCrewTypes(widget.aircraft.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.aircraft.name),
        elevation: 0,
      ),
      body: FutureBuilder<List<CrewType>>(
        future: _crewTypesFuture,
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
              child: Text('No crew types found'),
            );
          }

          final crewTypes = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Choose Your Role',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Select whether you are air crew or ground crew',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: ListView.builder(
                    itemCount: crewTypes.length,
                    itemBuilder: (context, index) {
                      return CrewTypeCard(
                        crewType: crewTypes[index],
                        aircraft: widget.aircraft,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TopicsScreen(
                                aircraft: widget.aircraft,
                                crewType: crewTypes[index],
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

class CrewTypeCard extends StatelessWidget {
  final CrewType crewType;
  final Aircraft aircraft;
  final VoidCallback onTap;

  const CrewTypeCard({
    Key? key,
    required this.crewType,
    required this.aircraft,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Set icon and color based on crew type
    IconData icon;
    Color color;

    if (crewType.name.toLowerCase().contains('air')) {
      icon = Icons.person;
      color = Colors.blue;
    } else {
      icon = Icons.engineering;
      color = Colors.orange;
    }

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
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 48,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        crewType.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Specific for ${aircraft.name}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}