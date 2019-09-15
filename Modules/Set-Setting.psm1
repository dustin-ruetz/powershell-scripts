<#
  .SYNOPSIS
    Change a registry setting.
#>

Function Set-Setting {
  Param (
    [String]$Path,
    [String]$Name,
    $Value
  )

  Set-ItemProperty -Path $Path -Name $Name -Value $Value
}

Export-ModuleMember Set-Setting
