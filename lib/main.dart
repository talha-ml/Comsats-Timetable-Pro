import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart'; // Isko 'flutter pub add google_fonts' se install kar lein
import 'models/timetable_model.dart';
import 'screens/upload_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialization logic same rakha hai
  await NotificationService().init();
  await NotificationService().requestPermission();
  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(TimetableModelAdapter());
  }
  await Hive.openBox<TimetableModel>('timetableBox');

  runApp(const TimetableProApp());
}

class TimetableProApp extends StatelessWidget {
  const TimetableProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timetable Pro',
      debugShowCheckedModeBanner: false,

      // 🎨 PROFESSIONAL THEMING
      theme: ThemeData(
        useMaterial3: true,
        // BlueAccent ko base bana kar aik clean look
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          primary: const Color(0xFF1E88E5),
          secondary: const Color(0xFF00C853),
          surface: Colors.white,
        ),

        // Google Fonts use karne se app premium lagti hai
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),

        // AppBar ka standard look
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E88E5),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),

        // Buttons ko round aur clean banaya
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),
      ),

      // Splash screen ya direct home
      home: const UploadScreen(),
    );
  }
}