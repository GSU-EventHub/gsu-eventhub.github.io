#!/usr/bin/env bash
set -euo pipefail
cd /workspace/gsu-eventhub.github.io
source tool/cloud-env.sh
mkdir -p /workspace/tools "$PUB_CACHE" "$XDG_CONFIG_HOME"
if [[ ! -x /workspace/tools/flutter-3.47.7/bin/flutter ]]; then
  git clone --depth 1 --branch 3.47.7 https://github.com/flutter/flutter.git /workspace/tools/flutter-3.47.7
  git -C /workspace/tools/flutter-3.47.7 switch -c stable
fi
# Assert the immutable official tag rather than silently upgrading stable.
test "$(git -C /workspace/tools/flutter-3.47.7 rev-parse HEAD)" = abaf9c523780a608bd46686fd5e53740a07077f8
flutter --version
flutter config --enable-web --no-analytics
flutter precache --web
flutter pub get --enforce-lockfile

if [[ ! -x /workspace/tools/go/bin/go ]]; then
  archive=$(mktemp /tmp/eventhub-go.XXXXXX.tar.gz)
  curl --fail --location https://go.dev/dl/go1.27.2.linux-amd64.tar.gz --output "$archive"
  echo "ecbadb99091a3f46e31f5f934b068b1864eafa7995211b39eaddf76996045fe5  $archive" | sha256sum --check
  tar -xzf "$archive" -C /workspace/tools
  rm "$archive"
fi
go version
npm ci --prefix tool/browser --cache /workspace/.npm-cache
