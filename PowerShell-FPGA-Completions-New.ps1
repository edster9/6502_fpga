# PowerShell tab completion for Make targets
# Add this to your PowerShell profile: $PROFILE
# Updated for Tang Nano FPGA development

# Shared completion script block for make targets
$MakeCompletionScript = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    
    # Parse Makefile for targets
    $targets = @()
    if (Test-Path "Makefile") {
        $content = Get-Content "Makefile"
        foreach ($line in $content) {
            if ($line -match "^\.PHONY:\s*(.+)$") {
                $targets += $matches[1] -split '\s+'
            }
            if ($line -match "^([a-zA-Z0-9_-]+):\s*") {
                $targets += $matches[1]
            }
        }
    }
    
    # Filter and return matching targets
    $targets | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

# Register completion for both 'make' and 'm' commands
Register-ArgumentCompleter -CommandName make -ScriptBlock $MakeCompletionScript
Register-ArgumentCompleter -CommandName m -ScriptBlock $MakeCompletionScript

# Additional useful aliases for FPGA development
function m {
    param([Parameter(ValueFromRemainingArguments = $true)][string[]]$args)
    make @args
}

# Alternative alias
Set-Alias -Name mk -Value make

# Function to quickly build and program
function Start-BuildAndProgram {
    param([string]$project)
    make $project
    if ($LASTEXITCODE -eq 0) {
        make "prog-$project"
    }
}
Set-Alias -Name bp -Value Start-BuildAndProgram

# Function to simulate and view waveforms
function Start-SimAndWave {
    param([string]$project)
    make "sim-$project"
    if ($LASTEXITCODE -eq 0) {
        make "wave-$project"
    }
}
Set-Alias -Name sw -Value Start-SimAndWave

Write-Host "FPGA Development shortcuts loaded:" -ForegroundColor Green
Write-Host "  m <target>     - Short for 'make <target>'" -ForegroundColor Cyan  
Write-Host "  bp <project>   - Build and program project" -ForegroundColor Cyan
Write-Host "  sw <project>   - Simulate and view waveforms" -ForegroundColor Cyan
Write-Host "  Tab completion available for make targets!" -ForegroundColor Yellow
