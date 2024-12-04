class Event {
  final String title;
  final String description;
  final String? imageUrl;
  final DateTime date;
  final String? location;
  final int? maxParticipants;
  final int currentParticipants;
  final String status;

  Event(
      {required this.title,
      required this.description,
      this.imageUrl,
      required this.date,
      this.location,
      this.maxParticipants,
      this.currentParticipants = 0,
      this.status = 'upcoming'});

  // Factory constructor untuk membuat Event dari Map
  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      title: map['title'],
      description: map['description'],
      imageUrl: map['image_url'],
      date: DateTime.parse(map['date']),
      location: map['location'],
      maxParticipants: map['max_participants'],
      currentParticipants: map['current_participants'] ?? 0,
      status: map['status'] ?? 'upcoming',
    );
  }

  // Metode untuk mengkonversi Event ke Map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'date': date.toIso8601String(),
      'location': location,
      'max_participants': maxParticipants,
      'current_participants': currentParticipants,
      'status': status,
    };
  }
}
