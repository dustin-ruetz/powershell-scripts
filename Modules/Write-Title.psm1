Function Write-Title ([String]$Title) {
  Write-Host $Title -BackgroundColor 'green' -ForegroundColor 'black'
}

Export-ModuleMember Write-Title
