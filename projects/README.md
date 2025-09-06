# FPGA Learning Projects

This workspace contains multiple FPGA projects for learning and development on the Tang Nano.

## Project Structure

```
projects/
├── hello_world/        # Simple LED counter for learning Verilog
│   ├── src/
│   │   └── hello_world.v
│   └── testbench/
│       └── hello_world_tb.v
└── 6502_computer/      # Advanced 6502 computer system
    ├── src/
    │   ├── top.v           # System top-level
    │   ├── cpu/
    │   │   └── cpu_6502.v  # 6502 CPU core
    │   └── memory/
    │       └── memory_controller.v
    └── testbench/          # (To be created)
```

## Getting Started

### 1. Learn with Hello World
Start with the `hello_world` project to learn Verilog basics:
- Simple 24-bit counter
- Controls RGB LED on Tang Nano
- Extensively commented for learning
- Quick build and simulation

### 2. Progress to 6502 Computer
Move to the `6502_computer` project for advanced topics:
- Complete 6502 CPU implementation
- Memory controller with RAM/ROM
- External PSRAM interface
- Complex system integration

## Build Commands

### Using Make
```bash
# Build Hello World project
make hello_world

# Simulate Hello World
make sim-hello_world

# Build 6502 Computer
make 6502_computer

# Program the FPGA
make prog-hello_world

# Build for Tang Nano 20K
make hello_world BOARD=20k
```

### Using VS Code Tasks
Open Command Palette (Ctrl+Shift+P) and run:
- `Tasks: Run Task` → `Build Hello World`
- `Tasks: Run Task` → `Simulate Hello World`
- `Tasks: Run Task` → `Program Hello World`
- `Tasks: Run Task` → `Build 6502 Computer`

## Learning Path

1. **Start Here**: `projects/hello_world/`
   - Read the extensively commented Verilog code
   - Build and simulate the project
   - Program it to your Tang Nano
   - Watch the LEDs blink at different rates

2. **Understanding Simulation**:
   - Run simulation and check `build/hello_world.vcd`
   - Open VCD files with GTKWave to see waveforms
   - Understand the testbench structure

3. **Modify and Experiment**:
   - Change LED blink patterns
   - Modify counter sizes
   - Add different behaviors

4. **Progress to 6502**:
   - Study the CPU implementation
   - Learn about memory controllers
   - Understand system integration

## Hardware Requirements

- **Tang Nano FPGA Board** (Gowin GW1N-LV1)
- **24MHz Crystal** (built-in)
- **RGB LEDs** (built-in)
- **External PSRAM** (for 6502 project)

## Pin Assignments

See `constraints/tangnano.cst` for detailed pin mappings:
- Clock: Pin 4 (24MHz crystal)
- LED Red: Pin 18
- LED Green: Pin 16  
- LED Blue: Pin 17

## Tools Used

- **Yosys** - Synthesis
- **nextpnr-himbaechel** - Place & Route
- **gowin_pack** - Bitstream generation
- **openFPGALoader** - Programming
- **Icarus Verilog** - Simulation
- **GTKWave** - Waveform viewing

## Next Steps

- Create more intermediate projects
- Add state machines and FSMs
- Implement communication protocols
- Connect external hardware
- Build more complex 6502 software

Happy learning! 🚀
