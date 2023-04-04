import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hostlr_student/presentation/home_screen/home_screen.dart';
import 'package:hostlr_student/presentation/login_or_sign_up/login._page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final storage = const FlutterSecureStorage();
  @override
  void initState() {
    super.initState();
    checkUserStatus();
  }

  Future<void> checkUserStatus() async {
    try {
      final token = await storage.read(key: 'token');
      if (token != null) {
        log("User found");
        Future.delayed(const Duration(seconds: 2)).then((value) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const HomeScreen()));
        });
      } else {
        log("No user found");
        Future.delayed(const Duration(seconds: 2)).then((value) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const LoginScreen()));
        });
      }
    } catch (e) {
      log("Auto Login Failed--> $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: SizedBox(
              height: 300,
              width: 300,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    children: [
                      Text(
                        'hostlr.',
                        style: GoogleFonts.poppins(
                          color: const Color.fromARGB(255, 90, 68, 188)
                              .withOpacity(0.8),
                          fontSize: 68,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                      Text(
                        'Management made easy',
                        style: GoogleFonts.poppins(
                          color: Colors.grey.withOpacity(0.7),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  SpinKitWave(
                    size: 40,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: index.isEven
                                ? Color.fromARGB(234, 90, 68, 188)
                                : Color.fromARGB(137, 178, 167, 218),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Material(
                child: RichText(
                  text: TextSpan(
                    text: "Made with ❤️ by ",
                    style: GoogleFonts.poppins(
                      color: Colors.grey.withOpacity(1),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                    children: const <TextSpan>[
                      TextSpan(
                          text: 'Team hostlr.',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
