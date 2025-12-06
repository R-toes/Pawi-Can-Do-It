import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawicandoit/services/auth_service.dart';
import 'package:pawicandoit/screens/login_screen.dart'; // To navigate back on sign out
// Import your game files - adjust if your game file is named differently
import 'package:flame/game.dart'show GameWidget;
import 'package:pawicandoit/game/Game.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;
  String? _username;

  @override
  void initState() {
    super.initState();
    // Get the currently logged-in user when the screen loads
    _currentUser = _authService.getCurrentUser();
    // Fetch user data from Firestore
    _fetchUserData();
  }

  // Fetches the user's document from Firestore to get their username
  Future<void> _fetchUserData() async {
    if (_currentUser != null) {
      // Get the document snapshot from the 'users' collection
      DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(_currentUser!.uid).get();

      // Check if the document exists and then update the state
      if (userDoc.exists) {
        setState(() {
          // Cast the data to a Map and get the 'username' field
          _username = (userDoc.data() as Map<String, dynamic>)['username'];
        });
      }
    }
  }

  // Method to handle signing out
  Future<void> _signOut() async {
    await _authService.signOut();
    // After signing out, replace the home screen with the login screen
    // This prevents the user from pressing 'back' and returning to the home screen
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false, // This predicate removes all previous routes
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          // Add a sign-out button to the app bar
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome message
              // It shows a loading text until the username is fetched
              Text(
                'Welcome,',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, color: Colors.grey[700]),
              ),
              Text(
                _username ?? 'Loading...', // Display username or 'Loading...'
                textAlign: TextAlign.center,
                style:
                const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 60),

              // Play Game Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  textStyle: const TextStyle(fontSize: 22),
                ),
                onPressed: () {
                  // First, make sure we have a user before starting the game
                  if (_currentUser != null) {
                    // When pressed, navigate to the Flame GameWidget
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => GameWidget(
                          // Pass the user's ID into your Game class constructor
                          game: Game(userId: _currentUser!.uid),
                        ),
                      ),
                    );
                  } else {
                    // This is a fallback, in case the user data isn't loaded yet
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User not loaded yet. Please wait.')),
                    );
                  }
                },
                child: const Text('Play Game'),
              ),
              const SizedBox(height: 20),

              // (Optional) Button to view scores - we can build this next
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  // We will create a ScoreScreen later
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Score screen coming soon!')),
                  );
                },
                child: const Text('View My Scores'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
