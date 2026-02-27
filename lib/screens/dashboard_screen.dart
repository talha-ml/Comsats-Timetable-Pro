import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/timetable_model.dart';
import '../services/notification_service.dart';
import 'upload_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late Box<TimetableModel> box;
  List<TimetableModel> allData = [];
  List<TimetableModel> filteredData = []; // Role/Section ke mutabiq
  List<TimetableModel> displayedData = []; // Specific day ke mutabiq

  late TabController _tabController;
  final List<String> weekDays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];

  String selectedRole = 'Student';
  Set<String> departments = {};
  Set<String> sections = {};
  Set<String> teachers = {};
  String? selectedDepartment;
  String? selectedSection;
  String? selectedTeacher;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    // Aaj ka din auto-select karne ke liye
    int today = DateTime.now().weekday - 1;
    _tabController.index = today >= 0 && today < 7 ? today : 0;

    _loadData();
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _filterByDay();
      }
    });
  }

  void _loadData() {
    box = Hive.box<TimetableModel>('timetableBox');
    allData = box.values.toList();

    for (var item in allData) {
      if (item.departmentName.isNotEmpty) departments.add(item.departmentName);
      if (item.sectionName.isNotEmpty) sections.add(item.sectionName);
      if (item.teacherName.isNotEmpty && !item.teacherName.contains('TBA')) teachers.add(item.teacherName);
    }

    if (departments.isNotEmpty) selectedDepartment = departments.first;
    if (sections.isNotEmpty) selectedSection = sections.first;
    if (teachers.isNotEmpty) selectedTeacher = teachers.first;

    _applyRoleFilters();
  }

  void _applyRoleFilters() {
    setState(() {
      if (selectedRole == 'Student') {
        filteredData = allData.where((element) =>
        element.departmentName == selectedDepartment &&
            element.sectionName == selectedSection
        ).toList();
      } else {
        filteredData = allData.where((element) =>
        element.teacherName == selectedTeacher
        ).toList();
      }
      _filterByDay();
    });
    NotificationService().scheduleClassReminders(filteredData);
  }

  void _filterByDay() {
    String currentDay = weekDays[_tabController.index];
    setState(() {
      displayedData = filteredData.where((e) =>
      e.dayOfWeek.trim().toLowerCase() == currentDay.toLowerCase()
      ).toList();
      // Time ke mutabiq sort karna
      displayedData.sort((a, b) => a.startTime.compareTo(b.startTime));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Timetable Pro"),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload_outlined),
            onPressed: () => Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => const UploadScreen())
            ),
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          indicatorWeight: 4,
          tabs: weekDays.map((day) => Tab(text: day.substring(0, 3))).toList(),
        ),
      ),
      body: Column(
        children: [
          // 🛠 FILTERS SECTION
          _buildFilterPanel(),

          // 📅 TIMETABLE VIEW
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: displayedData.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: displayedData.length,
                itemBuilder: (context, index) => _buildClassCard(displayedData[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel() {
    return Container(
      padding: const EdgeInsets.all(15),
      color: Colors.blueAccent,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _roleChip("Student"),
              const SizedBox(width: 15),
              _roleChip("Teacher"),
            ],
          ),
          const SizedBox(height: 15),
          selectedRole == 'Student'
              ? Row(
            children: [
              Expanded(child: _miniDropdown(departments.toList(), selectedDepartment, (v) {
                selectedDepartment = v; _applyRoleFilters();
              })),
              const SizedBox(width: 10),
              Expanded(child: _miniDropdown(sections.toList(), selectedSection, (v) {
                selectedSection = v; _applyRoleFilters();
              })),
            ],
          )
              : _miniDropdown(teachers.toList(), selectedTeacher, (v) {
            selectedTeacher = v; _applyRoleFilters();
          }),
        ],
      ),
    );
  }

  Widget _roleChip(String label) {
    bool isSelected = selectedRole == label;
    return GestureDetector(
      onTap: () { setState(() => selectedRole = label); _applyRoleFilters(); },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white24,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(
            color: isSelected ? Colors.blueAccent : Colors.white,
            fontWeight: FontWeight.bold
        )),
      ),
    );
  }

  Widget _miniDropdown(List<String> items, String? value, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildClassCard(TimetableModel cls) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          // TIME BLOCK
          Container(
            width: 70,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Text(cls.startTime.split(' ')[0], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                Text(cls.startTime.split(' ')[1], style: const TextStyle(fontSize: 10, color: Colors.blueAccent)),
              ],
            ),
          ),
          const SizedBox(width: 15),
          // DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cls.subjectName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text("Room ${cls.roomNumber}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
                Row(
                  children: [
                    Icon(selectedRole == 'Student' ? Icons.person_outline : Icons.school_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(selectedRole == 'Student' ? cls.teacherName : cls.sectionName, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 10),
          const Text("No classes scheduled for today", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}