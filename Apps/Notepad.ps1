Import-Module $PSScriptRoot/../Modules/Set-Setting.psm1
Import-Module $PSScriptRoot/../Modules/Write-ChangedSettings.psm1
Import-Module $PSScriptRoot/../Modules/Write-Title.psm1

Write-Title 'Notepad'

$Settings = [PSCustomObject]@{
  FontFamily = @{
    Name = 'font-family'
    Property = 'lfFaceName'
    Value = 'Consolas'
  }
  FontSize = @{
    Name = 'font-size'
    Property = 'iPointSize'
    Value = 12
  }
  WordWrap = @{
    Name = 'word-wrap'
    Property = 'fWrap'
    Value = 'Enabled'
    ValueComputed = 1
  }
}

# multiply font-size value by 10 in order to set it properly
$FontSize = $Settings.FontSize
$FontSize | Add-Member -NotePropertyName 'ValueComputed' -NotePropertyValue ($FontSize.value * 10)

# create an empty ordered dictionary
$OrderedSettings = [Ordered]@{ }

# iterate through all setting objects in the $Settings object
$Settings.PSObject.Properties | ForEach-Object {
  # set a reference to the current setting object
  $Setting = $_.Value

  # determine whether to set the setting's $ValueComputed or $Value
  $ValueToSet = If ($Setting.ValueComputed) { $Setting.ValueComputed } Else { $Setting.Value }

  # HKCU is an abbreviation of the registry's 'HKEY_CURRENT_USER'
  Set-Setting 'HKCU:\Software\Microsoft\Notepad' $Setting.Property $ValueToSet

  # populate the ordered dictionary
  $OrderedSettings.Add($Setting.Name, $Setting.Value)
}

Write-ChangedSettings $OrderedSettings

Read-Host 'Press enter to exit'
Exit
