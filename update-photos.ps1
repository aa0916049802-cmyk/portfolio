# 扫描 photos 文件夹，生成 photos.js 供网页读取
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$photoDir = Join-Path $root "photos"
$exts = @("*.jpg", "*.jpeg", "*.png", "*.webp", "*.gif")

$files = Get-ChildItem -Path $photoDir -File -Include $exts -Recurse -Depth 0 -ErrorAction SilentlyContinue |
    Sort-Object Name

$entries = @()
foreach ($f in $files) {
    $name = $f.Name -replace '\\', '\\\\' -replace '"', '\"'
    $entries += "  `"photos/$name`""
}

$content = "// 此文件由 update-photos.ps1 自动生成，请勿手动编辑。`r`n"
$content += "// 把照片放进 photos 文件夹后，双击「刷新照片.bat」即可更新。`r`n"
$content += "window.PHOTOS = [`r`n" + ($entries -join ",`r`n") + "`r`n];`r`n"

[System.IO.File]::WriteAllText((Join-Path $root "photos.js"), $content, (New-Object System.Text.UTF8Encoding $true))

Write-Host ""
Write-Host ("已找到 {0} 张照片，photos.js 已更新。" -f $files.Count)
Write-Host "重新打开或刷新 index.html 即可看到最新照片。"
Write-Host ""
