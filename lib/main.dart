import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:stoc_one_2/sign_up.dart';
import ' ActivationKey/Admin_Dashboard.dart';
import 'Login.dart';
import 'dash_b.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp( MaterialApp(

    home:KeyDashboard() ,
  )

     );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stoc One',
      initialRoute: '/login', // Set the initial route
      routes: {
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),
        '/home': (context) => pages1(), // Add your home page route here
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: KeyDashboard(),
    );
  }
}

// Widget to check the authentication status and navigate accordingly
class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  _AuthCheckState createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to delay navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkCurrentUser();
    });
  }

  // Function to check if the user is logged in
  void _checkCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // If the user is logged in, navigate to the home page
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // If no user is logged in, navigate to the login page
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading spinner while checking the authentication state
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

