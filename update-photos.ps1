# 扫描 photos 文件夹，生成 photos.js 供网页读取
# photos 根目录及「灵感收藏」子文件夹 = 灵感收藏区；「我的作品」子文件夹 = 我的作品区
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$photoDir = Join-Path $root "photos"
$worksDir = Join-Path $photoDir "我的作品"
$exts = @("*.jpg", "*.jpeg", "*.png", "*.webp", "*.gif")

function Get-Entries($dir, $prefix) {
    if (-not (Test-Path $dir)) { return @() }
    $files = Get-ChildItem -Path $dir -File -Include $exts -Recurse -Depth 0 -ErrorAction SilentlyContinue | Sort-Object Name
    $list = @()
    foreach ($f in $files) {
        $name = $f.Name -replace '\\', '\\\\' -replace '"', '\"'
        $list += "    `"$prefix$name`""
    }
    return $list
}

$works = Get-Entries $worksDir "photos/我的作品/"
$insp = Get-Entries $photoDir "photos/"

$content = "// 此文件由 update-photos.ps1 自动生成，请勿手动编辑。`r`n"
$content += "// 「我的作品」= photos\我的作品 文件夹；「灵感收藏」= photos 文件夹本身。`r`n"
$content += "window.SECTIONS = {`r`n  works: [`r`n" + ($works -join ",`r`n") + "`r`n  ],`r`n  inspiration: [`r`n" + ($insp -join ",`r`n") + "`r`n  ]`r`n};`r`n"

[System.IO.File]::WriteAllText((Join-Path $root "photos.js"), $content, (New-Object System.Text.UTF8Encoding $true))

Write-Host ""
Write-Host ("我的作品 {0} 张，灵感收藏 {1} 张，photos.js 已更新。" -f $works.Count, $insp.Count)
Write-Host "重新打开或刷新网页即可看到变化。"
Write-Host ""
