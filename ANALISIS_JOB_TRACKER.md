# 📊 Analisis Spreadsheet Job Application Tracker & Desain Integrasi Supabase

Dokumen ini berisi hasil bedah dan analisis mendalam dari file template spreadsheet **`[FREE] Job Application Tracker by @persistancedee.xlsx`**, serta rancangan arsitektur dan skema database untuk diimplementasikan ke dalam aplikasi mobile (**AppliQ**) berbasis **Supabase**.

---

## 1. Ringkasan & Struktur Spreadsheet

File spreadsheet terdiri dari 3 sheet utama:
1. **`Read Me!`**: Panduan penggunaan, alur pengisian, dan info pembuat template.
2. **`Example`**: Contoh data riil pelacakan lamaran kerja (9 sampel baris data) lengkap dengan formula dashboard.
3. **`Template`**: Master template kosong siap pakai yang memiliki validasi data dan formula otomatis.

---

## 2. Struktur Data & Kolom Input Lamaran

Berdasarkan sheet `Example` dan `Template`, berikut adalah seluruh kolom data yang digunakan:

| No | Kolom Spreadsheet | Tipe Data | Keterangan / Pilihan Nilai | Validasi Input |
|---|---|---|---|---|
| 1 | **No** | Integer | Nomor urut otomatis (formula urut) | Auto-generated |
| 2 | **Applied Date** | Date | Tanggal pengiriman lamaran | Format Tanggal Valid (`YYYY-MM-DD`) |
| 3 | **Company** | Text | Nama perusahaan yang dilamar | Wajib diisi (Mandatory) |
| 4 | **Position** | Text | Posisi / nama role pekerjaan | Wajib diisi (Mandatory) |
| 5 | **Location** | Text | Kota/lokasi kerja (e.g. *Jakarta, Surabaya, London*) | Opsional / Teks bebas |
| 6 | **Sistem Kerja** | Enum / Dropdown | Model kerja | **Pilihan:**<br>• `On-site`<br>• `Hybrid`<br>• `WFH` |
| 7 | **Job Portal** | Enum / Dropdown | Saluran / sumber informasi lowongan | **Pilihan:**<br>• `Linked In`<br>• `JobStreet`<br>• `Glints`<br>• `KitaLulus`<br>• `Website`<br>• `Instagram`<br>• `Lainnya` |
| 8 | **Link (Opsional)** | URL / Text | Link URL postingan lowongan kerja | URL format valid |
| 9 | **Status** | Enum / Dropdown | Tahapan / status progress lamaran saat ini | **Pilihan:**<br>• `Applied`<br>• `Interview`<br>• `No Response`<br>• `Offering`<br>• `Accepted`<br>• `Rejected` |
| 10 | **Note** | Text / Computed | Catatan status otomatis & catatan personal | Formula pintar berbasis waktu & status |

---

## 3. Logika Bisnis & Formula Pintar (Dynamic Rules)

Di dalam spreadsheet terdapat formula dinamis pada kolom **Note** yang memberikan feedback otomatis kepada pencari kerja:

```excel
=IF(AND(Status="Applied", Today - Applied_Date = 0), "Dikirim hari ini",
 IF(AND(Status="Applied", Today - Applied_Date <= 30), "Dikirim " & (Today - Applied_Date) & " hari yang lalu",
 IF(AND(Status="Applied", Today - Applied_Date > 30), "Tidak ada respon lebih dari 30 hari",
 IF(OR(Status="Rejected", Status="No Response"), "Semangat, masih ada kesempatan lainnya",
 "Kamu sedang dalam tahap " & Status))))
```

### Aturan Feedback Status:
- 🟢 **Applied (Hari ini)**: `"Dikirim hari ini"`
- 🟡 **Applied (1–30 hari)**: `"Dikirim X hari yang lalu"` (indikator menunggu respon)
- ⏱️ **Applied (> 30 hari)**: `"Tidak ada respon lebih dari 30 hari"` (otomatis kandidat untuk diubah ke `No Response` / follow up)
- 💬 **Interview / Offering / Accepted**: `"Kamu sedang dalam tahap [Status]"` (status aktif & progresif)
- 💜 **Rejected / No Response**: `"Semangat, masih ada kesempatan lainnya"` (pesan motivasi psikologis)

---

## 4. Komponen Dashboard & Metrik Visual (KPI)

Dashboard pada bagian atas spreadsheet menghitung metrik berikut secara real-time:

1. **Statistik Utama**:
   - `Today's Date`: Tanggal aktif saat ini.
   - `Total Applications`: Total keseluruhan lamaran yang sudah dikirim (`COUNTIF(Status, "<>")`).
   - `Active Applications`: Jumlah lamaran yang masih berjalan (`Applied`, `Interview`, `Offering`).
2. **Breakdown Status Lamaran**:
   - `Applied` count
   - `Interview` count
   - `Offering` count
   - `Accepted` count
   - `Rejected` count
   - `No Response` count
3. **Analisis Visual & Distribusi**:
   - **Chart Status**: Grafik batang/donat proporsi status lamaran.
   - **Distribusi Sistem Kerja**: Persentase On-site vs Hybrid vs WFH.
   - **Distribusi Job Portal**: Portal lowongan yang paling sering digunakan atau paling banyak menghasilkan panggilan interview.

---

## 5. Rancangan Arsitektur Database Supabase (PostgreSQL)

Untuk aplikasi mobile (**AppliQ**), skema dirancang multi-user dengan keamanan **Row Level Security (RLS)** bawaan Supabase:

```
                  ┌──────────────────────────────┐
                  │      auth.users (Supabase)   │
                  └──────────────┬───────────────┘
                                 │ 1:1
                  ┌──────────────▼───────────────┐
                  │           profiles           │
                  └──────────────┬───────────────┘
                                 │ 1:N
                  ┌──────────────▼───────────────┐
                  │       job_applications       │
                  └──────────────┬───────────────┘
                                 │ 1:N
                  ┌──────────────▼───────────────┐
                  │      application_logs        │
                  │   (Riwayat Tahap/Interview)  │
                  └──────────────────────────────┘
```

### A. Tipe ENUM PostgreSQL

```sql
-- Enum Sistem Kerja
CREATE TYPE work_system_type AS ENUM ('On-site', 'Hybrid', 'WFH');

-- Enum Status Lamaran
CREATE TYPE application_status_type AS ENUM (
  'Applied',
  'Interview',
  'Offering',
  'Accepted',
  'Rejected',
  'No Response'
);

-- Enum Default Job Portal (Pengguna juga bisa input custom portal)
CREATE TYPE job_portal_type AS ENUM (
  'Linked In',
  'JobStreet',
  'Glints',
  'KitaLulus',
  'Website',
  'Instagram',
  'Lainnya'
);
```

---

### B. Skema Tabel Supabase

#### 1. Tabel `profiles`
Menyimpan profil pengguna yang terhubung dengan `auth.users`.
```sql
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  target_role TEXT,
  created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);
```

#### 2. Tabel `job_applications` (Inti Pelacakan)
```sql
CREATE TABLE public.job_applications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  company_name TEXT NOT NULL,
  position_title TEXT NOT NULL,
  location TEXT,
  work_system work_system_type NOT NULL DEFAULT 'On-site',
  job_portal job_portal_type NOT NULL DEFAULT 'Linked In',
  job_portal_custom TEXT, -- Jika memilih 'Lainnya'
  job_url TEXT,
  status application_status_type NOT NULL DEFAULT 'Applied',
  applied_date DATE NOT NULL DEFAULT CURRENT_DATE,
  salary_expectation NUMERIC(15, 2), -- Fitur tambahan untuk mobile app
  salary_offered NUMERIC(15, 2),
  notes TEXT, -- Catatan pribadi user
  is_favorite BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Indexing untuk kecepatan filter & query dashboard
CREATE INDEX idx_job_applications_user_id ON public.job_applications(user_id);
CREATE INDEX idx_job_applications_status ON public.job_applications(user_id, status);
CREATE INDEX idx_job_applications_applied_date ON public.job_applications(user_id, applied_date DESC);
```

#### 3. Tabel `application_logs` *(Fitur Tambahan Nilai Lebih)*
Menyimpan riwayat tahapan interview, kontak HR, jadwal tes, dan follow-up.
```sql
CREATE TABLE public.application_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  application_id UUID NOT NULL REFERENCES public.job_applications(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  stage_name TEXT NOT NULL, -- e.g. "HR Interview", "Technical Test", "User Interview"
  scheduled_at TIMESTAMPTZ,
  interviewer_name TEXT,
  notes TEXT,
  result TEXT, -- e.g. "Passed", "Waiting"
  created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);
```

---

### C. Row Level Security (RLS) Policies

Menjamin bahwa setiap pengguna hanya dapat membaca, menambah, mengubah, dan menghapus datanya sendiri.

```sql
-- Enable RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.job_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.application_logs ENABLE ROW LEVEL SECURITY;

-- Policies untuk Profiles
CREATE POLICY "Users can view their own profile"
  ON public.profiles FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
  ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- Policies untuk Job Applications
CREATE POLICY "Users can view own applications"
  ON public.job_applications FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own applications"
  ON public.job_applications FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own applications"
  ON public.job_applications FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own applications"
  ON public.job_applications FOR DELETE USING (auth.uid() = user_id);

-- Policies untuk Application Logs
CREATE POLICY "Users can manage own logs"
  ON public.application_logs FOR ALL USING (auth.uid() = user_id);
```

---

### D. Supabase RPC / Stored Function (Statistik Dashboard)

Fungsi database performa tinggi untuk langsung mengambil ringkasan dashboard dalam satu panggilan API:

```sql
CREATE OR REPLACE FUNCTION get_job_tracker_stats(p_user_id UUID)
RETURNS JSON AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_build_object(
    'total_applications', COUNT(*),
    'applied_count', COUNT(*) FILTER (WHERE status = 'Applied'),
    'interview_count', COUNT(*) FILTER (WHERE status = 'Interview'),
    'offering_count', COUNT(*) FILTER (WHERE status = 'Offering'),
    'accepted_count', COUNT(*) FILTER (WHERE status = 'Accepted'),
    'rejected_count', COUNT(*) FILTER (WHERE status = 'Rejected'),
    'no_response_count', COUNT(*) FILTER (WHERE status = 'No Response'),
    'by_work_system', (
      SELECT json_object_agg(work_system, count)
      FROM (
        SELECT work_system, COUNT(*) as count 
        FROM public.job_applications 
        WHERE user_id = p_user_id 
        GROUP BY work_system
      ) ws
    ),
    'by_portal', (
      SELECT json_object_agg(job_portal, count)
      FROM (
        SELECT job_portal, COUNT(*) as count 
        FROM public.job_applications 
        WHERE user_id = p_user_id 
        GROUP BY job_portal
      ) jp
    )
  ) INTO result
  FROM public.job_applications
  WHERE user_id = p_user_id;

  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

---

## 6. Rekomendasi Fitur Unggulan untuk Mobile App (AppliQ)

Dengan bertransformasi dari Spreadsheet ke Aplikasi Mobile, kita dapat menambahkan kapabilitas modern:

1. 📱 **Kanban Board & List View**: Tampilan kartu lamaran bergaya drag-and-drop antar status (`Applied` ➔ `Interview` ➔ `Offering`).
2. ⏰ **Smart Reminder & Inactivity Alert**: Notifikasi jika lamaran berstatus `Applied` sudah lebih dari 14 atau 30 hari tanpa respon untuk di-follow up atau diarsipkan.
3. 📅 **Calendar & Interview Scheduler**: Integrasi kalender untuk jadwal tes dan interview.
4. 📎 **Attachment Support (Supabase Storage)**: Upload CV/Resume khusus yang digunakan saat melamar ke lowongan tertentu.
5. 🔍 **Search & Filter Canggih**: Filter instan berdasarkan sistem kerja, portal, status, atau rentang tanggal.
6. 📊 **Visual Analytics**: Grafik interaktif dengan visualisasi persentase konversi (misal: *Berapa % lamaran dari LinkedIn yang lolos ke tahap interview vs JobStreet*).

---

## 7. Langkah Selanjutnya (Next Steps)

1. **Konfirmasi Desain UI/UX & Tech Stack Mobile**: (e.g. React Native / Expo, Flutter, atau FlutterFlow).
2. **Setup Project Supabase**: Eksekusi skema database SQL di Supabase SQL Editor.
3. **Inisialisasi Project Mobile**: Membangun arsitektur frontend mobile, state management, dan koneksi Supabase SDK.
