import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firebase/firestore_paths.dart';
import '../models/chat_message_model.dart';

class ChatRemoteDataSource {
  ChatRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<ChatMessageModel>> watchMessages(String threadId) {
    final collection = _firestore
        .doc(FirestorePaths.chatThread(threadId))
        .collection('messages')
        .orderBy('createdAt');
    return collection.snapshots().map(
      (snapshot) =>
          snapshot.docs.map(ChatMessageModel.fromDoc).toList(),
    );
  }

  Future<void> sendMessage(String threadId, ChatMessageModel model) async {
    await _firestore
        .doc(FirestorePaths.chatThread(threadId))
        .collection('messages')
        .add(model.toMap());
  }
}

