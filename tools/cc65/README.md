# 6502 Assembly Development Setup
# 
# This directory contains tools and setup for 6502 assembly programming

## cc65 Toolchain
cc65 is the recommended toolchain for 6502 development. It includes:
- ca65: 6502/65C02 macro assembler
- ld65: linker for object files created by ca65
- cc65: C compiler that generates 6502 assembly
- od65: object file disassembler
- ar65: archiver for object files

### Manual Installation (Windows)
1. Download from: https://github.com/cc65/cc65/releases/latest
2. Extract to `tools/cc65/`
3. Add `tools/cc65/bin` to your PATH

### Manual Installation (Linux/macOS)
```bash
# Ubuntu/Debian
sudo apt-get install cc65

# macOS with Homebrew
brew install cc65

# Or build from source
git clone https://github.com/cc65/cc65.git
cd cc65
make
```

## Usage Examples

### Simple Assembly Program
```assembly
; hello.s - Simple 6502 program
.setcpu "6502"

.segment "CODE"
reset:
    LDA #$42        ; Load 0x42 into accumulator
    STA $8000       ; Store to memory location $8000
    JMP reset       ; Loop forever

.segment "VECTORS"
.addr reset         ; NMI vector
.addr reset         ; Reset vector  
.addr reset         ; IRQ vector
```

### Build Commands
```bash
# Assemble and link
ca65 hello.s -o hello.o
ld65 -C basic.cfg hello.o -o hello.bin

# Or use cc65 with C code
cc65 hello.c
ca65 hello.s
ld65 -C basic.cfg hello.o -o hello.bin
```

## Configuration Files
The `cfg/` directory contains linker configuration files for different target systems.
