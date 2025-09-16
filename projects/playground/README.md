# Playground Project

A simple blank project template for learning and experimenting with the Tang Nano FPGA.

## Features

- Basic LED blinking pattern (6 LEDs)
- Clock divider example
- Test pin output for oscilloscope/logic analyzer
- Reset functionality
- Simple and clean starting point for modifications

## Files

- `src/playground.v` - Main Verilog module
- `constraints/tangnano9k.cst` - Pin assignments for Tang Nano 9K
- `constraints/tangnano20k.cst` - Pin assignments for Tang Nano 20K  
- `testbench/playground_tb.v` - Simulation testbench

## Building

For Tang Nano 9K:
```bash
make playground
```

For Tang Nano 20K:
```bash
make playground BOARD=20k
```

## Programming

For Tang Nano 9K:
```bash
make prog_playground
```

For Tang Nano 20K:
```bash
make prog_playground BOARD=20k
```

## Simulation

```bash
make sim-playground
```

## What it does

- Creates a slow blinking alternating pattern on the 6 onboard LEDs
- Outputs a faster square wave on the test pin for scope verification
- Responds to the reset button

## Customization Ideas

- Change the LED patterns
- Add different clock dividers
- Experiment with different logic
- Add more input/output pins
- Try different timing patterns

This is your blank canvas for FPGA experimentation!