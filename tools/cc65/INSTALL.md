# 6502 Assembly Development Setup

Since we don't have cc65 installed yet, here are manual installation instructions and alternative approaches:

## Option 1: Install cc65 manually (Recommended)

### Windows:
1. Download from: https://github.com/cc65/cc65/releases/latest
2. Download the `cc65-snapshot-win32.zip` file
3. Extract to `tools/cc65/`
4. The tools will be in `tools/cc65/bin/`

### Linux/macOS:
```bash
# Ubuntu/Debian
sudo apt-get install cc65

# macOS with Homebrew  
brew install cc65
```

## Option 2: Use online assembler
- https://www.masswerk.at/6502/assembler.html
- Paste assembly code, get machine code hex

## Option 3: Manual assembly (for learning)
You can hand-assemble simple programs using 6502 instruction reference.

## Test without cc65

For now, you can test the CPU with the existing testbench which already contains a working 6502 program in machine code.

## Once cc65 is installed:

```bash
cd projects/6502_computer/asm
./build.sh hello
```

This will create `build/hello.bin` with your assembled program.
