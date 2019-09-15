# JSON pretty printer
# adapted from Stack Overflow answer by Nimai
# https://stackoverflow.com/a/55384556

Function Format-Json([Parameter(Mandatory, ValueFromPipeline)][String] $json) {
  $indent = 0

  ($json -Split "`n" | ForEach-Object {
    if ($_ -match '[\}\]]\s*,?\s*$') {
      # this line ends with ] or }, so decrement the indentation level
      $indent--
    }
    $line = ('  ' * $indent) + $($_.TrimStart() -replace '":  (["{[])', '": $1' -replace ':  ', ': ')

    if ($_ -match '[\{\[]\s*$') {
      # this line ends with [ or {, so increment the indentation level
      $indent++
    }
    $line
  }) -Join "`n"
}

Export-ModuleMember Format-Json

# cSpell:words Nimai
