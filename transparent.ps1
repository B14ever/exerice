$inputDir = Join-Path $PSScriptRoot "webm"
$outputDir = Join-Path $PSScriptRoot "transparent-webm"

New-Item -ItemType Directory -Force -Path $outputDir | Out-Null

$files = Get-ChildItem -Path $inputDir -Filter "*.webm"

$total = $files.Count
$count = 0
$success = 0
$failed = 0

foreach ($file in $files) {
    $count++
    $output = Join-Path $outputDir $file.Name

    Write-Host ""
    Write-Host "[$count/$total] Processing: $($file.Name)" -ForegroundColor Cyan

    # Higher colorkey similarity (0.32) catches compression artifacts and near-white pixels
    & ffmpeg -y `
        -i "$($file.FullName)" `
        -vf "colorkey=0xFFFFFF:0.32:0.10" `
        -c:v libvpx-vp9 `
        -pix_fmt yuva420p `
        -crf 30 `
        -b:v 0 `
        -deadline good `
        -cpu-used 4 `
        -row-mt 1 `
        -an `
        "$output"

    if ($LASTEXITCODE -eq 0 -and (Test-Path $output)) {
        $success++
        Write-Host "  DONE" -ForegroundColor Green
    }
    else {
        $failed++
        Write-Host "  FAILED" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Gray
Write-Host "Finished:   $count/$total"
Write-Host "Successful: $success" -ForegroundColor Green
Write-Host "Failed:     $failed" -ForegroundColor Red
Write-Host "Output:     $outputDir"
Write-Host "============================================" -ForegroundColor Gray