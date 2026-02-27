

# 🎓 Comsats Timetable Pro

**Comsats Timetable Pro** is a high-performance, cross-platform mobile application built with Flutter. It solves the common problem of navigating complex university schedules by transforming raw CSV data into a dynamic, user-centric interface. Designed with both students and faculty in mind, the app ensures that no class is ever missed through a sophisticated multi-stage notification system.

## 🌟 Core Features

* **Intelligent CSV Ingestion:** Features a custom, robust CSV parsing engine that extracts timetable data with high accuracy, eliminating manual entry.
* **Automated Anomaly Detection:** Real-time data validation highlights inconsistencies (e.g., missing instructor names or irregular room numbers) during the upload phase, ensuring data integrity.
* **Triple-Layer Notification Engine:** Implements an advanced scheduling logic that provides reminders at **30-minute, 15-minute, and 5-minute** intervals before each class.
* **Dual-Persona Architecture:**
* **Student View:** Filterable schedules based on specific Departments and Sections.
* **Faculty View:** Personalized dashboards focusing exclusively on assigned teaching modules.


* **Offline-First Experience:** Leverages Hive NoSQL storage for ultra-fast data retrieval and full offline functionality.
* **Modern Weekly Grid UI:** A sleek, tabbed interface organized by days of the week (Monday–Sunday) for intuitive navigation.

---

## 🛠 Technical Stack

* **Framework:** Flutter (Material 3)
* **Local Database:** Hive (NoSQL Key-Value Store)
* **Scheduling:** Flutter Local Notifications
* **Timezone Handling:** Timezone & Intl packages for precise scheduling
* **UI/UX:** Google Fonts (Poppins), Glassmorphism-inspired design, and custom theme configurations.

---

## 📂 Project Architecture

```text
lib/
├── models/         # Hive data models and generated TypeAdapters
├── screens/        # UI components: Splash, Upload, Review, and Dashboard
├── services/       # Notification logic and background scheduling
├── utils/          # Helper functions and constants
└── main.dart       # Application entry point and service initialization

```

---

## 🚀 Installation & Setup

1. **Clone the Repository:**
```bash
git clone https://github.com/your-username/Comsats-Timetable-Pro.git

```


2. **Install Dependencies:**
```bash
flutter pub get

```


3. **Generate Local Database Adapters:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs

```


4. **Configure App Icons:**
```bash
flutter pub run flutter_launcher_icons

```


5. **Build Release APK:**
```bash
flutter build apk --release

```



---

## 📝 Data Requirements (CSV Format)

The application requires a CSV file with exactly 8 columns in the following sequence:
`day_of_week, start_time, end_time, subject_name, room_number, teacher_name, section_name, department_name`

---

## 👨‍💻 Developed By

**M. Talha**
*Computer Science Student | 7th Semester*
*Passionate about Business Analytics & Product Management*
