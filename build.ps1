#!/usr/bin/env pwsh
# FPGA Build Script for Tang Nano Projects
# Usage: .\build.ps1 -Target <target> -Project <project> -Board <board> [-File <file>]
# Targets: hello_world, blinky, 6502, tutorial, simulate, program, clean
# Projects: hello_world, 6502_computer, tutorial
# Boards: 9k, 20k
# File: For tutorial project, specify which step to build (e.g., step1, step2, etc.)

param(
    [Parameter(Position = 0)]
    [string]$Target = "hello_world",
    [Parameter(Position = 1)]
    [string]$Project = "hello_world",
    [Parameter(Position = 2)]
    [ValidateSet("9k", "20k")]
    [string]$Board = "9k",
    [Parameter(Position = 3)]
    [string]$File = ""
)

# Source OSS CAD Suite environment
Write-Host "Setting up OSS CAD Suite environment..." -ForegroundColor Yellow
& ".\oss-cad-suite\environment.ps1"

# Board-specific configuration
$BoardConfig = switch ($Board) {
    "9k" {
        @{
            Device         = "GW1NR-LV9QN88PC6/I5"
            Family         = "GW1N-9"
            ConstraintFile = "constraints/tangnano9k.cst"
            Description    = "Tang Nano 9K"
        }
    }
    "20k" {
        @{
            Device         = "GW2A-LV18PG256C8/I7"
            Family         = "GW2A-18C"
            ConstraintFile = "constraints/tangnano20k.cst" 
            Description    = "Tang Nano 20K"
        }
    }
}

Write-Host "Target Board: $($BoardConfig.Description) ($($BoardConfig.Device))" -ForegroundColor Green

# Create build directory if it doesn't exist
if (-not (Test-Path "build")) {
    New-Item -ItemType Directory -Path "build" | Out-Null
}

# Validate project exists (for project-based targets)
if ($Target -ne "clean" -and $Target -ne "program") {
    $ProjectPath = "projects\$Project"
    if (-not (Test-Path $ProjectPath)) {
        Write-Host "Project '$Project' not found at $ProjectPath" -ForegroundColor Red
        Write-Host "Available projects:" -ForegroundColor Yellow
        Get-ChildItem "projects" -Directory | ForEach-Object { Write-Host "  - $($_.Name)" -ForegroundColor Yellow }
        exit 1
    }
}

switch ($Target.ToLower()) {
    "hello_world" {
        Write-Host "Building Hello World project..." -ForegroundColor Green
        
        # Synthesis
        Write-Host "Running synthesis..." -ForegroundColor Cyan
        & yosys -p "read_verilog projects/hello_world/src/hello_world.v; synth_gowin -json build/hello_world.json"
        if ($LASTEXITCODE -ne 0) { exit 1 }
        
        # Place & Route
        Write-Host "Running place & route..." -ForegroundColor Cyan
        & nextpnr-himbaechel --json build/hello_world.json --write build/hello_world_pnr.json --device $($BoardConfig.Device) --vopt family=$($BoardConfig.Family) --vopt cst=$($BoardConfig.ConstraintFile)
        if ($LASTEXITCODE -ne 0) { exit 1 }
        
        # Generate bitstream
        Write-Host "Generating bitstream..." -ForegroundColor Cyan
        & gowin_pack -d $($BoardConfig.Device) -o build/hello_world.fs build/hello_world_pnr.json
        if ($LASTEXITCODE -ne 0) { exit 1 }
        
        Write-Host "Build complete! Bitstream: build/hello_world.fs" -ForegroundColor Green
    }

    "blinky" {
        Write-Host "Building blinky example..." -ForegroundColor Green
        
        # Synthesis
        Write-Host "Running synthesis..." -ForegroundColor Cyan
        & yosys -p "read_verilog examples/blinky.v; synth_gowin -json build/blinky.json"
        if ($LASTEXITCODE -ne 0) { exit 1 }
        
        # Place & Route
        Write-Host "Running place & route..." -ForegroundColor Cyan
        & nextpnr-himbaechel --json build/blinky.json --write build/blinky_pnr.json --device $($BoardConfig.Device) --vopt family=$($BoardConfig.Family) --vopt cst=$($BoardConfig.ConstraintFile)
        if ($LASTEXITCODE -ne 0) { exit 1 }
        
        # Generate bitstream
        Write-Host "Generating bitstream..." -ForegroundColor Cyan
        & gowin_pack -d $($BoardConfig.Device) -o build/blinky.fs build/blinky_pnr.json
        if ($LASTEXITCODE -ne 0) { exit 1 }
        
        Write-Host "Build complete! Bitstream: build/blinky.fs" -ForegroundColor Green
    }
    
    "6502" {
        Write-Host "Building 6502 Computer project..." -ForegroundColor Green
        
        # Synthesis
        Write-Host "Running synthesis..." -ForegroundColor Cyan
        & yosys -p "read_verilog projects/6502_computer/src/top.v projects/6502_computer/src/cpu/cpu_6502.v projects/6502_computer/src/memory/memory_controller.v; synth_gowin -json build/6502_computer.json"
        if ($LASTEXITCODE -ne 0) { exit 1 }
        
        # Place & Route
        Write-Host "Running place & route..." -ForegroundColor Cyan
        & nextpnr-himbaechel --json build/6502_computer.json --write build/6502_computer_pnr.json --device $($BoardConfig.Device) --vopt family=$($BoardConfig.Family) --vopt cst=$($BoardConfig.ConstraintFile)
        if ($LASTEXITCODE -ne 0) { exit 1 }
        
        # Generate bitstream
        Write-Host "Generating bitstream..." -ForegroundColor Cyan
        & gowin_pack -d $($BoardConfig.Device) -o build/6502_computer.fs build/6502_computer_pnr.json
        if ($LASTEXITCODE -ne 0) { exit 1 }
        
        Write-Host "Build complete! Bitstream: build/6502_computer.fs" -ForegroundColor Green
    }

    "tutorial" {
        # Validate File parameter for tutorial project
        if ([string]::IsNullOrEmpty($File)) {
            Write-Host "Tutorial project requires -File parameter" -ForegroundColor Red
            Write-Host "Available tutorial files:" -ForegroundColor Yellow
            if (Test-Path "projects\tutorial\src") {
                Get-ChildItem "projects\tutorial\src" -Filter "*.v" | ForEach-Object { 
                    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)
                    Write-Host "  - $baseName" -ForegroundColor Yellow 
                }
            }
            Write-Host "Example: .\build.ps1 -Target tutorial -Project tutorial -File step1 -Board 9k" -ForegroundColor Cyan
            exit 1
        }
        
        $SourceFile = "projects\tutorial\src\$File.v"
        if (-not (Test-Path $SourceFile)) {
            Write-Host "Tutorial file not found: $SourceFile" -ForegroundColor Red
            Write-Host "Available tutorial files:" -ForegroundColor Yellow
            Get-ChildItem "projects\tutorial\src" -Filter "*.v" | ForEach-Object { 
                $baseName = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)
                Write-Host "  - $baseName" -ForegroundColor Yellow 
            }
            exit 1
        }
        
        Write-Host "Building tutorial file: $File..." -ForegroundColor Green
        
        # Synthesis
        Write-Host "Running synthesis..." -ForegroundColor Cyan
        & yosys -p "read_verilog $SourceFile; synth_gowin -json build/tutorial_$File.json"
        if ($LASTEXITCODE -ne 0) { exit 1 }
        
        # Place & Route
        Write-Host "Running place & route..." -ForegroundColor Cyan
        & nextpnr-himbaechel --json build/tutorial_$File.json --write build/tutorial_$($File)_pnr.json --device $($BoardConfig.Device) --vopt family=$($BoardConfig.Family) --vopt cst=$($BoardConfig.ConstraintFile)
        if ($LASTEXITCODE -ne 0) { exit 1 }
        
        # Generate bitstream
        Write-Host "Generating bitstream..." -ForegroundColor Cyan
        & gowin_pack -d $($BoardConfig.Device) -o build/tutorial_$File.fs build/tutorial_$($File)_pnr.json
        if ($LASTEXITCODE -ne 0) { exit 1 }
        
        Write-Host "Build complete! Bitstream: build/tutorial_$File.fs" -ForegroundColor Green
    }

    "simulate" {
        switch ($Project.ToLower()) {
            "hello_world" {
                Write-Host "Simulating Hello World project..." -ForegroundColor Green
                
                Write-Host "Running simulation..." -ForegroundColor Cyan
                & iverilog -o build/hello_world_sim projects/hello_world/testbench/hello_world_tb.v projects/hello_world/src/hello_world.v
                if ($LASTEXITCODE -ne 0) { exit 1 }
                
                & vvp build/hello_world_sim
                if ($LASTEXITCODE -ne 0) { exit 1 }
                
                Write-Host "Simulation complete! VCD file: hello_world.vcd" -ForegroundColor Green
            }
            
            "blinky" {
                Write-Host "Simulating blinky example..." -ForegroundColor Green
                
                Write-Host "Running simulation..." -ForegroundColor Cyan
                & iverilog -o build/blinky_sim testbench/blinky_tb.v examples/blinky.v
                if ($LASTEXITCODE -ne 0) { exit 1 }
                
                & vvp build/blinky_sim
                if ($LASTEXITCODE -ne 0) { exit 1 }
                
                Write-Host "Simulation complete! VCD file: blinky.vcd" -ForegroundColor Green
            }
            
            "6502" {
                Write-Host "Simulating 6502 Computer project..." -ForegroundColor Green
                Write-Host "Note: 6502 simulation requires testbench creation" -ForegroundColor Yellow
                # TODO: Add 6502 testbench when created
            }
            
            "tutorial" {
                if ([string]::IsNullOrEmpty($File)) {
                    Write-Host "Tutorial simulation requires -File parameter" -ForegroundColor Red
                    Write-Host "Example: .\build.ps1 -Target simulate -Project tutorial -File step1" -ForegroundColor Cyan
                    exit 1
                }
                
                Write-Host "Simulating tutorial file: $File..." -ForegroundColor Green
                Write-Host "Note: Tutorial simulation requires testbench creation for $File" -ForegroundColor Yellow
                # TODO: Add tutorial testbenches when created
            }
            
            default {
                Write-Host "Unknown project for simulation: $Project" -ForegroundColor Red
                Write-Host "Available projects: hello_world, blinky, 6502" -ForegroundColor Yellow
                exit 1
            }
        }
    }
    
    "program" {
        Write-Host "Programming Tang Nano..." -ForegroundColor Green
        
        $BitstreamFile = switch ($Project.ToLower()) {
            "hello_world" { "build/hello_world.fs" }
            "blinky" { "build/blinky.fs" }
            "6502" { "build/6502_computer.fs" }
            "tutorial" { 
                if ([string]::IsNullOrEmpty($File)) {
                    Write-Host "Tutorial programming requires -File parameter" -ForegroundColor Red
                    exit 1
                }
                "build/tutorial_$File.fs" 
            }
            default {
                Write-Host "Unknown project: $Project" -ForegroundColor Red
                exit 1
            }
        }
        
        if (-not (Test-Path $BitstreamFile)) {
            Write-Host "Bitstream file not found: $BitstreamFile" -ForegroundColor Red
            Write-Host "Please build the project first" -ForegroundColor Yellow
            exit 1
        }
        
        Write-Host "Programming with $BitstreamFile..." -ForegroundColor Cyan
        & openFPGALoader -b tangnano $BitstreamFile
        if ($LASTEXITCODE -ne 0) { exit 1 }
        
        Write-Host "Programming complete!" -ForegroundColor Green
    }
    
    "clean" {
        Write-Host "Cleaning build directory..." -ForegroundColor Green
        if (Test-Path "build") {
            Remove-Item -Recurse -Force "build\*"
        }
        Write-Host "Clean complete!" -ForegroundColor Green
    }
    
    default {
        Write-Host "Unknown target: $Target" -ForegroundColor Red
        Write-Host "Available targets: hello_world, blinky, 6502, tutorial, simulate, program, clean" -ForegroundColor Yellow
        Write-Host "Available projects: hello_world, 6502_computer, tutorial" -ForegroundColor Yellow
        Write-Host "Available boards: 9k (Tang Nano 9K), 20k (Tang Nano 20K)" -ForegroundColor Yellow
        Write-Host "Examples:" -ForegroundColor Yellow
        Write-Host "  .\build.ps1 -Target hello_world -Project hello_world -Board 9k" -ForegroundColor Cyan
        Write-Host "  .\build.ps1 -Target tutorial -Project tutorial -File step1 -Board 9k" -ForegroundColor Cyan
        Write-Host "  .\build.ps1 -Target simulate -Project hello_world -Board 20k" -ForegroundColor Cyan
        Write-Host "  .\build.ps1 -Target 6502 -Project 6502_computer -Board 20k" -ForegroundColor Cyan
        exit 1
    }
}
