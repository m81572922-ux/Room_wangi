#!/usr/bin/env bash
set -euo pipefail

# Run this from the RWGacorFlutter project root.
if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter SDK tidak ditemukan. Install Flutter dan pastikan perintah 'flutter' tersedia di PATH."
  exit 1
fi

# Generate the official Android platform files for this Flutter project.
flutter create --platforms=android --project-name rw_gacor .
flutter pub get
echo
echo "Persiapan selesai. Build APK dengan:"
echo "  flutter build apk --release"
