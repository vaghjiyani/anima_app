import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/anime.dart';

class FavoritesService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String? get _userId => _auth.currentUser?.uid;

  static Future<void> addToFavorites(Anime anime) async {
    try {
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

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
          }, SetOptions(merge: true)); // Use merge to avoid overwriting
    } catch (e) {
      print('Error adding to favorites: $e');
      rethrow;
    }
  }

  static Future<void> removeFromFavorites(int malId) async {
    try {
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

      // Delete without waiting - prevents hanging
      _firestore
          .collection('users')
          .doc(_userId)
          .collection('favorites')
          .doc(malId.toString())
          .delete()
          .then((_) => print('✅ Removed favorite: $malId'))
          .catchError((e) => print('❌ Error: $e'));

      // Return immediately
      return;
    } on FirebaseException catch (e) {
      print('❌ Firebase error: ${e.code} - ${e.message}');
      throw Exception('Failed to remove favorite: ${e.message}');
    } catch (e) {
      print('❌ Error: $e');
      rethrow;
    }
  }

  static Future<bool> isFavorite(int malId) async {
    try {
      if (_userId == null) return false;

      final doc = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('favorites')
          .doc(malId.toString())
          .get();

      return doc.exists;
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }

  static Stream<List<Anime>> getFavorites() {
    try {
      if (_userId == null) return Stream.value([]);

      return _firestore
          .collection('users')
          .doc(_userId)
          .collection('favorites')
          .orderBy('addedAt', descending: true)
          .snapshots()
          .map((snapshot) {
            try {
              return snapshot.docs
                  .map((doc) {
                    try {
                      return Anime.fromFavorite(doc.data());
                    } catch (e) {
                      print('Error parsing anime from doc ${doc.id}: $e');
                      return null;
                    }
                  })
                  .whereType<Anime>() // Filter out nulls
                  .toList();
            } catch (e) {
              print('Error mapping favorites: $e');
              return <Anime>[];
            }
          })
          .handleError((error) {
            print('Error in favorites stream: $error');
            return <Anime>[];
          });
    } catch (e) {
      print('Error creating favorites stream: $e');
      return Stream.value([]);
    }
  }
}
