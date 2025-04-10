class Aircraft {
  final int id;
  final String name;
  final String? imageAsset;

  Aircraft({
    required this.id,
    required this.name,
    this.imageAsset,
  });

  factory Aircraft.fromMap(Map<String, dynamic> map) {
    return Aircraft(
      id: map['id'],
      name: map['name'],
      imageAsset: map['image_asset'],
    );
  }
}
