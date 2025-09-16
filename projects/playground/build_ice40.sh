#!/bin/bash
# Build script for playground project on iCE40 stick
# Uses open source iCE40 toolchain: yosys + nextpnr + iceprog

set -e  # Exit on any error

PROJECT=playground
DEVICE=hx1k  # Common iCE40 device, adjust as needed
PACKAGE=tq144  # Common package for iCE40 sticks

echo "Building $PROJECT for iCE40 stick..."

# Create build directory
mkdir -p build

# Step 1: Synthesis with Yosys
echo "Step 1: Synthesis..."
yosys -p "read_verilog -D ICE40 src/$PROJECT.v; synth_ice40 -top $PROJECT -json build/$PROJECT.json"

# Step 2: Place and Route with nextpnr
echo "Step 2: Place and Route..."
nextpnr-ice40 --$DEVICE --package $PACKAGE --json build/$PROJECT.json --pcf constraints/ice40_stick.pcf --asc build/$PROJECT.asc

# Step 3: Generate bitstream
echo "Step 3: Generate bitstream..."
icepack build/$PROJECT.asc build/$PROJECT.bin

echo "Build complete! Bitstream: build/$PROJECT.bin"
echo ""
echo "To program the board, run:"
echo "  iceprog build/$PROJECT.bin"