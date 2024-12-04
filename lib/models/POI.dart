class PointOfInterest {
  final int id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final String imageUrl;
  final String? category;
  final String status;
  final String? lastUpdated;

  PointOfInterest({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
    this.category,
    this.status = 'active',
    this.lastUpdated,
  });

  // Factory constructor untuk membuat POI dari Map
  factory PointOfInterest.fromMap(Map<String, dynamic> map) {
    return PointOfInterest(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      imageUrl: map['imageUrl'],
      category: map['category'],
      status: map['status'] ?? 'active',
      lastUpdated: map['last_updated'],
    );
  }

  // Metode untuk mengkonversi POI ke Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrl': imageUrl,
      'category': category,
      'status': status,
      'last_updated': lastUpdated,
    };
  }
}
