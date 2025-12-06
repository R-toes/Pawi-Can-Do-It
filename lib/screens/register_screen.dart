import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pawicandoit/services/auth_service.dart'; // Import your AuthService

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // --- ADD THIS LINE ---
  final AuthService _authService = AuthService();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- THIS IS THE NEW REGISTRATION LOGIC YOU ARE MISSING ---
  void _register() async {
    // First, validate the form to make sure all fields are correct
    if (_formKey.currentState!.validate()) {
      // Show a loading circle while we communicate with Firebase
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Get the user's input from the text fields
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();
      String username = _usernameController.text.trim();
      int age = int.parse(_ageController.text.trim());

      // Call the registration method from your AuthService
      User? user = await _authService.registerWithEmailAndPassword(
          email, password, username, age);

      // Dismiss the loading circle
      Navigator.of(context).pop();

      // Check if the registration was successful
      if (user != null) {
        // If successful, show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );
        // And navigate back to the login screen
        Navigator.of(context).pop();
      } else {
        // If it failed, show a generic error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Registration failed. The email may already be in use.')),
        );
      }
    }
  }
  // --- END OF NEW LOGIC ---

  @override
  Widget build(BuildContext context) {
    // The rest of your UI code is perfect, we just need to update the button
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SizedBox(height: 50.0),
                  const Text('Create Account', textAlign: TextAlign.center, style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8.0),
                  const Text('Let\'s get you started!', textAlign: TextAlign.center, style: TextStyle(fontSize: 16.0, color: Colors.grey)),
                  const SizedBox(height: 48.0),

                  // Username Field
                  TextFormField(controller: _usernameController, decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
                    validator: (value) { if (value == null || value.isEmpty) { return 'Please enter a username'; } return null; },
                  ),
                  const SizedBox(height: 16.0),

                  // Email Field
                  TextFormField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email)),
                    validator: (value) { if (value == null || value.isEmpty || !value.contains('@')) { return 'Please enter a valid email'; } return null; },
                  ),
                  const SizedBox(height: 16.0),

                  // Age Field
                  TextFormField(controller: _ageController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Age', border: OutlineInputBorder(), prefixIcon: Icon(FontAwesomeIcons.cakeCandles)),
                    validator: (value) { if (value == null || value.isEmpty) { return 'Please enter your age'; } if (int.tryParse(value) == null) { return 'Please enter a valid number'; } return null; },
                  ),
                  const SizedBox(height: 16.0),

                  // Password Field
                  TextFormField(controller: _passwordController, obscureText: !_isPasswordVisible, decoration: InputDecoration(labelText: 'Password', border: const OutlineInputBorder(), prefixIcon: const Icon(Icons.lock), suffixIcon: IconButton(icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off), onPressed: () { setState(() { _isPasswordVisible = !_isPasswordVisible; }); },),),
                    validator: (value) { if (value == null || value.isEmpty || value.length < 6) { return 'Password must be at least 6 characters'; } return null; },
                  ),
                  const SizedBox(height: 16.0),

                  // Confirm Password Field
                  TextFormField(controller: _confirmPasswordController, obscureText: !_isConfirmPasswordVisible, decoration: InputDecoration(labelText: 'Confirm Password', border: const OutlineInputBorder(), prefixIcon: const Icon(Icons.lock_clock), suffixIcon: IconButton(icon: Icon(_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off), onPressed: () { setState(() { _isConfirmPasswordVisible = !_isConfirmPasswordVisible; }); },),),
                    validator: (value) { if (value == null || value.isEmpty) { return 'Please confirm your password'; } if (value != _passwordController.text) { return 'Passwords do not match'; } return null; },
                  ),
                  const SizedBox(height: 24.0),

                  // --- UPDATE THIS BUTTON ---
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16.0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))),
                    onPressed: _register, // Change this to call the new _register method
                    child: const Text('Register', style: TextStyle(fontSize: 18)),
                  ),
                  // --- END OF BUTTON UPDATE ---

                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account?"),
                      TextButton(onPressed: () { Navigator.pop(context); }, child: const Text('Log in')),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
