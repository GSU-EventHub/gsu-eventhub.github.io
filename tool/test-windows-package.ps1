# Test the extracted distributable on windows-latest before publishing a release.
param([string]$PackagePath = "dist/GSU-EventHub-Windows-x64")
$ErrorActionPreference = "Stop"
$process = Start-Process -FilePath (Join-Path $PackagePath "GSU-EventHub.exe") -ArgumentList "-no-browser" -PassThru
try {
    $ready = $false
    for ($i = 0; $i -lt 30; $i++) {
        if ($process.HasExited) { throw "Launcher exited: $($process.ExitCode)" }
        try {
            $health = Invoke-WebRequest "http://127.0.0.1:47831/__eventhub_health" -UseBasicParsing
            if ($health.Content -eq "GSU-EventHub-1") { $ready = $true; break }
        } catch { Start-Sleep -Milliseconds 500 }
    }
    if (-not $ready) { throw "Packaged server failed readiness check" }
    foreach ($path in @("/", "/flutter_bootstrap.js", "/main.dart.js", "/assets/AssetManifest.bin", "/assets/assets/fonts/Roboto-Regular.ttf", "/canvaskit/canvaskit.wasm")) {
        $response = Invoke-WebRequest "http://127.0.0.1:47831$path" -UseBasicParsing
        if ($response.StatusCode -ne 200 -or $response.RawContentLength -eq 0) { throw "Asset check failed: $path" }
    }
    if (-not (Invoke-WebRequest "http://127.0.0.1:47831/" -UseBasicParsing).Content.Contains("GSU EventHub")) { throw "Wrong application" }
    $env:EVENTHUB_URL = "http://127.0.0.1:47831/"
    node tool/browser/check.cjs
    if ($LASTEXITCODE -ne 0) { throw "Packaged application browser checks failed" }
    Write-Host "Windows x64 executable served the compiled app, assets, and passed browser checks."
} finally {
    if (-not $process.HasExited) { Stop-Process -Id $process.Id -Force }
}
