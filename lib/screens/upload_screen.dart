import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import '../models/timetable_model.dart';
import 'data_review_screen.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  bool isProcessing = false;

  Future<void> _pickAndParseFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null) {
        setState(() { isProcessing = true; });

        File file = File(result.files.single.path!);
        final csvString = await file.readAsString();

        List<String> lines = csvString.split(RegExp(r'\r\n|\r|\n'));
        List<TimetableModel> parsedDataList = [];

        for (int i = 1; i < lines.length; i++) {
          if (lines[i].trim().isEmpty) continue;
          List<String> row = lines[i].split(',');

          if (row.length >= 8) {
            String day = row[0].trim();
            String start = row[1].trim();
            String end = row[2].trim();
            String subject = row[3].trim();
            String room = row[4].trim();
            String teacher = row[5].trim();
            String section = row[6].trim();
            String dept = row[7].trim();

            bool isAnomaly = teacher.contains('MS-') ||
                teacher.contains('CS-') ||
                teacher.contains('SE-') ||
                room.length > 10;

            parsedDataList.add(
                TimetableModel(
                  dayOfWeek: day,
                  startTime: start,
                  endTime: end,
                  subjectName: subject,
                  roomNumber: room,
                  teacherName: teacher,
                  sectionName: section,
                  departmentName: dept,
                  isAnomaly: isAnomaly,
                )
            );
          }
        }

        setState(() { isProcessing = false; });

        if (parsedDataList.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DataReviewScreen(parsedData: parsedDataList),
            ),
          );
        } else {
          _showError("CSV file mein koi valid data nahi mila.");
        }
      }
    } catch (e) {
      setState(() { isProcessing = false; });
      _showError("File read karne mein error aagaya: $e");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        )
    );
  }

  void _showSampleFormatDialog() {
    String sampleHeaders = "day_of_week,start_time,end_time,subject_name,room_number,teacher_name,section_name,department_name";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.description, color: Colors.blueAccent),
              SizedBox(width: 10),
              Text("CSV File Format"),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Columns sequence laazmi follow karein:"),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
                  ),
                  child: const Text(
                    "1. Day, 2. Start, 3. End,\n4. Subject, 5. Room, 6. Teacher,\n7. Section, 8. Dept",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueAccent),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Got it"),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.copy, size: 18),
              label: const Text("Copy Headers"),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: sampleHeaders));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Headers copied to clipboard!")),
                );
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blueAccent.shade700, Colors.blueAccent.shade400],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.auto_awesome, size: 60, color: Colors.white),
              const SizedBox(height: 10),
              const Text(
                "Timetable Pro",
                style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Setup your workspace",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const Spacer(),

              // 🎨 MAIN INTERACTIVE CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isProcessing) ...[
                      const CircularProgressIndicator(),
                      const SizedBox(height: 20),
                      const Text("Analyzing CSV Data...", style: TextStyle(fontWeight: FontWeight.w500)),
                    ] else ...[
                      const Icon(Icons.upload_file_rounded, size: 80, color: Colors.blueAccent),
                      const SizedBox(height: 20),
                      const Text(
                        "Upload Schedule",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Select the CSV file you exported\nfrom your university portal.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _pickAndParseFile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: const Text("Select CSV File", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextButton.icon(
                        icon: const Icon(Icons.help_outline),
                        label: const Text("Don't have a file? View Format"),
                        onPressed: _showSampleFormatDialog,
                      ),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}