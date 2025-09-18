class SmsMessage {
  final int id;
  final String address;
  final String body;
  final DateTime date;
  final bool isRead;
  final bool isSent;
  final int threadId;
  final String? contactName;

  SmsMessage({
    required this.id,
    required this.address,
    required this.body,
    required this.date,
    required this.isRead,
    required this.isSent,
    required this.threadId,
    this.contactName,
  });

  factory SmsMessage.fromMap(Map<String, dynamic> map) {
    return SmsMessage(
      id: map['_id'] ?? 0,
      address: map['address'] ?? '',
      body: map['body'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(
        int.tryParse(map['date']?.toString() ?? '0') ?? 0,
      ),
      isRead: map['read'] == 1 || map['read'] == true,
      isSent: map['type'] == 2, // 1 = received, 2 = sent
      threadId: map['thread_id'] ?? 0,
      contactName: map['contact_name'],
    );
  }

  SmsMessage copyWith({
    int? id,
    String? address,
    String? body,
    DateTime? date,
    bool? isRead,
    bool? isSent,
    int? threadId,
    String? contactName,
  }) {
    return SmsMessage(
      id: id ?? this.id,
      address: address ?? this.address,
      body: body ?? this.body,
      date: date ?? this.date,
      isRead: isRead ?? this.isRead,
      isSent: isSent ?? this.isSent,
      threadId: threadId ?? this.threadId,
      contactName: contactName ?? this.contactName,
    );
  }
}

class SmsThread {
  final int threadId;
  final String address;
  final String? contactName;
  final SmsMessage lastMessage;
  final int messageCount;
  final int unreadCount;

  SmsThread({
    required this.threadId,
    required this.address,
    this.contactName,
    required this.lastMessage,
    required this.messageCount,
    required this.unreadCount,
  });
}
