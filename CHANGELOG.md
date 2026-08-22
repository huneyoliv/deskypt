# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## Versioning & Release Convention

### Version Number Schema

This project uses **Semantic Versioning** (`MAJOR.MINOR.PATCH`):

| Segment | When to increment | Example |
|---------|-------------------|---------|
| `MAJOR` | Breaking changes or complete architectural overhaul | `2.0.0` |
| `MINOR` | New backward-compatible features or significant UX additions | `1.1.0` |
| `PATCH` | Bug fixes, small improvements, removals, or dependency updates | `1.0.6` |

> During the initial rollout phase (`1.0.x`), `PATCH` increments are also used for feature additions
> that do not break existing functionality, reflecting rapid iteration on the v1 baseline.

### Git Tag & Release Workflow

Releases are distributed as multiplatform installers (Windows `.exe`, macOS `.dmg`, Linux `.deb` / `.tar.gz`)
via the GitHub Actions pipeline defined in `.github/workflows/release.yml`.

**The CI/CD pipeline is tag-driven.** It activates exclusively on `push` events targeting tags
that match the pattern `v*.*.*`. Tags are **not** created automatically by any workflow step —
they must be created manually before the release push.

#### Required steps to publish a new version

```bash
# 1. Ensure all commits for the release are on the target branch.
# 2. Create an annotated tag pointing to the release commit.
git tag -a v<MAJOR>.<MINOR>.<PATCH> <commit-sha> -m "Release v<MAJOR>.<MINOR>.<PATCH>"

# 3. Push the tag to origin. This is what triggers the release pipeline.
git push origin v<MAJOR>.<MINOR>.<PATCH>
```

> **Important:** Pushing commits without a corresponding tag will **not** trigger the release
> pipeline. Only the tag push initiates the build matrix (Windows, macOS, Linux) and the
> subsequent GitHub Release publication.

#### Tag naming convention

Tags must follow the pattern `v<MAJOR>.<MINOR>.<PATCH>` exactly (e.g., `v1.0.6`).
Tags deviating from this pattern (e.g., `1.0.6` without the `v` prefix) will not match
the workflow trigger and will be silently ignored by the pipeline.

---

## [1.0.6] - 2026-08-22

### 🔄 Changed & Improved
- **Streamlined Authentication Architecture**: Refactored the core authentication flow to prioritize official, native Yeolpumta E-mail & Password credentials, alongside robust social login integrations (Kakao, Naver, Apple).
- **Refined Login Screen UI**: Polished login layout with optimized spacing, responsive form elements, and seamless error feedback.
- **Local QR Pairing Simplification**: Cleaned up internal OAuth loopback services and local QR pairing helpers, maintaining high stability and security across desktop platforms.

### 🗑️ Removed
- **Google OAuth & Companion Module**: Removed experimental Google OAuth integration and external companion dependencies due to third-party SHA-1 signature enforcement by Google Play Services, ensuring a lean and self-contained desktop experience.

### 🧪 Testing & Quality Assurance
- **Full Test Suite & Analyzer Validation**: 291 automated unit and widget tests passing with 100% success rate and 0 lint issues across the codebase.
- **Interactive CLI Dev Runner**: Added `scripts/test_runner.ps1` — interactive menu-driven CLI for running the full test suite or launching the desktop app (`flutter run -d windows`) locally.
- **Batch QA Runner**: Updated `scripts/run_all_tests.ps1` to run only DeskYPT Desktop tests and analysis after Companion module removal.

---

## [1.0.5] - 2026-08-21

### ✨ Added
- **QR Code Companion Sync & Mobile Auth Pairing**: Implemented local network peer-to-peer pairing server (`QrAuthService`) with ephemeral cryptographic session tokens and mobile pairing web interface for social login transfer.
- **Vector QR Code Dialog**: Added glassmorphic `QrAuthDialog` featuring vector QR code rendering (`qr_flutter`), real-time connection status, link clipboard export, and manual JWT token input fallback.
- **Direct JWT Session Ingestion**: Added `signInWithJwt` method in `AuthRepository` and `AuthNotifier` to seamlessly authenticate and restore profile data via `splashLogin`.
- **OAuth Social Login Infrastructure**: Implemented RFC 8252 PKCE and loopback HTTP server authentication for Kakao and Naver providers.
- **Native Social Auth UI**: Integrated custom branded Kakao, Naver, and Apple login buttons on `LoginScreen` with loading states, cancellation support, and localized feedback.
- **PKCE & Cryptographic Utilities**: Added `OAuthPkce` helper for secure verifier/challenge generation, state CSRF validation, and JWT payload decoding.

---

## [1.0.4] - 2026-08-21

### ✨ Added
- **Full Multi-Language Localization**: Added complete English, Korean, and Brazilian Portuguese support.
- **Profile & Account Management**: Added comprehensive user profile editing, avatar selection, and account settings.
- **Auto-Update System**: Integrated background release checking against GitHub Releases with direct download support.
- **Time Table Grid**: Added interactive timetable with zoom, block drag/creation, and color categorization.

---

## [1.0.3] - 2026-08-20

### ✨ Added
- **Focus Mode & Ambient Audio**: Integrated ambient sounds and focus timer with fullscreen support.
- **Subject & Category Customization**: Full CRUD operations on subjects with color pickers and icon customization.

---

## [1.0.0] - 2026-08-18

### ✨ Initial Release
- Desktop client for Yeolpumta (YPT) study tracker.
- Real-time study timer with subject selection.
- Group study rooms with live member presence.
- Daily, weekly, and monthly analytics dashboards.
