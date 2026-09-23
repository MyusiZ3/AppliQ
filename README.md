# AppliQ — Job Application Tracker & Career Management System

AppliQ is a mobile application built with Flutter and Supabase designed to help job seekers systematically track, organize, and manage their recruitment pipelines, interview schedules, and career records.

---

## Key Features

- **Interactive Kanban Pipeline & Tracking**: Manage recruitment workflows with drag-and-drop Kanban boards, stage duration indicators, and instant status updates (`Applied`, `Interview`, `Offering`, `Accepted`, `Rejected`, `No Response`).
- **Instant ATS Resume / CV PDF Builder**: Create industry-standard ATS-friendly CVs with contact details, education, work experience, certifications, and skills, rendered and exported directly to PDF.
- **Customizable Cover Letter Generator**: Generate formal job application letters (Indonesian & English) with real-time recipient customization, dynamic attachment lists, and digital signature integration.
- **Calendar & Reminder Synchronization**: Sync interview schedules directly to device calendars and Google Calendar, accompanied by timely local push notification alerts.
- **Cloud Synchronization & Row-Level Security**: Fully backed by Supabase PostgreSQL with strict Row Level Security (RLS) policies ensuring complete data privacy and isolation.
- **Google Authentication & Drive Integration**: Seamless authentication via Google OAuth 2.0 with optional dedicated Google Drive folder backup.
- **Multi-Language Support**: Complete localization covering Indonesian (🇮🇩), English (🇬🇧), Japanese (🇯🇵), and Korean (🇰🇷).
- **Professional HR Templates**: Ready-to-copy communication templates for follow-ups, interview confirmations, salary negotiations, and thank-you notes.
- **Career Analytics & Metrics**: Visual dashboards displaying application pipelines, conversion rates, and work system breakdowns.
- **Adaptive Theme System**: Modern light and dark modes with customizable monochrome and accent palettes.

---

## Architecture Overview

The codebase is organized following clean architectural principles:

```
lib/
├── core/
│   ├── config/          # Environment variables and runtime configuration
│   └── constants/       # Color tokens, typography, themes, and enum definitions
├── data/
│   ├── models/          # Entity data structures (JobApplication, UserProfile, etc.)
│   └── repositories/    # Repository interfaces and Supabase data sources
├── presentation/
│   ├── screens/         # Feature screens (Auth, Home, Applications, Schedule, Dashboard, Profile)
│   └── widgets/         # Reusable UI components and modal sheets
├── services/            # Notification, Google Drive, and platform service handlers
└── utils/               # Formatters, UI helpers, and theme managers
```

---

## Technical Stack

- **Framework**: Flutter SDK (`^3.6.0`)
- **Programming Language**: Dart
- **Backend & Database**: Supabase (PostgreSQL 15+, GoTrue OAuth 2.0, PostgREST)
- **Security**: PostgreSQL Row Level Security (RLS)
- **External APIs**: Google Sign-In, Google Drive API v3
- **Local Notifications**: `flutter_local_notifications`, `timezone`
- **Document Rendering**: `pdf`, `printing`

---

## Getting Started

### Prerequisites

- Flutter SDK (version 3.24.0 or higher)
- Android SDK / Android Studio for mobile builds
- Active Supabase project
- Google Cloud Console project with OAuth credentials configured

### Environment Configuration

Create a `.env` file in the project root directory containing the following keys:

```env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-supabase-anon-key
GOOGLE_WEB_CLIENT_ID=your-google-oauth-web-client-id.apps.googleusercontent.com
```

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/MyusiZ3/AppliQ.git
   cd AppliQ
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application:
   ```bash
   flutter run
   ```

---

## Testing & Quality Assurance

Run all unit and widget tests:

```bash
flutter test
```

---

## Build and Release

To compile a release APK for Android with code obfuscation:

```bash
flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols
```

The compiled binary will be located at:
`build/app/outputs/flutter-apk/app-release.apk`

---

## Documentation

Detailed design specifications, database migration scripts, and architecture requirements are available in the `docs/` folder:

- [docs/PRD.md](docs/PRD.md): Product Requirements Document
- [docs/SRS.md](docs/SRS.md): Software Requirements Specification
- [docs/DATABASE_DESIGN.md](docs/DATABASE_DESIGN.md): PostgreSQL Schema, DDL Scripts, and RLS Policies
- [docs/DESIGN_THINKING.md](docs/DESIGN_THINKING.md): Persona Analysis and Design Guidelines

---

## License

This project is licensed under the terms of the GNU General Public License v3.0 (GPL-3.0). See the [LICENSE](LICENSE) file for the full license text.

Copyright (C) 2026 Muhamad Sidik ([@MyusiZ3](https://github.com/MyusiZ3)).
