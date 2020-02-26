<#
  .SYNOPSIS
    Generate a list of installed software.

  .DESCRIPTION
    List the computer's installed software by checking registry
    locations for the LocalMachine (lm) and CurrentUser (cu).

  .NOTES
    * Adapted from Anthony Howell's (i.e. ThePoShWolf) blog post and PowerShell Utilities repository.
    * https://theposhwolf.com/howtos/Using-Powershell-to-get-a-list-of-installed-software-from-a-remote-computer-fast-as-lightning
    * https://github.com/ThePoShWolf/Utilities/blob/master/Misc/Get-InstalledSoftware.ps1
#>

Function Get-InstalledSoftware {
  # cSpell: disable

  <#
  Param(
    [Alias('Computer', 'ComputerName', 'HostName')]
    [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$true, Mandatory=$true, Position=1)]
    [string[]]$Name = $env:COMPUTERNAME
  )
  #>

  Begin {
    $lmKeys = @(
      'Software\Microsoft\Windows\CurrentVersion\Uninstall',
      'SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
    )
    $lmReg = [Microsoft.Win32.RegistryHive]::LocalMachine
    $cuKeys = @('Software\Microsoft\Windows\CurrentVersion\Uninstall')
    $cuReg = [Microsoft.Win32.RegistryHive]::CurrentUser
  }

  Process {
    <#
    if (!(Test-Connection -ComputerName $Computer -count 1 -quiet)) {
      Write-Error -Message "Unable to contact $Computer. Please verify its network connectivity and try again." -Category ObjectNotFound -TargetObject $Computer
      Break
    }
    #>

    $masterKeys = @()
    $remoteCURegKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($cuReg, $computer)
    $remoteLMRegKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($lmReg, $computer)

    foreach ($key in $lmKeys) {
      $regKey = $remoteLMRegKey.OpenSubkey($key)
      foreach ($subName in $regKey.GetSubkeyNames()) {
        foreach ($sub in $regKey.OpenSubkey($subName)) {
          $masterKeys += (New-Object PSObject -Property @{
              'ComputerName' = $Computer
              'Name' = $sub.GetValue('displayname')
              'SystemComponent' = $sub.GetValue('systemcomponent')
              'ParentKeyName' = $sub.GetValue('parentkeyname')
              'Version' = $sub.GetValue('DisplayVersion')
              'UninstallCommand' = $sub.GetValue('UninstallString')
              'InstallDate' = $sub.GetValue('InstallDate')
              'RegPath' = $sub.ToString()
            })
        }
      }
    }

    foreach ($key in $cuKeys) {
      $regKey = $remoteCURegKey.OpenSubkey($key)
      if ($regKey -ne $null) {
        foreach ($subName in $regKey.getsubkeynames()) {
          foreach ($sub in $regKey.opensubkey($subName)) {
            $masterKeys += (New-Object PSObject -Property @{
                'ComputerName' = $Computer
                'Name' = $sub.GetValue('displayname')
                'SystemComponent' = $sub.GetValue('systemcomponent')
                'ParentKeyName' = $sub.GetValue('parentkeyname')
                'Version' = $sub.GetValue('DisplayVersion')
                'UninstallCommand' = $sub.GetValue('UninstallString')
                'InstallDate' = $sub.GetValue('InstallDate')
                'RegPath' = $sub.ToString()
              })
          }
        }
      }
    }

    $woFilter = { $null -ne $_.name -AND $_.SystemComponent -ne '1' -AND $null -eq $_.ParentKeyName }
    $props = 'Name', 'Version', 'ComputerName', 'Installdate', 'UninstallCommand', 'RegPath'
    $masterKeys = ($masterKeys | Where-Object $woFilter | Select-Object $props | Sort-Object Name)
    $masterKeys
  }

  End { }
}

Export-ModuleMember Get-InstalledSoftware
