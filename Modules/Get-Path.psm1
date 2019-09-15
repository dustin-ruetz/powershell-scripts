Function Get-UserProfilePath {
  Return $Env:UserProfile
}

Function Get-DownloadsPath {
  Return "$(Get-UserProfilePath)/Downloads"
}

Function Get-ScoopAppsPath {
  Return "$(Get-UserProfilePath)/scoop/apps"
}

Function Get-StartMenuPath {
  Return "$(Get-UserProfilePath)/AppData/Roaming/Microsoft/Windows/Start Menu/Programs"
}

Export-ModuleMember -Function *
