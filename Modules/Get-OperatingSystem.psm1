<#
  .SYNOPSIS
    Get the operating system.

  .NOTES
    PowerShell Core (i.e. v6+) features built-in $IsOperatingSystem booleans.
#>

Function Get-OperatingSystem {
  If ($IsMacOS) {
    Return 'macOS'
  }
  If (($IsWindows) -or ($Env:OS -match 'Windows')) {
    Return 'Windows'
  }
}

Export-ModuleMember Get-OperatingSystem
