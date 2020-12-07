# Project   : Win10DeBloater
# Usecase   : Windows10 Bloatware Remover
# Author    : Sounak 'St4rr3h' Roy
# Email     : mail.roy.sounak@gmail.com
# Github    : www.github.com/sounak-starreh-roy
# LinkedIn  : www.linkedin.com/in/roy-sounak
# Copyright : Free
# Licence   : GNU General Public Licence v3.0

# method to run application as admin
Function RunAsAdmin {
    Start-Process powershell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
}

# method to set application config
Function Config {
    $AppLog = "C:\Win10DeBloater\Logs"
    If (!(Test-Path $AppLog)) {
        New-Item -Path "$DebloatFolder" -ItemType Directory
    }
    Start-Transcript -OutputDirectory "$AppLog"
    Add-Type -AssemblyName PresentationCore, PresentationFramework   
}

# method to uninstall all bloatwares
Function DebloatApps {
    $WinBloatwareList = @(
        # defaults / bloatwares
        "*Microsoft.People*"
        "*Microsoft.Messaging*"
        "*Microsoft.WindowsCommunicationsApps*"
        "*Microsoft.WindowsAlarms*"
        "*Microsoft.News*"
        "*Microsoft.BingNews*"
        "*Microsoft.WindowsMaps*"
        "*Microsoft.HEIFImageExtension*"
        "*Microsoft.WebpImageExtension*"
        "*Microsoft.WindowsSoundRecorder*"
        "*Microsoft.VP9VideoExtensions*"
        "*Microsoft.Paint3D*"
        "*Microsoft.Whiteboard*"
        "*Microsoft.ScreenSketch*"
        "*Microsoft.Microsoft3DViewer*"
        "*Microsoft.Print3D*"
        "*Microsoft.GetHelp*"
        "*Microsoft.Getstarted*"
        "*Microsoft.WindowsFeedbackHub*"
        # media apps
        "*Microsoft.ZuneMusic*"
        "*Microsoft.ZuneVideo*"
        # ads
        "**Microsoft.Advertising.Xaml_10.1712.5.0_x86__8wekyb3d8bbwe*"*
        # office suite
        "*Microsoft.SkypeApp*"
        "*Microsoft.OneConnect*"
        "*Microsoft.Office.Lens*"
        "*Microsoft.Office.Sway*"
        "*Microsoft.Office.OneNote*"
        "*Microsoft.Office.Todo.List*"
        "*Microsoft.MicrosoftOfficeHub*"
        # xbox
        "*Microsoft.XboxApp*"
        "*Microsoft.Xbox.TCUI*"
        "*Microsoft.XboxGameCallableUI*"
        "*Microsoft.XboxGameOverlay*"
        "*Microsoft.XboxGamingOverlay*"
        "*Microsoft.XboxIdentityProvider*"
        "*Microsoft.XboxSpeechToTextOverlay*"
        # third party apps
        "*Slack*"
        "*Spotify*"
        "*Twitter*"
        "*Facebook*"
        "*Minecraft*"
        "*CandyCrush*"
        "*BubbleWitch3Saga*"
        "*Wunderlist*"
        "*EclipseManager*"
        "*PandoraMediaInc*"
        "*Duolingo-LearnLanguagesforFree*"
        "*AdobeSystemsIncorporated.AdobePhotoshopExpress*"
    )
    foreach ($Bloatware in $WinBloatwareList) {
        Get-AppxPackage -Name $Bloatware| Remove-AppxPackage
        Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $Bloatware | Remove-AppxProvisionedPackage -Online
    }
}

# method to remove all unnecessary registry keys
Function DebloatKeys {
    $WinKeysList = @(
        # remove background tasks
        "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\46928bounde.EclipseManager_2.2.4.51_neutral__a5h4egax66k6y"
        "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
        "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.MicrosoftOfficeHub_17.7909.7600.0_x64__8wekyb3d8bbwe"
        "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
        "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
        "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.XboxGameCallableUI_1000.16299.15.0_neutral_neutral_cw5n1h2txyewy"    
        # windows file
        "HKCR:\Extensions\ContractId\Windows.File\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"            
        # registry keys to delete that aren't uninstalled by RemoveAppXPackage/RemoveAppXProvisionedPackage
        "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\46928bounde.EclipseManager_2.2.4.51_neutral__a5h4egax66k6y"
        "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
        "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
        "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\Microsoft.XboxGameCallableUI_1000.16299.15.0_neutral_neutral_cw5n1h2txyewy"          
        # scheduled tasks
        "HKCR:\Extensions\ContractId\Windows.PreInstalledConfigTask\PackageId\Microsoft.MicrosoftOfficeHub_17.7909.7600.0_x64__8wekyb3d8bbwe" 
        # protocol keys
        "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
        "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
        "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\Microsoft.XboxGameCallableUI_1000.16299.15.0_neutral_neutral_cw5n1h2txyewy"     
    )
    foreach ($WinKey in $WinKeysList) {
        Remove-Item $WinKey -Recurse
    }
}

# Method to protect privacy & data collection
Function PrivacyProtect {
    # disable windows feedback experience
    $FeedBack = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\FeedBackvertisingInfo"
    If (Test-Path $FeedBack) {
        Set-ItemProperty $FeedBack Enabled -Value 0 
    }
    # disable windows feedback to send annonymous data
    $WinFeedBack = "HKCU:\Software\Microsoft\Siuf\Rules"
    If (!(Test-Path $WinFeedBack)) { 
        New-Item $WinFeedBack
    }
    Set-ItemProperty $WinFeedBack PeriodInNanoSeconds -Value 0
    # disable diagnostics tracking
    Stop-Service "DiagTrack"
    Set-Service "DiagTrack" -StartupType Disabled
    # disable location tracking
    $Sensor = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}"
    $LocationConf = "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration"
    If (!(Test-Path $Sensor)) {
        New-Item $Sensor
    }
    Set-ItemProperty $Sensor SensorPermissionState -Value 0 
    If (!(Test-Path $LocationConf)) {
        New-Item $LocationConf
    }
    Set-ItemProperty $LocationConf Status -Value 0
    # disable data collection
    $DataCollection1 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
    $DataCollection2 = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
    $DataCollection3 = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection"    
    If (Test-Path $DataCollection1) {
        Set-ItemProperty $DataCollection1  AllowTelemetry -Value 0 
    }
    If (Test-Path $DataCollection2) {
        Set-ItemProperty $DataCollection2  AllowTelemetry -Value 0 
    }
    If (Test-Path $DataCollection3) {
        Set-ItemProperty $DataCollection3  AllowTelemetry -Value 0 
    }
    # disable cortana as default windows search
    $Search = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
    If (Test-Path $Search) {
        Set-ItemProperty $Search AllowCortana -Value 0 
    }
    # disable bloatware from start menu
    $RegistryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
    $RegistryOEM = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
    If (!(Test-Path $RegistryPath)) { 
        New-Item $RegistryPath
    }
    Set-ItemProperty $RegistryPath DisableWindowsConsumerFeatures -Value 1
    If (!(Test-Path $RegistryOEM)) {
        New-Item $RegistryOEM
    }
    Set-ItemProperty $RegistryOEM  ContentDeliveryAllowed -Value 0 
    Set-ItemProperty $RegistryOEM  OemPreInstalledAppsEnabled -Value 0 
    Set-ItemProperty $RegistryOEM  PreInstalledAppsEnabled -Value 0 
    Set-ItemProperty $RegistryOEM  PreInstalledAppsEverEnabled -Value 0 
    Set-ItemProperty $RegistryOEM  SilentInstalledAppsEnabled -Value 0 
    Set-ItemProperty $RegistryOEM  SystemPaneSuggestionsEnabled -Value 0
    # disable web search in start menu
    $WebSearch = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
    Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" BingSearchEnabled -Value 0 
    If (!(Test-Path $WebSearch)) {
        New-Item $WebSearch
    }
    Set-ItemProperty $WebSearch DisableWebSearch -Value 1
    # disable live tiles in start menu
    $Tiles = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications"    
    If (!(Test-Path $Tiles)) {      
        New-Item $Tiles
    }
    Set-ItemProperty $Tiles NoTileApplicationNotification -Value 1
    # disable mixed reality portal
    $Portal = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Holographic"    
    If (Test-Path $Portal) {
        Set-ItemProperty $Portal FirstRunSucceeded -Value 0 
    }
    # disable scheduled tasks
    Get-ScheduledTask  XblGameSaveTaskLogon | Disable-ScheduledTask
    Get-ScheduledTask  XblGameSaveTask | Disable-ScheduledTask
    Get-ScheduledTask  Consolidator | Disable-ScheduledTask
    Get-ScheduledTask  UsbCeip | Disable-ScheduledTask
    Get-ScheduledTask  DmClient | Disable-ScheduledTask
    Get-ScheduledTask  DmClientOnScenarioDownload | Disable-ScheduledTask
}

# method to disable cortana
Function DisableCortana {
    $Cortana1 = "HKCU:\SOFTWARE\Microsoft\Personalization\Settings"
    $Cortana2 = "HKCU:\SOFTWARE\Microsoft\InputPersonalization"
    $Cortana3 = "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore"
    If (!(Test-Path $Cortana1)) {
        New-Item $Cortana1
    }
    Set-ItemProperty $Cortana1 AcceptedPrivacyPolicy -Value 0 
    If (!(Test-Path $Cortana2)) {
        New-Item $Cortana2
    }
    Set-ItemProperty $Cortana2 RestrictImplicitTextCollection -Value 1 
    Set-ItemProperty $Cortana2 RestrictImplicitInkCollection -Value 1 
    If (!(Test-Path $Cortana3)) {
        New-Item $Cortana3
    }
    Set-ItemProperty $Cortana3 HarvestContacts -Value 0
}

# method to disable edge as the default .pdf viewer
Function DisableEdgePDF {
    $NoPDF = "HKCR:\.pdf"
    $NoProgIds = "HKCR:\.pdf\OpenWithProgids"
    $NoWithList = "HKCR:\.pdf\OpenWithList" 
    If (!(Get-ItemProperty $NoPDF  NoOpenWith)) {
        New-ItemProperty $NoPDF NoOpenWith 
    }        
    If (!(Get-ItemProperty $NoPDF  NoStaticDefaultVerb)) {
        New-ItemProperty $NoPDF  NoStaticDefaultVerb 
    }        
    If (!(Get-ItemProperty $NoProgIds  NoOpenWith)) {
        New-ItemProperty $NoProgIds  NoOpenWith 
    }        
    If (!(Get-ItemProperty $NoProgIds  NoStaticDefaultVerb)) {
        New-ItemProperty $NoProgIds  NoStaticDefaultVerb 
    }        
    If (!(Get-ItemProperty $NoWithList  NoOpenWith)) {
        New-ItemProperty $NoWithList  NoOpenWith
    }        
    If (!(Get-ItemProperty $NoWithList  NoStaticDefaultVerb)) {
        New-ItemProperty $NoWithList  NoStaticDefaultVerb 
    }
    $Edge = "HKCR:\AppXd4nrz8ff68srnhf9t5a8sbjyar1cr723_"
    If (Test-Path $Edge) {
        Set-Item $Edge AppXd4nrz8ff68srnhf9t5a8sbjyar1cr723_ 
    }
}

# method to enable dmw services
Function CheckDMWService {
    If (Get-Service -Name dmwappushservice | Where-Object {$_.StartType -eq "Disabled"}) {
        Set-Service -Name dmwappushservice -StartupType Automatic
    }
    If (Get-Service -Name dmwappushservice | Where-Object {$_.Status -eq "Stopped"}) {
        Start-Service -Name dmwappushservice
    } 
}

# uninstall one drive
Function UninstallOneDrive {
    # disable use of one drive
    $OneDriveKey = 'HKLM:Software\Policies\Microsoft\Windows\OneDrive'
    If (!(Test-Path $OneDriveKey)) {
        Mkdir $OneDriveKey
        Set-ItemProperty $OneDriveKey -Name OneDrive -Value DisableFileSyncNGSC
    }
    Set-ItemProperty $OneDriveKey -Name OneDrive -Value DisableFileSyncNGSC
    # uninstall one drive
    New-PSDrive  HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT
    $onedrive = "$env:SYSTEMROOT\SysWOW64\OneDriveSetup.exe"
    $ExplorerReg1 = "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
    $ExplorerReg2 = "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
    Stop-Process -Name "OneDrive*"
    Start-Sleep 3
    If (!(Test-Path $onedrive)) {
        $onedrive = "$env:SYSTEMROOT\System32\OneDriveSetup.exe"
        New-PSDrive  HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT
        $onedrive = "$env:SYSTEMROOT\SysWOW64\OneDriveSetup.exe"
        $ExplorerReg1 = "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
        $ExplorerReg2 = "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
        Stop-Process -Name "OneDrive*"
        Start-Sleep 3
        If (!(Test-Path $onedrive)) {
            $onedrive = "$env:SYSTEMROOT\System32\OneDriveSetup.exe"
        }
        Start-Process $onedrive "/uninstall" -NoNewWindow -Wait
        Start-Sleep 3
        taskkill.exe /F /IM explorer.exe
        Start-Sleep 3
        Remove-Item "$env:USERPROFILE\OneDrive" -Force -Recurse
        Remove-Item "$env:LOCALAPPDATA\Microsoft\OneDrive" -Force -Recurse
        Remove-Item "$env:PROGRAMDATA\Microsoft OneDrive" -Force -Recurse
        If (Test-Path "$env:SYSTEMDRIVE\OneDriveTemp") {
            Remove-Item "$env:SYSTEMDRIVE\OneDriveTemp" -Force -Recurse
        }
        If (!(Test-Path $ExplorerReg1)) {
            New-Item $ExplorerReg1
        }
        Set-ItemProperty $ExplorerReg1 System.IsPinnedToNameSpaceTree -Value 0 
        If (!(Test-Path $ExplorerReg2)) {
            New-Item $ExplorerReg2
        }
        Set-ItemProperty $ExplorerReg2 System.IsPinnedToNameSpaceTree -Value 0
        Start-Process explorer.exe -NoNewWindow
        $OneDriveKey = 'HKLM:Software\Policies\Microsoft\Windows\OneDrive'
        If (!(Test-Path $OneDriveKey)) {
            Mkdir $OneDriveKey 
        }
        Start-Process $onedrive "/uninstall" -NoNewWindow -Wait
        Start-Sleep 3
        taskkill.exe /F /IM explorer.exe
        Start-Sleep 3
        If (Test-Path "$env:USERPROFILE\OneDrive") {
            Remove-Item "$env:USERPROFILE\OneDrive" -Force -Recurse
        }
        If (Test-Path "$env:LOCALAPPDATA\Microsoft\OneDrive") {
            Remove-Item "$env:LOCALAPPDATA\Microsoft\OneDrive" -Force -Recurse
        }
        If (Test-Path "$env:PROGRAMDATA\Microsoft OneDrive") {
            Remove-Item "$env:PROGRAMDATA\Microsoft OneDrive" -Force -Recurse
        }
        If (Test-Path "$env:SYSTEMDRIVE\OneDriveTemp") {
            Remove-Item "$env:SYSTEMDRIVE\OneDriveTemp" -Force -Recurse
        }
        If (!(Test-Path $ExplorerReg1)) {
            New-Item $ExplorerReg1
        }
        Set-ItemProperty $ExplorerReg1 System.IsPinnedToNameSpaceTree -Value 0 
        If (!(Test-Path $ExplorerReg2)) {
            New-Item $ExplorerReg2
        }
        Set-ItemProperty $ExplorerReg2 System.IsPinnedToNameSpaceTree -Value 0
        Start-Process explorer.exe -NoNewWindow
        Remove-item env:OneDrive
    }
}

# method to unpin tiles from start menu
Function UnpinStart {
    (New-Object -Com Shell.Application).
    NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').
    Items() |
        % { $_.Verbs() } |
        ? {$_.Name -match 'Un.*pin from Start'} |
        % {$_.DoIt()}
}

# method to remove 3d objects
Function Remove3dObjects {
    $Objects32 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}"
    $Objects64 = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}"
    If (Test-Path $Objects32) {
        Remove-Item $Objects32 -Recurse 
    }
    If (Test-Path $Objects64) {
        Remove-Item $Objects64 -Recurse 
    }
}

# main method
Function RunApplication {
    Write-Host "Creating temporary PSDrive 'HKCR' (HKEY_CLASSES_ROOT)"
    New-PSDrive  HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT
    Start-Sleep 1
    Write-Host "Uninstalling bloatware, please wait."
    DebloatApps
    Start-Sleep 1
    Write-Host "Removing registry keys."
    DebloatKeys
    Start-Sleep 1
    Write-Host "Protect Privacy"
    PrivacyProtect
    Start-Sleep 1
    Write-Host "Disabling Cortana from search"
    DisableCortana
    Start-Sleep 1
    Write-Host "Disabling Edge as default PDF Reader"
    DisableEdgePDF
    Start-Sleep 1
    Write-Host "Enable DMW Services"
    CheckDMWService
    Start-Sleep 1
    Write-Host "Uninstalling One Drive"
    UninstallOneDrive
    Start-Sleep 1
    Write-Host "Removing tiles from Start Menu"
    UnpinStart
    Start-Sleep 1
    Write-Host "Removing 3D Objects"
    Remove3dObjects
    Start-Sleep 1
    Write-Host "Congratulations! You now have a clean Windows 10 installation."
}

RunApplication