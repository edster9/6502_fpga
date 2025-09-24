# 6502 FPGA Computer

A complete 6502-based computer implementation for multiple FPGA development boards, featuring the proven **Arlet Ottens 6502 CPU core** and comprehensive development environment with simulation-first workflow.

## 🎯 Project Highlights

- ✅ **Multi-Board Support**: Tang Nano 20K, Tang Primer 25K, and iCE40 FPGA stick
- ✅ **Working 6502 CPU**: Cycle-accurate Arlet Ottens implementation verified in simulation
- ✅ **Complete Toolchain**: OSS CAD Suite with enhanced Makefile and auto-completion
- ✅ **Professional Workflow**: Git integration, comprehensive testing, waveform analysis
- ✅ **Playground Projects**: Interactive LED/switch demos for learning FPGA basics
- 🔄 **Memory System**: RAM/ROM controllers and peripherals (next phase)

## Quick Start

```bash
# Build playground project for Tang Nano 20K (default)
make playground

# Build for Tang Primer 25K (8 switches control 8 LEDs via PMOD)
make playground BOARD=primer_25k

# Build for iCE40 stick (4 switches control 4 LEDs)
make playground BOARD=ice40

# Test the 6502 CPU core
make sim_6502_computer

# View CPU execution in GTKWave
make wave_6502_computer
```

**Expected Results**: 
- **Playground Projects**: LEDs immediately respond to switch changes - perfect for verifying hardware setup
- **6502 CPU Simulation**: CPU executes LDA/LDX/LDY/STA/JMP instructions correctly with memory write confirmation

## Project Structure

```
├── projects/              # Main project directories
│   ├── hello_world/       # Basic LED Hello World project
│   ├── playground/        # Interactive LED/switch demos for learning
│   │   ├── src/
│   │   │   ├── playground_ice40.v      # iCE40 stick (4 switches/LEDs)
│   │   │   ├── playground_nano_20k.v   # Tang Nano 20K (onboard components)
│   │   │   └── playground_primer_25k.v # Tang Primer 25K (PMOD 8 switches/LEDs)
│   │   └── constraints/
│   │       ├── ice40.pcf               # iCE40 pin constraints
│   │       ├── nano_20k.cst           # Tang Nano 20K constraints
│   │       └── primer_25k.cst         # Tang Primer 25K constraints
│   ├── 6502_computer/     # 6502 CPU Computer implementation
│   ├── uart/              # UART communication project
│   ├── simple_cpu/        # Simple CPU example
│   └── sound/             # Audio generation project
├── build/                 # Build outputs (generated)
├── tools/                 # OSS CAD Suite and development tools
└── Makefile               # Comprehensive build system with multi-board support
```

## Hardware Targets

### Tang Nano 20K (Default)
- **FPGA**: Gowin GW2A-LV18QN88C8/I7  
- **Resources**: 20,736 LUT4, 15,552 DFF, 828 BSRAM
- **Memory**: 64Mbit external PSRAM
- **Clock**: 27MHz crystal oscillator
- **I/O**: 2x onboard buttons, RGB LEDs, GPIO pins, HDMI interface
- **Playground**: 2-switch to 2-LED demo using onboard components

### Tang Primer 25K
- **FPGA**: Gowin GW5A-LV25MG121NES
- **Resources**: 23,520 LUT4, 23,520 DFF, 1,152 BSRAM  
- **Memory**: 256Mbit external PSRAM
- **Clock**: 50MHz crystal oscillator
- **I/O**: Extensive GPIO via PMOD connectors
- **Playground**: 8-switch to 8-LED demo via PMOD1/PMOD2

### iCE40 FPGA Stick
- **FPGA**: Lattice iCE40-HX1K or iCE40-HX4K
- **Resources**: 1,280+ LUT4, 1,024+ DFF (varies by model)
- **Clock**: 12MHz crystal oscillator
- **I/O**: 4x switches, 4x LEDs, GPIO pins
- **Playground**: 4-switch to 4-LED direct mapping
- **Note**: Flash programming supported for permanent deployment

## Quick Start

### 1. Setup Development Environment
```bash
# The OSS CAD Suite is already included in tools/oss-cad-suite
# Version: 2025-09-24 (updated from 2025-09-04)
# All required tools are pre-configured
```

### 2. Start with Playground Projects
```bash
# Build playground for Tang Nano 20K (default - uses onboard components)
make playground

# Build playground for Tang Primer 25K (8-switch/8-LED PMOD demo)
make playground BOARD=primer_25k

# Build playground for iCE40 stick (4-switch/4-LED demo)
make playground BOARD=ice40

# Program to hardware (SRAM - temporary)
make prog_playground

# For iCE40: Flash programming (permanent)
make prog_playground BOARD=ice40  # Actually flashes, survives power cycle
```

### 3. Build Other Projects
```bash
# Build Hello World for Tang Nano 20K
make hello_world

# Build Hello World for Tang Primer 25K  
make hello_world BOARD=primer_25k

# Build and view all available commands
make help
```

### 4. Simulate and Debug
```bash
# Run simulation
make sim_hello_world

# View waveforms in GTKWave
make wave_hello_world
```

## Complete Command Reference

### Build Commands
| Command | Description | Board Support |
|---------|-------------|---------------|
| `make playground` | Build Playground LED/switch project | nano_20k, primer_25k, ice40 |
| `make hello_world` | Build Hello World LED project | nano_20k, primer_25k |
| `make debug_uart` | Build Debug UART project | nano_20k, primer_25k |
| `make 6502_computer` | Build 6502 Computer project | nano_20k, primer_25k |
| `make simple_cpu` | Build Simple CPU project | nano_20k, primer_25k |
| `make sound` | Build Sound generation project | nano_20k, primer_25k |
| `make video` | Build Video output project | nano_20k, primer_25k |

### Board Selection
| Board Parameter | Hardware | Description |
|----------------|----------|-------------|
| `BOARD=nano_20k` | Tang Nano 20K | Default board, onboard components |
| `BOARD=primer_25k` | Tang Primer 25K | PMOD-based I/O, higher capacity |
| `BOARD=ice40` | iCE40 FPGA stick | 4 switches/LEDs, flash programming |

### Simulation Commands
| Command | Description |
|---------|-------------|
| `make sim_hello_world` | Simulate Hello World project |
| `make sim_debug_uart` | Simulate Debug UART project |
| `make sim_6502_computer` | Simulate 6502 Computer project |
| `make sim_simple_cpu` | Simulate Simple CPU project |

### Waveform Viewing Commands
| Command | Description |
|---------|-------------|
| `make wave_hello_world` | View Hello World waveforms in GTKWave |
| `make wave_debug_uart` | View Debug UART waveforms in GTKWave |
| `make wave_uart` | View UART waveforms in GTKWave |
| `make wave_6502_computer` | View 6502 Computer waveforms in GTKWave |
| `make wave_simple_cpu` | View Simple CPU waveforms in GTKWave |

### Programming Commands
| Command | Description |
|---------|-------------|
| `make prog_playground` | Program Playground to FPGA |
| `make prog_hello_world` | Program Hello World to Tang Nano |
| `make prog_debug_uart` | Program Debug UART to Tang Nano |
| `make prog_6502_computer` | Program 6502 Computer to Tang Nano |
| `make prog_simple_cpu` | Program Simple CPU to Tang Nano |

**Note**: For Tang Nano boards, programming is to SRAM (temporary). For iCE40, programming is to flash (permanent).

### Utility Commands
| Command | Description |
|---------|-------------|
| `make clean` | Clean all build files |
| `make clean_hello_world` | Clean Hello World build files |
| `make clean_debug_uart` | Clean Debug UART build files |
| `make clean_6502_computer` | Clean 6502 Computer build files |
| `make clean_simple_cpu` | Clean Simple CPU build files |
| `make help` | Show comprehensive help |
| `make list-projects` | List all available projects |
| `make list-boards` | List supported boards |
| `make list-devices` | List connected FPGA devices |
| `make list-supported` | List all supported FPGA devices |
| `make list-gowin` | List supported Gowin/Tang devices |

### Board Selection Examples
```bash
# Build playground for Tang Nano 20K (default - onboard switches/LEDs)
make playground

# Build playground for Tang Primer 25K (PMOD 8-switch/8-LED demo)
make playground BOARD=primer_25k

# Build playground for iCE40 stick (4-switch/4-LED demo)  
make playground BOARD=ice40

# Build other projects for different boards
make hello_world BOARD=primer_25k
make 6502_computer BOARD=nano_20k

# Simulate and view waveforms (board-independent)
make sim_6502_computer
make wave_6502_computer

# Program specific board builds
make prog_playground                    # Programs nano_20k build (SRAM)
make prog_playground BOARD=primer_25k   # Programs primer_25k build (SRAM) 
make prog_playground BOARD=ice40        # Programs ice40 build (Flash - permanent!)
```

### Clean Commands Examples
```bash
# Clean all build files
make clean

# Clean specific project build files
make clean_hello_world
make clean_debug_uart
make clean_6502_computer

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

### Learning Path
1. **Playground**: `make playground` - Start here! Interactive LED/switch control for immediate feedback
   - Tang Nano 20K: 2 onboard switches control 2 LEDs
   - Tang Primer 25K: 8 PMOD switches control 8 PMOD LEDs  
   - iCE40 stick: 4 switches directly control 4 LEDs
2. **Hello World**: `make hello_world` - Learn LED patterns and timing
3. **Debug UART**: `make debug_uart` - Understand serial communication and debugging
4. **Simple CPU**: `make simple_cpu` - Basic processor concepts and state machines
5. **6502 Computer**: `make 6502_computer` - Complete retro computer implementation

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

### Playground Project Features
- **Tang Nano 20K**: Uses 2 onboard switches and 2 onboard LEDs for basic input/output learning
- **Tang Primer 25K**: Features 8-switch to 8-LED mapping via PMOD connectors for advanced I/O
- **iCE40 FPGA stick**: Direct 4-switch to 4-LED control with flash programming capability
- **Real-time Response**: Switches immediately control LED states - perfect for learning digital logic
- **Hardware Verification**: All playground variants tested and working on actual hardware

### Hello World Project
- **LED Patterns**: Configurable blinking patterns and timing
- **Clock Domains**: Understanding FPGA clock management  
- **Multi-board Support**: Automatically adapts to different board LED configurations
- **Pin Constraints**: Learn proper I/O pin assignment and electrical specifications

### Advanced Projects
- **UART Communication**: Serial debugging and communication protocols
- **6502 CPU**: Complete 8-bit microprocessor with cycle-accurate simulation
- **Sound Generation**: Audio synthesis and PWM-based sound output
- **Video Output**: HDMI/VGA signal generation for display interfaces

## Build System Details

The Makefile provides:
- **Multi-board Support**: Single command builds for nano_20k, primer_25k, and ice40 boards
- **Automatic Board Detection**: Intelligent constraint file and source file selection
- **Comprehensive Help**: `make help` shows all available commands and examples
- **Colored Output**: Clear visual feedback during builds with status indicators
- **Error Handling**: Proper error reporting and cleanup on build failures
- **Dependency Tracking**: Source changes trigger appropriate rebuilds
- **Organized Structure**: Board-specific source files and constraint files

## Troubleshooting

### Common Issues
- **"Tool not found" errors**: Run `source tools/oss-cad-suite/environment` first
- **Board not detected**: Check USB connection and driver installation (use Zadig for FTDI)
- **Build failures**: Verify board selection matches your hardware (`BOARD=nano_20k/primer_25k/ice40`)
- **Programming failures**: Ensure board is powered and in programming mode
- **GTKWave won't open**: Use proper environment setup before launching

### Board-Specific Tips
- **Tang Nano 20K**: Uses SRAM programming (temporary), supports HDMI output
- **Tang Primer 25K**: Requires PMOD modules for playground project, higher FPGA capacity
- **iCE40 stick**: Flash programming survives power cycles, limited to smaller designs

### Getting Help
- Run `make help` for complete command reference and examples
- Check `make list-devices` to see connected FPGA boards
- Verify board selection: `make list-boards` shows supported options
- Build logs provide detailed error information

## Contributing

1. Create new projects in `projects/<project_name>/` directory
2. Add board-specific source files: `src/<project>_<board>.v`
3. Create constraint files: `constraints/<board>.cst` or `constraints/<board>.pcf`
4. Update Makefile targets for new projects
5. Test builds on all supported boards
6. Add simulation testbenches in `testbench/`
7. Document new features and usage examples

## License

MIT License - see LICENSE file for details.
