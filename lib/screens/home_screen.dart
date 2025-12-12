import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawicandoit/services/auth_service.dart';
import 'package:pawicandoit/screens/login_screen.dart'; // To navigate back on sign out
import 'package:flame/game.dart' show GameWidget;
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
    _currentUser = _authService.getCurrentUser();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (_currentUser != null) {
      DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(_currentUser!.uid).get();
      if (userDoc.exists && mounted) {
        setState(() {
          _username = (userDoc.data() as Map<String, dynamic>)['username'];
        });
      }
    }
  }

  Future<void> _signOut() async {
    await _authService.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Shared text shadow style for better readability on the background
    const shadowStyle = [
      Shadow(
        blurRadius: 10.0,
        color: Colors.black87,
        offset: Offset(2.0, 2.0),
      ),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true, // Allows the body to go behind the AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _signOut,
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: Container(
        // Set the background for the entire screen
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/tortol_bg.png"),
            fit: BoxFit.fill,
          ),
        ),
        // Use SafeArea to avoid UI overlapping with system notches (like the time, battery icon)
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // MODIFICATION: Removed the Spacer and added a small fixed gap.
                // You can remove this SizedBox to move it even higher.
                const SizedBox(height: 16.0),

                // Logo
                Image.asset(
                  'assets/images/pawiCanDoIt_logo.png',
                  height: 200, // Adjusted height from 225 to 200
                ),
                const SizedBox(height: 50),

                // Styled Welcome Text
                const Text(
                  'Welcome,',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    shadows: shadowStyle,
                  ),
                ),
                Text(
                  _username ?? 'Loading...',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: shadowStyle,
                  ),
                ),
                const SizedBox(height: 50),

                // "Start Game" button
                GestureDetector(
                  onTap: () {
                    if (_currentUser != null) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              GameWidget(
                                game: Game(userId: _currentUser!.uid),
                              ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('User not loaded yet. Please wait.')),
                      );
                    }
                  },
                  child: Image.asset(
                    'assets/images/startGameButton.png',
                    height: 60,
                  ),
                ),
                const SizedBox(height: 20),

                // "Leaderboards" button
                GestureDetector(
                  onTap: () {
                    // This can be updated later to navigate to a new screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Leaderboard screen coming soon!')),
                    );
                  },
                  child: Image.asset(
                    'assets/images/leaderboardsButton.png',
                    height: 60,
                  ),
                ),

                // Spacer to push the SDG text to the bottom
                const Spacer(),

                // --- MODIFICATION START ---
                // SDG 14 Text Container
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                  margin: const EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5), // Semi-transparent black background
                    borderRadius: BorderRadius.circular(12.0), // Rounded corners
                  ),
                  child: const Text(
                    'SDG 14: Life Below Water\nHighlights marine conservation and addresses ocean pollution challenges.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white, // Changed from white70 to white
                      fontSize: 14,      // Increased font size
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // --- MODIFICATION END ---
              ],
            ),
          ),
        ),
      ),
    );
  }
}
