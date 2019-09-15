<#
  .SYNOPSIS
    Print out a list of changed settings.
#>

Function Write-ChangedSettings {
  Param (
    # to specify that a function parameter be of the
    # 'Ordered' type, use the full type name
    [System.Collections.Specialized.OrderedDictionary]$Settings
  )

  Write-Host 'Changed the following settings:'
  Write-Host ($Settings | Out-String)
}

Export-ModuleMember Write-ChangedSettings
