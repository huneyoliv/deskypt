# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.3] - 2026-08-18

### ✨ Added
- **Rich Markdown Changelog Viewer**: Integrated `flutter_markdown` into `UpdateDialog` with custom dark-themed styling, selectable text, styled headers, code snippets, lists, and external link navigation.
- **High-Resolution Multi-Layer Desktop Icons**: Generated multi-resolution Windows icon asset (`app_icon.ico`) with 7 layers (16x16, 24x24, 32x32, 48x48, 64x64, 128x128, 256x256) ensuring authentic YPT flame icon rendering on Windows Taskbar, Alt+Tab, and desktop shortcuts.
- **Cross-Platform Icon Packaging**: Synchronized high-resolution application icons for macOS (`AppIcon.appiconset`) and Linux desktop packaging (`/usr/share/pixmaps/deskypt.png`).

---

## [1.0.2] - 2026-08-18

### ⚡ Performance & Polish
- **UI Material Polish**: Standardized Material container surfaces across dialogs, profile settings, and notification panels for optimal ink splashes and desktop interaction.
- **Dynamic Version Display**: Integrated `AppConstants.appVersion` directly into the profile view and about dialogs.
- **CI/CD Pipeline Validation**: Verified automated Quality Gate test execution and automatic release notes extraction from `CHANGELOG.md`.

---

## [1.0.1] - 2026-08-18

### ✨ Added
- **Official Multiplatform Icons**: Authentic Yeolpumta (YPT) app icon configured for Windows (`.ico`), macOS (`AppIcon.appiconset`), and Linux desktop packaging.
- **Group Exploration & Search API**: Complete categorization filters (Exams, Civil Service, College, Languages, High School, Others), sorting options, reactive search by title, and password-protected group join support.
- **Batch Notifications**: Support for group poke/shake push notification (`shakeAllMembers`).
- **Integrated Release Notes**: Direct extraction of changelog notes from `CHANGELOG.md` into the application's update dialog and GitHub Releases.

### 🐛 Fixed
- **Group API Contracts**: Secure mapping and parsing for real-time studying members, study time (`sm`), active subject names/colors, and Studicon avatars (`sd`, `gd`, `st`).
- **Multiplatform Widget Tests**: Standardized `splashFactory` to `InkRipple.splashFactory` to prevent shader exceptions in desktop headless tests.
- **Version Synchronization**: Centralized `AppConstants.appVersion` to ensure the update check button disappears when running the latest release.
- **CI/CD Quality Gate**: Enforced mandatory automated tests and static analysis gate before building or deploying releases.

---

## [1.0.0] - 2026-08-17

### ✨ Added
- **Initial DeskYPT Release**: Modern cross-platform desktop client for the Yeolpumta (YPT) study platform on Windows, macOS, and Linux.
- **Real-Time Study Timer**: Precision stopwatch with subject tracking, rest timers, daily goals, and background synchronization.
- **Subject Management**: Create, edit, archive, delete, recolor, and reorder study subjects.
- **Planner & Timetable**: Visual weekly schedule and study timetable.
- **Cam Study & Groups**: View group members studying in real-time with webcam/camera captures and active subjects.
- **Flashcards & SmartBook**: Integrated PDF document reader and study flashcard decks.
- **Global & Group Rankings**: Real-time leaderboards with daily, weekly, and monthly periods.
- **Strict Focus Mode**: Distraction blocker and desktop process monitoring.
- **Multilingual Support**: English, Portuguese, Spanish, and Korean translations.
- **Auto-Update System**: GitHub Release integration with OS-specific installer downloads.
