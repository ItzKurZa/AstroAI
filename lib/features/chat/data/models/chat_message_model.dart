import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  ChatMessageModel({
    required super.id,
    required super.sender,
    required super.text,
    required super.createdAt,
  });

  factory ChatMessageModel.fromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final timestamp = data['createdAt'];
    DateTime createdAt;
    if (timestamp is Timestamp) {
      createdAt = timestamp.toDate();
    } else {
      createdAt = DateTime.now();
    }
    return ChatMessageModel(
      id: doc.id,
      sender: data['sender'] as String? ?? 'advisor',
      text: data['text'] as String? ?? '',
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sender': sender,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

