# Development Tools

This directory contains the development toolchains required for the 6502 FPGA project.

## OSS CAD Suite

**What it is:** A complete open-source FPGA development toolchain including synthesis (Yosys), place & route (nextpnr), and device-specific tools. This is used for synthesizing Verilog designs and generating bitstreams for the Tang Nano FPGA boards.

**Where to get it:** Download from the releases page at:
https://github.com/YosysHQ/oss-cad-suite-build/releases/latest

Extract the downloaded archive to `tools/oss-cad-suite/` in this project. The project includes scripts to automatically configure the environment.

## CC65 Toolchain

**What it is:** A complete C compiler suite for 6502-based systems, including assembler, linker, and libraries. This is used for developing software that runs on the 6502 CPU implemented in the FPGA.

**Where to get it:** Download and installation instructions available at:
https://cc65.github.io/getting-started.html

Extract or install to `tools/cc65/` in this project to maintain a self-contained development environment.

## Usage

Both toolchains are configured to work locally within this project directory. The build system automatically sets up the proper environment paths when running make commands.
