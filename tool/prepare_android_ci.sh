#!/usr/bin/env bash
set -euo pipefail

# Recreate Android's generated scaffold if the uploaded project lacks Gradle Wrapper.
if [[ -f android/gradlew ]]; then
  chmod +x android/gradlew
  exit 0
fi

TMP_DIR="$(mktemp -d)"
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

# Preserve app-specific Android integration and launcher icon files before regenerating scaffold.
cp android/app/src/main/kotlin/com/example/rwgacor/MainActivity.kt "$TMP_DIR/MainActivity.kt"
cp android/app/src/main/AndroidManifest.xml "$TMP_DIR/AndroidManifest.xml"
mkdir -p "$TMP_DIR/mipmap"
cp -a android/app/src/main/res/mipmap-* "$TMP_DIR/mipmap/" 2>/dev/null || true

rm -rf android
flutter create --platforms=android --project-name rwgacor --org com.example .

# Restore Shizuku integration.
mkdir -p android/app/src/main/kotlin/com/example/rwgacor
cp "$TMP_DIR/MainActivity.kt" android/app/src/main/kotlin/com/example/rwgacor/MainActivity.kt
cp "$TMP_DIR/AndroidManifest.xml" android/app/src/main/AndroidManifest.xml
if compgen -G "$TMP_DIR/mipmap/*" >/dev/null; then
  cp -a "$TMP_DIR"/mipmap/* android/app/src/main/res/
fi

# Add Shizuku libraries to whichever Gradle DSL Flutter generated.
python3 - <<'PY'
from pathlib import Path
p = Path('android/app/build.gradle.kts')
if p.exists():
    s = p.read_text()
    deps = '''\ndependencies {\n    implementation("dev.rikka.shizuku:api:13.1.5")\n    implementation("dev.rikka.shizuku:provider:13.1.5")\n}\n'''
    if 'dev.rikka.shizuku:api' not in s:
        s += deps
    p.write_text(s)
else:
    p = Path('android/app/build.gradle')
    s = p.read_text()
    deps = '''\ndependencies {\n    implementation 'dev.rikka.shizuku:api:13.1.5'\n    implementation 'dev.rikka.shizuku:provider:13.1.5'\n}\n'''
    if 'dev.rikka.shizuku:api' not in s:
        s += deps
    p.write_text(s)
PY

chmod +x android/gradlew
if [[ ! -f android/gradle/wrapper/gradle-wrapper.properties ]]; then
  echo 'ERROR: Gradle wrapper properties were not generated.' >&2
  exit 1
fi
