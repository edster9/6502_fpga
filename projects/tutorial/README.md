# FPGA Tutorial Project

This tutorial project contains step-by-step examples to learn FPGA development with Verilog.

## Tutorial Steps

### Step 1: Basic LED Toggle (`step1.v`)
- Simple LED that toggles every second
- Demonstrates basic clock dividers and counters
- Uses only the red LED

**Build:** `make tutorial-step1`

### Step 2: RGB Color Cycling (`step2.v`)
- Cycles through different colors on the RGB LED
- Demonstrates state machines
- Changes color every 0.5 seconds

**Build:** `make tutorial-step2`

### Step 3: PWM Brightness Control (`step3.v`)
- Uses PWM to create a breathing effect on the red LED
- Demonstrates PWM generation and brightness control
- Shows how to create smooth transitions

**Build:** `make tutorial-step3`

### Step 4: Button Debouncing (`step4.v`)
- Demonstrates button input handling (simulated since no physical buttons)
- Shows proper debouncing techniques
- Toggles LEDs on simulated button presses

**Build:** `make tutorial-step4`

## Usage

To build any tutorial step:
```bash
make tutorial-step<number>
# or for Tang Nano 20K:
make tutorial-step<number> BOARD=20k
```

To program the FPGA:
```bash
make prog-tutorial-step<number>
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
4. Build with: `make tutorial-step<number>`

## Notes

- All tutorial steps are designed for the Tang Nano's 27MHz clock
- Pin constraints are automatically applied based on the selected board (9K or 20K)
- Each step builds independently - you can jump to any step
- Output files are named `tutorial_<stepname>.fs` in the build directory
