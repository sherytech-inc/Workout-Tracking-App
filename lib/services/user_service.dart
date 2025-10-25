import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createUserDocument(User user) async {
    final doc = _db.collection('users').doc(user.uid);
    await doc.set({
      'email': user.email,
      'createdAt': FieldValue.serverTimestamp(),
      'displayName': user.displayName ?? '',
    }, SetOptions(merge: true));
  }

  Future<void> ensureUserDocument(User user) async {
    final doc = _db.collection('users').doc(user.uid);
    final snapshot = await doc.get();
    if (!snapshot.exists) {
      await createUserDocument(user);
    }
  }
}
