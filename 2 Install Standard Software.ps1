# Set the download directory
$DownloadFolder = "C:\Temp\SW_Downloads"
If (-not (Test-Path -Path $DownloadFolder)) {
    New-Item -ItemType Directory -Path $DownloadFolder
}

# Function to download software with error handling
function Download-Software {
    param (
        [string]$SoftwareName,
        [string]$DownloadUrl
    )

    # Assume the URL directly points to the correct file for simplicity
    $fileName = [System.IO.Path]::GetFileName($DownloadUrl)
    $SoftwarePath = Join-Path -Path $DownloadFolder -ChildPath $fileName

    Write-Host "Attempting to download $SoftwareName..."
    try {
        Invoke-WebRequest -Uri $DownloadUrl -OutFile $SoftwarePath -UseBasicParsing
        Write-Host "$SoftwareName downloaded successfully to $SoftwarePath."
    } catch {
        Write-Host "Failed to download $SoftwareName. Error: $_"
        $SoftwarePath = $null  # Prevent installation attempt on failure
    }

    return $SoftwarePath
}


# Function to install software silently
function Install-Software {
    param (
        [string]$SoftwarePath,
        [string]$InstallArguments
    )
    if (-not [string]::IsNullOrWhiteSpace($SoftwarePath)) {
        Write-Host "Installing $SoftwarePath silently..."
        Start-Process -FilePath $SoftwarePath -ArgumentList $InstallArguments -Wait -PassThru
        Write-Host "$SoftwarePath installation completed."
    } else {
        Write-Host "Installation path for software is null or empty. Skipping installation."
    }
}

# Software options with download URLs and silent install commands
$softwareOptions = @{
    "Chrome" = @{
        Url = "https://dl.google.com/chrome/install/latest/chrome_installer.exe";
        InstallArgs = "/silent /install";
    };
    "Chrome RDP" = @{
        Url = "https://dl.google.com/dl/edgedl/chrome-remote-desktop/chromeremotedesktophost.msi";
        InstallArgs = "/quiet /norestart";
    };
    "Google Drive" = @{
        Url = "https://dl.google.com/drive-file-stream/GoogleDriveSetup.exe";
        InstallArgs = "--silent --desktop_shortcut --skip_launch_new --gsuite_shortcuts=true";
    };
    "Slack" = @{
        #Url = "https://slack.com/ssb/download-win64-msi";
        Url = "https://downloads.slack-edge.com/releases/windows/4.36.140/prod/x64/slack-standalone-4.36.140.0.msi";
        InstallArgs = "INSTALLLEVEL=2 /quiet /norestart";
    };
    "Zoom" = @{
        Url = "https://zoom.us/client/latest/ZoomInstallerFull.msi?archType=x64";
        InstallArgs = "/quiet /qn /norestart";
    };
    "Adobe Acrobat" = @{
        Url = "ftp://ftp.adobe.com/pub/adobe/reader/win/AcrobatDC/2001320064/AcroRdrDC2001320064_en_US.exe";
        InstallArgs = "/sAll /rs /msi EULA_ACCEPT=YES";
    };
    "Google Enterprise Login" = @{
        Url = "https://files.pp.eco/PlanetGSuiteEnterpriseLoginInstaller.exe";
        InstallArgs = "/install";
    };
    "Cloudflare WARP" = @{
        Url = "https://files.pp.eco/Cloudflare_WARP_Release-x64.msi";
        InstallArgs = "/qn ORGANIZATION=`"planetfoundation`" ONBOARDING=`"false`" AUTO_CONNECT=`"30`"";
    };
    "sipgate" = @{
        Url = "https://sipgate-desktop-app.s3.eu-central-1.amazonaws.com/sipgate-softphone.exe";
        InstallArgs = "/S"; # Assuming '/S' for silent installation. Verify the correct argument for SIPgate
    };
    

    # Add more software options here
}

# Collect user consents
$selectedSoftware = @()
foreach ($software in $softwareOptions.GetEnumerator()) {
    $userChoice = Read-Host "Would you like to install $($software.Key)? (y/n) [Default: y]"
    # If the user presses Enter without a choice, or chooses 'y', proceed with installation
    if ($userChoice -eq '' -or $userChoice.ToLower() -eq 'y') {
        $userChoice = 'y'
    } else {
        $userChoice = 'n'
    }

    if ($userChoice -eq 'y') {
        $selectedSoftware += $software
    }
}

# Download and install selected software
foreach ($software in $selectedSoftware) {
    $softwarePath = Download-Software -SoftwareName $software.Key -DownloadUrl $software.Value.Url
    Install-Software -SoftwarePath $softwarePath -InstallArguments $software.Value.InstallArgs
}

Write-Host "Software installation process completed."
