import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/anime.dart';

class FavoritesService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String? get _userId => _auth.currentUser?.uid;

  static Future<void> addToFavorites(Anime anime) async {
    if (_userId == null) return;
    
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('favorites')
        .doc(anime.malId.toString())
        .set({
      'malId': anime.malId,
      'title': anime.title,
      'imageUrl': anime.imageUrl,
      'score': anime.score,
      'episodes': anime.episodes,
      'status': anime.status,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> removeFromFavorites(int malId) async {
    if (_userId == null) return;
    
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('favorites')
        .doc(malId.toString())
        .delete();
  }

  static Future<bool> isFavorite(int malId) async {
    if (_userId == null) return false;
    
    final doc = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('favorites')
        .doc(malId.toString())
        .get();
    
    return doc.exists;
  }

  static Stream<List<Anime>> getFavorites() {
    if (_userId == null) return Stream.value([]);
    
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('favorites')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Anime.fromFavorite(doc.data()))
            .toList());
  }
}