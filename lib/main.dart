import 'package:flutter/material.dart';
import 'package:login_bear_animation/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:login_bear_animation/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login_bear_animation/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('✅ Firebase inicializado correctamente');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
    home: StreamBuilder<User?>(
  stream: FirebaseAuth.instance.authStateChanges(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (snapshot.hasData) {
      return const HomeScreen();
    }
    return const LoginScreen();
  },
),
    );
  }
}