# Source from the repository when building Android in this cloud.
source /workspace/gsu-eventhub.github.io/tool/cloud-env.sh
export ANDROID_HOME=/workspace/tools/android-sdk
export ANDROID_USER_HOME=/workspace/.android
export ANDROID_AVD_HOME=/workspace/.android/avd
export GRADLE_USER_HOME=/workspace/.gradle
export JAVA_HOME=/workspace/tools/jdk-17
export XDG_CACHE_HOME=/workspace/.cache
export XDG_DATA_HOME=/workspace/.local/share
export XDG_STATE_HOME=/workspace/.local/state
export XDG_BIN_HOME=/workspace/.local/bin
export PATH="$JAVA_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"
export JAVA_TOOL_OPTIONS="${JAVA_TOOL_OPTIONS:-} -Djava.util.prefs.userRoot=/workspace/.java-prefs -Djavax.net.ssl.trustStore=/etc/ssl/certs/java/cacerts"
# Gradle's JVM does not automatically use HTTPS_PROXY. Keep downloads on the
# managed session proxy, with normal TLS validation and its existing trust store.
export GRADLE_OPTS="${GRADLE_OPTS:-} -Dhttp.proxyHost=proxy -Dhttp.proxyPort=8080 -Dhttps.proxyHost=proxy -Dhttps.proxyPort=8080"
