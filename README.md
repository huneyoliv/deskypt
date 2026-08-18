<div align="center">

# ⏱️ DeskYPT — Yeolpumta Desktop Client

**A modern, powerful, and sleek desktop client for the Yeolpumta (YPT) study platform.**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Platforms](https://img.shields.io/badge/Platforms-Windows%20%7C%20macOS%20%7C%20Linux-blue?style=for-the-badge&logo=windows&logoColor=white)](https://github.com/huneyoliv/deskypt/releases)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)
[![CI/CD](https://img.shields.io/badge/Build-Passing-brightgreen?style=for-the-badge&logo=githubactions&logoColor=white)](https://github.com/huneyoliv/deskypt/actions)
[![Tests](https://img.shields.io/badge/Tests-256%2B%20Passing-success?style=for-the-badge&logo=dart)](https://github.com/huneyoliv/deskypt)

**[English](README.md)** • **[Português (Brasil)](README.pt-BR.md)**

[Key Features](#-key-features) •
[Installation](#-installation--downloads) •
[Architecture](#-architecture--technologies) •
[Local Development](#-local-development) •
[CI/CD & Releases](#-cicd--releases) •
[License](#-license)

</div>

---

## 📖 About the Project

**DeskYPT** is designed to provide the ultimate focus and productivity experience for students on desktop operating systems (Windows, macOS, and Linux). Built with a modern dark theme aligned with Yeolpumta's design language and optimized for high-resolution displays, DeskYPT brings all the core study features directly to your computer.

---

## ✨ Key Features

### ⏱️ Study Timer & Pomodoro
- **Standard & Pomodoro Modes**: Customizable focus sessions, short breaks, and long breaks.
- **Subject Management**: Create, edit, archive, and customize subjects with color palettes.
- **Manual Study Logs**: Add past study sessions with instant time calculations.
- **Offline Synchronization**: Persistent request queue for uninterrupted tracking during connectivity drops.

### 🛡️ Focus Mode & Distraction Blocker
- **Process Monitoring**: Automated detection and alerts for unauthorized distraction applications open during study.
- **Strict Mode**: Locks navigation to maintain deep focus.
- **Floating Mini Player**: Compact timer overlay to monitor elapsed study time alongside study materials.

### 👥 Study Groups & Cam Study
- **Real-Time Attendance Feed**: View active members studying live with real-time status updates.
- **Cam Study**: Periodic webcam capture and secure upload for study verification.
- **Group Chat**: Rich messaging with emoji reactions, media attachments, and official YPT stickers.
- **Social Nudges**: Send "Shakes" to motivate group peers.

### 📅 Planner, Timetable & D-Days
- **D-Day Countdowns**: Visual countdown timers for exams, tests, and target milestones.
- **Smart To-Do List**: Priority-based tasks with due dates and recurrence rules.
- **Weekly Timetable**: Interactive weekly schedule grid organized by subject blocks.

### 📊 Global Rankings & Activity Heatmap
- **Multilevel Leaderboards**: Real-time global, national, and category-based leaderboards.
- **Activity Heatmap Grid**: GitHub-style annual matrix visualizing daily study intensity and consistency.
- **Monthly Calendar**: Detailed day-by-day study streaks and goal completion.

### 🃏 Flashcards with Spaced Repetition (SM-2)
- **Custom Decks**: Organize study cards by subject and topic.
- **SuperMemo-2 Algorithm**: Adaptive review scheduling based on retention feedback (Again, Hard, Good, Easy).

### 📹 Timelapse Recorder
- Automated study session screen captures with built-in gallery viewer and video playback.

### 🎨 Studicons & Avatar Store
- Customizable doll avatars with outfits, accessories, and dynamic poses reactive to study state.
- Real Flames balance tracking and equipment management.

### 🌐 Comprehensive Internationalization (i18n)
- Native support for 28 languages with instant runtime locale switching.

### 🔄 In-App Update Notifications
- Automatic release checks against GitHub Releases API with animated badge indicator in sidebar.
- Modal dialog with full changelog release notes and direct native installer download buttons.

---

## 💻 Installation & Downloads

Download the latest version directly from our official [**Releases Page**](https://github.com/huneyoliv/deskypt/releases/latest).

| Platform | Package / Installer | Format | Installation Instructions |
| :--- | :--- | :--- | :--- |
| **Windows** | `DeskYPT-Windows-Installer-x64.exe` | Executable Setup | Run the `.exe` installer and follow the setup wizard. |
| **macOS** | `DeskYPT-macOS-Installer.dmg` | Disk Image | Open `.dmg` and drag `DeskYPT.app` to your `Applications` folder. |
| **Linux (Debian/Ubuntu)** | `DeskYPT-Linux-x64.deb` | Debian Package | Run `sudo apt install ./DeskYPT-Linux-x64.deb` or `sudo dpkg -i DeskYPT-Linux-x64.deb`. |
| **Linux (Other Distros)** | `DeskYPT-Linux-x64.tar.gz` | Portable Archive | Extract the archive and execute `./deskypt`. |

---

## 🏗️ Architecture & Technologies

The codebase follows **Clean Architecture** principles with clear layer separation:

```
lib/
├── core/                  # Core services, networking, themes, constants & i18n
│   ├── api/               # HTTP client (Dio) and auth interceptors
│   ├── cdn/               # Dynamic CDN resolvers for avatars & assets
│   ├── constants/         # API endpoints and application defaults
│   ├── localization/      # Translation engine and fallback dictionaries
│   ├── services/          # System services (Focus, Webcam, Updates, Window)
│   └── theme/             # Dark theme palette, typography & styles
├── data/                  # Data layer, DTOs and repositories
│   ├── models/            # Data models with JSON serialization
│   └── repositories/      # API communication and data access abstraction
├── features/              # Feature-first modular components
│   ├── auth/              # Email authentication & social logins (Google / Apple)
│   ├── challenges/        # Study challenges and flame bets
│   ├── flashcards/        # Deck management & SM-2 algorithm
│   ├── focus/             # Process blocker and Mini Player
│   ├── groups/            # Study groups, attendance, chat & Cam Study
│   ├── notifications/     # Notification center and alerts
│   ├── planner/           # Planner, To-Do list & timetable grid
│   ├── profile/           # User profile and account security
│   ├── ranks/             # Leaderboards, Heatmap matrix & calendar
│   ├── settings/          # Study preferences, language and legal dialogs
│   ├── smartbook/         # Built-in PDF reader and study material viewer
│   ├── store/             # Studicon avatar inventory & store
│   ├── timelapse/         # Screen recording & timelapse playback
│   ├── timer/             # Main study timer, Pomodoro & subject tracker
│   └── updates/           # Release checker, changelog viewer & installer links
└── shared/                # Shared widgets (AppShell, SidebarNav, TitleBar, Avatars)
```

### Key Libraries:
- **Framework**: [Flutter Desktop](https://flutter.dev) (Dart 3.x)
- **State Management**: [Flutter Riverpod](https://riverpod.dev)
- **Routing**: [GoRouter](https://pub.dev/packages/go_router)
- **Networking**: [Dio](https://pub.dev/packages/dio)
- **Secure Storage**: [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) & [shared_preferences](https://pub.dev/packages/shared_preferences)
- **Charts & Animations**: [FL Chart](https://pub.dev/packages/fl_chart) & [Lottie](https://pub.dev/packages/lottie)
- **Desktop Window Control**: [window_manager](https://pub.dev/packages/window_manager)

---

## 🛠️ Local Development

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (`>= 3.0.0`)
- **Windows**: Visual Studio 2022 with "Desktop development with C++" workload.
- **macOS**: Xcode 15+ with Command Line Tools.
- **Linux**: Build toolchain:
  ```bash
  sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libsecret-1-dev libjsoncpp-dev
  ```

### Clone the Repository
```bash
git clone https://github.com/huneyoliv/deskypt.git
cd deskypt
```

### Install Dependencies
```bash
flutter pub get
```

### Run the Application
```bash
# Windows
flutter run -d windows

# macOS
flutter run -d macos

# Linux
flutter run -d linux
```

### Run Automated Tests & Static Analysis
```bash
# Run all 256+ automated unit & widget tests
flutter test

# Run static analysis
flutter analyze
```

---

## 🚀 CI/CD & Releases

Continuous Integration and Continuous Delivery are powered by **GitHub Actions**:

1. **Continuous Integration (`ci.yml`)**: Triggered on every Push and Pull Request to execute `flutter analyze` and `flutter test`.
2. **Multiplatform Release Compilation (`release.yml`)**: Automatically triggered on semver tag push (e.g. `v1.0.0`):
   - **Windows**: Compiles release and builds official `DeskYPT-Windows-Installer-x64.exe` using Inno Setup.
   - **macOS**: Compiles `.app` bundle and generates `DeskYPT-macOS-Installer.dmg`.
   - **Linux**: Compiles release and creates `DeskYPT-Linux-x64.deb` Debian package for `apt`, plus portable `DeskYPT-Linux-x64.tar.gz`.
   - **Automated Publishing**: Attaches all built installers to the official GitHub Release with generated changelog.

### How to Release a New Version
```bash
# 1. Bump version in pubspec.yaml (e.g. 1.0.1)
# 2. Commit, tag, and push:
git tag v1.0.1
git push origin v1.0.1
```

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).
