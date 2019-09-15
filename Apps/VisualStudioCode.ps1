Import-Module $PSScriptRoot/../Modules/Format-Json.psm1
Import-Module $PSScriptRoot/../Modules/Get-OperatingSystem.psm1
Import-Module $PSScriptRoot/../Modules/Get-Path.psm1 -Function 'Get-ScoopAppsPath'
Import-Module $PSScriptRoot/../Modules/Write-ChangedSettings.psm1
Import-Module $PSScriptRoot/../Modules/Write-Title.psm1

Write-Title 'Visual Studio Code'

$Proceed = Read-Host 'Proceed to install extensions? (y/n)'

If ($Proceed -eq 'y') {
  $Extensions = @(
    'slevesque.vscode-autohotkey',
    'streetsidesoftware.code-spell-checker', # cSpell
    'editorconfig.editorconfig',
    'dbaeumer.vscode-eslint', # eslint
    'pkief.material-icon-theme',
    'ms-vscode.powershell'
  )

  ForEach ($Extension in $Extensions) {
    code --install-extension $Extension
  }
}

$Settings = [ordered]@{
  '// vscode settings' = ''
  'editor.minimap.enabled' = $false
  'editor.renderWhitespace' = 'selection'
  'files.insertFinalNewline' = $true
  'files.trimFinalNewlines' = $true
  'files.trimTrailingWhitespace' = $true
  'html.format.endWithNewline' = $true
  'html.format.extraLiners' = ''
  'html.format.indentInnerHtml' = $true
  'telemetry.enableCrashReporter' = $false
  'telemetry.enableTelemetry' = $false
  'terminal.integrated.cursorBlinking' = $true
  'terminal.integrated.cursorStyle' = 'line'
  'update.enableWindowsBackgroundUpdates' = $false
  'update.mode' = 'none'
  'window.menuBarVisibility' = 'toggle'
  'window.title' = '${dirty}${activeEditorShort}${separator}${rootName}'
  'workbench.colorTheme' = 'Solarized Dark'
  'workbench.iconTheme' = 'material-icon-theme'
  'workbench.view.alwaysShowHeaderActions' = $true
  'zenMode.hideLineNumbers' = $false
  'zenMode.hideTabs' = $false
  '// extension settings' = ''
  'cSpell.enabledLanguageIds' = @(
    'ahk',
    'asciidoc',
    'css',
    'dockerfile',
    'git-commit',
    'html',
    'ignore',
    'javascript',
    'javascriptreact',
    'json',
    'jsonc',
    'jsx-tags',
    'markdown',
    'php',
    'plaintext',
    'powershell',
    'properties',
    'pug',
    'restructuredtext',
    'scss',
    'shellscript',
    'text',
    'typescript',
    'typescriptreact',
    'xml',
    'yaml',
    'yml'
  )
  'cSpell.userWords' = @(
    'autohotkey',
    'cmder',
    'editorconfig',
    'hashcheck',
    'recurse',
    'Ruetz'
  )
  'eslint.autoFixOnSave' = $true
  'material-icon-theme.activeIconPack' = 'react'
  'material-icon-theme.showUpdateMessage' = $true
  'powershell.codeFormatting.useCorrectCasing' = $true
  'powershell.integratedConsole.showOnStartup' = $false
}

$OperatingSystem = Get-OperatingSystem

$Path =
  If ($OperatingSystem -eq 'macOS') {
    'mac-path'
  }
  ElseIf ($OperatingSystem -eq 'Windows') {
    "$(Get-ScoopAppsPath)/vscode-portable/current/data/user-data/User/settings.json"
  }

# convert the settings to JSON and write to disk
$Settings | ConvertTo-Json | Format-Json | Set-Content $Path

Write-ChangedSettings $Settings

Read-Host 'Press enter to exit'
Exit

# cSpell:words dbaeumer, pkief, slevesque, streetsidesoftware
