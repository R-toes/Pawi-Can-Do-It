import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  // Get instances of Firebase Auth and Firestore
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Method to REGISTER a new user ---
  Future<User?> registerWithEmailAndPassword(
      String email, String password, String username, int age) async {
    try {
      // 1. Create the user with email and password in Firebase Auth
      UserCredential userCredential =
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      // 2. If user is created successfully, save their additional data in Firestore.
      // We are NOT saving a highScore here anymore. The 'scores' subcollection
      // will be created later when the user plays their first game.
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'username': username,
          'email': email,
          'age': age,
        });
      }
      return user;
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Auth errors (e.g., email already in use)
      // In a real app, you'd want to show this error to the user.
      print('Firebase Auth Exception: ${e.message}');
      return null;
    } catch (e) {
      // Handle any other generic errors
      print('An unexpected error occurred: $e');
      return null;
    }
  }

  // --- Method to SIGN IN a user ---
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      // Sign in the user with the given credentials
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Handle errors like wrong password, user not found, etc.
      print('Firebase Auth Exception: ${e.message}');
      return null;
    } catch (e) {
      // Handle any other generic errors
      print('An unexpected error occurred: $e');
      return null;
    }
  }

  // --- Method to SIGN OUT a user ---
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // --- Method to get the current user ---
  // This can be useful to check if a user is already logged in when the app starts.
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }
}
