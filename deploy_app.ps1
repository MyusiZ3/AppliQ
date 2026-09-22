# ==========================================
# AppliQ - Auto Deploy (GitHub Pages & Releases)
# ==========================================

Write-Host "--- Memulai proses Auto-Deploy AppliQ ke GitHub ---" -ForegroundColor Cyan

# 1. Ambil Versi dari pubspec.yaml
$pubspec = Get-Content "pubspec.yaml" -Raw
if ($pubspec -match "version:\s*([^\s#]+)") {
    $versionName = $Matches[1].Trim()
    Write-Host "[OK] Versi terdeteksi: $versionName" -ForegroundColor Green
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
Write-Host "--- Membersihkan file lama di folder public ---" -ForegroundColor Yellow
if (!(Test-Path "public")) { New-Item -ItemType Directory -Path "public" }

Remove-Item "public\AppliQ_*.bin" -ErrorAction SilentlyContinue
Remove-Item "public\*.apk" -ErrorAction SilentlyContinue
Remove-Item "public\app.bin" -ErrorAction SilentlyContinue

$apkSource = "build\app\outputs\flutter-apk\app-release.apk"

# 4. Sinkronisasi Versi di Landing Page (public\index.html)
Write-Host "--- Sinkronisasi Versi di Landing Page ---" -ForegroundColor Yellow
$indexPath = "public\index.html"
if (Test-Path $indexPath) {
    $content = Get-Content $indexPath -Raw
    $newContent = $content
    
    # Ganti placeholder {{VERSION}} jika ada
    if ($newContent -match "\{\{VERSION\}\}") {
        $newContent = $newContent -replace "\{\{VERSION\}\}", $versionName
        Write-Host "[INFO] Placeholder {{VERSION}} ditemukan dan diperbarui." -ForegroundColor Cyan
    } 
    # Jika tidak ada placeholder, cari versi lama dan timpa
    elseif ($lastVersion -and ($newContent -match [regex]::Escape($lastVersion))) {
        $newContent = $newContent -replace [regex]::Escape($lastVersion), $versionName
        Write-Host "[INFO] Versi lama $lastVersion ditemukan dan diperbarui ke $versionName." -ForegroundColor Cyan
    }
    else {
        Write-Host "[WARN] Tidak ditemukan placeholder {{VERSION}} atau versi lama di index.html. Sinkronisasi dilewati." -ForegroundColor Yellow
    }

    $newContent | Set-Content $indexPath -NoNewline
}

# 5. Buat GitHub Release dan Upload File APK
Write-Host "--- Membuat GitHub Release (v$versionName) ---" -ForegroundColor Yellow

if (Get-Command gh -ErrorAction SilentlyContinue) {
    $ghPath = "gh"
} else {
    $ghPath = "C:\Program Files\GitHub CLI\gh.exe"
}

$binSource = "build\app\outputs\flutter-apk\app.bin"
if (Test-Path $apkSource) {
    Copy-Item -Path $apkSource -Destination $binSource -Force
}

$notes = "AppliQ Release v$versionName`n- Build executed on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n- Modern Job Application Tracker & Interview Companion"

if (Test-Path $ghPath) {
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
    Write-Host "[WARN] GitHub CLI ($ghPath) tidak ditemukan. Melewati upload release." -ForegroundColor Yellow
}

# 6. Deploy Landing Page ke GitHub Pages (via gh-pages branch)
Write-Host "--- Deploy Landing Page ke GitHub Pages ---" -ForegroundColor Yellow
try {
    # Commit perubahan public folder ke branch saat ini jika ada
    git add public/index.html .github/workflows/deploy-pages.yml
    git commit -m "chore(release): sync landing page for v$versionName" 2>$null
    git push origin main 2>$null
    Write-Host "[OK] Landing page ter-push ke repository! GitHub Actions akan men-deploy ke GitHub Pages." -ForegroundColor Green
} catch {
    Write-Host "[INFO] Melewati auto push git." -ForegroundColor Gray
}

Write-Host "`n[OK] Selesai! Versi AppliQ tersinkronisasi (v$versionName)" -ForegroundColor DarkGreen
Write-Host "Link Web Landing Page  : https://myusiz3.github.io/AppliQ/" -ForegroundColor Cyan
Write-Host "Link Download APK Rilis: https://github.com/MyusiZ3/AppliQ/releases/download/v$versionName/app-release.apk" -ForegroundColor Cyan
