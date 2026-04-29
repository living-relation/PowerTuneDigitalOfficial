$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$simulator = Join-Path $scriptDir "NeedleSimulator.qml"

if (-not (Test-Path $simulator)) {
    Write-Error "Needle simulator not found at: $simulator"
}

function Get-QtLauncher {
    $cmdQmlscene = Get-Command qmlscene -ErrorAction SilentlyContinue
    if ($cmdQmlscene) {
        return @{ exe = $cmdQmlscene.Source; mode = "qmlscene" }
    }

    $cmdQml = Get-Command qml -ErrorAction SilentlyContinue
    if ($cmdQml) {
        return @{ exe = $cmdQml.Source; mode = "qml" }
    }

    $candidates = @()

    if ($env:QTDIR) {
        $candidates += (Join-Path $env:QTDIR "bin\qmlscene.exe")
        $candidates += (Join-Path $env:QTDIR "bin\qml.exe")
    }

    $roots = @(
        "$env:SystemDrive\Qt",
        "$env:ProgramFiles\Qt",
        "${env:ProgramFiles(x86)}\Qt"
    ) | Where-Object { $_ -and (Test-Path $_) }

    foreach ($root in $roots) {
        $candidates += Get-ChildItem -Path $root -Recurse -Filter "qmlscene.exe" -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName }
        $candidates += Get-ChildItem -Path $root -Recurse -Filter "qml.exe" -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName }
    }

    $qmlscenePath = $candidates | Where-Object { $_ -match "qmlscene\.exe$" } | Select-Object -First 1
    if ($qmlscenePath) {
        return @{ exe = $qmlscenePath; mode = "qmlscene" }
    }

    $qmlPath = $candidates | Where-Object { $_ -match "qml\.exe$" } | Select-Object -First 1
    if ($qmlPath) {
        return @{ exe = $qmlPath; mode = "qml" }
    }

    return $null
}

$launcher = Get-QtLauncher
if (-not $launcher) {
    Write-Host ""
    Write-Host "Could not find a Qt QML runtime (qmlscene/qml)." -ForegroundColor Yellow
    Write-Host "Install Qt (with qmlscene or qml in PATH), then run this script again." -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

Write-Host "Launching NeedleSimulator with $($launcher.exe)"

if ($launcher.mode -eq "qmlscene") {
    Start-Process -FilePath $launcher.exe -ArgumentList @($simulator) -WorkingDirectory $scriptDir
} else {
    Start-Process -FilePath $launcher.exe -ArgumentList @($simulator) -WorkingDirectory $scriptDir
}

Write-Host "Started."
