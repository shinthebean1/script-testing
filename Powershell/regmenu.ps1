Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process -Force

Clear-Host
$Host.UI.RawUI.WindowTitle = "Registry Menu"

Write-Host "Checking for admin rights.."
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Prompting UAC.."
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$currenttime = Get-Date -DisplayHint Date

$null = New-Module {
    function Invoke-WithoutProgress {
        [CmdletBinding()]
        param (
            [Parameter(Mandatory)] [scriptblock] $ScriptBlock
        )

        $prevProgressPreference = $global:ProgressPreference
        $global:ProgressPreference = 'SilentlyContinue'

        try {
            . $ScriptBlock
        }
        finally {
            $global:ProgressPreference = $prevProgressPreference
        }
    }
}

Clear-Host
$Host.UI.RawUI.WindowTitle = "Registry Menu"

function regmenu {
    Clear-Host ""
    Write-Host "======================="
    Write-Host "     REGISTRY MENU     "
    Write-Host "======================="
    Write-Host ""

    Write-Host "[1] Create a Restore Point
[2] Backup Registry
[3] Import Backup"
    Write-Host ""
    $firstprompt = Read-Host "Select an option"

    if ($firstprompt -eq "1") {
        restorepoint
    }
    elseif ($firstprompt -eq "2") {
        regbackup
    }
    elseif ($firstprompt -eq "3") {
        importbackup
    }
    else {
        Write-Host "The option you have selected isn't valid."
        pause
        regmenu
    }
}

function restorepoint {
    Write-Host ""
    $restoredesc = Read-Host "What would you like to name your Restore Point"
    $descriptioncheck = "$restoredesc"
    $restorePoints = Get-ComputerRestorePoint
    
    # Check if any restore point matches the specified description
    if ($restorePoints | Where-Object { $_.Description -eq $descriptioncheck }) {
        Write-Host "Restore point with description '$descriptioncheck' already exists."
        pause
        regmenu
    }
    else {
        Write-Host ""
        Write-Host "Creating restore point.."
    }
    
    Invoke-WithoutProgress {
        $driveSpecs = 
        Get-CimInstance -Class Win32_LogicalDisk -ErrorAction SilentlyContinue |
        Where-Object { $_.DriveType -eq 3 } | 
        ForEach-Object { $_.Name + '\' }
  
        Enable-ComputerRestore $driveSpecs -ErrorAction SilentlyContinue

    }
    try {
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" -Name "SystemRestorePointCreationFrequency" -Force > $null
    }
    catch {
        Write-Host "There was an error while removing the registry key that disbles SystemRestorePoint Frequency.."
        pause
        regmenu
    }

    try {
        New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore\" -Name "SystemRestorePointCreationFrequency" -Value 0 -Force > $null
    }
    catch {
        Write-Host "There was an error while creating a registry key to disable SystemRestorePoint Frequency.."
        pause
        regmenu
    }

    try {
        Invoke-WithoutProgress {
            Checkpoint-Computer -Description "$restoredesc" -RestorePointType MODIFY_SETTINGS
        }
    }
    catch {
        Write-Host "There was an error while creating a system restorepoint."
        pause
        regmenu
    }

    Write-Host "Restore Point Creation with description "$restoredesc" has been created at $currenttime"
    pause
    regmenu
}


function regbackup { 
    Write-Host ""
    $env:DOCUMENTS = [Environment]::GetFolderPath("mydocuments")
    $regbackupname = Read-Host "What would you like to rename the registry backup"
    if ($regbackupname -like "*.reg*") {
        Write-Host "Backup name cannot contain .reg."
        pause
        regmenu
    }

    if (-not (Test-Path "$env:DOCUMENTS\Registry Backups")) {
        try {
            New-Item -Path "$env:DOCUMENTS\Registry Backups" -ItemType Directory -Force | Out-Null
        }
        catch {
            Write-Host "Unable to create registry backups folder."
            pause
            regmenu
        }
    }


    Write-Host ""
    Write-Host "Backing up registry.. This can take ~15 minutes"
    Write-Host ""
    reg export HKLM "$env:DOCUMENTS\Registry Backups\HKLM_$regbackupname.reg" | Out-Null
    Write-Host "1/5 Complete | HKLM"
    reg export HKCU "$env:DOCUMENTS\Registry Backups\HKCU_$regbackupname.reg" | Out-Null
    Write-Host "2/5 Complete | HKCU"
    reg export HKCR "$env:DOCUMENTS\Registry Backups\HKCR_$regbackupname.reg" | Out-Null
    Write-Host "3/5 Complete | HKCR"
    reg export HKCC "$env:DOCUMENTS\Registry Backups\HKCC_$regbackupname.reg" | Out-Null
    Write-Host "4/5 Complete | HKCC"
    reg export HKU "$env:DOCUMENTS\Registry Backups\HKU_$regbackupname.reg" | Out-Null
    Write-Host "5/5 Complete | HKU"
    Write-Host ""
    Write-Host "Registry Backup has completed, saved to $env:DOCUMENTS\Registry Backups"
    pause
    regmenu
}

function importbackup {
    Write-Host ""
    Write-Host "Searching for .reg files on your system to be used as an import.."
    $env:DOCUMENTS = [Environment]::GetFolderPath("mydocuments")

    Get-ChildItem "$env:DOCUMENTS\Registry Backups\" | Out-GridView -Title 'Choose a file' -PassThru | ForEach-Object { $_.FullName }
    $filenames = @(Get-ChildItem "$env:DOCUMENTS\Registry Backups\" | Out-GridView -Title 'Choose a file' -PassThru)
    Write-Host "You chose: $filenames"
    $importprompt = Read-Host "Are you sure that you want to proceed with restoring the registry with that file? (Y/N) "
    $restorecomplete = false

    if ($importprompt -eq "Y") {
        Write-H
        restorepoint
    } elseif ($importprompt -eq "y") {
        restorepoint
    } elseif ($importprompt -eq "N") {
        regmenu
    } elseif ($importprompt -eq "n") {
        regmenu
    }
}

regmenu