# Database Design & PostgreSQL Specification: AppliQ

- Database Engine: PostgreSQL 15+ (Supabase Managed)
- Security Model: Row Level Security (RLS) dengan Supabase GoTrue Auth Integration
- Encoding: UTF-8

---

## 1. Entity-Relationship Model (ERD)

```
+----------------------------------------------------------------------+
|                           auth.users                                 |
|                       (Supabase Auth Engine)                         |
|----------------------------------------------------------------------|
| id                     : UUID (PK)                                   |
| email                  : VARCHAR                                     |
| raw_user_meta_data     : JSONB (name, avatar_url, full_name, etc.)   |
+----------------------------------+-----------------------------------+
                                   | 1:1 (Trigger Managed)
                                   v
+----------------------------------------------------------------------+
|                        public.profiles                               |
|----------------------------------------------------------------------|
| id                     : UUID (PK, FK -> auth.users.id)              |
| email                  : TEXT                                        |
| full_name              : TEXT                                        |
| avatar_url             : TEXT                                        |
| target_role            : TEXT                                        |
| created_at             : TIMESTAMPTZ                                 |
| updated_at             : TIMESTAMPTZ                                 |
+----------------------------------+-----------------------------------+
                                   | 1:N
                                   v
+----------------------------------------------------------------------+
|                     public.job_applications                          |
|----------------------------------------------------------------------|
| id                     : UUID (PK, DEFAULT gen_random_uuid())        |
| user_id                : UUID (FK -> public.profiles.id)             |
| company_name           : TEXT                                        |
| position_title         : TEXT                                        |
| location               : TEXT                                        |
| work_system            : work_system_type (ENUM)                     |
| job_portal             : job_portal_type (ENUM)                      |
| job_portal_custom      : TEXT                                        |
| job_url                : TEXT                                        |
| status                 : application_status_type (ENUM)              |
| applied_date           : DATE                                        |
| salary_expectation     : NUMERIC(15, 2)                              |
| salary_offered         : NUMERIC(15, 2)                              |
| notes                  : TEXT                                        |
| is_favorite            : BOOLEAN                                     |
| created_at             : TIMESTAMPTZ                                 |
| updated_at             : TIMESTAMPTZ                                 |
+----------------------------------+-----------------------------------+
                                   | 1:N
                                   v
+----------------------------------------------------------------------+
|                      public.application_logs                         |
|----------------------------------------------------------------------|
| id                     : UUID (PK, DEFAULT gen_random_uuid())        |
| application_id         : UUID (FK -> public.job_applications.id)     |
| user_id                : UUID (FK -> public.profiles.id)             |
| stage_name             : TEXT                                        |
| scheduled_at           : TIMESTAMPTZ                                 |
| interviewer_name       : TEXT                                        |
| meeting_link           : TEXT                                        |
| notes                  : TEXT                                        |
| result                 : TEXT                                        |
| created_at             : TIMESTAMPTZ                                 |
+----------------------------------------------------------------------+

+----------------------------------+-----------------------------------+
                                   | 1:1 (Unique User Profile Data)
                                   v
+----------------------------------------------------------------------+
|                        public.user_resumes                           |
|----------------------------------------------------------------------|
| id                     : UUID (PK, DEFAULT gen_random_uuid())        |
| user_id                : UUID (FK -> public.profiles.id, UNIQUE)     |
| full_name              : TEXT                                        |
| city_country           : TEXT                                        |
| phone_number           : TEXT                                        |
| email                  : TEXT                                        |
| linkedin_url           : TEXT                                        |
| portfolio_url          : TEXT                                        |
| summary                : TEXT                                        |
| educations             : JSONB (List of EducationItem)               |
| experiences            : JSONB (List of ExperienceItem)              |
| certifications         : JSONB (List of CertificationItem)           |
| technical_skills       : JSONB (List of String)                      |
| soft_skills            : JSONB (List of String)                      |
| birth_place_date       : TEXT                                        |
| full_address           : TEXT                                        |
| marital_status         : TEXT                                        |
| citizenship            : TEXT                                        |
| last_education         : TEXT                                        |
| target_job_position    : TEXT                                        |
| selected_attachments   : JSONB (List of String)                      |
| created_at             : TIMESTAMPTZ                                 |
| updated_at             : TIMESTAMPTZ                                 |
+----------------------------------------------------------------------+
```

---

## 2. Complete SQL DDL Script

Script SQL di bawah ini dapat dieksekusi langsung pada Supabase SQL Editor.

```sql
-- ====================================================================
-- 1. ENUM DEFINITIONS
-- ====================================================================

DO $$ BEGIN
    CREATE TYPE work_system_type AS ENUM ('On-site', 'Hybrid', 'WFH');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE application_status_type AS ENUM (
      'Applied',
      'Interview',
      'Offering',
      'Accepted',
      'Rejected',
      'No Response'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE job_portal_type AS ENUM (
      'Linked In',
      'JobStreet',
      'Glints',
      'KitaLulus',
      'Website',
      'Instagram',
      'Lainnya'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- ====================================================================
-- 2. TABLE DEFINITIONS
-- ====================================================================

-- 2.1 Profiles Table (Linked with Supabase Auth)
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  target_role TEXT,
  created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 2.2 Job Applications Table
CREATE TABLE IF NOT EXISTS public.job_applications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  company_name TEXT NOT NULL,
  position_title TEXT NOT NULL,
  location TEXT,
  work_system work_system_type NOT NULL DEFAULT 'On-site',
  job_portal job_portal_type NOT NULL DEFAULT 'Linked In',
  job_portal_custom TEXT,
  job_url TEXT,
  status application_status_type NOT NULL DEFAULT 'Applied',
  applied_date DATE NOT NULL DEFAULT CURRENT_DATE,
  salary_expectation NUMERIC(15, 2),
  salary_offered NUMERIC(15, 2),
  notes TEXT,
  is_favorite BOOLEAN DEFAULT FALSE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 2.3 Application Logs / Recruitment Stages Table
CREATE TABLE IF NOT EXISTS public.application_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  application_id UUID NOT NULL REFERENCES public.job_applications(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  stage_name TEXT NOT NULL,
  scheduled_at TIMESTAMPTZ,
  interviewer_name TEXT,
  meeting_link TEXT,
  notes TEXT,
  result TEXT DEFAULT 'Waiting',
  created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 2.4 User Resumes & Cover Letter Builder Table
CREATE TABLE IF NOT EXISTS public.user_resumes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE REFERENCES public.profiles(id) ON DELETE CASCADE,
  full_name TEXT NOT NULL DEFAULT '',
  city_country TEXT NOT NULL DEFAULT '',
  phone_number TEXT NOT NULL DEFAULT '',
  email TEXT NOT NULL DEFAULT '',
  linkedin_url TEXT,
  portfolio_url TEXT,
  summary TEXT,
  educations JSONB NOT NULL DEFAULT '[]'::jsonb,
  experiences JSONB NOT NULL DEFAULT '[]'::jsonb,
  certifications JSONB NOT NULL DEFAULT '[]'::jsonb,
  technical_skills JSONB NOT NULL DEFAULT '[]'::jsonb,
  soft_skills JSONB NOT NULL DEFAULT '[]'::jsonb,
  birth_place_date TEXT,
  full_address TEXT,
  marital_status TEXT NOT NULL DEFAULT 'Belum Menikah',
  citizenship TEXT NOT NULL DEFAULT 'Indonesia',
  last_education TEXT,
  target_job_position TEXT,
  selected_attachments JSONB NOT NULL DEFAULT '[]'::jsonb,
  created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- ====================================================================
-- 3. INDEXING FOR PERFORMANCE
-- ====================================================================

CREATE INDEX IF NOT EXISTS idx_job_applications_user_id 
  ON public.job_applications(user_id);

CREATE INDEX IF NOT EXISTS idx_job_applications_status 
  ON public.job_applications(user_id, status);

CREATE INDEX IF NOT EXISTS idx_job_applications_applied_date 
  ON public.job_applications(user_id, applied_date DESC);

CREATE INDEX IF NOT EXISTS idx_application_logs_app_id 
  ON public.application_logs(application_id);

CREATE INDEX IF NOT EXISTS idx_application_logs_user_id 
  ON public.application_logs(user_id);

CREATE INDEX IF NOT EXISTS idx_user_resumes_user_id 
  ON public.user_resumes(user_id);

-- ====================================================================
-- 4. DATABASE TRIGGERS (AUTH SYNC & TIMESTAMP UPDATE)
-- ====================================================================

-- 4.1 Update Timestamp Trigger Function
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = TIMEZONE('utc'::text, NOW());
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_profiles_timestamp ON public.profiles;
CREATE TRIGGER trigger_update_profiles_timestamp
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS trigger_update_job_applications_timestamp ON public.job_applications;
CREATE TRIGGER trigger_update_job_applications_timestamp
  BEFORE UPDATE ON public.job_applications
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS trigger_update_user_resumes_timestamp ON public.user_resumes;
CREATE TRIGGER trigger_update_user_resumes_timestamp
  BEFORE UPDATE ON public.user_resumes
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- 4.2 Auto-create Profile from Google Auth Metadata
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, avatar_url)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name', ''),
    COALESCE(NEW.raw_user_meta_data->>'avatar_url', NEW.raw_user_meta_data->>'picture', '')
  )
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    full_name = COALESCE(EXCLUDED.full_name, public.profiles.full_name),
    avatar_url = COALESCE(EXCLUDED.avatar_url, public.profiles.avatar_url),
    updated_at = TIMEZONE('utc'::text, NOW());
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT OR UPDATE ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ====================================================================
-- 5. ROW LEVEL SECURITY (RLS) POLICIES
-- ====================================================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.job_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.application_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_resumes ENABLE ROW LEVEL SECURITY;

-- 5.1 Profiles Policies
DROP POLICY IF EXISTS "Profiles: Users can view own profile" ON public.profiles;
CREATE POLICY "Profiles: Users can view own profile"
  ON public.profiles FOR SELECT
  USING (auth.uid() = id);

DROP POLICY IF EXISTS "Profiles: Users can update own profile" ON public.profiles;
CREATE POLICY "Profiles: Users can update own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

-- 5.2 Job Applications Policies
DROP POLICY IF EXISTS "JobApp: Users can view own applications" ON public.job_applications;
CREATE POLICY "JobApp: Users can view own applications"
  ON public.job_applications FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "JobApp: Users can insert own applications" ON public.job_applications;
CREATE POLICY "JobApp: Users can insert own applications"
  ON public.job_applications FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "JobApp: Users can update own applications" ON public.job_applications;
CREATE POLICY "JobApp: Users can update own applications"
  ON public.job_applications FOR UPDATE
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "JobApp: Users can delete own applications" ON public.job_applications;
CREATE POLICY "JobApp: Users can delete own applications"
  ON public.job_applications FOR DELETE
  USING (auth.uid() = user_id);

-- 5.3 Application Logs Policies
DROP POLICY IF EXISTS "AppLogs: Users can view own logs" ON public.application_logs;
CREATE POLICY "AppLogs: Users can view own logs"
  ON public.application_logs FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "AppLogs: Users can insert own logs" ON public.application_logs;
CREATE POLICY "AppLogs: Users can insert own logs"
  ON public.application_logs FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "AppLogs: Users can update own logs" ON public.application_logs;
CREATE POLICY "AppLogs: Users can update own logs"
  ON public.application_logs FOR UPDATE
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "AppLogs: Users can delete own logs" ON public.application_logs;
CREATE POLICY "AppLogs: Users can delete own logs"
  ON public.application_logs FOR DELETE
  USING (auth.uid() = user_id);

-- 5.4 User Resumes Policies
DROP POLICY IF EXISTS "UserResumes: Users can view own resume" ON public.user_resumes;
CREATE POLICY "UserResumes: Users can view own resume"
  ON public.user_resumes FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "UserResumes: Users can insert own resume" ON public.user_resumes;
CREATE POLICY "UserResumes: Users can insert own resume"
  ON public.user_resumes FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "UserResumes: Users can update own resume" ON public.user_resumes;
CREATE POLICY "UserResumes: Users can update own resume"
  ON public.user_resumes FOR UPDATE
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "UserResumes: Users can delete own resume" ON public.user_resumes;
CREATE POLICY "UserResumes: Users can delete own resume"
  ON public.user_resumes FOR DELETE
  USING (auth.uid() = user_id);

-- ====================================================================
-- 6. RPC STORED PROCEDURE: DASHBOARD AGGREGATION
-- ====================================================================

CREATE OR REPLACE FUNCTION public.get_job_tracker_stats(p_user_id UUID)
RETURNS JSON AS $$
DECLARE
  result JSON;
BEGIN
  IF auth.uid() IS NULL OR auth.uid() != p_user_id THEN
    RAISE EXCEPTION 'Unauthorized access';
  END IF;

  SELECT json_build_object(
    'total_applications', COUNT(*),
    'applied_count', COUNT(*) FILTER (WHERE status = 'Applied'),
    'interview_count', COUNT(*) FILTER (WHERE status = 'Interview'),
    'offering_count', COUNT(*) FILTER (WHERE status = 'Offering'),
    'accepted_count', COUNT(*) FILTER (WHERE status = 'Accepted'),
    'rejected_count', COUNT(*) FILTER (WHERE status = 'Rejected'),
    'no_response_count', COUNT(*) FILTER (WHERE status = 'No Response'),
    'by_work_system', COALESCE((
      SELECT json_object_agg(work_system, count)
      FROM (
        SELECT work_system, COUNT(*) as count 
        FROM public.job_applications 
        WHERE user_id = p_user_id 
        GROUP BY work_system
      ) ws
    ), '{}'::json),
    'by_portal', COALESCE((
      SELECT json_object_agg(job_portal, count)
      FROM (
        SELECT job_portal, COUNT(*) as count 
        FROM public.job_applications 
        WHERE user_id = p_user_id 
        GROUP BY job_portal
      ) jp
    ), '{}'::json)
  ) INTO result
  FROM public.job_applications
  WHERE user_id = p_user_id;

  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

---

## 3. Data Dictionary

### Tabel `public.profiles`
| Nama Kolom | Tipe Data | Nullable | Default | Keterangan |
|---|---|---|---|---|
| `id` | UUID | NO | - | Primary Key, merujuk ke `auth.users(id)`. |
| `email` | TEXT | NO | - | Alamat email terdaftar. |
| `full_name` | TEXT | YES | - | Nama lengkap dari akun Google. |
| `avatar_url` | TEXT | YES | - | URL foto profil dari Google. |
| `target_role` | TEXT | YES | - | Preferensi posisi target yang dicari pengguna. |
| `created_at` | TIMESTAMPTZ | NO | NOW() | Timestamp pembuatan record. |
| `updated_at` | TIMESTAMPTZ | NO | NOW() | Timestamp pembaruan data terakhir. |

### Tabel `public.job_applications`
| Nama Kolom | Tipe Data | Nullable | Default | Keterangan |
|---|---|---|---|---|
| `id` | UUID | NO | gen_random_uuid() | Primary Key entri lamaran. |
| `user_id` | UUID | NO | - | Foreign Key merujuk ke `public.profiles(id)`. |
| `company_name` | TEXT | NO | - | Nama perusahaan. |
| `position_title` | TEXT | NO | - | Posisi pekerjaan. |
| `location` | TEXT | YES | - | Kota / wilayah kerja. |
| `work_system` | work_system_type | NO | 'On-site' | Enum: `On-site`, `Hybrid`, `WFH`. |
| `job_portal` | job_portal_type | NO | 'Linked In' | Enum sumber lowongan kerja. |
| `job_portal_custom` | TEXT | YES | - | Nama portal kustom jika memilih `Lainnya`. |
| `job_url` | TEXT | YES | - | URL tautan lowongan kerja. |
| `status` | application_status_type | NO | 'Applied' | Enum status lamaran. |
| `applied_date` | DATE | NO | CURRENT_DATE | Tanggal pengiriman lamaran. |
| `salary_expectation` | NUMERIC(15, 2) | YES | - | Ekspektasi gaji pengguna. |
| `salary_offered` | NUMERIC(15, 2) | YES | - | Penawaran gaji dari perusahaan. |
| `notes` | TEXT | YES | - | Catatan personal pengguna. |
| `is_favorite` | BOOLEAN | NO | FALSE | Penanda lamaran prioritas tinggi. |
| `created_at` | TIMESTAMPTZ | NO | NOW() | Timestamp pembuatan record. |
| `updated_at` | TIMESTAMPTZ | NO | NOW() | Timestamp update terakhir. |

### Tabel `public.application_logs`
| Nama Kolom | Tipe Data | Nullable | Default | Keterangan |
|---|---|---|---|---|
| `id` | UUID | NO | gen_random_uuid() | Primary Key catatan tahapan. |
| `application_id` | UUID | NO | - | Foreign Key merujuk ke `public.job_applications(id)`. |
| `user_id` | UUID | NO | - | Foreign Key merujuk ke `public.profiles(id)`. |
| `stage_name` | TEXT | NO | - | Nama tahapan (e.g. "HR Interview", "Technical Test"). |
| `scheduled_at` | TIMESTAMPTZ | YES | - | Jadwal tanggal dan waktu tes/wawancara. |
| `interviewer_name` | TEXT | YES | - | Nama kontak atau pewawancara. |
| `meeting_link` | TEXT | YES | - | Tautan video call atau lokasi tes. |
| `notes` | TEXT | YES | - | Catatan teknis, kisi-kisi, atau evaluasi. |
| `result` | TEXT | YES | 'Waiting' | Hasil tahap: `Waiting`, `Passed`, `Failed`. |
| `created_at` | TIMESTAMPTZ | NO | NOW() | Timestamp pembuatan log. |

### Tabel `public.user_resumes`
| Nama Kolom | Tipe Data | Nullable | Default | Keterangan |
|---|---|---|---|---|
| `id` | UUID | NO | gen_random_uuid() | Primary Key entri data resume & surat lamaran. |
| `user_id` | UUID | NO | - | Foreign Key unik merujuk ke `public.profiles(id)`. |
| `full_name` | TEXT | NO | '' | Nama lengkap & gelar profesional. |
| `city_country` | TEXT | NO | '' | Domisili kota & negara. |
| `phone_number` | TEXT | NO | '' | Nomor kontak WhatsApp / seluler. |
| `email` | TEXT | NO | '' | Email aktif korespondensi. |
| `linkedin_url` | TEXT | YES | - | Tautan profil LinkedIn. |
| `portfolio_url` | TEXT | YES | - | Tautan website / portofolio / GitHub. |
| `summary` | TEXT | YES | - | Ringkasan eksekutif profil profesional. |
| `educations` | JSONB | NO | '[]'::jsonb | Array JSON riwayat pendidikan (`EducationItem`). |
| `experiences` | JSONB | NO | '[]'::jsonb | Array JSON pengalaman kerja / magang (`ExperienceItem`). |
| `certifications` | JSONB | NO | '[]'::jsonb | Array JSON sertifikasi & lisensi (`CertificationItem`). |
| `technical_skills` | JSONB | NO | '[]'::jsonb | Array JSON daftar Hard Skills. |
| `soft_skills` | JSONB | NO | '[]'::jsonb | Array JSON daftar Soft Skills. |
| `birth_place_date` | TEXT | YES | - | Tempat, tanggal lahir untuk data surat lamaran resmi. |
| `full_address` | TEXT | YES | - | Alamat lengkap domisili/KTP untuk surat lamaran. |
| `marital_status` | TEXT | NO | 'Belum Menikah' | Status pernikahan (e.g. Belum Menikah, Menikah). |
| `citizenship` | TEXT | NO | 'Indonesia' | Kewarganegaraan. |
| `last_education` | TEXT | YES | - | Keterangan jenjang pendidikan terakhir lengkap. |
| `target_job_position` | TEXT | YES | - | Posisi pekerjaan umum yang dituju. |
| `selected_attachments` | JSONB | NO | '[]'::jsonb | Array JSON berkas lampiran standar cover letter. |
| `created_at` | TIMESTAMPTZ | NO | NOW() | Timestamp pembuatan resume data. |
| `updated_at` | TIMESTAMPTZ | NO | NOW() | Timestamp pembaruan resume data terakhir. |
