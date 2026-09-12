# F-Droid Submission & Build Guide

This document explains how **CheckerChecks** is configured for distribution on [F-Droid](https://f-droid.org) and how to submit it to the official `fdroiddata` repository or IzzyOnDroid.

---

## 📋 Inclusion Requirements Satisfied

| Requirement | Status | Details |
|---|---|---|
| **Free / Open Source License** | ✅ Done | [LICENSE](file:///Users/christembassyabujazone1/projects/CheckerChecks/LICENSE) (MIT License) in root. |
| **Unique Package ID** | ✅ Done | `com.checkerchecks.checkerchecks` configured in [build.gradle.kts](file:///Users/christembassyabujazone1/projects/CheckerChecks/android/app/build.gradle.kts). |
| **No Mandatory Proprietary Blobs** | ✅ Done | The app is 100% offline-first. Firebase cloud sync is optional and guarded; `com.google.gms.google-services` is conditionally applied in gradle only when `google-services.json` is present. |
| **App Branding & Human Label** | ✅ Done | `android:label="CheckerChecks"` configured in [AndroidManifest.xml](file:///Users/christembassyabujazone1/projects/CheckerChecks/android/app/src/main/AndroidManifest.xml). |
| **Fastlane Metadata** | ✅ Done | Stored in [`fastlane/metadata/android/en-US/`](file:///Users/christembassyabujazone1/projects/CheckerChecks/fastlane/metadata/android/en-US/) (`title.txt`, `short_description.txt`, `full_description.txt`, `images/icon.png`, and screenshots). |
| **F-Droid Package Recipe** | ✅ Done | [`metadata/com.checkerchecks.checkerchecks.yml`](file:///Users/christembassyabujazone1/projects/CheckerChecks/metadata/com.checkerchecks.checkerchecks.yml). |
| **Automated Test Suite** | ✅ Clean | Passes `flutter analyze` and `flutter test` with 0 warnings. |

---

## 🛠️ Building the Release APK Locally

To test a release APK identical to what F-Droid builds:

```bash
# Ensure flutter analytics are disabled (F-Droid standard)
flutter config --no-analytics

# Fetch dependencies
flutter pub get

# Build APK in release mode
flutter build apk --release
```

The compiled APK will be output to:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 🚀 Submitting to Official F-Droid

1. **Tag your release** on Git:
   ```bash
   git tag -a v1.0.0 -m "Release v1.0.0"
   git push origin v1.0.0
   ```

2. **Fork [`fdroiddata`](https://gitlab.com/fdroid/fdroiddata)** on GitLab.

3. **Add the metadata recipe**:
   Copy [`metadata/com.checkerchecks.checkerchecks.yml`](file:///Users/christembassyabujazone1/projects/CheckerChecks/metadata/com.checkerchecks.checkerchecks.yml) into the `metadata/` directory of your `fdroiddata` clone:
   ```bash
   git checkout -b add-checkerchecks
   cp metadata/com.checkerchecks.checkerchecks.yml <path-to-fdroiddata>/metadata/com.checkerchecks.checkerchecks.yml
   git commit -m "Add com.checkerchecks.checkerchecks"
   git push origin add-checkerchecks
   ```

4. **Verify using `fdroid build`** (optional, if you have `fdroidserver` installed):
   ```bash
   fdroid checkupdates com.checkerchecks.checkerchecks
   fdroid build -v -s com.checkerchecks.checkerchecks
   ```

5. **Open a Merge Request**:
   Submit a Merge Request to `fdroid/fdroiddata` on GitLab. The F-Droid CI pipeline will automatically test and verify the recipe.
