$inputDir = Join-Path $PSScriptRoot "gifs"
$outputDir = Join-Path $PSScriptRoot "webm"

# Check input directory
if (-not (Test-Path $inputDir)) {
    Write-Host "ERROR: GIF folder not found:" -ForegroundColor Red
    Write-Host $inputDir -ForegroundColor Yellow
    exit 1
}

# Create output directory
New-Item -ItemType Directory -Force -Path $outputDir | Out-Null

# Get GIF files
$files = Get-ChildItem -Path $inputDir -Filter "*.gif"

$total = $files.Count
$count = 0
$success = 0
$failed = 0

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "GIF -> WebM Conversion" -ForegroundColor Cyan
Write-Host "GIF files found: $total" -ForegroundColor Cyan
Write-Host "Output: $outputDir" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

foreach ($file in $files) {

    $count++

    $output = Join-Path $outputDir ($file.BaseName + ".webm")

    Write-Host ""
    Write-Host "[$count/$total] Converting: $($file.Name)" -ForegroundColor Cyan

    & ffmpeg -y `
        -i "$($file.FullName)" `
        -vf "format=rgba,colorkey=0xFFFFFF:0.12:0.08,format=yuva420p" `
        -c:v libvpx-vp9 `
        -pix_fmt yuva420p `
        -crf 30 `
        -b:v 0 `
        -deadline good `
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
Write-Host "============================================" -ForegroundColor Green
Write-Host "Finished: $count/$total"
Write-Host "Successful: $success"
Write-Host "Failed: $failed"
Write-Host "WebM files: $outputDir"
Write-Host "============================================" -ForegroundColor Green