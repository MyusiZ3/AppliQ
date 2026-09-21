# Analisis Spreadsheet Job Application Tracker

Dokumen ini berisi hasil analisis terhadap file template spreadsheet `[FREE] Job Application Tracker by @persistancedee.xlsx`.

---

## 1. Struktur Spreadsheet

File spreadsheet terdiri dari 3 sheet:
1. `Read Me!`: Panduan pengisian, alur operasional, dan informasi lisensi pembuat template.
2. `Example`: Sampel data pelacakan lamaran kerja (9 entri) beserta formula dashboard.
3. `Template`: Master template kosong dengan validasi data dan formula otomatis.

---

## 2. Struktur Data dan Kolom Input

| No | Nama Kolom | Tipe Data | Pilihan Nilai / Format | Validasi |
|---|---|---|---|---|
| 1 | No | Integer | Nomor urut baris | Auto-generated |
| 2 | Applied Date | Date | Tanggal pengiriman lamaran (YYYY-MM-DD) | Valid Date |
| 3 | Company | Text | Nama perusahaan | Mandatory |
| 4 | Position | Text | Posisi / jabatan yang dilamar | Mandatory |
| 5 | Location | Text | Lokasi / kota penempatan kerja | Optional |
| 6 | Sistem Kerja | Enum | `On-site`, `Hybrid`, `WFH` | Dropdown |
| 7 | Job Portal | Enum | `Linked In`, `JobStreet`, `Glints`, `KitaLulus`, `Website`, `Instagram`, `Lainnya` | Dropdown |
| 8 | Link (Opsional) | URL | Tautan lowongan pekerjaan | Valid URL |
| 9 | Status | Enum | `Applied`, `Interview`, `No Response`, `Offering`, `Accepted`, `Rejected` | Dropdown |
| 10 | Note | Text / Computed | Catatan status otomatis berbasis waktu & status | Calculated |

---

## 3. Logika Bisnis Kolom Note

Pada spreadsheet, kolom Note dihitung secara otomatis menggunakan formula:

```excel
=IF(AND(Status="Applied", Today - Applied_Date = 0), "Dikirim hari ini",
 IF(AND(Status="Applied", Today - Applied_Date <= 30), "Dikirim " & (Today - Applied_Date) & " hari yang lalu",
 IF(AND(Status="Applied", Today - Applied_Date > 30), "Tidak ada respon lebih dari 30 hari",
 IF(OR(Status="Rejected", Status="No Response"), "Semangat, masih ada kesempatan lainnya",
 "Kamu sedang dalam tahap " & Status))))
```

### Klasifikasi Respon:
- Applied (Hari Ini): Label "Dikirim hari ini"
- Applied (1 - 30 Hari): Label "Dikirim X hari yang lalu"
- Applied (> 30 Hari): Label peringatan "Tidak ada respon lebih dari 30 hari"
- Interview / Offering / Accepted: Label "Kamu sedang dalam tahap [Status]"
- Rejected / No Response: Label "Semangat, masih ada kesempatan lainnya"

---

## 4. Metrik Dashboard & Visualisasi

Spreadsheet menghitung metrik agregat berikut:
- Total Lamaran: Dihitung dengan rumus `COUNTIF(Status, "<>")`.
- Breakdown Status: Jumlah lamaran per kategori status (`Applied`, `Interview`, `Offering`, `Accepted`, `Rejected`, `No Response`).
- Distribusi Sistem Kerja: Proporsi lamaran untuk sistem kerja On-site, Hybrid, dan WFH.
- Distribusi Job Portal: Rekapitulasi jumlah lamaran per sumber lowongan.
