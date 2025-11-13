import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class CommentEntry {
  CommentEntry({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String displayName;
  final String text;
  final DateTime createdAt;
}

abstract class CommentsRepository {
  Stream<List<CommentEntry>> watchComments({
    required String signId,
    required String date,
  });

  Future<void> addComment({
    required String signId,
    required String date,
    required String text,
  });
}

class FirestoreCommentsRepository implements CommentsRepository {
  FirestoreCommentsRepository()
      : _firestore = FirebaseFirestore.instance,
        _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> _collection(
      String signId, String date) {
    return _firestore.collection('comments').doc(signId).collection(date);
  }

  @override
  Stream<List<CommentEntry>> watchComments({
    required String signId,
    required String date,
  }) {
    return _collection(signId, date)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => CommentEntry(
                  id: doc.id,
                  userId: doc.data()['uid'] as String? ?? '',
                  displayName: doc.data()['displayName'] as String? ?? 'User',
                  text: doc.data()['text'] as String? ?? '',
                  createdAt:
                      (doc.data()['createdAt'] as Timestamp?)?.toDate() ??
                          DateTime.now(),
                ),
              )
              .toList(),
        );
  }

  @override
  Future<void> addComment({
    required String signId,
    required String date,
    required String text,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('User not signed in');
    }
    await _collection(signId, date).add({
      'uid': user.uid,
      'displayName': user.displayName ?? user.email ?? 'User',
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

class MemoryCommentsRepository implements CommentsRepository {
  final _controller = StreamController<List<CommentEntry>>.broadcast();
  final List<CommentEntry> _entries = [];

  @override
  Stream<List<CommentEntry>> watchComments({
    required String signId,
    required String date,
  }) {
    return _controller.stream;
  }

  @override
  Future<void> addComment({
    required String signId,
    required String date,
    required String text,
  }) async {
    final entry = CommentEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'local',
      displayName: 'local',
      text: text,
      createdAt: DateTime.now(),
    );
    _entries.insert(0, entry);
    _controller.add(List.unmodifiable(_entries));
  }
}

CommentsRepository resolveCommentsRepository() {
  if (Firebase.apps.isNotEmpty) {
    try {
      return FirestoreCommentsRepository();
    } catch (error) {
      debugPrint('Falling back to memory comments repository: $error');
    }
  }
  return MemoryCommentsRepository();
}
