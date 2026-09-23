# ==========================================
# AppliQ - Auto Build & GitHub Release
# ==========================================

Write-Host "--- Memulai proses Build & Release AppliQ ---" -ForegroundColor Cyan

# 1. Ambil Versi dari pubspec.yaml
$pubspec = Get-Content "pubspec.yaml" -Raw
if ($pubspec -match "version:\s*([^\s#]+)") {
    $fullVersion = $Matches[1].Trim()
    $versionName = ($fullVersion -split '\+')[0]
    Write-Host "[OK] Versi terdeteksi: $versionName (Build: $fullVersion)" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Gagal membaca versi dari pubspec.yaml" -ForegroundColor Red
    exit
}

# 2. Build APK (Hanya jika belum ada atau versi berubah)
Write-Host "--- Memeriksa Build APK ---" -ForegroundColor Yellow
$lastVersionFile = "build\app\outputs\flutter-apk\last_version.txt"
$lastVersion = ""
if (Test-Path $lastVersionFile) {
    $lastVersion = Get-Content $lastVersionFile
}

$apkPath = "build\app\outputs\flutter-apk\app-release.apk"
$shouldBuild = $true

if (Test-Path $apkPath) {
    if ($lastVersion -eq $versionName) {
        Write-Host "[INFO] File Build v$versionName terdeteksi, melewati proses build..." -ForegroundColor Gray
        $shouldBuild = $false
    } else {
        Write-Host "[INFO] Versi berubah ($lastVersion -> $versionName). Memaksa build ulang..." -ForegroundColor Cyan
    }
}

if ($shouldBuild) {
    if (Test-Path $apkPath) {
        Write-Host "Menghapus build lama..." -ForegroundColor Gray
        Remove-Item $apkPath -Force
    }
    
    Write-Host "Memulai Build APK (Release v$versionName) ---" -ForegroundColor Yellow
    flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols
    
    if ($LASTEXITCODE -eq 0) {
        if (!(Test-Path "build\app\outputs\flutter-apk")) { New-Item -ItemType Directory -Path "build\app\outputs\flutter-apk" -Force }
        $versionName | Out-File $lastVersionFile -NoNewline
        Write-Host "[OK] Build v$versionName selesai!" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] Build APK Gagal!" -ForegroundColor Red
        exit
    }
}

# 3. Bersihkan Folder Public
if (Test-Path "public") {
    Remove-Item "public\AppliQ_*.bin" -ErrorAction SilentlyContinue
    Remove-Item "public\*.apk" -ErrorAction SilentlyContinue
    Remove-Item "public\app.bin" -ErrorAction SilentlyContinue
}

$apkSource = "build\app\outputs\flutter-apk\app-release.apk"

# 4. Sinkronisasi Git Commit ke GitHub
Write-Host "--- Mengunggah Commit ke GitHub ---" -ForegroundColor Yellow
git push origin main

# 5. Buat GitHub Release dan Upload File APK
Write-Host "--- Membuat GitHub Release (v$versionName) ---" -ForegroundColor Yellow

$ghCmd = Get-Command gh -ErrorAction SilentlyContinue
if ($ghCmd) {
    $ghPath = $ghCmd.Source
} elseif (Test-Path "C:\Program Files\GitHub CLI\gh.exe") {
    $ghPath = "C:\Program Files\GitHub CLI\gh.exe"
} else {
    $ghPath = $null
}

$binSource = "build\app\outputs\flutter-apk\app.bin"
if (Test-Path $apkSource) {
    Copy-Item -Path $apkSource -Destination $binSource -Force
}

$notes = "AppliQ Release v$versionName`n- Build executed on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n- Modern Job Application Tracker & Interview Companion"

if ($ghPath -and (Test-Path $ghPath)) {
    Write-Host "Menghapus tag lama (jika ada) via GitHub CLI..." -ForegroundColor Gray
    & $ghPath release delete "v$versionName" --cleanup-tag --yes 2>$null

    Write-Host "Mengunggah APK dan BIN ke repositori GitHub Releases..." -ForegroundColor Cyan
    & $ghPath release create "v$versionName" $apkSource $binSource --title "AppliQ v$versionName" --notes $notes

    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] Membuat GitHub Release Gagal!" -ForegroundColor Red
    } else {
        Write-Host "[OK] Berhasil upload ke GitHub Releases!" -ForegroundColor Green
    }
} else {
    Write-Host "[WARN] GitHub CLI tidak ditemukan. Melewati upload release." -ForegroundColor Yellow
}

Write-Host "`n[OK] Selesai! Versi AppliQ v$versionName siap." -ForegroundColor DarkGreen
Write-Host "Link Download APK Rilis: https://github.com/MyusiZ3/AppliQ/releases/download/v$versionName/app-release.apk" -ForegroundColor Cyan
