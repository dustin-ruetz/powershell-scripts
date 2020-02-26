Import-Module $PSScriptRoot/../Modules/Get-InstalledSoftware.psm1
Import-Module $PSScriptRoot/../Modules/Get-Path.psm1 -Function Get-DownloadsPath
Import-Module $PSScriptRoot/../Modules/Write-Title.psm1

$Name = 'HashCheck'
$Slug = $Name.ToLower()

Write-Title $Name

$AppInfo = Get-InstalledSoftware | Where-Object { $_.Name -Match $Name }
If ($AppInfo.Version) {
  $Version = $AppInfo.Version
  Write-Host "$Slug-$Version is installed."
}
Else {
  Write-Host "$Slug is not installed."
}

$GitHubUrl = 'https://github.com'
$Webpage = Invoke-WebRequest -Uri "$GitHubUrl/gurnec/HashCheck/releases/latest" -UseBasicParsing

# determine the latest version by finding <a> hrefs containing 'HashCheckSetup'
# version format = 'major.minor.patch (MMMM YYYY)'
$SetupFilename = 'HashCheckSetup-v*.*.*.exe'

# two links - first is the setup file, last is the checksum file
$ExeDownloadLink = $Webpage.Links.Href -Match $SetupFilename | Select-Object -First 1
$ChecksumDownloadLink = $Webpage.Links.Href -Match $SetupFilename | Select-Object -Last 1

$ExeFilename = $ExeDownloadLink.split('/') | Select-Object -Last 1
$ChecksumFilename = $ChecksumDownloadLink.split('/') | Select-Object -Last 1

$LatestAvailableVersion = $ExeFilename -Replace 'HashCheckSetup-v', '' -Replace '.exe', ''

Write-Host "The latest version is $LatestAvailableVersion."
$Proceed = Read-Host 'Proceed to download and install? (y/n)'

If ($Proceed -eq 'y') {
  Write-Host 'Downloading ...'

  (New-Object System.Net.WebClient).DownloadFile(
    "$GitHubUrl$ExeDownloadLink",
    "$(Get-DownloadsPath)/$ExeFilename"
  )
  (New-Object System.Net.WebClient).DownloadFile(
    "$GitHubUrl$ChecksumDownloadLink",
    "$(Get-DownloadsPath)/$ChecksumFilename"
  )

  Write-Host "Installing $ExeFileName ..."
  Invoke-Item "$(Get-DownloadsPath)/$ExeFilename"

  Write-Host 'Installation complete.'
  Read-Host 'Press enter to exit'
  Exit
}
Else {
  Exit
}
