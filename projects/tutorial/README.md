# FPGA Tutorial Project

This tutorial project contains step-by-step examples to learn FPGA development with Verilog.

## Tutorial Steps

### Step 1: Basic LED Toggle (`step1.v`)
- Simple LED that toggles every second
- Demonstrates basic clock dividers and counters
- Uses only the red LED

**Build:** `.\build.ps1 -Target tutorial -Project tutorial -File step1 -Board 9k`

### Step 2: RGB Color Cycling (`step2.v`)
- Cycles through different colors on the RGB LED
- Demonstrates state machines
- Changes color every 0.5 seconds

**Build:** `.\build.ps1 -Target tutorial -Project tutorial -File step2 -Board 9k`

### Step 3: PWM Brightness Control (`step3.v`)
- Uses PWM to create a breathing effect on the red LED
- Demonstrates PWM generation and brightness control
- Shows how to create smooth transitions

**Build:** `.\build.ps1 -Target tutorial -Project tutorial -File step3 -Board 9k`

### Step 4: Button Debouncing (`step4.v`)
- Demonstrates button input handling (simulated since no physical buttons)
- Shows proper debouncing techniques
- Toggles LEDs on simulated button presses

**Build:** `.\build.ps1 -Target tutorial -Project tutorial -File step4 -Board 9k`

## Usage

To build any tutorial step:
```powershell
.\build.ps1 -Target tutorial -Project tutorial -File <stepname> -Board <9k|20k>
```

To program the FPGA:
```powershell
.\build.ps1 -Target program -Project tutorial -File <stepname>
```

## Adding New Steps

1. Create a new `.v` file in the `src/` directory (e.g., `step5.v`)
2. Make sure the module name matches the filename (e.g., `module step5`)
3. Use the standard port interface:
   ```verilog
   module stepX (
       input clk,          // 27MHz clock input
       output led_r,       // Red LED output
       output led_g,       // Green LED output  
       output led_b        // Blue LED output
   );
   ```
4. Build with: `.\build.ps1 -Target tutorial -Project tutorial -File stepX -Board 9k`

## Notes

- All tutorial steps are designed for the Tang Nano's 27MHz clock
- Pin constraints are automatically applied based on the selected board (9K or 20K)
- Each step builds independently - you can jump to any step
- Output files are named `tutorial_<stepname>.fs` in the build directory
