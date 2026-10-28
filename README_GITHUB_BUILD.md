# Build RW GACOR APK with GitHub Actions

This package includes a GitHub Actions workflow that attempts to build a **debug APK** and verify its Android APK signature. It does not claim the build has passed until the workflow actually runs successfully.

## Steps
1. Create a new repository on GitHub.
2. Upload the contents of this ZIP to the repository root (not the ZIP file itself). Make sure `.github/workflows/android-apk.yml` is included. If uploading from a phone, GitHub's web editor can add files, but uploading a ZIP as a single file will not activate the workflow.
3. Commit to `main` or `master`, or open **Actions → Build RW GACOR APK → Run workflow**.
4. Wait for the workflow to finish. If it fails, open the failed step and save the full log.
5. If successful, open the run summary and download the artifact named `RWGacor-debug-apk`. It contains `app-debug.apk`.

## Important
- This workflow regenerates the Android scaffold if the Gradle wrapper is missing, then restores the app's `MainActivity.kt`, manifest, launcher icon resources, and Shizuku dependencies.
- The build runs on GitHub's runner. It has not been executed or validated in this packaging environment.
- Debug APKs use a debug signing key. They are for testing, not Play Store release. If a differently signed RW GACOR package is already installed, Android may reject installation as an update; uninstalling it can remove app data, so back up anything important first.
