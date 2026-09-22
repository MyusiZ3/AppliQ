# AppliQ — Job Application Tracker & Career Management System

AppliQ is a mobile application built with Flutter and Supabase designed to help job seekers systematically track, organize, and manage their recruitment pipelines, interview schedules, and career records.

---

## Key Features

- **Recruitment Pipeline Tracking**: Record job applications with company details, position, work arrangement (Remote, Hybrid, On-site), application channel, expected salary, and current status (`Applied`, `Interview`, `Offering`, `Accepted`, `Rejected`, `No Response`).
- **Cloud Synchronization & Row-Level Security**: Fully backed by Supabase PostgreSQL with strict Row Level Security (RLS) policies ensuring each authenticated user can only access their own data.
- **Google Authentication**: Seamless authentication using Google Sign-In with automatic user profile provisioning.
- **Google Drive CV Storage**: Attach and upload application documents directly to personal Google Drive folders organized by company and position name.
- **Interview Calendar & Reminders**: Schedule upcoming interviews with integrated local notification alerts.
- **Professional HR Templates**: Ready-to-copy communication formats for follow-ups, interview confirmations, salary inquiries, and offering negotiation.
- **Career Analytics & Conversion Metrics**: Visual breakdown of application progress, stage duration indicators, and interview conversion ratios.
- **Report Exporting**: Export comprehensive application records to formatted PDF summaries or copy raw CSV data for spreadsheet processing.
- **Adaptive Theme System**: Integrated light and dark modes with a default monochrome aesthetic and optional accent modes.

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
