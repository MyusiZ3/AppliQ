# Software Requirements Specification (SRS): AppliQ

- Project Name: AppliQ Mobile Application
- Document Version: 1.0.0
- Development Stack: Flutter (Dart), Supabase (PostgreSQL, GoTrue Auth, PostgREST, Realtime, Storage)

---

## 1. Introduction

### 1.1 Purpose
Dokumen Spesifikasi Kebutuhan Perangkat Lunak (Software Requirements Specification - SRS) ini mendefinisikan seluruh kebutuhan fungsional, non-fungsional, arsitektur sistem, antarmuka eksternal, dan batasan teknis untuk pembangunan aplikasi mobile pelacak lamaran kerja **AppliQ**.

### 1.2 Scope of Product
AppliQ adalah aplikasi mobile berbasis Flutter yang terhubung dengan backend BaaS (Backend-as-a-Service) Supabase. Aplikasi ini mengelola siklus hidup lamaran pekerjaan pengguna secara aman, memproses otentikasi OAuth Google, menyajikan analisis data, serta mencatat tahapan rekrutmen.

### 1.3 Definitions and Acronyms
- BaaS: Backend as a Service
- RLS: Row Level Security (Mekanisme keamanan baris PostgreSQL)
- JWT: JSON Web Token (Token otorisasi pengguna)
- OAuth 2.0: Open Authorization Protocol
- SDK: Software Development Kit
- DDL: Data Definition Language
- RPC: Remote Procedure Call (Fungsi SQL di PostgreSQL yang dapat dipanggil via API)

---

## 2. System Architecture

### 2.1 High-Level Architecture Diagram

```
+------------------------------------------------------------------+
|                   Flutter Mobile Application                     |
|                                                                  |
|   +----------------------------------------------------------+   |
|   |                   Presentation Layer                     |   |
|   |   (Widgets, Screens, Theme Tokens, State Notifiers)      |   |
|   +----------------------------+-----------------------------+   |
|                                |                                 |
|   +----------------------------v-----------------------------+   |
|   |                    Domain / BLoC Layer                   |   |
|   |   (Use Cases, Business Rules, State Management)          |   |
|   +----------------------------+-----------------------------+   |
|                                |                                 |
|   +----------------------------v-----------------------------+   |
|   |                     Data Layer                           |   |
|   |   (Repositories, DTO Models, Local Cache, Supabase SDK)  |   |
|   +----------------------------+-----------------------------+   |
+--------------------------------|---------------------------------+
                                 | HTTPS / WSS
                                 v
+------------------------------------------------------------------+
|                     Supabase Cloud Backend                       |
|                                                                  |
|   +----------------------------------------------------------+   |
|   |                      GoTrue Auth                         |   |
|   |   (Google OAuth 2.0 Provider, JWT Token Generator)       |   |
|   +----------------------------+-----------------------------+   |
|                                |                                 |
|   +----------------------------v-----------------------------+   |
|   |                 PostgREST API Engine                     |   |
|   |   (Auto-generated REST API from PostgreSQL Schema)       |   |
|   +----------------------------+-----------------------------+   |
|                                |                                 |
|   +----------------------------v-----------------------------+   |
|   |              PostgreSQL Relational Database              |   |
|   |   (Tables, Enums, Triggers, RLS Policies, RPC Functions) |   |
|   +----------------------------------------------------------+   |
+------------------------------------------------------------------+
```

### 2.2 Frontend Architecture (Flutter)
- Design Pattern: Feature-First Clean Architecture
- State Management: Riverpod atau Flutter BLoC
- HTTP / BaaS Client: `supabase_flutter` SDK
- Local Secure Storage: `flutter_secure_storage` untuk menyimpan access token dan refresh token

---

## 3. Specific Functional Requirements

### 3.1 Module 1: Authentication & Account Management

| Requirement ID | Description | Acceptance Criteria |
|---|---|---|
| **FR-AUTH-01** | Login dengan Akun Google | Sistem menyediakan opsi login sekali klik menggunakan Google Sign-In via Supabase Auth. |
| **FR-AUTH-02** | Ekstraksi Data Profil | Sistem mengekstrak `email`, `full_name`, dan `avatar_url` dari metadata Google setelah autentikasi sukses. |
| **FR-AUTH-03** | Sinkronisasi Profil ke Database | Database PostgreSQL secara otomatis membuat record di tabel `public.profiles` saat user baru terdaftar melalui trigger. |
| **FR-AUTH-04** | Manajemen Sesi | Sesi pengguna tetap aktif (persistent session) di perangkat hingga pengguna menekan tombol Logout atau token kadaluwarsa. |
| **FR-AUTH-05** | Logout Akun | Menghapus token autentikasi dari secure storage dan mengarahkan pengguna kembali ke Login Screen. |

### 3.2 Module 2: Job Application Management (Core CRUD)

| Requirement ID | Description | Acceptance Criteria |
|---|---|---|
| **FR-APP-01** | Tambah Lamaran Baru | Pengguna dapat menyimpan entri lamaran baru dengan validasi field wajib (Perusahaan, Posisi, Sistem Kerja, Job Portal, Status, Tanggal). |
| **FR-APP-02** | Tampilkan Daftar Lamaran | Sistem menampilkan daftar seluruh lamaran milik pengguna aktif yang diurutkan berdasarkan tanggal terbaru. |
| **FR-APP-03** | Detail Lamaran | Pengguna dapat membuka kartu lamaran untuk melihat seluruh rincian atribut, catatan, dan riwayat tahapan. |
| **FR-APP-04** | Perbarui Data Lamaran | Pengguna dapat mengubah status lamaran, catatan, tautan pekerjaan, atau rincian lainnya kapan saja. |
| **FR-APP-05** | Hapus Lamaran | Pengguna dapat menghapus record lamaran dengan konfirmasi modal. Penghapusan data akan menghapus sub-log terkait (CASCADE). |
| **FR-APP-06** | Status Feedback Otomatis | Sistem menghitung dan menampilkan teks status pintar (misal: "Dikirim hari ini", "Dikirim X hari yang lalu", "Tidak ada respon > 30 hari") secara tepat. |

### 3.3 Module 3: Interview and Recruitment Stage Logs

| Requirement ID | Description | Acceptance Criteria |
|---|---|---|
| **FR-LOG-01** | Tambah Tahap Rekrutmen | Pengguna dapat menambahkan jadwal wawancara/tes (Nama Tahap, Tanggal & Jam, Pewawancara, Catatan, Tautan Meeting) pada lamaran tertentu. |
| **FR-LOG-02** | Tampilkan Riwayat Tahapan | Sistem menyajikan seluruh tahapan lamaran secara kronologis (timeline view). |
| **FR-LOG-03** | Update Status Tahapan | Pengguna dapat memperbarui hasil tahap wawancara (Waiting, Passed, Failed). |

### 3.4 Module 4: Search, Filtering, and Sorting

| Requirement ID | Description | Acceptance Criteria |
|---|---|---|
| **FR-SRCH-01** | Pencarian Instan | Pengguna dapat mencari lamaran berdasarkan substring nama perusahaan atau nama posisi secara real-time. |
| **FR-FLTR-01** | Filter Berdasarkan Status | Pengguna dapat menyaring data berdasarkan satu atau lebih status (`Applied`, `Interview`, `Offering`, `Accepted`, `Rejected`, `No Response`). |
| **FR-FLTR-02** | Filter Sistem Kerja | Pengguna dapat menyaring data berdasarkan model kerja (`On-site`, `Hybrid`, `WFH`). |
| **FR-SORT-01** | Pengurutan Data | Sistem menyediakan opsi pengurutan: Tanggal Terbaru, Tanggal Terlama, Nama Perusahaan (A-Z). |

### 3.5 Module 5: Analytics Dashboard

| Requirement ID | Description | Acceptance Criteria |
|---|---|---|
| **FR-DASH-01** | Agregasi KPI Utama | Sistem menampilkan metrik total lamaran, lamaran aktif, total interview, dan offering. |
| **FR-DASH-02** | Grafik Distribusi Status | Sistem menyajikan grafik proporsi status lamaran kerja pengguna. |
| **FR-DASH-03** | Analisis Portal Lowongan | Sistem menyajikan rekapitulasi jumlah lamaran per portal (LinkedIn, JobStreet, Glints, dll.) untuk melihat portal paling aktif. |
| **FR-DASH-04** | Eksekusi via RPC | Seluruh agregasi statistik dieksekusi di database level melalui Supabase Stored Procedure (`get_job_tracker_stats`) untuk efisiensi bandwidth mobile. |

---

## 4. Non-Functional Requirements

### 4.1 Security & Data Privacy (NFR-SEC)
- NFR-SEC-01: Seluruh tabel PostgreSQL wajib mengaktifkan Row Level Security (RLS).
- NFR-SEC-02: Kebijakan RLS memastikan query hanya dapat memproses record dengan kondisi `auth.uid() = user_id`.
- NFR-SEC-03: Kunci API rahasia (Service Role Key) dilarang keras ditanam di kode aplikasi mobile; aplikasi mobile hanya menggunakan `Anon Key` yang diproteksi RLS.
- NFR-SEC-04: Komunikasi client-server wajib menggunakan TLS 1.3 / HTTPS.

### 4.2 Performance (NFR-PERF)
- NFR-PERF-01: Waktu inisialisasi aplikasi (Cold Start) tidak boleh melebihi 2.0 detik pada perangkat mid-range.
- NFR-PERF-02: Waktu respon query daftar lamaran pertama kali <= 800ms pada jaringan 4G.
- NFR-PERF-03: Scroll list lamaran berjalan mulus pada 60 FPS tanpa jank.

### 4.3 Reliability & Availability (NFR-REL)
- NFR-REL-01: Penanganan error terstruktur saat perangkat kehilangan koneksi internet (Offline Banner & Graceful Error Messages).
- NFR-REL-02: Form input memiliki validasi lokal sebelum request dikirim ke backend.

### 4.4 Usability & UI Standards (NFR-UI)
- NFR-UI-01: Desain antarmuka mematuhi standar Human Interface Guidelines (iOS) dan Material Design 3 (Android).
- NFR-UI-02: Menghindari elemen visual tidak fungsional (anti-slop standard), menerapkan rasio kontras warna minimal WCAG 2.1 AA (4.5:1 untuk body text).

---

## 5. External Interface Requirements

### 5.1 Google Identity Services (OAuth 2.0)
- Provider: Google Cloud Console OAuth 2.0 Client ID (Web Client & Android SHA-1 Client).
- Redirect URI: `https://<supabase-project-id>.supabase.co/auth/v1/callback`
- Scope: `openid`, `email`, `profile`

### 5.2 Supabase PostgREST & WebSocket
- Base URL: `https://<supabase-project-id>.supabase.co/rest/v1`
- Protocol: HTTPS untuk REST API, WSS untuk Supabase Realtime Channels.
- Header Autentikasi:
  - `apikey: <SUPABASE_ANON_KEY>`
  - `Authorization: Bearer <USER_ACCESS_TOKEN>`

---

## 6. Error Handling & Edge Cases

| Skenario Kegagalan | Respon Sistem |
|---|---|
| Jaringan internet terputus saat menyimpan lamaran | Tampilkan snackbar peringatan kesalahan koneksi, pertahankan data pada form agar pengguna tidak perlu mengetik ulang. |
| Token autentikasi kadaluwarsa (Expired JWT) | `supabase_flutter` secara otomatis memperbarui token via Refresh Token. Jika gagal, arahkan user ke layar Login dengan pesan informatif. |
| Pengguna memilih Job Portal 'Lainnya' | Input text `job_portal_custom` wajib diisi sebelum form dapat disubmit. |
| Penghapusan data lamaran yang memiliki sub-log | Konfirmasi modal eksplisit: "Menghapus lamaran ini juga akan menghapus seluruh catatan wawancara terkait". Operasi dieksekusi via `ON DELETE CASCADE`. |
