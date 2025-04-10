class Topic {
  final int id;
  final String name;
  final int crewId;
  final int aircraftId;

  Topic({
    required this.id,
    required this.name,
    required this.crewId,
    required this.aircraftId,
  });

  factory Topic.fromMap(Map<String, dynamic> map) {
    return Topic(
      id: map['id'],
      name: map['name'],
      crewId: map['crew_id'],
      aircraftId: map['aircraft_id'],
    );
  }
}