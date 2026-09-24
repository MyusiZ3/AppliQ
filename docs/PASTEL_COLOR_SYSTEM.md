# AppliQ Neo-Pastel Design System (Non-Monochrome Mode)

Dokumen ini mendefinisikan palet warna **Neo-Pastel** untuk **AppliQ** saat **Monochrome Mode dinonaktifkan** (`AccentThemeMode.color`). Warna-warna di bawah ini telah disesuaikan dengan revisi hex resmi dari pengguna.

---

## 1. Aturan Emas Kontras (Anti-Tabrakan Teks)

> [!IMPORTANT]
> - **Pada Permukaan Pastel (Kuning, Ungu, Biru Muda, Mint, Coral):**
>   Warna teks dan ikon **WAJIB menggunakan Hitam Pekat (`#0d0c0f`)**. Dengan aturan ini, rasio kontras mencapai **> 12:1** (standar tertinggi WCAG AAA), sehingga teks tidak pernah bertabrakan atau menyatu dengan warna background.
> - **Pada Permukaan Gelap (Dark Surface Cards):**
>   Warna teks menggunakan **Putih Bersih (`#F8FAFC`)**, teks pendukung menggunakan **Muted Slate (`#9896A4`)**, dan ikon dapat menggunakan aksen warna pastel.

---

## 2. Palet Warna Pastel Utama (Accent Tokens)

| Token Name | Hex Code | Preview | Penggunaan Komponen | Warna Teks / Ikon |
| :--- | :--- | :---: | :--- | :--- |
| **`pastelLime`** | `#ECFF8E` | 🟩 | Kartu Metrik Utama (Total Lamaran), Tombol CTA Utama, Tag Highlight | `#0D0C0F` (Dark Obsidian) |
| **`pastelLavender`**| `#BFAEF8` | 🟪 | Kartu Metrik Kedua (Jadwal Interview), Tombol FAB `+`, Tag Filter | `#0D0C0F` (Dark Obsidian) |
| **`pastelSky`** | `#8EEFFE` | 🟦 | Kartu Metrik Ketiga (Menunggu Respon / Assessment), Active Chips | `#0D0C0F` (Dark Obsidian) |
| **`pastelMint`** | `#9EF5CF` | 🟩 | Status Offering / Accepted, Tag "Success", Gaji / Penawaran | `#0D0C0F` (Dark Obsidian) |
| **`pastelCoral`** | `#FFB2BA` | 🟥 | Status Rejected, Deadline Mendesak, Alert / Peringatan | `#0D0C0F` (Dark Obsidian) |
| **`pastelAmber`** | `#FED888` | 🟨 | Status Dalam Proses, Bookmark Aktif | `#0D0C0F` (Dark Obsidian) |

---

## 3. Surface & Background Tokens

### A. Dark Mode
| Token Name | Hex Code | Deskripsi & Komponen |
| :--- | :--- | :--- |
| **`darkBgObsidian`** | `#0D0C0F` | Latar belakang aplikasi utama (Scaffold background) |
| **`darkCardSurface`** | `#17161B` | Kartu reguler (Application card, list item, menu group) |
| **`darkCardElevated`** | `#201E27` | Bottom sheet, dialog pop-up, search bar |
| **`darkCardBorder`** | `#292735` | Border halus kartu reguler (tebal: 0.8px) |
| **`darkTextPrimary`** | `#F8FAFC` | Judul, posisi pekerjaan, angka metrik pada kartu gelap |
| **`darkTextSecondary`**| `#9896A4` | Nama perusahaan, tanggal, keterangan pendukung |
| **`darkTextMuted`** | `#666472` | Placeholder text, divider, disabled icon |

### B. Light Mode Counterpart
| Token Name | Hex Code | Deskripsi & Komponen |
| :--- | :--- | :--- |
| **`lightBgSlate`** | `#F8F9FB` | Background aplikasi saat light mode |
| **`lightCardSurface`** | `#FFFFFF` | Permukaan kartu utama |
| **`lightCardBorder`** | `#E4E4EB` | Garis tepi kartu |
| **`lightTextPrimary`** | `#0D0C0F` | Teks judul utama |
| **`lightTextSecondary`**| `#5C5A69` | Teks sekunder |

---

## 4. Pemetaan Komponen (Component Mapping)

### 1. Dashboard Metric Cards (Home Screen)
- **Card 1 (Total Lamaran / Active):**
  - Background: `pastelLime` (`#ECFF8E`)
  - Icon: `CupertinoIcons.doc_text` (Warna: `#0D0C0F`)
  - Angka & Label: `#0D0C0F`
- **Card 2 (Interview / Jadwal):**
  - Background: `pastelLavender` (`#BFAEF8`)
  - Icon: `CupertinoIcons.calendar` (Warna: `#0D0C0F`)
  - Angka & Label: `#0D0C0F`
- **Card 3 (Menunggu Respon):**
  - Background: `pastelSky` (`#8EEFFE`)
  - Icon: `CupertinoIcons.clock` (Warna: `#0D0C0F`)
  - Angka & Label: `#0D0C0F`

### 2. Floating Action Button (FAB)
- Background: `pastelLavender` (`#BFAEF8`)
- Icon `+`: `#0D0C0F` (Hitam Pekat)
- Shape: Circular / Rounded (Radius 20)

### 3. Application Cards & Status Badges
- Card Background: `darkCardSurface` (`#17161B`)
- Card Border: `darkCardBorder` (`#292735`)
- Bookmark Aktif: `pastelAmber` (`#FED888`)
- **Status Badges (Pill):**
  - *Applied*: Dark pill dengan border subtle `#292735` & teks `#9896A4`
  - *Interview*: Background `pastelSky` (`#8EEFFE`) dengan teks `#0D0C0F`
  - *Offering / Accepted*: Background `pastelMint` (`#9EF5CF`) dengan teks `#0D0C0F`
  - *Rejected*: Background `pastelCoral` (`#FFB2BA`) dengan teks `#0D0C0F`

---

## 5. Implementasi Kode di `AppColors`

```dart
// Neo-Pastel Accent Tokens
static const Color pastelLime = Color(0xFFECFF8E);       // Kuning / Lime Pastel
static const Color pastelLavender = Color(0xFFBFAEF8);   // Ungu Pastel
static const Color pastelSky = Color(0xFF8EEFFE);        // Biru Muda Pastel
static const Color pastelMint = Color(0xFF9EF5CF);       // Mint / Soft Emerald
static const Color pastelCoral = Color(0xFFFFB2BA);      // Coral / Rose
static const Color pastelAmber = Color(0xFFFED888);      // Amber / Warm Gold

// High-Contrast Foreground for Pastel Surfaces
static const Color textOnPastel = Color(0xFF0D0C0F);     // Hitam Pekat
```
