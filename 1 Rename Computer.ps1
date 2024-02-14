# Prompt the user for the Computer ID
$computerID = Read-Host "What is the Computer ID? Type in full eg: Plant-XXX"

# Use the input to rename the computer
# You might need to run PowerShell as Administrator for this to work
Try {
    Rename-Computer -NewName $computerID -Force -ErrorAction Stop
    Write-Host "Computer has been successfully renamed to $computerID"
} Catch {
    Write-Error "Failed to rename the computer. Error: $_"
}

# Add English to List of Windows Language for Keyboard
Set-WinUserLanguageList de-DE,en-US -Force
