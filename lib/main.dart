import 'package:ajarly/const/app_dimensions.dart';
import 'package:ajarly/screens/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  // تهيئة للفايربيز
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  // هل المستخدم لازال مسجل ام لا
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (user == null) {
          debugPrint('User is currently signed out!');
        } else {
          debugPrint('User is signed in!');
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppDimensions.initialize(context);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(fontFamily: 'Almarai'),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
