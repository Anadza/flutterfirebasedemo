import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart'; // File yang dihasilkan oleh flutterfire configure
import 'auth_screen.dart'; // Import layar autentikasi
import 'home_screen.dart'; // Akan kita buat nanti

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Catsin Admin',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, userSnapshot) {
          if (userSnapshot.hasData) {
            return const HomeScreen(); // Pengguna sudah login
          }
          return const AuthScreen(); // Pengguna belum login
        },
      ),
    );
  }
}
