class Message {
  final bool isUser;
  final String message;
  final DateTime date;
  final String? sender;
  final String? status;

  Message(
      {required this.isUser,
      required this.message,
      required this.date,
      this.sender,
      this.status = 'sent'});

  // Factory constructor untuk membuat Message dari Map
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      isUser: map['is_user'] ?? false,
      message: map['message'] ?? '',
      date: DateTime.parse(map['date']),
      sender: map['sender'],
      status: map['status'] ?? 'sent',
    );
  }

  // Metode untuk mengkonversi Message ke Map
  Map<String, dynamic> toMap() {
    return {
      'is_user': isUser,
      'message': message,
      'date': date.toIso8601String(),
      'sender': sender,
      'status': status,
    };
  }
}
