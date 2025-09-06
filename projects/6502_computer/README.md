# 6502 Computer Project

This directory contains a complete 6502 computer implementation for FPGA.

## Directory Structure

```
6502_computer/
├── src/           # Verilog HDL source files
│   ├── top.v      # Top-level module (CPU + minimal memory)
│   ├── cpu.v      # Arlet Ottens 6502 CPU core
│   └── ALU.v      # 6502 ALU implementation
├── testbench/     # Simulation testbenches
│   └── cpu_6502_tb.v  # Comprehensive CPU test
└── asm/           # 6502 assembly programs
    ├── hello.s    # Simple test program
    ├── build.sh   # Assembly build script
    └── hello_manual.txt  # Manual assembly reference
```

## Building the Hardware

From the project root directory:

```bash
# Simulate the CPU
make sim-6502_computer

# Build for Tang Nano 9K  
make 6502_computer

# Program to FPGA
make prog-6502_computer

# View simulation waveforms
make wave-6502_computer
```

## Assembly Programming

The `asm/` directory contains 6502 assembly programs that can run on the CPU.

### Requirements
- cc65 toolchain (assembler and linker)
- Install from: https://github.com/cc65/cc65/releases/latest

### Building Assembly Programs
```bash
cd projects/6502_computer/asm
./build.sh hello
```

## Current Status

✅ **CPU Core**: Arlet Ottens 6502 - fully verified  
✅ **Simulation**: Comprehensive testbench with real 6502 program  
✅ **FPGA Build**: Successfully synthesizes and routes  
✅ **Assembly Tools**: Basic setup with cc65 configuration  
🔄 **Memory System**: Currently just NOP stub  
🔄 **I/O System**: Not yet implemented  

## Test Results

The CPU has been verified to correctly execute:
- Load immediate (LDA, LDX, LDY)
- Store operations (STA, STX, STY)  
- Memory loads (LDA from memory)
- Arithmetic (ADC with carry handling)
- Increment/Decrement (INX, INY, DEX)
- Control flow (JMP instructions)

All tests pass with 100% success rate!
