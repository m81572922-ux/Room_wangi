$ErrorActionPreference = "Stop"

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  Write-Error "Flutter SDK tidak ditemukan. Install Flutter dan pastikan perintah 'flutter' tersedia di PATH."
  exit 1
}

flutter create --platforms=android --project-name rw_gacor .
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

flutter pub get
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host ""
Write-Host "Persiapan selesai. Build APK dengan:"
Write-Host "  flutter build apk --release"
