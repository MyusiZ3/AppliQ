# ==========================================
# AppliQ - Auto Build & GitHub Release
# ==========================================
param(
    [ValidateSet("patch", "minor", "major", "none", "")]
    [string]$Bump = ""
)

Write-Host "--- Memulai proses Build & Release AppliQ ---" -ForegroundColor Cyan

# 1. Ambil & Kelola Versi (Auto-Bump Support)
$pubspec = Get-Content "pubspec.yaml" -Raw
if ($pubspec -match "version:\s*([^\s#]+)") {
    $fullVersion = $Matches[1].Trim()
    $versionParts = ($fullVersion -split '\+')
    $versionName = $versionParts[0]
    $buildNumber = if ($versionParts.Length -gt 1) { [int]$versionParts[1] } else { 1 }
} else {
    Write-Host "[ERROR] Gagal membaca versi dari pubspec.yaml" -ForegroundColor Red
    exit
}

if (-not $Bump) {
    if ([Environment]::UserInteractive) {
        $vParts = $versionName.Split('.')
        $pPatch = if ($vParts.Length -gt 2) { "$($vParts[0]).$($vParts[1]).$([int]$vParts[2] + 1)" } else { "$versionName.1" }
        $pMinor = if ($vParts.Length -gt 1) { "$($vParts[0]).$([int]$vParts[1] + 1).0" } else { "$versionName.0" }
        $pMajor = "$([int]$vParts[0] + 1).0.0"

        Write-Host "Versi saat ini: v$versionName (Build: $buildNumber)" -ForegroundColor Cyan
        Write-Host "Pilih Bump Versi:" -ForegroundColor Yellow
        Write-Host "  [1] Patch ($versionName -> $pPatch)"
        Write-Host "  [2] Minor ($versionName -> $pMinor)"
        Write-Host "  [3] Major ($versionName -> $pMajor)"
        Write-Host "  [Enter] Lewati / Gunakan versi saat ini"
        $choice = Read-Host "Pilihan [1/2/3/Enter]"
        if ($choice -eq "1") { $Bump = "patch" }
        elseif ($choice -eq "2") { $Bump = "minor" }
        elseif ($choice -eq "3") { $Bump = "major" }
    }
}

if ($Bump -and $Bump -ne "none") {
    $v = $versionName.Split('.')
    $major = [int]$v[0]
    $minor = if ($v.Length -gt 1) { [int]$v[1] } else { 0 }
    $patch = if ($v.Length -gt 2) { [int]$v[2] } else { 0 }
    $newBuild = $buildNumber + 1

    switch ($Bump.ToLower()) {
        "patch" { $patch++ }
        "minor" { $minor++; $patch = 0 }
        "major" { $major++; $minor = 0; $patch = 0 }
    }
    $newVersionName = "$major.$minor.$patch"
    $newFullVersion = "$newVersionName+$newBuild"

    Write-Host "[BUMP] Menaikkan versi: $versionName+$buildNumber -> $newFullVersion" -ForegroundColor Green

    # Update pubspec.yaml
    $pubspec = $pubspec -replace "version:\s*[^\s#]+", "version: $newFullVersion"
    $pubspec | Set-Content "pubspec.yaml" -NoNewline

    # Update lib/core/config/app_config.dart
    $appConfigPath = "lib\core\config\app_config.dart"
    if (Test-Path $appConfigPath) {
        $appConfigContent = Get-Content $appConfigPath -Raw
        $appConfigContent = $appConfigContent -replace "static const String appVersion = '[^']+';", "static const String appVersion = '$newVersionName';"
        $appConfigContent = $appConfigContent -replace "static const int buildNumber = \d+;", "static const int buildNumber = $newBuild;"
        $appConfigContent | Set-Content $appConfigPath -NoNewline
        Write-Host "[OK] Versi di $appConfigPath diperbarui ke $newVersionName" -ForegroundColor Green
    }

    $versionName = $newVersionName
    $fullVersion = $newFullVersion
}

Write-Host "[OK] Versi target release: $versionName (Build: $fullVersion)" -ForegroundColor Green

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
    $buildArgs = @("build", "apk", "--release", "--obfuscate", "--split-debug-info=build/app/outputs/symbols")
    if (Test-Path ".env") {
        $buildArgs += "--dart-define-from-file=.env"
    }
    flutter @buildArgs
    
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
$namedApkName = "AppliQ-v$versionName-release.apk"
$namedApkPath = "build\app\outputs\flutter-apk\$namedApkName"

if (Test-Path $apkSource) {
    Copy-Item -Path $apkSource -Destination $namedApkPath -Force
    Write-Host "[OK] Menyiapkan paket rilis bernama: $namedApkName" -ForegroundColor Green
}

# 4. Sinkronisasi Versi di Landing Page (public\index.html)
Write-Host "--- Sinkronisasi Versi di Landing Page ---" -ForegroundColor Yellow
$indexPath = "public\index.html"
if (Test-Path $indexPath) {
    $content = Get-Content $indexPath -Raw
    $newContent = $content
    
    # Ganti {{VERSION}} jika ada
    $newContent = $newContent -replace '\{\{VERSION\}\}', $versionName
    
    # Ganti link download rilis APK ke AppliQ-vX.X.X-release.apk
    $newContent = $newContent -replace 'releases/download/v[^/]+/[^"''\s`]+\.apk', "releases/download/v$versionName/$namedApkName"
    
    # Ganti teks versi di button badge, button text, dan QR card footer
    $newContent = $newContent -replace '<span>v[0-9]+\.[0-9]+\.[0-9]+</span>', "<span>v$versionName</span>"
    $newContent = $newContent -replace '<span>v\{\{VERSION\}\}</span>', "<span>v$versionName</span>"
    $newContent = $newContent -replace '<span>v[0-9]+\.[0-9]+\.[0-9]+(\+[0-9]+)?\s+RELEASE</span>', "<span>v$versionName RELEASE</span>"
    $newContent = $newContent -replace '<span>v\{\{VERSION\}\}\s+RELEASE</span>', "<span>v$versionName RELEASE</span>"
    $newContent = $newContent -replace 'Download (Free )?APK \(v[0-9]+\.[0-9]+\.[0-9]+\)', "Download APK (v$versionName)"
    $newContent = $newContent -replace 'Download (Free )?APK \(v\{\{VERSION\}\}\)', "Download APK (v$versionName)"
    $newContent = $newContent -replace 'aria-label="Download AppliQ version [^"]+"', "aria-label=""Download AppliQ version $versionName"""

    if ($newContent -ne $content) {
        $newContent | Set-Content $indexPath -NoNewline
        Write-Host "[OK] Versi di public\index.html berhasil diperbarui ke v$versionName" -ForegroundColor Green
    } else {
        Write-Host "[INFO] Versi di public\index.html sudah sesuai (v$versionName)." -ForegroundColor Gray
    }
}

# Auto-commit jika ada file versi yang berubah akibat auto-bump
$status = git status --porcelain pubspec.yaml lib/core/config/app_config.dart public/index.html
if ($status) {
    Write-Host "[GIT] Menyimpan perubahan versi ke git..." -ForegroundColor Cyan
    git add pubspec.yaml lib/core/config/app_config.dart public/index.html
    git commit -m "chore(release): bump version to v$versionName" 2>$null
}

# 5. Sinkronisasi Git Commit ke GitHub
Write-Host "--- Mengunggah Commit ke GitHub ---" -ForegroundColor Yellow
git push origin main

# 6. Buat GitHub Release dan Upload File APK
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

    Write-Host "Mengunggah paket APK ($namedApkName) ke repositori GitHub Releases..." -ForegroundColor Cyan
    & $ghPath release create "v$versionName" $namedApkPath $binSource --title "AppliQ v$versionName" --notes $notes

    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] Membuat GitHub Release Gagal!" -ForegroundColor Red
    } else {
        Write-Host "[OK] Berhasil upload ke GitHub Releases!" -ForegroundColor Green
    }
} else {
    Write-Host "[WARN] GitHub CLI tidak ditemukan. Melewati upload release." -ForegroundColor Yellow
}

Write-Host "`n[OK] Selesai! Versi AppliQ v$versionName siap." -ForegroundColor DarkGreen
Write-Host "Link Web Landing Page  : https://myusiz3.github.io/AppliQ/" -ForegroundColor Cyan
Write-Host "Link Download APK Rilis: https://github.com/MyusiZ3/AppliQ/releases/download/v$versionName/$namedApkName" -ForegroundColor Cyan
