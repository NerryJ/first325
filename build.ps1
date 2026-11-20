# Reconstruit first325-app/index.html (+ icônes) à partir de simulateur-first-325.html
$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$src = Get-Content -Raw -Encoding utf8 (Join-Path $here '..\simulateur-first-325.html')

# Hors ligne : pas de polices distantes (repli sur les polices système Android)
$src = [regex]::Replace($src, '<link rel="preconnect"[^>]*>\s*', '')
$src = [regex]::Replace($src, '<link rel="stylesheet" href="https://fonts\.googleapis\.com[^>]*>\s*', '')
$src = $src.Replace('--f-display:"Barlow Condensed","Arial Narrow"', '--f-display:"Barlow Condensed","Roboto Condensed","sans-serif-condensed","Arial Narrow"')
$src = $src.Replace('<meta name="claude:viewport-fit-sides" content="cover">', '')

$i = $src.IndexOf('<div class="wrap">')
$head = $src.Substring(0, $i)
$body = $src.Substring($i)

$sw = @'
<script>
if ('serviceWorker' in navigator && location.protocol.indexOf('http') === 0) {
  addEventListener('load', function () { navigator.serviceWorker.register('sw.js').catch(function () {}); });
}
</script>
'@

$html = @"
<!doctype html>
<html lang="fr">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<meta name="theme-color" content="#13293B">
<link rel="manifest" href="manifest.webmanifest">
<link rel="icon" href="icon-192.png">
$head
</head>
<body>
$body
$sw
</body>
</html>
"@
[IO.File]::WriteAllText((Join-Path $here 'index.html'), $html, (New-Object Text.UTF8Encoding $false))

# Icônes : voiles sur fond marine
Add-Type -AssemblyName System.Drawing
foreach ($n in 192, 512) {
  $bmp = New-Object Drawing.Bitmap $n, $n
  $g = [Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = 'AntiAlias'
  $g.Clear([Drawing.Color]::FromArgb(19, 41, 59))
  $s = $n / 100.0
  $white = New-Object Drawing.SolidBrush ([Drawing.Color]::FromArgb(246, 248, 248))
  $orange = New-Object Drawing.SolidBrush ([Drawing.Color]::FromArgb(212, 95, 39))
  $sea = New-Object Drawing.SolidBrush ([Drawing.Color]::FromArgb(43, 108, 140))
  $pt = { param($x, $y) New-Object Drawing.PointF ($x * $s), ($y * $s) }
  $g.FillPolygon($white, [Drawing.PointF[]]@((& $pt 50 18), (& $pt 50 70), (& $pt 26 70)))
  $g.FillPolygon($orange, [Drawing.PointF[]]@((& $pt 54 24), (& $pt 54 70), (& $pt 76 70)))
  $g.FillPolygon($sea, [Drawing.PointF[]]@((& $pt 22 74), (& $pt 80 74), (& $pt 72 82), (& $pt 30 82)))
  $bmp.Save((Join-Path $here "icon-$n.png"), [Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose(); $bmp.Dispose()
}
"index.html et icônes générés dans $here"
