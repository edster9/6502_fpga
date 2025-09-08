#!/bin/bash
# Build script for 6502 assembly programs
# Usage: ./build.sh [program_name]
# Run from projects/6502_computer/asm/ directory

PROGRAM=${1:-hello}
CC65_PATH="../../../tools/cc65/bin"
BUILD_DIR="../../../build"
CFG_PATH="../../../tools/cc65/cfg"

echo "Building 6502 assembly program: $PROGRAM"

# Check if cc65 is in PATH or local tools directory
if command -v ca65 >/dev/null 2>&1; then
    echo "Using system cc65 tools"
    CA65="ca65"
    LD65="ld65"
elif [ -f "$CC65_PATH/ca65.exe" ]; then
    echo "Using local cc65 tools"
    CA65="$CC65_PATH/ca65.exe"
    LD65="$CC65_PATH/ld65.exe"
else
    echo "ERROR: cc65 tools not found!"
    echo "Please install cc65 or place it in $CC65_PATH/"
    echo ""
    echo "Download from: https://github.com/cc65/cc65/releases/latest"
    exit 1
fi

# Create build directory
mkdir -p "$BUILD_DIR"

# Assemble the source file
echo "Assembling $PROGRAM.s..."
$CA65 "$PROGRAM.s" -o "$BUILD_DIR/$PROGRAM.o"

if [ $? -ne 0 ]; then
    echo "Assembly failed!"
    exit 1
fi

# Link the object file
echo "Linking $PROGRAM.o..."
$LD65 -C "$CFG_PATH/basic.cfg" "$BUILD_DIR/$PROGRAM.o" -o "$BUILD_DIR/$PROGRAM.bin"

if [ $? -ne 0 ]; then
    echo "Linking failed!"
    exit 1
fi

echo "Build successful! Output: $BUILD_DIR/$PROGRAM.bin"
echo "Binary size: $(wc -c < "$BUILD_DIR/$PROGRAM.bin") bytes"

# Create hex dump for inspection
if command -v hexdump >/dev/null 2>&1; then
    echo ""
    echo "Hex dump of first 64 bytes:"
    hexdump -C "$BUILD_DIR/$PROGRAM.bin" | head -4
fi
