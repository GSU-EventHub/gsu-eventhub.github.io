"""Check the actual APK assets/permissions and optionally launch it on Android."""
import argparse
import os
from pathlib import Path
import subprocess
import time
from zipfile import ZipFile

parser = argparse.ArgumentParser()
parser.add_argument("apk", type=Path)
parser.add_argument("--device")
args = parser.parse_args()
sdk = Path(os.environ["ANDROID_HOME"])
tools = max((sdk / "build-tools").iterdir())


def run(*command):
    return subprocess.check_output(command, text=True, stderr=subprocess.STDOUT)


badging = run(str(tools / "aapt"), "dump", "badging", str(args.apk))
assert "name='io.github.gsu_eventhub.eventhub'" in badging, badging
assert "sdkVersion:'24'" in badging, badging
assert "application-label:'GSU EventHub'" in badging, badging
permissions = run(str(tools / "aapt"), "dump", "permissions", str(args.apk))
assert "android.permission.INTERNET" not in permissions, permissions
assert "EXTERNAL_STORAGE" not in permissions, permissions
with ZipFile(args.apk) as archive:
    assert archive.testzip() is None
    for name in [
        "lib/arm64-v8a/libflutter.so",
        "lib/arm64-v8a/libapp.so",
        "lib/x86_64/libapp.so",
        "assets/flutter_assets/assets/fonts/Inter.ttf",
    ]:
        assert name in archive.namelist(), name
print(run(str(tools / "apksigner"), "verify", "--verbose", str(args.apk)))
print("PASS: signed native Flutter APK, bundled assets, Android 7+, offline permissions.")

if args.device:
    evidence = Path("dist/android-evidence")
    evidence.mkdir(parents=True, exist_ok=True)
    package = "io.github.gsu_eventhub.eventhub"

    def adb(*command):
        return run("adb", "-s", args.device, *command)

    def launch():
        adb("shell", "am", "start", "-W", "-n", f"{package}/.MainActivity")
        for _ in range(5):
            time.sleep(2)
            adb("shell", "uiautomator", "dump", "/sdcard/eventhub-window.xml")
            xml = adb("shell", "cat", "/sdcard/eventhub-window.xml")
            (evidence / "home.xml").write_text(xml)
            if "Your planner" in xml:
                assert "No events yet" in xml, xml
                return
        raise AssertionError("Release app did not display its empty Home screen")

    try:
        adb("logcat", "-c")
        adb("shell", "am", "force-stop", package)
        launch()
        adb("shell", "input", "keyevent", "KEYCODE_BACK")
        time.sleep(1)
        launch()
        adb("shell", "am", "force-stop", package)
        launch()
        with (evidence / "android-home.png").open("wb") as output:
            subprocess.run(
                ["adb", "-s", args.device, "exec-out", "screencap", "-p"],
                stdout=output, check=True,
            )
        print("PASS: actual release APK Home, Android Back, force-stop/relaunch.")
    finally:
        (evidence / "logcat.txt").write_text(adb("logcat", "-d", "-t", "1000"))
