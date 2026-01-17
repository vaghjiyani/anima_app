import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add a new review
  Future<void> addReview({
    required String animeId,
    required int rating,
    required String reviewText,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Create review document
      final reviewData = {
        'animeId': animeId,
        'userId': user.uid,
        'userName':
            user.displayName ?? (user.email?.split('@')[0] ?? 'Anonymous User'),
        'userEmail': user.email ?? '',
        'rating': rating,
        'reviewText': reviewText,
        'timestamp': FieldValue.serverTimestamp(),
        'likes': 0,
        'helpful': 0,
      };

      await _firestore.collection('reviews').add(reviewData);
    } catch (e) {
      throw Exception('Failed to add review: $e');
    }
  }

  // Get reviews for a specific anime
  Stream<List<Map<String, dynamic>>> getReviewsForAnime(String animeId) {
    return _firestore
        .collection('reviews')
        .where('animeId', isEqualTo: animeId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
        });
  }

  // Get user's review for a specific anime
  Future<Map<String, dynamic>?> getUserReview(String animeId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final querySnapshot = await _firestore
          .collection('reviews')
          .where('animeId', isEqualTo: animeId)
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      final doc = querySnapshot.docs.first;
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    } catch (e) {
      throw Exception('Failed to get user review: $e');
    }
  }

  // Update an existing review
  Future<void> updateReview({
    required String reviewId,
    required int rating,
    required String reviewText,
  }) async {
    try {
      await _firestore.collection('reviews').doc(reviewId).update({
        'rating': rating,
        'reviewText': reviewText,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update review: $e');
    }
  }

  // Delete a review
  Future<void> deleteReview(String reviewId) async {
    try {
      await _firestore.collection('reviews').doc(reviewId).delete();
    } catch (e) {
      throw Exception('Failed to delete review: $e');
    }
  }

  // Get average rating for an anime
  Future<double> getAverageRating(String animeId) async {
    try {
      final querySnapshot = await _firestore
          .collection('reviews')
          .where('animeId', isEqualTo: animeId)
          .get();

      if (querySnapshot.docs.isEmpty) return 0.0;

      int totalRating = 0;
      for (var doc in querySnapshot.docs) {
        totalRating += (doc.data()['rating'] as int);
      }

      return totalRating / querySnapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get average rating: $e');
    }
  }

  // Get review count for an anime
  Future<int> getReviewCount(String animeId) async {
    try {
      final querySnapshot = await _firestore
          .collection('reviews')
          .where('animeId', isEqualTo: animeId)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get review count: $e');
    }
  }

  // Mark review as helpful
  Future<void> markReviewHelpful(String reviewId) async {
    try {
      await _firestore.collection('reviews').doc(reviewId).update({
        'helpful': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to mark review as helpful: $e');
    }
  }
}
