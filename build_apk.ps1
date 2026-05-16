# Pixel Town — Android APK build helper.
#
# Usage:
#   .\build_apk.ps1                                    # use bundled default Godot path
#   .\build_apk.ps1 -Install                           # build + adb install -r
#   .\build_apk.ps1 -GodotPath "C:\path\to\Godot.exe"  # override Godot binary
#
# This script will:
#   1. Patch your Godot editor settings with Android SDK + JDK paths (idempotent).
#   2. Run Godot in headless mode to export an Android debug APK.
#   3. Print the output APK path and an `adb install` command (or run it with -Install).

param(
    [string]$GodotPath = "C:\Users\wysoc\Downloads\Godot_v4.6.2-stable_win64.exe\Godot_v4.6.2-stable_win64_console.exe",
    [switch]$Install
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $GodotPath)) {
    Write-Error "Godot not found at $GodotPath"
    exit 1
}

$projectDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$buildDir   = Join-Path $projectDir "build"
$apkOut     = Join-Path $buildDir "pixel_town.apk"
$editorSettings = "$env:APPDATA\Godot\editor_settings-4.6.tres"
if (-not (Test-Path $editorSettings)) {
    # Fall back to the older filename if 4.6-specific settings haven't been created yet.
    $editorSettings = "$env:APPDATA\Godot\editor_settings-4.tres"
}
$jbr        = "C:\Program Files\Android\Android Studio\jbr"
$androidSdk = "$env:LOCALAPPDATA\Android\Sdk"
$keystore   = "$env:USERPROFILE\.android\debug.keystore"
$adb        = Join-Path $androidSdk "platform-tools\adb.exe"

Write-Host "Godot:        $GodotPath"
Write-Host "Project:      $projectDir"
Write-Host "JBR (JDK):    $jbr"
Write-Host "Android SDK:  $androidSdk"
Write-Host "Keystore:     $keystore"

# Sanity-check Android prereqs.
foreach ($req in @($jbr, $androidSdk, $keystore)) {
    if (-not (Test-Path $req)) {
        Write-Error "Missing required path: $req"
        exit 1
    }
}

# Patch editor_settings-4.tres so the Godot CLI knows where the SDK + JDK live.
if (Test-Path $editorSettings) {
    Write-Host "Patching $editorSettings..."
    $content = Get-Content $editorSettings -Raw
    $jbrEsc       = $jbr.Replace('\', '/')
    $androidSdkEsc = $androidSdk.Replace('\', '/')
    $keystoreEsc  = $keystore.Replace('\', '/')
    $content = $content -replace 'export/android/java_sdk_path = ".*"',     "export/android/java_sdk_path = `"$jbrEsc`""
    $content = $content -replace 'export/android/android_sdk_path = ".*"',  "export/android/android_sdk_path = `"$androidSdkEsc`""
    $content = $content -replace 'export/android/debug_keystore = ".*"',    "export/android/debug_keystore = `"$keystoreEsc`""
    # Ensure the debug_keystore_user line exists (Godot 4.6 omits it from
    # the default tres but the Android exporter still expects it).
    if ($content -notmatch 'export/android/debug_keystore_user') {
        $insertLine = 'export/android/debug_keystore_user = "androiddebugkey"'
        $content = $content -replace '(export/android/debug_keystore_pass = "[^"]*")', "$insertLine`r`n`$1"
    }
    # Use .NET to write UTF-8 *without BOM*. Windows PowerShell 5.1's
    # `Set-Content -Encoding utf8` prepends a BOM and Godot's .tres parser
    # rejects it ("Expected '[' on line 1").
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($editorSettings, $content, $utf8NoBom)
}

# Ensure output dir exists.
if (-not (Test-Path $buildDir)) {
    New-Item -ItemType Directory -Path $buildDir | Out-Null
}

# Build the APK headless.
# Note: Godot writes plenty of harmless warnings to stderr during export. Don't
# pipe `2>&1` while $ErrorActionPreference="Stop" — PowerShell would treat each
# stderr line as a fatal NativeCommandError and abort before the APK is written.
$prevEAP = $ErrorActionPreference
$ErrorActionPreference = "Continue"
Push-Location $projectDir
try {
    Write-Host "Importing assets (first pass)..."
    & $GodotPath --headless --path "$projectDir" --import
    $importExit = $LASTEXITCODE
    Write-Host "Exporting debug APK..."
    & $GodotPath --headless --path "$projectDir" --export-debug "Android" "$apkOut"
    $exportExit = $LASTEXITCODE
} finally {
    Pop-Location
    $ErrorActionPreference = $prevEAP
}

if ($importExit -ne 0) {
    Write-Warning "Godot --import returned exit $importExit (continuing)."
}
if ($exportExit -ne 0) {
    Write-Warning "Godot --export-debug returned exit $exportExit."
}

if (-not (Test-Path $apkOut)) {
    Write-Error "APK was not produced. Check the Godot output above for errors."
    exit 1
}

$size = [math]::Round((Get-Item $apkOut).Length / 1MB, 1)
Write-Host ""
Write-Host "APK built: $apkOut  (${size} MB)" -ForegroundColor Green
Write-Host ""

if ($Install) {
    if (-not (Test-Path $adb)) {
        Write-Error "adb not found at $adb"
        exit 1
    }
    Write-Host "Checking for connected device..." -ForegroundColor Cyan
    $devices = & $adb devices | Select-String -Pattern "\sdevice$"
    if ($devices.Count -eq 0) {
        Write-Error "No Android device detected by adb. Connect a device with USB debugging enabled."
        exit 1
    }
    Write-Host "Installing APK on device..." -ForegroundColor Cyan
    & $adb install -r "$apkOut"
    if ($LASTEXITCODE -ne 0) {
        Write-Error "adb install failed (exit $LASTEXITCODE)."
        exit 1
    }
    Write-Host "Install complete." -ForegroundColor Green
} else {
    Write-Host "Install on a connected Android device:" -ForegroundColor Cyan
    Write-Host "  $adb install -r `"$apkOut`""
    Write-Host "  (or re-run with: .\build_apk.ps1 -Install)"
}
