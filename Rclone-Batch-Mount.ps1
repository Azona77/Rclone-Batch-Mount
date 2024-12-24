Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
# Define drive labels and other configurable parameters
$driveLabels = @('WD Elements', 'Samsung USB', 'portable2', 'portable3', 'Other Drive Name')
# rclone path relative to the portable hard drive(folder containing rclone.exe)
$relativeRclonePath = "tool\rclone"

$rcloneCacheDir = "C:\Temp\Rclone_cache"
# rclone mounts
$command = "rclone"
$mount_1 = "mount", "rclone_local:", "S:", "--vfs-cache-mode", "full", "--cache-dir", "C:\Temp\Rclone_cache"
$mount_2 = "mount", "rclone_cloud:", "T:", "--vfs-cache-mode", "full", "--cache-dir", "C:\Temp\Rclone_cache"

# Check if any rclone process is running
$existingRcloneProcess = Get-Process rclone -ErrorAction SilentlyContinue
if ($existingRcloneProcess) {
    # If rclone processes are running, stop them
    $existingRcloneProcess | Stop-Process -Force

    # Check if cache directory is valid and exists
    if ($rcloneCacheDir -and (Test-Path -Path $rcloneCacheDir)) {
        # Remove all contents from rclone cache directory
        Remove-Item -Recurse -Force -Path $rcloneCacheDir
        Write-Output "Successfully deleted rclone cache contents: $rcloneCacheDir"
    } elseif ($rcloneCacheDir) {
        Write-Output "Cache directory is invalid or does not exist: $rcloneCacheDir"
    } else {
        Write-Output "Unable to retrieve rclone cache path. Ensure rclone is configured correctly and accessible in PowerShell."
    }

    # Notify user and exit script
    Write-Host "Rclone process is already running. It will be closed and the script will exit."
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    $notifyIcon = New-Object System.Windows.Forms.NotifyIcon
    $notifyIcon.Icon = [System.Drawing.SystemIcons]::Information
    $notifyIcon.Visible = $true
    $notifyIcon.BalloonTipIcon = 'Info'
    $notifyIcon.BalloonTipTitle = 'Rclone Closed'
    $notifyIcon.BalloonTipText = 'Rclone has been closed and cache deleted.'
    $notifyIcon.ShowBalloonTip(10000)
    $notifyIcon.Dispose()
    exit
}

# Detect drive labels and configure rclone path
foreach ($label in $driveLabels) {
    $UDrive = Get-WmiObject Win32_Volume | Where-Object { $_.Label -eq $label } | Select-Object -ExpandProperty DriveLetter
    if ($UDrive) {
        $fullRclonePath = $UDrive + $relativeRclonePath
        if (Test-Path "$fullRclonePath\rclone.exe") {
            $Env:Path += ";$fullRclonePath"
            Write-Host "Drive for $label found. Using path: $fullRclonePath"
            break
        } else {
            Write-Host "rclone.exe not found in $fullRclonePath"
        }
    }
}

# Use environment variable if no drives are found
if (-not $UDrive) {
    Write-Host "No defined drives found. Using system path in environment variable."
}

# Prompt user for rclone password
$Pass = Read-Host "Enter Rclone password" -AsSecureString
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Pass)
$PlainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

# Set environment variable for rclone password
Set-ItemProperty -Path 'HKCU:\Environment' -Name 'RCLONE_CONFIG_PASS' -Value $PlainPassword

$PlainPassword = [Environment]::GetEnvironmentVariable("RCLONE_CONFIG_PASS", "User")

# Write the password to the environment variable
$Env:RCLONE_CONFIG_PASS = $PlainPassword

Start-Process -FilePath $command -ArgumentList $mount_1 -WindowStyle Hidden
Start-Process -FilePath $command -ArgumentList $mount_2 -WindowStyle Hidden

# Clean up password in environment variable
Remove-ItemProperty -Path 'HKCU:\Environment' -Name 'RCLONE_CONFIG_PASS'
