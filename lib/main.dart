import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/jamu_provider.dart';
import 'screens/dashboard_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Mencoba inisialisasi Firebase menggunakan file opsi platform default.
  // Jika gagal (karena kredensial placeholder atau tidak ada internet),
  // JamuProvider secara otomatis akan berjalan dalam Mode Simulasi Lokal.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase initialized successfully");
  } catch (e) {
    print("Firebase initialization failed/skipped: $e");
    print("App will run in local simulation mode.");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => JamuProvider()),
      ],
      child: const JamuApp(),
    ),
  );
}

class JamuApp extends StatelessWidget {
  const JamuApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jamu Herbal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const DashboardScreen(),
    );
  }
}
