# GSU EventHub Android download

This branch contains the compiled Android classroom/test application. The Flutter/Dart source is on the [main branch](https://github.com/GSU-EventHub/gsu-eventhub.github.io/tree/main).

## Download and install

[Download GSU-EventHub-Android.apk](https://github.com/GSU-EventHub/gsu-eventhub.github.io/raw/refs/heads/android-apk/GSU-EventHub-Android.apk)

Requires Android 7.0 or newer. Open the APK on your Android phone and allow installation from that file source if prompted. No Flutter, Android Studio, account, browser, or internet connection is needed to use the application. This is not an iPhone/iOS package.

The app starts empty and saves events in app-private device files. Android and website planners are separate. Uninstalling or clearing app data deletes its events.

## Build and verification

Compiled with Flutter 3.47.7 and Dart, Android SDK 35/36, and Java 17 from source commit a6abcf900ef0df71931a62c2c6cac7bd4b9eaa29. The APK contains the native Flutter engine and compiled Dart application, rather than a WebView or browser launcher.

All 18 unit/widget tests, the web build/browser suite, local Android release compilation, and APK signature/assets/offline-permission inspection passed. Android runtime checks are still in progress; physical-phone testing remains unverified. GitHub Actions is queued during reported degraded performance. This is a classroom/test preview, not a claim that all Android device checks are complete.

This release-optimized APK uses a development certificate. Stable signing across CI builds and Play Store publication are not configured. A later APK with a different certificate may require uninstalling, which deletes local events. Retain the current APK while its data matters. The private signing key is not included here.
