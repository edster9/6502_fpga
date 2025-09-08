# 6502 FPGA Computer

A complete 6502-based computer implementation for the Tang Nano FPGA development board, featuring the proven **Arlet Ottens 6502 CPU core** and comprehensive development environment with simulation-first workflow.

## 🎯 Project Highlights

- ✅ **Working 6502 CPU**: Cycle-accurate Arlet Ottens implementation verified in simulation
- ✅ **Complete Toolchain**: OSS CAD Suite with enhanced Makefile and auto-completion
- ✅ **Professional Workflow**: Git integration, comprehensive testing, waveform analysis
- 🔄 **Memory System**: RAM/ROM controllers and peripherals (next phase)

## Quick Verification

```bash
# Test the 6502 CPU core
make sim_6502_computer

# View CPU execution in GTKWave
make wave_6502_computer
```

**Expected Result**: CPU executes LDA/LDX/LDY/STA/JMP instructions correctly, with memory write confirmation.

## Project Structure

```
├── projects/              # Main project directories
│   ├── hello-world/       # Basic LED Hello World project
│   └── 6502-computer/     # 6502 CPU Computer implementation
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
make sim_hello_world

# View waveforms in GTKWave
make wave_hello_world
```

### 4. Program the FPGA
```bash
# Program the Tang Nano
make prog_hello_world
```

## Complete Command Reference

### Build Commands
| Command | Description | Board Support |
|---------|-------------|---------------|
| `make hello_world` | Build Hello World LED project | 9K, 20K |
| `make debug_uart` | Build Debug UART project | 9K, 20K |
| `make 6502_computer` | Build 6502 Computer project | 9K, 20K |
| `make simple_cpu` | Build Simple CPU project | 9K, 20K |

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
| `make wave_6502_computer` | View 6502 Computer waveforms in GTKWave |
| `make wave_simple_cpu` | View Simple CPU waveforms in GTKWave |

### Programming Commands
| Command | Description |
|---------|-------------|
| `make prog_hello_world` | Program Hello World to Tang Nano |
| `make prog_debug_uart` | Program Debug UART to Tang Nano |
| `make prog_6502_computer` | Program 6502 Computer to Tang Nano |
| `make prog_simple_cpu` | Program Simple CPU to Tang Nano |

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

### Board Selection Examples
```bash
# Build for Tang Nano 9K (default)
make hello-world

# Build for Tang Nano 20K
make hello-world BOARD=20k

# Simulate and view waveforms (board-independent)
make sim-hello-world
make wave-hello-world

# Program specific board builds
make prog-hello-world        # Programs 9K build
make prog-hello-world BOARD=20k  # Programs 20K build
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
1. **Hello World**: `make hello_world` - Learn basic LED control and FPGA fundamentals
2. **Debug UART**: `make debug_uart` - Understand serial communication and debugging
3. **Simple CPU**: `make simple_cpu` - Basic processor concepts and state machines
4. **6502 Computer**: `make 6502_computer` - Complete retro computer implementation

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
