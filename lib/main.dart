import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:pawicandoit/firebase_options.dart';
import 'package:pawicandoit/screens/login_screen.dart';
import 'package:pawicandoit/services/auth_service.dart';
import 'package:pawicandoit/services/database_service.dart';

// Create a GetIt instance that will be used to locate our services.
final GetIt locator = GetIt.instance;

// This function registers the services with the locator.
void setupLocator() {
  // registerLazySingleton means the service is only created once, the first time it's requested.
  locator.registerLazySingleton(() => AuthService());
  locator.registerLazySingleton(() => DatabaseService());
}

void main() async {
  // Ensures that the Flutter app is properly initialized.
  WidgetsFlutterBinding.ensureInitialized();

  // Initializes Firebase using the options from the generated file.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Call the setup function to register our services.
  setupLocator();

  // Runs your app.
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Pawi Can Do It',
      debugShowCheckedModeBanner: false, // Hides the debug banner
      home: LoginScreen(), // The LoginScreen is the correct starting point.
    );
  }
}
