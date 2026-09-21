# AppliQ - Smart Job Application Tracker Mobile App

AppliQ adalah aplikasi mobile pelacak lamaran pekerjaan (Job Application Tracker) yang dirancang untuk membantu pencari kerja mengorganisasi, memantau siklus rekrutmen, dan menganalisis efektivitas kanal lowongan secara terstruktur dan real-time.

Aplikasi dibangun menggunakan **Flutter** untuk antarmuka mobile dan **Supabase** (PostgreSQL, GoTrue Auth, Row Level Security) sebagai backend infrastructure.

---

## 1. Dokumentasi Teknis dan Persiapan

Seluruh dokumen spesifikasi, perancangan, dan arsitektur tersimpan rapi dalam direktori `docs/`:

1. [docs/DESIGN_THINKING.md](file:///c:/Users/muham/Documents/Github/AppliQ/docs/DESIGN_THINKING.md)
   Mencakup perancangan User Persona (Fresh Graduate & Mid-Level Professional), Problem Statements, Empathy Map, User Journey Flow, dan Pedoman Sistem Desain Antarmuka Fungsional (Anti-Slop Standard).

2. [docs/PRD.md](file:///c:/Users/muham/Documents/Github/AppliQ/docs/PRD.md)
   Product Requirements Document yang merinci tujuan produk, spesifikasi fitur (Google Auth + Auto Profile Sync, CRUD Lamaran, Status Rules, Stage Logs, Search/Filter, Dashboard Analitik), metrik keberhasilan, dan rencana rilis.

3. [docs/SRS.md](file:///c:/Users/muham/Documents/Github/AppliQ/docs/SRS.md)
   Software Requirements Specification yang mendefinisikan arsitektur sistem (Flutter Clean Architecture + Supabase BaaS), daftar kebutuhan fungsional (FR-01 s/d FR-18), kebutuhan non-fungsional, integrasi antarmuka eksternal, dan penanganan kesalahan.

4. [docs/DATABASE_DESIGN.md](file:///c:/Users/muham/Documents/Github/AppliQ/docs/DATABASE_DESIGN.md)
   Rancangan skema database PostgreSQL lengkap siap pakai untuk Supabase: DDL script, Enum types, Auto-sync Trigger akun Google ke tabel `profiles`, Row Level Security (RLS) policies, Indexing, dan Stored Procedure (`get_job_tracker_stats`).

5. [docs/SPREADSHEET_ANALYSIS.md](file:///c:/Users/muham/Documents/Github/AppliQ/docs/SPREADSHEET_ANALYSIS.md)
   Dokumentasi hasil bedah data struktur kolom dan logika bisnis dari file master spreadsheet referensi awal.

---

## 2. Tech Stack

- Mobile Frontend: Flutter (Dart)
- Backend & Auth: Supabase (PostgreSQL 15+, GoTrue OAuth 2.0 Google Provider, PostgREST)
- Database Security: PostgreSQL Row Level Security (RLS)
- Cloud Storage: Supabase Storage (Attachment PDF Resume)

---

## 3. Struktur Direktori Proyek

```
AppliQ/
├── docs/
│   ├── DESIGN_THINKING.md
│   ├── PRD.md
│   ├── SRS.md
│   ├── DATABASE_DESIGN.md
│   └── SPREADSHEET_ANALYSIS.md
├── [FREE] Job Application Tracker by @persistancedee.xlsx
├── .gitignore
└── README.md
```

---

## 4. Lisensi

MIT License
