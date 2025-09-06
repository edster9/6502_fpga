# cc65 6502 Cross-Development Tools

This directory contains the cc65 cross-compiler toolchain for 6502 development.

## Status: ✅ **INSTALLED AND WORKING**

## Tools Available

- `bin/ca65.exe` - 6502/65C02 macro assembler
- `bin/ld65.exe` - Linker for object files  
- `bin/cc65.exe` - C compiler for 6502 targets
- `bin/ar65.exe` - Archiver for object files
- `bin/od65.exe` - Object file disassembler
- `cfg/basic.cfg` - Custom linker configuration for our 6502 system

## Usage

Assembly programs are built from `projects/6502_computer/asm/`:

```bash
cd projects/6502_computer/asm
./build.sh hello    # Builds hello.s into build/hello.bin
```

## Installation Notes

- Binary files are excluded from git via .gitignore
- Only our custom `cfg/basic.cfg` and this README are tracked
- To reinstall: download cc65 zip and extract to this directory

## More Info

- Homepage: https://github.com/cc65/cc65
- Documentation included in `html/` directory (when installed)
- Example programs in `samples/` directory (when installed)