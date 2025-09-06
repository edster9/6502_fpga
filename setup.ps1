# Setup script for 6502 FPGA development environment
# This script helps download and setup OSS CAD Suite

param(
    [switch]$Download,
    [switch]$Extract,
    [switch]$Test
)

$OSSCadPath = "tools\oss-cad-suite"
$DownloadPath = "tools\oss-cad-suite-download"

# Create tools directory
if (-not (Test-Path "tools")) {
    New-Item -ItemType Directory -Path "tools" | Out-Null
}

if ($Download) {
    Write-Host "Downloading OSS CAD Suite..." -ForegroundColor Green
    
    # Get latest release info
    $latestRelease = Invoke-RestMethod -Uri "https://api.github.com/repos/YosysHQ/oss-cad-suite-build/releases/latest"
    $windowsAsset = $latestRelease.assets | Where-Object { $_.name -like "*windows-x64*.tgz" }
    
    if (-not $windowsAsset) {
        Write-Host "Could not find Windows x64 release" -ForegroundColor Red
        exit 1
    }
    
    $downloadUrl = $windowsAsset.browser_download_url
    $fileName = $windowsAsset.name
    
    Write-Host "Downloading $fileName..." -ForegroundColor Cyan
    Write-Host "URL: $downloadUrl" -ForegroundColor Gray
    
    if (-not (Test-Path $DownloadPath)) {
        New-Item -ItemType Directory -Path $DownloadPath | Out-Null
    }
    
    $outputPath = Join-Path $DownloadPath $fileName
    
    try {
        Invoke-WebRequest -Uri $downloadUrl -OutFile $outputPath -UseBasicParsing
        Write-Host "Download complete: $outputPath" -ForegroundColor Green
    }
    catch {
        Write-Host "Download failed: $_" -ForegroundColor Red
        Write-Host "Please download manually from:" -ForegroundColor Yellow
        Write-Host "https://github.com/YosysHQ/oss-cad-suite-build/releases/latest" -ForegroundColor Yellow
        exit 1
    }
}

if ($Extract) {
    Write-Host "Extracting OSS CAD Suite..." -ForegroundColor Green
    
    # Find the downloaded file
    $tgzFile = Get-ChildItem -Path $DownloadPath -Filter "*.tgz" | Select-Object -First 1
    
    if (-not $tgzFile) {
        Write-Host "No .tgz file found in $DownloadPath" -ForegroundColor Red
        Write-Host "Please download first with -Download switch" -ForegroundColor Yellow
        exit 1
    }
    
    Write-Host "Extracting $($tgzFile.Name)..." -ForegroundColor Cyan
    
    # Extract using tar (available in Windows 10+)
    try {
        tar -xzf $tgzFile.FullName -C "tools"
        Write-Host "Extraction complete!" -ForegroundColor Green
        
        # Clean up download
        Remove-Item -Path $DownloadPath -Recurse -Force
        Write-Host "Cleaned up download files" -ForegroundColor Gray
    }
    catch {
        Write-Host "Extraction failed: $_" -ForegroundColor Red
        Write-Host "Please extract manually to tools/ directory" -ForegroundColor Yellow
        exit 1
    }
}

if ($Test) {
    Write-Host "Testing OSS CAD Suite installation..." -ForegroundColor Green
    
    if (-not (Test-Path $OSSCadPath)) {
        Write-Host "OSS CAD Suite not found at $OSSCadPath" -ForegroundColor Red
        Write-Host "Please run setup with -Download and -Extract flags first" -ForegroundColor Yellow
        exit 1
    }
    
    # Test environment
    try {
        & "$OSSCadPath\environment.ps1"
        
        Write-Host "Testing tools..." -ForegroundColor Cyan
        
        # Test yosys
        $yosysVersion = & yosys -V 2>&1 | Select-Object -First 1
        Write-Host "  Yosys: $yosysVersion" -ForegroundColor Gray
        
        # Test nextpnr
        $nextpnrVersion = & nextpnr-himbaechel --version 2>&1 | Select-Object -First 1
        Write-Host "  Nextpnr: $nextpnrVersion" -ForegroundColor Gray
        
        # Test openFPGALoader
        $loaderVersion = & openFPGALoader --version 2>&1 | Select-Object -First 1
        Write-Host "  openFPGALoader: $loaderVersion" -ForegroundColor Gray
        
        # Test iverilog
        $iverilogVersion = & iverilog -V 2>&1 | Select-Object -First 1
        Write-Host "  Icarus Verilog: $iverilogVersion" -ForegroundColor Gray
        
        Write-Host "All tools working correctly!" -ForegroundColor Green
    }
    catch {
        Write-Host "Tool test failed: $_" -ForegroundColor Red
        exit 1
    }
}

if (-not ($Download -or $Extract -or $Test)) {
    Write-Host "6502 FPGA Development Environment Setup" -ForegroundColor Green
    Write-Host "=======================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Usage: .\setup.ps1 [options]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Cyan
    Write-Host "  -Download    Download OSS CAD Suite" -ForegroundColor White
    Write-Host "  -Extract     Extract downloaded OSS CAD Suite" -ForegroundColor White
    Write-Host "  -Test        Test OSS CAD Suite installation" -ForegroundColor White
    Write-Host ""
    Write-Host "Quick setup:" -ForegroundColor Cyan
    Write-Host "  .\setup.ps1 -Download -Extract -Test" -ForegroundColor White
    Write-Host ""
    
    if (Test-Path $OSSCadPath) {
        Write-Host "OSS CAD Suite appears to be already installed!" -ForegroundColor Green
        Write-Host "Run '.\setup.ps1 -Test' to verify installation" -ForegroundColor Yellow
    }
    else {
        Write-Host "OSS CAD Suite not found. Please run with -Download and -Extract" -ForegroundColor Yellow
    }
}
