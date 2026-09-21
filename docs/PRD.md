# Product Requirements Document (PRD): AppliQ

- Project Name: AppliQ Mobile Application
- Version: 1.0.0
- Target Platform: Mobile (Android & iOS) via Flutter
- Backend Infrastructure: Supabase (PostgreSQL, Supabase Auth, Row Level Security, Supabase Storage)
- Target Audience: Pencari kerja aktif (entry-level, professional, career switcher)

---

## 1. Executive Summary

AppliQ adalah aplikasi mobile pelacak lamaran pekerjaan (Job Application Tracker) yang membantu pencari kerja mencatat, memantau siklus rekrutmen, mengelola jadwal wawancara, serta menganalisis efektivitas kanal lowongan secara terstruktur dan real-time.

Aplikasi ini menggantikan proses pencatatan manual spreadsheet dengan antarmuka mobile yang cepat (quick-entry), sinkronisasi otomatis profil akun Google, visualisasi status yang jelas, serta isolasi data multi-user yang aman berbasis Supabase Row Level Security.

---

## 2. Business & User Objectives

### 2.1 User Objectives
- Mengurangi waktu input pencatatan lamaran kerja menjadi di bawah 30 detik per entri.
- Memberikan visibilitas status lamaran secara terpusat agar pengguna selalu siap ketika dihubungi pihak perusahaan/recruiter.
- Menyediakan riwayat catatan tahapan wawancara dan jadwal tes secara terorganisasi.
- Menyajikan ringkasan performa lamaran untuk mengukur tingkat keberhasilan di setiap portal kerja.

### 2.2 Product Success Metrics (KPIs)
- Time-to-Log: Rata-rata waktu pencatatan lamaran baru <= 30 detik.
- User Retention: Pengguna kembali memperbarui status lamaran minimal 2 kali seminggu.
- Data Integrity: 100% isolasi data antar pengguna terjamin melalui Supabase Row Level Security.
- Crash-Free Sessions: >= 99.5% stabilitas aplikasi Flutter.

---

## 3. User Personas

1. Fajar Pratama (Fresh Graduate, 23 th): Melamar secara masif di berbagai portal, membutuhkan pencatatan cepat dari smartphone dan peringatan jika lamaran sudah tidak ada kabar > 30 hari.
2. Rina Wulandari (Mid-Level Professional, 28 th): Melamar secara selektif, membutuhkan pencatatan log wawancara multi-tahap (interviewer, jadwal, feedback, catatan teknis) dan visualisasi pipeline.

---

## 4. Scope & Feature Specifications

### 4.1 Feature 1: Authentication & User Profile Sync
- Deskripsi: Pengguna masuk ke aplikasi menggunakan akun Google (Google OAuth) melalui Supabase Auth.
- Spesifikasi Fungsional:
  - Tombol Sign in with Google di layar onboarding/login.
  - Saat login berhasil, sistem secara otomatis mengekstrak metadata dari Google ID Token:
    - ID Pengguna (`auth.uid()`)
    - Alamat Email (`user.email`)
    - Nama Lengkap (`user.user_metadata['full_name']` atau `'name'`)
    - Foto Profil (`user.user_metadata['avatar_url']` atau `'picture'`)
  - Ekstraksi ini disinkronisasikan ke tabel database `public.profiles` secara otomatis via PostgreSQL Database Trigger.
  - Sesi login disimpan secara persisten di secure storage perangkat mobile (Auto-login saat aplikasi dibuka).
  - Opsi Logout yang menghapus sesi lokal dan membersihkan state aplikasi.

### 4.2 Feature 2: Job Application Management (CRUD)
- Deskripsi: Modul utama untuk mencatat dan mengelola data lamaran pekerjaan.
- Spesifikasi Form Input:
  - Company Name (Text, Mandatory): Nama perusahaan yang dilamar.
  - Position Title (Text, Mandatory): Nama posisi/jabatan.
  - Location (Text, Optional): Kota / wilayah penempatan.
  - Work System (Dropdown, Mandatory): Pilihan `On-site`, `Hybrid`, `WFH`.
  - Job Portal (Dropdown, Mandatory): Pilihan `Linked In`, `JobStreet`, `Glints`, `KitaLulus`, `Website`, `Instagram`, `Lainnya`.
  - Custom Portal Name (Text, Conditional): Muncul jika memilih opsi `Lainnya`.
  - Job Posting URL (URL, Optional): Tautan langsung ke lowongan kerja.
  - Status (Dropdown, Mandatory): Pilihan `Applied`, `Interview`, `Offering`, `Accepted`, `Rejected`, `No Response`. Default: `Applied`.
  - Applied Date (Date Picker, Mandatory): Tanggal pengiriman lamaran. Default: Hari ini.
  - Salary Expectation & Salary Offered (Numeric, Optional): Estimasi gaji yang diajukan atau ditawarkan.
  - User Personal Notes (Textarea, Optional): Catatan khusus pengguna.
- Spesifikasi Aksi:
  - Create: Menambah entri baru ke tabel `job_applications`.
  - Read: Menampilkan daftar lamaran dalam format List Card atau Kanban Column.
  - Update: Mengubah status, detail lowongan, dan catatan kapan saja.
  - Delete: Menghapus data lamaran dengan dialog konfirmasi keamanan.

### 4.3 Feature 3: Smart Dynamic Feedback Rules
- Deskripsi: Sistem secara otomatis menampilkan badge teks informatif pada kartu lamaran berdasarkan selisih tanggal dan status:
  - Status `Applied` dan tanggal lamaran = hari ini: Label "Dikirim hari ini".
  - Status `Applied` dan selisih tanggal 1-30 hari: Label "Dikirim X hari yang lalu".
  - Status `Applied` dan selisih tanggal > 30 hari: Label peringatan "Tidak ada respon > 30 hari".
  - Status `Interview` / `Offering` / `Accepted`: Label "Tahap [Status]".
  - Status `Rejected` / `No Response`: Label "Selesai / Evaluasi".

### 4.4 Feature 4: Recruitment Stage & Interview Logs
- Deskripsi: Sub-catatan untuk setiap proses wawancara atau tes teknis yang berlangsung pada suatu lamaran.
- Data Fields:
  - Stage Name (e.g. HR Interview, Technical Test, User Interview, Offering Call).
  - Scheduled Timestamp (Tanggal dan waktu pelaksanaan).
  - Interviewer / Recruiter Name (Nama kontak/pewawancara).
  - Meeting Link / Location (Tautan Google Meet/Zoom atau alamat fisik).
  - Notes & Questions (Catatan materi tes atau pertanyaan yang ditanyakan).
  - Result Status (Waiting, Passed, Failed).

### 4.5 Feature 5: Search, Filter, & Sort
- Search: Pencarian instan berbasis teks untuk Nama Perusahaan dan Posisi.
- Filter:
  - Filter berdasarkan Status (`Applied`, `Interview`, `Offering`, dll).
  - Filter berdasarkan Sistem Kerja (`On-site`, `Hybrid`, `WFH`).
  - Filter berdasarkan Job Portal.
- Sorting:
  - Tanggal lamaran terbaru (Default).
  - Tanggal lamaran terlama.
  - Urutan alfabet nama perusahaan (A-Z).

### 4.6 Feature 6: Analytics Dashboard
- Ringkasan KPI:
  - Total Lamaran Keseluruhan.
  - Jumlah Lamaran Aktif (Applied + Interview + Offering).
  - Jumlah Wawancara Mendatang.
  - Persentase Respon Positif (Interview + Offering / Total).
- Grafik dan Distribusi:
  - Distribusi Status Lamaran (Bar Chart / Donut Chart).
  - Rekapitulasi Berdasarkan Job Portal (Mengukur efektivitas sumber lowongan).
  - Rekapitulasi Berdasarkan Sistem Kerja (On-site vs Hybrid vs WFH).

---

## 5. Non-Functional Requirements

- Keamanan:
  - Seluruh komunikasi data menggunakan HTTPS/TLS enkripsi standar.
  - Otorisasi data murni dikontrol oleh PostgreSQL Row Level Security (RLS) di Supabase. Tidak ada pengguna yang dapat mengakses data pengguna lain meskipun mengetahui ID record.
- Performa:
  - Waktu muat daftar lamaran <= 1 detik pada koneksi internet standar (4G/WiFi).
  - Penggunaan indexing pada kolom `user_id`, `status`, dan `applied_date`.
- Offline Capability (Roadmap v1.1):
  - Local caching data menggunakan SQLite/Hive di aplikasi Flutter untuk membaca data saat offline.

---

## 6. Release & Milestone Plan

- Milestone 1: Dokumentasi Arsitektur, Skema Database, dan Konfigurasi Supabase Auth.
- Milestone 2: Setup Project Flutter, Design Tokens, Routing, dan Integrasi Supabase SDK.
- Milestone 3: Implementasi Autentikasi Google dan Sinkronisasi Profil Pengguna.
- Milestone 4: Implementasi Modul CRUD Job Applications dan Filter/Search.
- Milestone 5: Implementasi Sub-Modul Interview Stage Logs.
- Milestone 6: Implementasi Dashboard Analitik dan Agregasi Data.
- Milestone 7: Pengujian, Optimasi Performa, dan Build Rilis.
