// ignore_for_file: library_private_types_in_public_api

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:medtriangle/Screens/login_screen.dart';
import 'package:medtriangle/Screens/medical_info.dart';

import 'Screens/laboratory_tests.dart';
import 'Screens/patient_info.dart';
import 'Screens/treatment.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedTriangle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
        future: FirebaseAuth.instance.authStateChanges().first,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while checking the authentication status
            return const CircularProgressIndicator();
          } else {
            if (snapshot.hasData) {
              // User is logged in, navigate to the BottomNavBarScreen
              return const BottomNavBarScreen();
            } else {
              // User is not logged in, navigate to the LoginScreen
              return const LoginScreen();
            }
          }
        },
      ),
    );
  }
}

class BottomNavBarScreen extends StatefulWidget {
  const BottomNavBarScreen({super.key});

  @override
  _BottomNavBarScreenState createState() => _BottomNavBarScreenState();
}

class _BottomNavBarScreenState extends State<BottomNavBarScreen> {
  void _logout(BuildContext context) {
    FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginScreen()));
    Fluttertoast.showToast(msg: 'Logged out');
  }

  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const PatientInformationScreen(),
    const MedicalInformationScreen(),
    const TreatmentScreen(),
    const LabTestsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MedTriangle'),
        actions: [
          InkWell(
              onTap: () {
                _logout(context);
              },
              child: const Icon(Icons.logout))
        ],
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.blueGrey,
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Patient Info',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            label: 'Medical Info',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services_outlined),
            label: 'Treatment',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.biotech_rounded),
            label: 'Laboratory Tests',
          ),
        ],
      ),
    );
  }
}
