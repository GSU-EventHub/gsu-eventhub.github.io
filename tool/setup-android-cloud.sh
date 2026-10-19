#!/usr/bin/env bash
set -euo pipefail
cd /workspace/gsu-eventhub.github.io
source tool/android-cloud-env.sh
if [[ ! -x "$JAVA_HOME/bin/javac" ]]; then
  archive=$(mktemp /tmp/eventhub-jdk.XXXXXX.tar.gz)
  curl --fail --location https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.20.1%2B1/OpenJDK17U-jdk_x64_linux_hotspot_17.0.20.1_1.tar.gz --output "$archive"
  echo "3808d1d15e3ec6bd5b84057fb5d84c33d8a1536a258146bcea2e603fc726e08e  $archive" | sha256sum --check
  mkdir -p "$JAVA_HOME"
  tar -xzf "$archive" --strip-components=1 -C "$JAVA_HOME"
  rm "$archive"
fi
mkdir -p "$ANDROID_HOME/cmdline-tools"
if [[ ! -x "$ANDROID_HOME/cmdline-tools/latest/bin/android" ]]; then
  archive=$(mktemp /tmp/eventhub-android-tools.XXXXXX.zip)
  curl --fail --location https://dl.google.com/android/repository/commandlinetools-linux-16111833_latest.zip --output "$archive"
  # Official repository2-3.xml checksum for this exact Linux tools archive.
  echo "e025545c62a8e64c7559119566a569fb1dec5f60  $archive" | sha1sum --check
  unzip -q "$archive" -d "$ANDROID_HOME/cmdline-tools"
  mv "$ANDROID_HOME/cmdline-tools/cmdline-tools" "$ANDROID_HOME/cmdline-tools/latest"
  rm "$archive"
fi
android --no-metrics --sdk="$ANDROID_HOME" sdk install \
  platforms/android-36 platforms/android-35 build-tools/36.0.0 \
  build-tools/35.0.0 ndk/28.2.13676358 cmake/3.22.1 platform-tools
flutter config --enable-android --android-sdk "$ANDROID_HOME" --jdk-dir "$JAVA_HOME" --no-analytics
flutter precache --android
flutter pub get --enforce-lockfile
