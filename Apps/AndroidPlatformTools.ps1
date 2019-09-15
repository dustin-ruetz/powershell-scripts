Import-Module $PSScriptRoot/../Modules/Get-Path.psm1 `
  -Function Get-DownloadsPath, Get-ScoopAppsPath, Get-StartMenuPath, Get-UserProfilePath
Import-Module $PSScriptRoot/../Modules/Write-Title.psm1

$Name = 'Android Platform Tools'
$Slug = $Name.ToLower() -Replace ' ', '-'

Write-Title $Name

$UserAppsPath = "$(Get-UserProfilePath)/data/apps"

If (Test-Path "$UserAppsPath/$Slug-*.*.*") {
  $LatestInstalledVersion = (Get-ChildItem -Path $UserAppsPath -Filter "$Slug-*.*.*" -Directory).Name | Select-Object -Last 1
  Write-Host "$LatestInstalledVersion is installed."
}
Else {
  Write-Host "$Slug is not installed."
}

# determine the latest version by finding the first <h4> tag on the page
# version format = 'major.minor.patch (MMMM YYYY)'
$Webpage = Invoke-WebRequest -Uri 'https://developer.android.com/studio/releases/platform-tools'
$LatestAvailableVersion = ($Webpage.ParsedHtml.getElementsByTagName('h4')[0]).innerText

Write-Host "The latest version is $LatestAvailableVersion."
$Proceed = Read-Host 'Proceed to download and install? (y/n)'

If ($Proceed -eq 'y') {
  $TempDir = "$(Get-DownloadsPath)/$Slug.temp"
  $ZipFile = "$TempDir.zip"

  Write-Host 'Downloading and extracting ...'

  # download the latest android-platform-tools
  (New-Object System.Net.WebClient).DownloadFile(
    'https://dl.google.com/android/repository/platform-tools-latest-windows.zip',
    $ZipFile
  )

  # extract the .zip file
  Expand-Archive -Path $ZipFile -DestinationPath $TempDir

  # get the version number
  $SourceProperties = Get-Content -Path "$TempDir/platform-tools/source.properties"
  $Revision = $SourceProperties | Select-String -Pattern 'Pkg.Revision='
  $Version = $Revision -Replace 'Pkg.Revision=', ''

  $SlugAndVersion = "$Slug-$Version"

  Write-Host "Installing $SlugAndVersion ..."

  # make a copy of the single subdirectory and rename it
  Copy-Item "$TempDir/platform-tools/" -Destination "$UserAppsPath/$SlugAndVersion/" -Recurse

  # delete the temporary directory and the .zip file
  Remove-Item $TempDir -Recurse
  Remove-Item $ZipFile

  # create a new shortcut in the Start Menu
  $WScriptShell = New-Object -ComObject WScript.Shell
  $Shortcut = $WScriptShell.CreateShortcut("$(Get-StartMenuPath)/$SlugAndVersion.lnk")

  # set the target and 'start in' value
  $Shortcut.TargetPath = "$(Get-ScoopAppsPath)/cmder/current/Cmder.exe"
  $Shortcut.WorkingDirectory = "$UserAppsPath/$SlugAndVersion"

  # write the shortcut
  $Shortcut.Save()

  Write-Host 'Installation complete.'
  Read-Host 'Press enter to exit'
  Exit
}
Else {
  Exit
}
