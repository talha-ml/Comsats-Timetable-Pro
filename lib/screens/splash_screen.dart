import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/timetable_model.dart';
import 'upload_screen.dart';
import 'dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Animation set up
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _controller.forward();
    _navigateToNext();
  }

  void _navigateToNext() {
    // 3 second baad check karega ke data hai ya nahi
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      var box = Hive.box<TimetableModel>('timetableBox');

      // 🚨 SMART LOGIC: Agar data pehle se save hai toh seedha Dashboard!
      if (box.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } else {
        // Agar pehli dafa app khuli hai toh Upload screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UploadScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🎓 LOGO: Abhi ke liye icon use kar rahe hain
              const Icon(Icons.auto_stories, size: 100, color: Color(0xFF1E88E5)),
              const SizedBox(height: 20),
              Text(
                "COMSATS",
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E88E5),
                ),
              ),
              Text(
                "Timetable Pro",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.grey[600],
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 50),
              const CircularProgressIndicator(color: Color(0xFF1E88E5)),
            ],
          ),
        ),
      ),
    );
  }
}