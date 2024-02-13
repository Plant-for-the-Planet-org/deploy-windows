# Check OS architecture and set OneDrive setup path accordingly
if ([Environment]::Is64BitOperatingSystem) {
    $OneDriveSetupPath = "$env:SYSTEMROOT\SysWOW64\OneDriveSetup.exe"
} else {
    $OneDriveSetupPath = "$env:SYSTEMROOT\System32\OneDriveSetup.exe"
}

# Uninstall OneDrive silently
if (Test-Path $OneDriveSetupPath) {
    Start-Process $OneDriveSetupPath -ArgumentList "/uninstall" -NoNewWindow -Wait
    Write-Host "OneDrive has been uninstalled."
} else {
    Write-Host "OneDrive setup not found."
}

# Remove residual OneDrive directories
$OneDriveFolders = @(
    "$env:UserProfile\OneDrive",
    "$env:LOCALAPPDATA\Microsoft\OneDrive",
    "$env:ProgramData\Microsoft OneDrive"
)

foreach ($folder in $OneDriveFolders) {
    if (Test-Path $folder) {
        Remove-Item $folder -Force -Recurse -ErrorAction SilentlyContinue
        Write-Host "Removed residual folder: $folder"
    }
}

# Prevent OneDrive from being installed for new users (Optional)
# This step involves setting a Group Policy or a registry key. Uncomment the lines below to apply the registry edit.
# Note: This action is more permanent and should be used with understanding of the implications.

# Set registry key to prevent OneDrive setup for new users
# New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Name "DisableFileSyncNGSC" -Value 1 -PropertyType DWORD -Force
# Write-Host "OneDrive setup for new users has been disabled."

Write-Host "OneDrive removal process completed."
