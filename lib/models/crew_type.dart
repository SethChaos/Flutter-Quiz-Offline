class CrewType {
  final int id;
  final String name;
  final int aircraftId;

  CrewType({
    required this.id,
    required this.name,
    required this.aircraftId,
  });

  factory CrewType.fromMap(Map<String, dynamic> map) {
    return CrewType(
      id: map['id'],
      name: map['name'],
      aircraftId: map['aircraft_id'],
    );
  }
}