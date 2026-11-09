# AppliQ — Comprehensive Project Context & Reference

> **Tujuan Dokumen:** Dokumen ini merangkum seluruh arsitektur, struktur file, basis data, alur state, design system, dan panduan fitur dari aplikasi **AppliQ**. Dokumen ini dirancang sebagai acuan terpusat bagi AI assistant dan pengembang agar **tidak perlu membaca seluruh source code setiap kali prompting**.

---

## 1. Executive Summary & Tech Stack

**AppliQ** adalah aplikasi pelacak lamaran kerja (*Job Application Tracker*) dan manajemen karir personal (*Career Management System*) berbasis **Flutter** dan **Supabase**. Aplikasi ini dirancang untuk menggantikan spreadsheet manual dengan alur kerja modern: Kanban/List pipeline, pembuat CV ATS & Surat Lamaran PDF instan, sinkronisasi jadwal wawancara ke kalender dan notifikasi lokal, backup ke Google Drive, serta analitik karir.

### Tech Stack
- **Framework & SDK**: Flutter (SDK `^3.6.0`, Dart 3.x), Material Design 3.
- **Backend & Database**: Supabase Managed PostgreSQL 15+, GoTrue OAuth 2.0, Row Level Security (RLS), PostgREST API.
- **Authentication**: Google Sign-In (`google_sign_in: ^6.2.2`) via Supabase Auth.
- **Local Persistence & Cache**: `shared_preferences: ^2.5.3` (Offline-First via `LocalCacheService`).
- **Cloud & External APIs**: Google Drive API v3 (`googleapis: ^14.0.0`, `googleapis_auth: ^2.0.0`), Google Calendar Web Links.
- **Push & Local Notifications**: `flutter_local_notifications: ^18.0.1`, `timezone: ^0.10.0`.
- **Document & PDF Builder**: `pdf: ^3.11.3`, `printing: ^5.14.3`, `excel: ^4.0.6`.
- **Charting & Visualizations**: `fl_chart: ^0.70.2`.
- **Localization**: Native internal multi-language manager (Indonesian 🇮🇩, English 🇬🇧, Japanese 🇯🇵, Korean 🇰🇷).

---

## 2. Directory Structure & Architecture

Aplikasi menggunakan pendekatan **Clean Layered Architecture** dengan pemisahan yang jelas antara konfigurasi inti (*core*), data/repository, presentation (UI), layanan (*services*), dan utilities.

```
AppliQ/
├── .env / .env.example         # Konfigurasi Supabase & Google Web Client ID
├── pubspec.yaml                # Dependensi dan aset aplikasi
├── deploy_app.ps1              # Script otomatisasi build, version bump, APK rename, & Firebase deploy
├── .github/workflows/          # CI/CD Workflows
│   ├── deploy-pages.yml        # Deploy otomatis landing page ke GitHub Pages
│   └── supabase-keepalive.yml  # Keep-alive query berkala anti-pause 7 hari Supabase
├── public/                     # Static site & OTA server (index.html, version.json, APK download)
├── docs/                       # Dokumentasi spesifikasi, database, & design
│   ├── PROJECT_CONTEXT.md      # [DOKUMEN INI] Ringkasan komprehensif proyek
│   ├── PRD.md                  # Product Requirements Document
│   ├── SRS.md                  # Software Requirements Specification
│   ├── DATABASE_DESIGN.md      # PostgreSQL Schema, RLS, & Trigger Specs
│   ├── PASTEL_COLOR_SYSTEM.md  # Definisi Design System Neo-Pastel & Kontras WCAG
│   └── SPREADSHEET_ANALYSIS.md # Analisis migrasi template Excel ke sistem AppliQ
├── lib/
│   ├── main.dart               # Entry point, AppConfig, Supabase/Theme Init, AuthGate
│   ├── core/
│   │   ├── config/
│   │   │   └── app_config.dart          # Environment variables loader (.env / dart-define)
│   │   ├── constants/
│   │   │   ├── app_colors.dart          # Neo-Pastel tokens, Obsidian dark & Slate light surfaces
│   │   │   ├── app_enums.dart           # EmploymentType, WorkSystem, JobPortal, ApplicationStatus
│   │   │   └── app_theme.dart           # ThemeData builder (Light & Dark, Monochrome & Color mode)
│   │   ├── localization/
│   │   │   ├── app_strings.dart         # Wrapper strings statis terjemahan dinamis
│   │   │   └── languages/               # BaseLanguage, en_language, id_language, ja_language, ko_language
│   │   └── utils/
│   │       ├── calendar_helper.dart     # Ekspor event ke device calendar & link Google Calendar
│   │       ├── cover_letter_pdf_builder.dart # Generator PDF Surat Lamaran standar formal
│   │       ├── cv_ats_pdf_builder.dart  # Generator PDF CV format ATS-Friendly
│   │       ├── job_description_parser.dart   # Regex / Text extractor lowongan kerja dari clipboard
│   │       ├── network_helper.dart      # Pemeriksa konektivitas jaringan & latency
│   │       └── status_helper.dart       # Mapping warna, ikon, dan label status lamaran
│   ├── data/
│   │   ├── models/
│   │   │   ├── application_log.dart     # Model tahapan seleksi/interview (ApplicationLog)
│   │   │   ├── job_application.dart     # Model utama entitas lamaran (JobApplication)
│   │   │   ├── user_profile.dart        # Profil pengguna (UserProfile)
│   │   │   └── user_resume.dart         # Data CV lengkap (Education, Experience, Certification, Skills)
│   │   └── repositories/
│   │       ├── job_repository.dart          # Interface kontrak abstrak JobRepository
│   │       ├── mock_job_repository.dart     # Mock repository untuk pengujian & mode offline tanpa Supabase
│   │       └── supabase_job_repository.dart # Implementasi repository Supabase + Local Cache integration
│   ├── presentation/
│   │   ├── screens/
│   │   │   ├── main_nav.dart                # Bottom Navigation Bar (Home, Lamaran, Jadwal, Statistik)
│   │   │   ├── onboarding_screen.dart       # Onboarding swipe slider (hanya muncul pertama kali)
│   │   │   ├── applications/
│   │   │   │   ├── applications_list_screen.dart # List & Kanban pipeline, filter, search, & bookmark
│   │   │   │   ├── application_detail_screen.dart# Detail lamaran, log riwayat, gaji, upload dokumen
│   │   │   │   └── application_form_screen.dart  # Form Tambah/Ubah lamaran + Auto Draft Protection
│   │   │   ├── auth/
│   │   │   │   └── login_screen.dart        # Layar Google OAuth login + Mascot + Terms Sheets
│   │   │   ├── dashboard/
│   │   │   │   └── dashboard_screen.dart    # Analitik konversi corong, pie chart work system & portal
│   │   │   ├── home/
│   │   │   │   └── home_screen.dart         # Dashboard utama, kartu metrik pastel, upcoming interviews
│   │   │   ├── profile/
│   │   │   │   ├── career_screen.dart       # Target posisi, perusahaan impian, skill gaps & milestones
│   │   │   │   ├── document_preview_screen.dart  # Pratinjau PDF CV & Surat Lamaran + Ekspor / Cetak
│   │   │   │   ├── edit_profile_screen.dart # Edit nama, avatar, username, nomor telepon
│   │   │   │   ├── profile_screen.dart      # Pengaturan tema, bahasa, Google Drive sync, legal, logout
│   │   │   │   └── resume_builder_screen.dart # Form input interaktif data CV ATS & cover letter
│   │   │   └── schedule/
│   │   │       └── schedule_screen.dart     # Kalender interaktif, jadwal interview, sync reminder
│   │   └── widgets/
│   │       ├── animated_logo_mascot.dart    # Maskot kucing ekspresif AppliQ
│   │       ├── application_card.dart        # Kartu lamaran di daftar
│   │       ├── appliq_loading.dart          # Indikator loading khas AppliQ
│   │       ├── appliq_logo.dart             # Logo vektor & teks AppliQ
│   │       ├── app_avatar.dart              # Avatar dengan caching network image & fallback inisial
│   │       ├── app_error_state_widget.dart  # Tampilan state error dengan retry
│   │       ├── empty_state_view.dart        # Tampilan kosong informatif
│   │       ├── export_sheet.dart            # Modal ekspor Excel (.xlsx) & PDF data lamaran
│   │       ├── google_logo.dart             # Ikon vektor resmi Google
│   │       ├── hr_templates_sheet.dart      # Modal template chat/email HR (Follow-up, Offering, dll)
│   │       ├── job_description_parser_sheet.dart # Bottom sheet paste deskripsi lowongan untuk auto-fill
│   │       ├── legal_sheets.dart            # Bottom sheet Privacy Policy & Terms of Service
│   │       ├── metric_card.dart             # Kartu metrik bergradien / warna pastel
│   │       ├── notched_pill_card.dart       # Kartu berlekuk modern dengan badge status
│   │       ├── notification_sheet.dart      # Riwayat dan pengaturan notifikasi lokal
│   │       └── status_badge.dart            # Pill badge warna status (Applied, Interview, dll)
│   ├── services/
│   │   ├── app_update_service.dart          # Pemeriksa pembaruan in-app OTA, threshold force update, & direct APK download
│   │   ├── google_drive_service.dart        # Upload / Download / Backup file ke Google Drive App Folder
│   │   ├── local_cache_service.dart         # SharedPreferences snapshot cache (Offline-first)
│   │   └── notification_service.dart        # Local push notifications & scheduled reminders
│   └── utils/
│       ├── language_manager.dart            # State notifier bahasa aktif (ValueNotifier)
│       ├── navigator_key.dart               # GlobalKey<NavigatorState> untuk akses konteks navigasi
│       ├── theme_manager.dart               # ThemeMode (Dark/Light) & AccentThemeMode (Monochrome/Color)
│       └── ui_helper.dart                   # Toast, snackbar, haptic feedback, dialog konfirmasi
```

---

## 3. Database & Supabase Integration

### Tabel Utama (PostgreSQL 15+)
1. **`public.profiles`** (1:1 dengan `auth.users`)
   - `id` (UUID, PK -> auth.users.id)
   - `email`, `full_name`, `avatar_url`, `target_role`, `username`, `phone_number`
   - Disinkronkan otomatis saat registrasi/login pertama via PostgreSQL trigger `on_auth_user_created`.
2. **`public.job_applications`** (1:N terhadap profiles)
   - `id` (UUID, PK, `gen_random_uuid()`)
   - `user_id` (UUID, FK -> `profiles.id`)
   - `company_name`, `position_title`, `location`
   - `employment_type` (Enum: `Full Time`, `Internship`, `Contract`, `Part Time`, `Freelance`)
   - `work_system` (Enum: `On-site`, `Hybrid`, `WFH`, `Remote Global`, `Fleksibel`)
   - `job_portal` (Enum: `Linked In`, `JobStreet`, `Glints`, `Kalibrr`, `Dealls`, dll)
   - `job_portal_custom`, `job_url`
   - `status` (Enum: `Applied`, `Interview`, `Offering`, `Accepted`, `Rejected`, `No Response`)
   - `applied_date` (DATE)
   - `salary_expectation`, `salary_offered` (NUMERIC)
   - `notes`, `cv_file_url`, `cv_file_name`
   - `is_favorite` (BOOLEAN)
   - `reached_stages` (TEXT[] / JSONB tracking milestone)
3. **`public.application_logs`** (1:N terhadap job_applications)
   - `id` (UUID, PK)
   - `application_id` (UUID, FK -> `job_applications.id` ON DELETE CASCADE)
   - `user_id` (UUID, FK -> `profiles.id`)
   - `stage_name` (Text: misalnya "HR Screening", "Technical Interview", "User Interview")
   - `scheduled_at` (TIMESTAMPTZ)
   - `interviewer_name`, `meeting_link`, `notes`, `result` ("Waiting", "Passed", "Failed")
4. **`public.user_resumes`** (1:1 terhadap profiles)
   - `id` (UUID, PK)
   - `user_id` (UUID, FK -> `profiles.id`, UNIQUE)
   - Data kontak, biodata, target pekerjaan
   - JSONB columns: `educations`, `experiences`, `certifications`, `technical_skills`, `soft_skills`, `selected_attachments`

### Keamanan (Row-Level Security - RLS)
- Seluruh tabel dilindungi RLS: `ALTER TABLE ... ENABLE ROW LEVEL SECURITY;`
- Kebijakan isolasi data: `auth.uid() = user_id` untuk `SELECT`, `INSERT`, `UPDATE`, `DELETE`.
- Pengguna hanya dapat membaca dan menulis data miliknya sendiri.

---

## 4. Design System: Neo-Pastel & Contrast Engine

Aplikasi memiliki dua mode tema utama:
1. **Mode Tampilan**: Dark Mode (Obsidian) vs Light Mode (Slate).
2. **Mode Aksen**: Color Mode (Neo-Pastel) vs Monochrome Mode (Grayscale).

### Token Warna Neo-Pastel (Non-Monochrome)
| Token | Hex | Target Komponen | Warna Kontras Teks / Ikon |
| :--- | :--- | :--- | :--- |
| **`pastelLime`** | `#ECFF8E` | Total Lamaran, Tombol CTA Utama, Tag Sorotan | `#0D0C0F` (Dark Obsidian) |
| **`pastelLavender`**| `#BFAEF8` | Jadwal Interview, Tombol Aksi Tambah, Filter Aktif | `#0D0C0F` (Dark Obsidian) |
| **`pastelSky`** | `#8EEFFE` | Status Menunggu Respon / Assessment, Filter Chips | `#0D0C0F` (Dark Obsidian) |
| **`pastelMint`** | `#9EF5CF` | Status Offering / Accepted, Badge Success, Gaji | `#0D0C0F` (Dark Obsidian) |
| **`pastelCoral`** | `#FFB2BA` | Status Rejected, Deadline Mendesak, Alert Bahaya | `#0D0C0F` (Dark Obsidian) |
| **`pastelAmber`** | `#FED888` | Sedang Berjalan, Bookmark Aktif | `#0D0C0F` (Dark Obsidian) |

### Surface Tokens
- **Dark Mode**: Background: `#0D0C0F` (`darkBgObsidian`), Card Surface: `#17161B`, Elevated/Sheet: `#201E27`, Border: `#292735`.
- **Light Mode**: Background: `#F8F9FB` (`lightBgSlate`), Card Surface: `#FFFFFF`, Border: `#E4E4EB`.

### Aturan Emas Kontras (Anti-Tabrakan & WCAG AAA)
> Pada seluruh permukaan pastel (`pastelLime`, `pastelLavender`, `pastelSky`, `pastelMint`, `pastelCoral`, `pastelAmber`), teks dan ikon **WAJIB menggunakan warna gelap pekat `#0D0C0F`** agar rasio kontras melebihi **12:1** (WCAG AAA). Dilarang keras menggunakan teks putih di atas latar belakang pastel.

---

## 5. State Management & Offline-First Strategy

1. **State Management**:
   - `ValueNotifier` / `ValueListenableBuilder`: Digunakan untuk reaktivitas global seperti tema (`ThemeManager.notifier`, `ThemeManager.accentNotifier`) dan bahasa (`LanguageManager.notifier`).
   - `JobRepository.dataChanges`: Broadcast stream (`StreamController<void>.broadcast()`) di repository yang memancarkan sinyal setiap ada perubahan data CRUD. Screen mendengarkan stream ini untuk auto-refresh data.
   - `StatefulWidget` dengan `setState`: Digunakan untuk state lokal di setiap layar/form guna menjaga performa ringan tanpa overhead framework state yang kompleks.

2. **Offline-First Persistence (`LocalCacheService`)**:
   - Data lamaran (`job_applications`), profil, log tahapan, dan statistik disimpan sebagai JSON snapshot di `SharedPreferences`.
   - Saat aplikasi dibuka, cache ditampilkan secara instan sehingga pengguna tidak melihat layar kosong atau loading lambat saat koneksi buruk.
   - Sinkronisasi asinkron terjadi di latar belakang; jika offline, repository tetap dapat menyajikan data dari snapshot lokal.
   - Form draft protection: Input form lamaran yang belum disimpan dicadangkan ke cache draft secara berkala dengan namespace userId (`LocalCacheService.saveFormDraft`). Cache dibersihkan saat submit berhasil atau logout, serta dilindungi guard `_isSaved` agar form baru tidak memuat data lamaran sebelumnya. Pengguna juga dapat membuang draf secara manual melalui ikon tong sampah di AppBar.
   - Penghapusan Akun Aman: `deleteAccount()` memanggil PostgreSQL RPC `public.delete_current_user()` (`SECURITY DEFINER`) untuk menghapus akun secara atomik dari `auth.users` dengan cascade otomatis ke `public.profiles` dan seluruh data relasional, lengkap dengan fallback pembersihan tabel mandiri.

---

## 6. Fitur-Fitur Inti & Alur Kerja

1. **Autentikasi & Onboarding**:
   - Alur `AuthGate`: Cek onboarding -> Cek login pengguna -> MainNav atau LoginScreen.
   - Google Sign-In terintegrasi dengan Supabase GoTrue Auth. Fallback ke `MockJobRepository` jika kredensial Supabase belum dikonfigurasi di `.env`.

2. **Pelacak Lamaran (Applications Pipeline)**:
   - Tampilan List & Tab Kanban dengan pengelompokan status (`Applied`, `Interview`, `Offering`, `Accepted`, `Rejected`, `No Response`).
   - Pencarian real-time berdasarkan posisi atau perusahaan, filter portal & work system, serta filter cepat bookmark/favorit.
   - Detail lamaran: Log tahapan interview bertingkat, catatan personal, dokumen CV yang dilampirkan, riwayat status.

3. **Generator CV ATS & Surat Lamaran PDF**:
   - `cv_ats_pdf_builder.dart`: Menghasilkan berkas PDF siap cetak dengan format ATS single-column/two-column standar internasional (kontak, ringkasan, riwayat pendidikan, pengalaman kerja dengan bullet points, sertifikasi, keahlian teknis & soft skills).
   - `cover_letter_pdf_builder.dart`: Menghasilkan Surat Lamaran formal (Bahasa Indonesia & English) dengan penyesuaian dinamis nama HR/Perusahaan, posisi, dan lampiran.
   - `DocumentPreviewScreen`: Memberikan kontrol pratinjau langsung dengan fitur cetak dan ekspor berkas.

4. **Sinkronisasi Jadwal & Notifikasi**:
   - `calendar_helper.dart`: Mengonversi jadwal tahapan interview ke tautan pembuatan event Google Calendar atau kalender sistem ponsel.
   - `notification_service.dart`: Menjadwalkan pengingat push notification lokal (1 jam sebelum, 1 hari sebelum) sebelum jadwal wawancara dimulai.

5. **Job Description Parser (`job_description_parser.dart`)**:
   - Mengekstrak informasi otomatis saat pengguna menyalin teks lowongan dari portal kerja: mendeteksi nama perusahaan, posisi, sistem kerja (WFH/Hybrid/Onsite), estimasi gaji, dan persyaratan kualifikasi secara regex/NLP rule-based.

6. **HR Communication Templates**:
   - Lembar cepat berisi template komunikasi profesional yang siap disalin (*one-tap copy*):
     - Follow-up status lamaran (bahasa Indonesia & Inggris).
     - Konfirmasi kehadiran wawancara.
     - Permintaan reschedule jadwal.
     - Negosiasi penawaran gaji (*salary negotiation*).
     - Surat ucapan terima kasih pasca-interview (*thank you note*).

7. **Multi-Bahasa (Localization)**:
   - Didukung secara penuh: Indonesian (`id`), English (`en`), Japanese (`ja`), Korean (`ko`).
   - Aksesibel melalui `LanguageManager` dan `AppStrings`.

8. **In-App OTA Updates & Automated Release Delivery**:
   - `AppUpdateService`: Memeriksa ketersediaan versi rilis terbaru dari server via endpoint `version.json`. Dialog pembaruan enterprise memberikan petunjuk lokasi menu About untuk update manual sewaktu-waktu.
   - Kebijakan Pembaruan: Maksimal toleransi lag 3 versi sebelum memicu mode *force update* (wajib perbarui). Untuk lag < 3 versi, pengguna dapat memilih tunda (*snooze* per versi).
   - Unduhan Berkas APK Langsung: Download berkas APK langsung di aplikasi dengan dialog status, serta fallback otomatis membuka browser unduh eksternal.
   - Otomatisasi Rilis & Packaging: Skrip `deploy_app.ps1` (`-Bump patch|minor|major`) menaikkan versi di `pubspec.yaml`, menyelaraskan `version.json` & `public/index.html`, mengompilasi APK rilis dengan obfuscation, mengemas nama file menjadi `AppliQ-vX.X.X-release.apk`, dan mendeploy ke Firebase Hosting.

---

## 7. Panduan Perubahan Kode & Praktik Terbaik (Rules for Agents & Devs)

1. **Prinsip Kontras UI**: Selalu terapkan `#0D0C0F` untuk teks di atas background pastel token (`pastelLime`, `pastelLavender`, `pastelSky`, dsb.).
2. **Kepatuhan Anti-Slop**:
   - Hindari komponen generik tanpa fungsi jelas (misalnya dekorasi hampa, icon tanpa label fungsional, atau animasi berlebihan yang mengganggu).
   - Pertahankan identitas unik AppliQ: Maskot kucing ekspresif, kartu notched-pill, kartu metrik neo-pastel, dan tone microcopy yang ramah namun profesional.
3. **Penyimpanan State & Cache**:
   - Setiap mutasi data di repository (`create`, `update`, `delete`) wajib memanggil `notifyDataChanged()` dan memperbarui cache `LocalCacheService`.
4. **Keamanan & Secrets**:
   - Jangan pernah melakukan hardcode token Supabase service key atau API key rahasia di dalam kode dart. Gunakan `.env` atau `--dart-define`.
   - Selalu pastikan query database Supabase mengandalkan RLS dengan `auth.uid()`.

