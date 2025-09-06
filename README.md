# 6502 FPGA Computer

A complete 6502-based computer implementation for the Tang Nano FPGA development board, featuring the proven **Arlet Ottens 6502 CPU core** and comprehensive development environment with simulation-first workflow.

## 🎯 Project Highlights

- ✅ **Working 6502 CPU**: Cycle-accurate Arlet Ottens implementation verified in simulation
- ✅ **Complete Toolchain**: OSS CAD Suite with enhanced Makefile and auto-completion
- ✅ **Educational Tutorials**: Boolean algebra and K-map derived digital logic examples  
- ✅ **Professional Workflow**: Git integration, comprehensive testing, waveform analysis
- 🔄 **Memory System**: RAM/ROM controllers and peripherals (next phase)

## Quick Verification

```bash
# Test the 6502 CPU core
make sim-6502_computer

# View CPU execution in GTKWave
make wave-6502_computer
```

**Expected Result**: CPU executes LDA/LDX/LDY/STA/JMP instructions correctly, with memory write confirmation.

## Project Structure

```
├── projects/              # Main project directories
│   ├── hello_world/       # Basic LED Hello World project
│   ├── 6502_computer/     # 6502 CPU Computer implementation
│   └── tutorial/          # Step-by-step learning tutorials
│       └── src/           # Tutorial source files
│           ├── step1.v    # Basic LED toggle
│           ├── step2.v    # RGB color cycling
│           ├── step3.v    # PWM breathing effect
│           └── step4.v    # Button debouncing
├── testbench/             # All simulation testbenches
│   ├── blinky_tb.v        # Blinky testbench (legacy)
│   ├── tutorial_step1_tb.v # Tutorial Step 1 testbench
│   ├── tutorial_step2_tb.v # Tutorial Step 2 testbench
│   ├── tutorial_step3_tb.v # Tutorial Step 3 testbench
│   └── tutorial_step4_tb.v # Tutorial Step 4 testbench
├── constraints/           # FPGA pin constraints for different boards
│   ├── tangnano9k.cst     # Tang Nano 9K constraints
│   └── tangnano20k.cst    # Tang Nano 20K constraints
├── build/                 # Build outputs (generated)
├── tools/                 # OSS CAD Suite and development tools
└── Makefile               # Comprehensive build system
```

## Hardware Targets

### Tang Nano 9K (Default)
- **FPGA**: Gowin GW1NR-LV9QN88PC6/I5
- **Resources**: 8,640 LUT4, 6,480 DFF, 270 BSRAM
- **Memory**: 256KB external PSRAM
- **Clock**: 27MHz crystal oscillator
- **I/O**: RGB LEDs, GPIO pins, HDMI interface

### Tang Nano 20K  
- **FPGA**: Gowin GW2A-LV18PG256C8/I7
- **Resources**: 20,736 LUT4, 15,552 DFF, 30 BSRAM
- **Memory**: 64Mbit external PSRAM
- **Clock**: 27MHz crystal oscillator
- **I/O**: RGB LEDs, GPIO pins, HDMI interface

## Quick Start

### 1. Setup Development Environment
```bash
# The OSS CAD Suite is already included in tools/oss-cad-suite
# Just ensure your terminal can run the tools
```

### 2. Build Your First Project
```bash
# Build Hello World for Tang Nano 9K
make hello_world

# Build Hello World for Tang Nano 20K  
make hello_world BOARD=20k

# Build and view all available commands
make help
```

### 3. Simulate and Debug
```bash
# Run simulation
make sim-hello_world

# View waveforms in GTKWave
make wave-hello_world
```

### 4. Program the FPGA
```bash
# Program the Tang Nano
make prog-hello_world
```

## Complete Command Reference

### Build Commands
| Command | Description | Board Support |
|---------|-------------|---------------|
| `make hello_world` | Build Hello World LED project | 9K, 20K |
| `make 6502_computer` | Build 6502 Computer project | 9K, 20K |
| `make tutorial-step1` | Build Tutorial Step 1 (LED toggle) | 9K, 20K |
| `make tutorial-step2` | Build Tutorial Step 2 (RGB cycling) | 9K, 20K |
| `make tutorial-step3` | Build Tutorial Step 3 (PWM breathing) | 9K, 20K |
| `make tutorial-step4` | Build Tutorial Step 4 (Button debounce) | 9K, 20K |

### Simulation Commands
| Command | Description |
|---------|-------------|
| `make sim-hello_world` | Simulate Hello World project |
| `make sim-6502_computer` | Simulate 6502 Computer project |
| `make sim-tutorial-step1` | Simulate Tutorial Step 1 |
| `make sim-tutorial-step2` | Simulate Tutorial Step 2 |
| `make sim-tutorial-step3` | Simulate Tutorial Step 3 |
| `make sim-tutorial-step4` | Simulate Tutorial Step 4 |

### Waveform Viewing Commands
| Command | Description |
|---------|-------------|
| `make wave-hello_world` | View Hello World waveforms in GTKWave |
| `make wave-6502_computer` | View 6502 Computer waveforms in GTKWave |
| `make wave-tutorial-step1` | View Tutorial Step 1 waveforms in GTKWave |
| `make wave-tutorial-step2` | View Tutorial Step 2 waveforms in GTKWave |
| `make wave-tutorial-step3` | View Tutorial Step 3 waveforms in GTKWave |
| `make wave-tutorial-step4` | View Tutorial Step 4 waveforms in GTKWave |

### Programming Commands
| Command | Description |
|---------|-------------|
| `make prog-hello_world` | Program Hello World to Tang Nano |
| `make prog-6502_computer` | Program 6502 Computer to Tang Nano |
| `make prog-tutorial-step1` | Program Tutorial Step 1 to Tang Nano |
| `make prog-tutorial-step2` | Program Tutorial Step 2 to Tang Nano |
| `make prog-tutorial-step3` | Program Tutorial Step 3 to Tang Nano |
| `make prog-tutorial-step4` | Program Tutorial Step 4 to Tang Nano |
| `make prog-tutorial-step4` | Program Tutorial Step 4 to Tang Nano |

### Utility Commands
| Command | Description |
|---------|-------------|
| `make clean` | Clean all build files |
| `make clean-hello_world` | Clean Hello World build files |
| `make clean-6502_computer` | Clean 6502 Computer build files |
| `make clean-tutorial-step1` | Clean Tutorial Step 1 build files |
| `make clean-tutorial-step2` | Clean Tutorial Step 2 build files |
| `make clean-tutorial-step3` | Clean Tutorial Step 3 build files |
| `make clean-tutorial-step4` | Clean Tutorial Step 4 build files |
| `make help` | Show comprehensive help |
| `make list-projects` | List all available projects |
| `make list-boards` | List supported boards |

### Board Selection Examples
```bash
# Build for Tang Nano 9K (default)
make hello_world

# Build for Tang Nano 20K
make hello_world BOARD=20k

# Simulate and view waveforms (board-independent)
make sim-hello_world
make wave-hello_world

# Program specific board builds
make prog-hello_world        # Programs 9K build
make prog-hello_world BOARD=20k  # Programs 20K build
```

### Clean Commands Examples
```bash
# Clean all build files
make clean

# Clean specific project build files
make clean-hello_world
make clean-6502_computer
make clean-tutorial-step1

# Clean before fresh build
make clean && make hello_world
```

## Development Workflow

### Typical Development Cycle
1. **Write/Edit Verilog**: Modify source files in `projects/*/src/`
2. **Simulate**: `make sim-<project>` to verify functionality
3. **Debug**: `make wave-<project>` to analyze timing and signals
4. **Build**: `make <project>` to synthesize for target FPGA
5. **Program**: `make prog-<project>` to load onto hardware
6. **Test**: Verify hardware functionality

### Tutorial Learning Path
1. **Step 1**: `make tutorial-step1` - Learn basic LED control and clock division
2. **Step 2**: `make tutorial-step2` - Understand state machines with RGB cycling
3. **Step 3**: `make tutorial-step3` - Master PWM techniques with breathing effect
4. **Step 4**: `make tutorial-step4` - Handle user input with button debouncing

## Development Tools

The project includes a complete open-source FPGA toolchain in `tools/oss-cad-suite/`:

- **Yosys**: Verilog synthesis to netlist
- **nextpnr-himbaechel**: Place and route for Gowin FPGAs
- **gowin_pack**: Bitstream generation
- **openFPGALoader**: Board programming
- **Icarus Verilog**: Verilog simulation
- **GTKWave**: Waveform visualization
- **Project Apicula**: Gowin FPGA support libraries

## Project Features

### Hello World Project
- Basic LED control demonstration
- Clock domain understanding
- Pin constraint usage
- Multi-board support

### Tutorial Projects
- **Step 1**: Counter-based LED toggling with precise timing
- **Step 2**: RGB color cycling using state machines
- **Step 3**: PWM brightness control with breathing effect
- **Step 4**: Button input with proper debouncing

### 6502 Computer Project (In Development)
- Full 6502 CPU implementation
- Memory management and I/O
- Cycle-accurate simulation
- Interactive programming interface

## Build System Details

The Makefile provides:
- **Automatic dependency tracking**: Source changes trigger rebuilds
- **Multi-board support**: Single command builds for different targets
- **Colored output**: Clear visual feedback during builds
- **Error handling**: Proper error reporting and cleanup
- **Parallel builds**: Efficient use of build resources

## Troubleshooting

### Common Issues
- **"Tool not found" errors**: Ensure OSS CAD Suite environment is set up
- **GTKWave won't open**: Use the proper environment setup sequence
- **Build failures**: Check source file syntax and constraint file paths
- **Programming failures**: Verify board connection and driver installation

### Getting Help
- Run `make help` for complete command reference
- Check build logs in terminal output
- Verify file paths match project structure
- Ensure board selection matches your hardware

## Contributing

1. Create new projects in `projects/` directory
2. Add corresponding testbenches in `testbench/`
3. Update Makefile targets for new projects
4. Test builds on both Tang Nano 9K and 20K
5. Document new features in README

```
0x0000-0x00FF: Zero Page RAM
0x0100-0x01FF: Stack
0x0200-0x7FFF: General RAM
0x8000-0xBFFF: I/O Space
0xC000-0xFFFF: ROM/Bootloader
```

## Building

Use VS Code tasks or command line:

```bash
# Synthesize design
yosys -p "read_verilog src/top.v; synth_gowin -json build/top.json"

# Place and route
nextpnr-himbaechel --json build/top.json --write build/top_pnr.json \
    --device GW1N-LV1QN48C6/I5 --vopt cst=constraints/tangnano.cst

# Generate bitstream
gowin_pack -d GW1N-LV1QN48C6/I5 -o build/top.fs build/top_pnr.json

# Program FPGA
openFPGALoader -b tangnano build/top.fs
```

## License

MIT License - see LICENSE file for details.
