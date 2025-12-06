import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Method to save a game score for a specific user ---
  // It takes the user's unique ID and the score they achieved.
  Future<void> saveScore(String userId, int score) async {
    try {
      // First, get a reference to the 'scores' subcollection that lives inside
      // the specific user's document.
      // The path is: /users/{userId}/scores
      final scoresCollection =
      _firestore.collection('users').doc(userId).collection('scores');

      // Now, add a new document to that subcollection.
      // Firestore will automatically generate a unique ID for this score entry.
      await scoresCollection.add({
        'score': score,
        'timestamp': FieldValue
            .serverTimestamp(), // Use the server's time for accuracy and consistency.
      });

      print('Score of $score for user $userId saved successfully.');
    } catch (e) {
      // If anything goes wrong, print an error to the debug console.
      print('Error saving score: $e');
      // In a production app, you might want to handle this error more gracefully,
      // for example, by saving the score locally to try again later.
    }
  }
}
