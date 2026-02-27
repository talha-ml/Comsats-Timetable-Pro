import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/timetable_model.dart';
import 'dashboard_screen.dart';

class DataReviewScreen extends StatefulWidget {
  final List<TimetableModel> parsedData;

  const DataReviewScreen({super.key, required this.parsedData});

  @override
  State<DataReviewScreen> createState() => _DataReviewScreenState();
}

class _DataReviewScreenState extends State<DataReviewScreen> {
  late List<TimetableModel> dataList;

  @override
  void initState() {
    super.initState();
    dataList = widget.parsedData;
  }

  Future<void> _editRow(TimetableModel row, int index) async {
    TextEditingController subjectCtrl = TextEditingController(text: row.subjectName);
    TextEditingController roomCtrl = TextEditingController(text: row.roomNumber);
    TextEditingController teacherCtrl = TextEditingController(text: row.teacherName);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Fix Data Entry", style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildEditField(subjectCtrl, "Subject Name", Icons.book),
                const SizedBox(height: 15),
                _buildEditField(roomCtrl, "Room Number", Icons.meeting_room),
                const SizedBox(height: 15),
                _buildEditField(teacherCtrl, "Teacher Name", Icons.person),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                setState(() {
                  dataList[index].subjectName = subjectCtrl.text.trim();
                  dataList[index].roomNumber = roomCtrl.text.trim();
                  dataList[index].teacherName = teacherCtrl.text.trim();
                  dataList[index].isAnomaly = false;
                });
                Navigator.pop(context);
              },
              child: const Text("Apply Changes"),
            )
          ],
        );
      },
    );
  }

  Widget _buildEditField(TextEditingController ctrl, String label, IconData icon) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }

  Future<void> _saveToDatabase() async {
    bool hasAnomalies = dataList.any((element) => element.isAnomaly);

    if (hasAnomalies) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please fix all red-highlighted errors first!"),
          backgroundColor: Colors.orange[800],
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    var box = Hive.box<TimetableModel>('timetableBox');
    await box.clear();
    await box.addAll(dataList);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    int anomalyCount = dataList.where((e) => e.isAnomaly).length;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Verify Data"),
        elevation: 0,
      ),
      body: Column(
        children: [
          // 💡 INFO BAR
          Container(
            padding: const EdgeInsets.all(16),
            color: anomalyCount > 0 ? Colors.orange[50] : Colors.green[50],
            child: Row(
              children: [
                Icon(
                  anomalyCount > 0 ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                  color: anomalyCount > 0 ? Colors.orange[800] : Colors.green[800],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    anomalyCount > 0
                        ? "Found $anomalyCount potential errors. Click the red pencil to fix them."
                        : "All data looks clean! You can now save to your device.",
                    style: TextStyle(
                        color: anomalyCount > 0 ? Colors.orange[900] : Colors.green[900],
                        fontWeight: FontWeight.w500
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 📋 DATA LIST
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: dataList.length,
              itemBuilder: (context, index) {
                final item = dataList[index];
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(
                      color: item.isAnomaly ? Colors.redAccent : Colors.grey[200]!,
                      width: item.isAnomaly ? 1.5 : 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(
                      item.subjectName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.group, size: 14, color: Colors.grey),
                            const SizedBox(width: 5),
                            Text("${item.sectionName} • ${item.departmentName}"),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.meeting_room, size: 14, color: Colors.grey),
                            const SizedBox(width: 5),
                            Text("Room: ${item.roomNumber}"),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.person, size: 14, color: Colors.grey),
                            const SizedBox(width: 5),
                            Text("Prof: ${item.teacherName}"),
                          ],
                        ),
                      ],
                    ),
                    trailing: item.isAnomaly
                        ? IconButton(
                      icon: const Icon(Icons.edit_note_rounded, color: Colors.redAccent, size: 30),
                      onPressed: () => _editRow(item, index),
                    )
                        : const Icon(Icons.check_circle, color: Colors.green),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // 💾 FLOATING ACTION BUTTON
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveToDatabase,
        backgroundColor: Colors.blueAccent,
        icon: const Icon(Icons.save_rounded, color: Colors.white),
        label: const Text("Save Timetable", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}