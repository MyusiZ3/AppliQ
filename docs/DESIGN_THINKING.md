# Dokumen Design Thinking: AppliQ

Dokumen ini memuat pendekatan Design Thinking dalam perancangan produk AppliQ, mencakup tahap Empathize, Define, Ideate, Prototype Flow, dan pedoman sistem desain antarmuka.

---

## 1. Empathize

### 1.1 Latar Belakang Masalah
Pencari kerja aktif di Indonesia rata-rata mengirimkan 10 hingga 50 lamaran per bulan melalui berbagai kanal digital (LinkedIn, JobStreet, Glints, KitaLulus, portal karier internal, dsb). Selama proses ini, kendala utama yang dialami adalah:
- Terputusnya konteks tindak lanjut (follow-up) karena pencatatan tercecer di catatan manual atau spreadsheet yang sulit diakses dari perangkat mobile.
- Sulit membedakan lowongan yang masih aktif menunggu respon dengan lowongan yang sudah kadaluwarsa (> 30 hari tanpa kabar).
- Ketiadaan pencatatan historis jadwal tes dan wawancara yang terstruktur per lowongan kerja.
- Beban kognitif saat harus membuka laptop hanya untuk memperbarui status lamaran singkat.

### 1.2 User Persona

#### Persona 1: Job Seeker Aktif (Entry-Level / Fresh Graduate)
- Nama: Fajar Pratama (23 tahun)
- Status: Lulusan baru, mencari posisi Software Engineer / QA
- Perilaku:
  - Mengirim lamaran setiap hari secara agresif melalui mobile browser dan aplikasi job portal.
  - Sering lupa posisi apa saja yang dilamar di perusahaan tertentu saat dihubungi via WhatsApp / Telepon oleh recruiter.
- Kebutuhan:
  - Akses cepat untuk mencatat lamaran langsung dari smartphone dalam waktu kurang dari 30 detik.
  - Notifikasi otomatis mengenai status lamaran yang belum ada tindak lanjut.
  - Ringkasan statistik lamaran untuk mengevaluasi efektivitas resume.

#### Persona 2: Career Switcher / Mid-Level Professional
- Nama: Rina Wulandari (28 tahun)
- Status: Sedang bekerja, mencari peluang baru secara terukur
- Perilaku:
  - Selektif dalam melamar (1-3 lamaran berkualitas per minggu).
  - Melewati proses rekrutmen multi-tahap (HR interview, user interview, technical test, salary negotiation).
- Kebutuhan:
  - Pencatatan log wawancara terperinci (nama pewawancara, tanggal/waktu, catatan pertanyaan, tautan meeting).
  - Visualisasi pipeline lamaran kerja untuk melihat posisi mana yang mendekati tahap offering.
  - Keamanan privasi data agar catatan lamaran tidak dapat diakses pihak lain.

---

## 2. Define

### 2.1 Problem Statements
1. Pencari kerja kehilangan kendali atas status lamaran mereka karena ketiadaan alat pelacak yang cepat, terstruktur, dan berorientasi mobile.
2. Pengguna spreadsheet mengalami friksi input data di layar sentuh ponsel, yang menyebabkan pencatatan berhenti di tengah jalan.
3. Ketiadaan rekapitulasi data tahapan rekrutmen menyulitkan pencari kerja dalam mempersiapkan diri menghadapi wawancara lanjutan.

### 2.2 Point of View (POV)
Pencari kerja aktif membutuhkan cara praktis dan instan untuk mengorganisasi setiap siklus lamaran kerja langsung dari perangkat mobile mereka, agar mereka dapat merespons recruiter secara profesional, tepat waktu, dan memiliki visibilitas penuh terhadap proses pencarian kerja.

### 2.3 How Might We (HMW)
- HMW 1: Bagaimana kita mempermudah pencatatan lamaran baru di perangkat mobile dalam waktu kurang dari 30 detik?
- HMW 2: Bagaimana kita memberikan visibilitas status lamaran secara real-time tanpa membuat pengguna kewalahan dengan data kompleks?
- HMW 3: Bagaimana kita membantu pengguna mengingat dan mempersiapkan jadwal wawancara secara terintegrasi?

---

## 3. Ideate

### 3.1 Pemetaan Fitur & Nilai Produk (Value Proposition)
- Autentikasi Cepat: Integrasi Google Sign-In langsung via Supabase Auth tanpa registrasi manual yang rumit.
- Quick Entry Form: Form pencatatan ringkas dengan nilai default cerdas (tanggal hari ini, dropdown portal kerja populer, dan sistem kerja).
- Status Tracking Dinamis: Label visual status dengan penanda durasi otomatis (misal: "Dikirim 12 hari yang lalu" atau "Perlu follow-up").
- Recruitment Stage Log: Sub-pencatatan untuk jadwal wawancara, nama recruiter, dan catatan teknis per lamaran.
- Dashboard Analitik Ringkas: Visualisasi total lamaran, persentase konversi per portal kerja, dan distribusi sistem kerja (On-site, Hybrid, WFH).

### 3.2 Prioritas Fitur (MoSCoW Matrix)
- Must Have:
  - Autentikasi Google OAuth via Supabase.
  - CRUD lamaran kerja (Perusahaan, Posisi, Lokasi, Sistem Kerja, Portal, Status, Tanggal, Link, Catatan).
  - Filter dan pencarian data berdasarkan status dan kata kunci.
  - Dashboard statistik status lamaran.
- Should Have:
  - Pencatatan tahapan rekrutmen / interview logs.
  - Penanda durasi otomatis tanpa respon (> 30 hari).
  - Tampilan visual berbentuk List dan Kanban Board.
- Could Have:
  - Sinkronisasi jadwal interview ke kalender perangkat.
  - Lampiran dokumen resume (PDF) per lamaran via Supabase Storage.
- Won't Have (v1):
  - Scraping otomatis dari email lowongan.
  - Fitur jejaring sosial antar pelamar.

---

## 4. Prototype & Application Flow

### 4.1 Alur Pengguna Utama (User Journey Flow)

```
[Mulai] 
   │
   ▼
[Splash Screen] ──> Cek Sesi Supabase?
   │                      │
   ├─ Sesi Ada ───────────┼──────────────┐
   │                      │              │
   ▼ (Belum Ada)          │              │
[Login Screen]            │              │
   │                      │              │
   ▼                      │              │
[Sign in with Google]     │              │
   │                      │              │
   ▼                      │              │
[Sync Profile Data] ──────┘              │
   │                                     │
   ▼                                     ▼
[Main Screen / Dashboard & Application List]
   │
   ├──> [Floating Action Button: Tambah Lamaran]
   │       │
   │       ▼
   │    [Form Input Lamaran] ──> Simpan ──> Refresh List & Stats
   │
   ├──> [Pilih Kartu Lamaran]
   │       │
   │       ▼
   │    [Detail Lamaran]
   │       ├──> [Edit Data / Ubah Status]
   │       ├──> [Tambah / Edit Interview Stage Log]
   │       └──> [Hapus Lamaran]
   │
   ├──> [Filter & Search Tab]
   │       └──> Filter by Status (Applied, Interview, Offering, dsb.)
   │
   └──> [Profile & Analytics Screen]
           ├──> Visualisasi Statistik Loker & Portal
           └──> Logout
```

### 4.2 Struktur Navigasi Aplikasi
1. Tab 1: Applications (Daftar lamaran, pencarian, filter status, beralih antara List View dan Kanban View).
2. Tab 2: Dashboard (Metrik konversi, ringkasan per status, performa portal kerja).
3. Tab 3: Schedule (Jadwal interview dan tes yang akan datang).
4. Tab 4: Profile (Informasi akun Google, preferensi target role, logout).

---

## 5. UI Design System Guidelines (Anti-Slop Standard)

Untuk menghindari tampilan generic AI (seperti gradien ungu-biru mengambang, teks tidak terbaca, dan dekorasi tanpa fungsi), AppliQ menerapkan prinsip desain fungsional, bersih, dan kontras tinggi.

### 5.1 Filosofi Desain
- Functional Minimalism: Setiap elemen UI memiliki tujuan informasional yang jelas.
- High Information Density: Tata letak kartu informasi padat namun terstruktur rapi, memaksimalkan penggunaan layar mobile.
- Clear Visual Hierarchy: Tipografi berjenjang tegas, penggunaan warna hanya sebagai pembeda status fungsional.

### 5.2 Skema Warna (Neutral & Semantic Tokens)
- Base Background: `#0F172A` (Dark Slate / Charcoal) untuk Dark Mode, `#F8FAFC` (Off-White / Crisp Slate) untuk Light Mode.
- Surface / Cards: `#1E293B` (Dark Mode Surface), `#FFFFFF` (Light Mode Surface).
- Borders & Dividers: `#334155` (Dark), `#E2E8F0` (Light).
- Primary Text: `#F8FAFC` (Dark), `#0F172A` (Light).
- Secondary Text: `#94A3B8` (Dark), `#64748B` (Light).
- Accent / Brand: `#2563EB` (Royal Blue) atau `#0D9488` (Deep Teal) - Flat, solid, tanpa gradien acak.

### 5.3 Semantic Status Colors (Flat & Readable)
- Applied: `#64748B` (Neutral Slate)
- Interview: `#D97706` (Warm Amber / Ochre)
- Offering: `#059669` (Forest Green)
- Accepted: `#16A34A` (Emerald)
- Rejected: `#DC2626` (Muted Crimson)
- No Response: `#475569` (Dark Slate Gray)

### 5.4 Tipografi
- Font Family: Inter atau Plus Jakarta Sans.
- Skala Ukuran:
  - Header 1 (Title): 20px, Bold
  - Header 2 (Section): 16px, Semi-Bold
  - Body Regular: 14px, Regular
  - Body Small / Metadata: 12px, Medium
  - Badge / Status: 11px, Semi-Bold (Uppercase, Tracking 0.5px)
