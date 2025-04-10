import 'package:flutter/material.dart';
import 'package:quizz/models/aircraft.dart';
import 'package:quizz/services/database_service.dart';
import 'package:quizz/screens/crew_selection_screen.dart';

class AircraftSelectionScreen extends StatefulWidget {
  const AircraftSelectionScreen({super.key});

  @override
  _AircraftSelectionScreenState createState() => _AircraftSelectionScreenState();
}

class _AircraftSelectionScreenState extends State<AircraftSelectionScreen> {
  final DatabaseService _databaseService = DatabaseService.instance;
  late Future<List<Aircraft>> _aircraftFuture;

  @override
  void initState() {
    super.initState();
    _aircraftFuture = _databaseService.getAircraft();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: const Text('Select Aircraft'),
    elevation: 0,
    ),
    body: FutureBuilder<List<Aircraft>>(
      future: _aircraftFuture,
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
            child: Text('No aircraft found'),
          );
        }

        final aircraft = snapshot.data!;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose Aircraft Type',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select the aircraft type you want to learn about',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: aircraft.length,
                  itemBuilder: (context, index) {
                    return AircraftCard(
                      aircraft: aircraft[index],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CrewSelectionScreen(
                              aircraft: aircraft[index],
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

class AircraftCard extends StatelessWidget {
  final Aircraft aircraft;
  final VoidCallback onTap;

  const AircraftCard({
    Key? key,
    required this.aircraft,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Center(
                  child: aircraft.imageAsset != null
                      ? Image.asset(
                    aircraft.imageAsset!,
                    fit: BoxFit.cover,
                  )
                      : Icon(
                    Icons.airplanemode_active,
                    size: 60,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: Theme.of(context).primaryColor,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      aircraft.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}