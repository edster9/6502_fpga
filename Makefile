# ==============================================================================
# FPGA Development Makefile for Tang Nano 9K/20K
# ==============================================================================
# This Makefile simplifies all FPGA development tasks:
# - Building projects for different boards
# - Running simulations
# - Viewing waveforms with GTKWave
# - Programming the FPGA
# - Managing multiple projects
#
# Usage Examples:
#   make help                    - Show all available commands
#   make hello_world             - Build hello_world project for Tang Nano 9K
#   make hello_world BOARD=20k   - Build hello_world project for Tang Nano 20K
#   make sim-hello_world         - Simulate hello_world project
#   make wave-hello_world        - View hello_world waveforms in GTKWave
#   make prog-hello_world        - Program hello_world to Tang Nano
#   make tutorial-step1          - Build tutorial step1
#   make clean                   - Clean all build files
# ==============================================================================

# ==============================================================================
# CONFIGURATION
# ==============================================================================

# Build directories
BUILD_DIR := build
PROJECTS_DIR := projects
CONSTRAINTS_DIR := constraints

# Board configuration (default: 9k, can override with BOARD=20k)
BOARD ?= 9k
ifeq ($(BOARD),20k)
    DEVICE := GW2A-LV18PG256C8/I7
    FAMILY := GW2A-18C
    CONSTRAINTS := $(CONSTRAINTS_DIR)/tangnano20k.cst
else
    DEVICE := GW1NR-LV9QN88PC6/I5
    FAMILY := GW1N-9C
    CONSTRAINTS := $(CONSTRAINTS_DIR)/tangnano9k.cst
endif

# OSS CAD Suite setup - bash only
OSS_CAD_SUITE := tools/oss-cad-suite

# Environment setup using bash and sourcing
ENV_SETUP := eval $$(./run_with_env.sh) &&
SHELL_TYPE := bash
SHELL := /bin/bash

# Define cleanup commands
define CLEAN_ALL
	rm -rf $(BUILD_DIR)/*
endef

define CLEAN_PROJECT
	rm -f $(BUILD_DIR)/$(1)*
endef

# Colors for output - disabled on Windows due to Git Bash compatibility
ifeq ($(OS),Windows_NT)
    # On Windows, disable colors to avoid control character issues
    GREEN := 
    BLUE := 
    YELLOW := 
    RED := 
    NC := 
else
    # On Unix systems, colors should work fine
    GREEN := \033[32m
    BLUE := \033[34m
    YELLOW := \033[33m
    RED := \033[31m
    NC := \033[0m
endif

# ==============================================================================
# MAIN TARGETS
# ==============================================================================

.PHONY: all help clean clean-hello_world clean-6502_computer clean-tutorial-step1 clean-tutorial-step2 clean-tutorial-step3 clean-tutorial-step4
.DEFAULT_GOAL := help

all: hello_world tutorial-step1

# Create build directory
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# ==============================================================================
# PROJECT BUILD TARGETS
# ==============================================================================

# Hello World Project
.PHONY: hello_world
hello_world: $(BUILD_DIR)/hello_world.fs
	@echo "$(GREEN)[OK] Hello World built successfully for Tang Nano $(BOARD)$(NC)"

$(BUILD_DIR)/hello_world.json: $(PROJECTS_DIR)/hello_world/src/hello_world.v | $(BUILD_DIR)
	@echo "$(BLUE)Synthesizing hello_world...$(NC)"
	$(ENV_SETUP) yosys -p "read_verilog $<; synth_gowin -json $@"

$(BUILD_DIR)/hello_world_pnr.json: $(BUILD_DIR)/hello_world.json
	@echo "$(BLUE)Place & Route for hello_world...$(NC)"
	$(ENV_SETUP) nextpnr-himbaechel --json $< --write $@ --device $(DEVICE) --vopt family=$(FAMILY) --vopt cst=$(CONSTRAINTS)

$(BUILD_DIR)/hello_world.fs: $(BUILD_DIR)/hello_world_pnr.json
	@echo "$(BLUE)Generating bitstream for hello_world...$(NC)"
	$(ENV_SETUP) gowin_pack -d $(DEVICE) -o $@ $<

# 6502 Computer Project
.PHONY: 6502_computer
6502_computer: $(BUILD_DIR)/6502_computer.fs
	@echo "$(GREEN)[OK] 6502 Computer built successfully for Tang Nano $(BOARD)$(NC)"

$(BUILD_DIR)/6502_computer.json: $(PROJECTS_DIR)/6502_computer/src/top.v $(PROJECTS_DIR)/6502_computer/src/cpu.v $(PROJECTS_DIR)/6502_computer/src/ALU.v | $(BUILD_DIR)
	@echo "$(BLUE)Synthesizing 6502_computer...$(NC)"
	$(ENV_SETUP) yosys -p "read_verilog -nolatches $^; hierarchy -check -top top; proc; opt; memory; opt; techmap; opt; clean; write_json $@"

$(BUILD_DIR)/6502_computer_pnr.json: $(BUILD_DIR)/6502_computer.json
	@echo "$(BLUE)Place & Route for 6502_computer...$(NC)"
	$(ENV_SETUP) nextpnr-himbaechel --json $< --write $@ --device $(DEVICE) --vopt family=$(FAMILY) --vopt cst=$(CONSTRAINTS_DIR)/tangnano9k_basic.cst

$(BUILD_DIR)/6502_computer.fs: $(BUILD_DIR)/6502_computer_pnr.json
	@echo "$(BLUE)Generating bitstream for 6502_computer...$(NC)"
	$(ENV_SETUP) gowin_pack -d $(DEVICE) -o $@ $<

# Tutorial Steps (Dynamic targets for step1, step2, step3, step4)
.PHONY: tutorial-step1 tutorial-step2 tutorial-step3 tutorial-step4
tutorial-step1: $(BUILD_DIR)/tutorial_step1.fs
tutorial-step2: $(BUILD_DIR)/tutorial_step2.fs  
tutorial-step3: $(BUILD_DIR)/tutorial_step3.fs
tutorial-step4: $(BUILD_DIR)/tutorial_step4.fs

$(BUILD_DIR)/tutorial_step%.json: $(PROJECTS_DIR)/tutorial/src/step%.v | $(BUILD_DIR)
	@echo "$(BLUE)Synthesizing tutorial step$*...$(NC)"
	$(ENV_SETUP) yosys -p "read_verilog $<; synth_gowin -json $@"

$(BUILD_DIR)/tutorial_step%_pnr.json: $(BUILD_DIR)/tutorial_step%.json
	@echo "$(BLUE)Place & Route for tutorial step$*...$(NC)"
	$(ENV_SETUP) nextpnr-himbaechel --json $< --write $@ --device $(DEVICE) --vopt family=$(FAMILY) --vopt cst=$(CONSTRAINTS)

$(BUILD_DIR)/tutorial_step%.fs: $(BUILD_DIR)/tutorial_step%_pnr.json
	@echo "$(BLUE)Generating bitstream for tutorial step$*...$(NC)"
	$(ENV_SETUP) gowin_pack -d $(DEVICE) -o $@ $<
	@echo "$(GREEN)[OK] Tutorial step$* built successfully for Tang Nano $(BOARD)$(NC)"

# ==============================================================================
# SIMULATION TARGETS  
# ==============================================================================

.PHONY: sim-hello_world sim-6502_computer sim-tutorial-step1 sim-tutorial-step2 sim-tutorial-step3 sim-tutorial-step4

sim-hello_world: $(BUILD_DIR)/hello_world.vcd
	@echo "$(GREEN)[OK] Hello World simulation completed$(NC)"

.PHONY: sim-hello_world sim-6502_computer sim-tutorial-step1 sim-tutorial-step2 sim-tutorial-step3 sim-tutorial-step4
.PHONY: run-sim-tutorial-step1 run-sim-tutorial-step2 run-sim-tutorial-step3 run-sim-tutorial-step4

# Standard simulation targets (check if VCD exists)
sim-hello_world: $(BUILD_DIR)/hello_world.vcd
	@echo "$(GREEN)[OK] Hello World simulation completed$(NC)"

sim-6502_computer: $(BUILD_DIR)/6502_computer.vcd
	@echo "$(GREEN)[OK] 6502 Computer simulation completed$(NC)"

sim-tutorial-step1: $(BUILD_DIR)/tutorial_step1.vcd
	@echo "$(GREEN)[OK] Tutorial step 1 simulation completed$(NC)"

sim-tutorial-step2: $(BUILD_DIR)/tutorial_step2.vcd
	@echo "$(GREEN)[OK] Tutorial step 2 simulation completed$(NC)"

sim-tutorial-step3: $(BUILD_DIR)/tutorial_step3.vcd
	@echo "$(GREEN)[OK] Tutorial step 3 simulation completed$(NC)"

sim-tutorial-step4: $(BUILD_DIR)/tutorial_step4.vcd
	@echo "$(GREEN)[OK] Tutorial step 4 simulation completed$(NC)"

# Force simulation targets (always run)
run-sim-tutorial-step1:
	@echo "$(BLUE)Running tutorial step 1 simulation...$(NC)"
	@-$(MAKE) clean-tutorial-step1
	@$(MAKE) $(BUILD_DIR)/tutorial_step1.vcd
	@echo "$(GREEN)[OK] Tutorial step 1 simulation completed and ready$(NC)"

run-sim-tutorial-step2:
	@echo "$(BLUE)Running tutorial step 2 simulation...$(NC)"
	@-$(MAKE) clean-tutorial-step2
	@$(MAKE) $(BUILD_DIR)/tutorial_step2.vcd
	@echo "$(GREEN)[OK] Tutorial step 2 simulation completed and ready$(NC)"

run-sim-tutorial-step3:
	@echo "$(BLUE)Running tutorial step 3 simulation...$(NC)"
	@-$(MAKE) clean-tutorial-step3
	@$(MAKE) $(BUILD_DIR)/tutorial_step3.vcd
	@echo "$(GREEN)[OK] Tutorial step 3 simulation completed and ready$(NC)"

run-sim-tutorial-step4:
	@echo "$(BLUE)Running tutorial step 4 simulation...$(NC)"
	@-$(MAKE) clean-tutorial-step4
	@$(MAKE) $(BUILD_DIR)/tutorial_step4.vcd
	@echo "$(GREEN)[OK] Tutorial step 4 simulation completed and ready$(NC)"

# Simulation build rules
$(BUILD_DIR)/hello_world_sim: $(PROJECTS_DIR)/hello_world/testbench/hello_world_tb.v $(PROJECTS_DIR)/hello_world/src/hello_world.v | $(BUILD_DIR)
	@echo "$(BLUE)Compiling hello_world simulation...$(NC)"
	$(ENV_SETUP) iverilog -o $@ $^

$(BUILD_DIR)/6502_computer_sim: $(PROJECTS_DIR)/6502_computer/testbench/cpu_6502_tb.v $(PROJECTS_DIR)/6502_computer/src/cpu.v $(PROJECTS_DIR)/6502_computer/src/ALU.v | $(BUILD_DIR)
	@echo "$(BLUE)Compiling 6502 CPU simulation...$(NC)"
	$(ENV_SETUP) iverilog -o $@ $^

$(BUILD_DIR)/tutorial_step%_sim: $(PROJECTS_DIR)/tutorial/testbench/step%_tb.v $(PROJECTS_DIR)/tutorial/src/step%.v | $(BUILD_DIR)
	@echo "$(BLUE)Compiling tutorial step$* simulation...$(NC)"
	$(ENV_SETUP) iverilog -o $@ $^

# VCD generation rules
$(BUILD_DIR)/%.vcd: $(BUILD_DIR)/%_sim
	@echo "$(BLUE)Running simulation for $*...$(NC)"
	$(ENV_SETUP) vvp $< && echo "$(GREEN)Waveform saved to $@$(NC)"

# ==============================================================================
# GTKWAVE TARGETS
# ==============================================================================

.PHONY: wave-hello_world wave-6502_computer wave-tutorial-step1 wave-tutorial-step2 wave-tutorial-step3 wave-tutorial-step4

wave-hello_world: $(BUILD_DIR)/hello_world.vcd
	@echo "$(BLUE)Opening GTKWave for hello_world...$(NC)"
	$(ENV_SETUP) gtkwave $<

wave-6502_computer: $(BUILD_DIR)/6502_computer.vcd
	@echo "$(BLUE)Opening GTKWave for 6502_computer...$(NC)"
	$(ENV_SETUP) gtkwave $<

wave-tutorial-step1: $(BUILD_DIR)/tutorial_step1.vcd
	@echo "$(BLUE)Opening GTKWave for tutorial step 1...$(NC)"
	$(ENV_SETUP) gtkwave $<

wave-tutorial-step2: $(BUILD_DIR)/tutorial_step2.vcd
	@echo "$(BLUE)Opening GTKWave for tutorial step 2...$(NC)"
	$(ENV_SETUP) gtkwave $<

wave-tutorial-step3: $(BUILD_DIR)/tutorial_step3.vcd
	@echo "$(BLUE)Opening GTKWave for tutorial step 3...$(NC)"
	$(ENV_SETUP) gtkwave $<

wave-tutorial-step4: $(BUILD_DIR)/tutorial_step4.vcd
	@echo "$(BLUE)Opening GTKWave for tutorial step 4...$(NC)"
	$(ENV_SETUP) gtkwave $<

# ==============================================================================
# PROGRAMMING TARGETS
# ==============================================================================

.PHONY: prog-hello_world prog-6502_computer prog-tutorial-step1 prog-tutorial-step2 prog-tutorial-step3 prog-tutorial-step4

prog-hello_world: $(BUILD_DIR)/hello_world.fs
	@echo "$(BLUE)Programming hello_world to Tang Nano...$(NC)"
	$(ENV_SETUP) openFPGALoader -b tangnano $<
	@echo "$(GREEN)[OK] hello_world programmed successfully$(NC)"

prog-6502_computer: $(BUILD_DIR)/6502_computer.fs
	@echo "$(BLUE)Programming 6502_computer to Tang Nano...$(NC)"
	$(ENV_SETUP) openFPGALoader -b tangnano $<
	@echo "$(GREEN)[OK] 6502_computer programmed successfully$(NC)"

prog-tutorial-step%: $(BUILD_DIR)/tutorial_step%.fs
	@echo "$(BLUE)Programming tutorial step$* to Tang Nano...$(NC)"
	$(ENV_SETUP) openFPGALoader -b tangnano $<
	@echo "$(GREEN)[OK] tutorial step$* programmed successfully$(NC)"

# ==============================================================================
# UTILITY TARGETS
# ==============================================================================

clean:
	@echo "$(YELLOW)Cleaning build directory...$(NC)"
	$(ENV_SETUP) $(CLEAN_ALL)
	@echo "$(GREEN)[OK] Build directory cleaned$(NC)"

# Project-specific clean targets
.PHONY: clean-hello_world clean-6502_computer clean-tutorial-step1 clean-tutorial-step2 clean-tutorial-step3 clean-tutorial-step4

clean-hello_world:
	@echo "$(YELLOW)Cleaning Hello World build files...$(NC)"
	$(ENV_SETUP) $(call CLEAN_PROJECT,hello_world)
	@echo "$(GREEN)[OK] Hello World build files cleaned$(NC)"

clean-6502_computer:
	@echo "$(YELLOW)Cleaning 6502 Computer build files...$(NC)"
	$(ENV_SETUP) $(call CLEAN_PROJECT,6502_computer)
	@echo "$(GREEN)[OK] 6502 Computer build files cleaned$(NC)"

clean-tutorial-step1:
	@echo "$(YELLOW)Cleaning Tutorial Step 1 build files...$(NC)"
	$(ENV_SETUP) $(call CLEAN_PROJECT,tutorial_step1)
	@echo "$(GREEN)[OK] Tutorial Step 1 build files cleaned$(NC)"

clean-tutorial-step2:
	@echo "$(YELLOW)Cleaning Tutorial Step 2 build files...$(NC)"
	$(ENV_SETUP) $(call CLEAN_PROJECT,tutorial_step2)
	@echo "$(GREEN)[OK] Tutorial Step 2 build files cleaned$(NC)"

clean-tutorial-step3:
	@echo "$(YELLOW)Cleaning Tutorial Step 3 build files...$(NC)"
	$(ENV_SETUP) $(call CLEAN_PROJECT,tutorial_step3)
	@echo "$(GREEN)[OK] Tutorial Step 3 build files cleaned$(NC)"

clean-tutorial-step4:
	@echo "$(YELLOW)Cleaning Tutorial Step 4 build files...$(NC)"
	$(ENV_SETUP) $(call CLEAN_PROJECT,tutorial_step4)
	@echo "$(GREEN)[OK] Tutorial Step 4 build files cleaned$(NC)"

list-projects:
	@echo "$(BLUE)Available Projects:$(NC)"
	@echo "  hello_world     - Basic LED Hello World"
	@echo "  6502_computer   - 6502 CPU Computer"
	@echo "  tutorial-step1  - Tutorial Step 1: Basic LED Toggle"
	@echo "  tutorial-step2  - Tutorial Step 2: RGB Color Cycling"
	@echo "  tutorial-step3  - Tutorial Step 3: PWM Breathing Effect"
	@echo "  tutorial-step4  - Tutorial Step 4: Button Debouncing"

list-boards:
	@echo "$(BLUE)Supported Boards:$(NC)"
	@echo "  9k  - Tang Nano 9K (GW1NR-LV9QN88PC6/I5) [default]"
	@echo "  20k - Tang Nano 20K (GW2A-LV18PG256C8/I7)"
	@echo ""
	@echo "Usage: make <target> BOARD=9k|20k"

# ==============================================================================
# HELP TARGET
# ==============================================================================

help:
	@echo "$(BLUE)==============================================================================$(NC)"
	@echo "$(BLUE)FPGA Development Makefile for Tang Nano 9K/20K$(NC)"
	@echo "$(BLUE)==============================================================================$(NC)"
	@echo ""
	@echo "$(GREEN)BUILD TARGETS:$(NC)"
	@echo "  hello_world          Build Hello World project"
	@echo "  6502_computer        Build 6502 Computer project"
	@echo "  tutorial-step1       Build Tutorial Step 1"
	@echo "  tutorial-step2       Build Tutorial Step 2"
	@echo "  tutorial-step3       Build Tutorial Step 3"
	@echo "  tutorial-step4       Build Tutorial Step 4"
	@echo ""
	@echo "$(GREEN)SIMULATION TARGETS:$(NC)"
	@echo "  sim-hello_world      Simulate Hello World"
	@echo "  sim-6502_computer    Simulate 6502 Computer"
	@echo "  sim-tutorial-step1   Simulate Tutorial Step 1"
	@echo "  sim-tutorial-step2   Simulate Tutorial Step 2"
	@echo "  sim-tutorial-step3   Simulate Tutorial Step 3"
	@echo "  sim-tutorial-step4   Simulate Tutorial Step 4"
	@echo ""
	@echo "$(GREEN)GTKWAVE TARGETS:$(NC)"
	@echo "  wave-hello_world     View Hello World waveforms"
	@echo "  wave-6502_computer   View 6502 Computer waveforms"
	@echo "  wave-tutorial-step1  View Tutorial Step 1 waveforms"
	@echo "  wave-tutorial-step2  View Tutorial Step 2 waveforms"
	@echo "  wave-tutorial-step3  View Tutorial Step 3 waveforms"
	@echo "  wave-tutorial-step4  View Tutorial Step 4 waveforms"
	@echo ""
	@echo "$(GREEN)PROGRAMMING TARGETS:$(NC)"
	@echo "  prog-hello_world     Program Hello World to Tang Nano"
	@echo "  prog-6502_computer   Program 6502 Computer to Tang Nano"
	@echo "  prog-tutorial-step1  Program Tutorial Step 1 to Tang Nano"
	@echo "  prog-tutorial-step2  Program Tutorial Step 2 to Tang Nano"
	@echo "  prog-tutorial-step3  Program Tutorial Step 3 to Tang Nano"
	@echo "  prog-tutorial-step4  Program Tutorial Step 4 to Tang Nano"
	@echo ""
	@echo "$(GREEN)UTILITY TARGETS:$(NC)"
	@echo "  clean                Clean build directory"
	@echo "  clean-hello_world    Clean Hello World build files"
	@echo "  clean-6502_computer  Clean 6502 Computer build files"
	@echo "  clean-tutorial-step1 Clean Tutorial Step 1 build files"
	@echo "  clean-tutorial-step2 Clean Tutorial Step 2 build files"
	@echo "  clean-tutorial-step3 Clean Tutorial Step 3 build files"
	@echo "  clean-tutorial-step4 Clean Tutorial Step 4 build files"
	@echo "  list-projects        List all available projects"
	@echo "  list-boards          List supported boards"
	@echo "  help                 Show this help"
	@echo ""
	@echo "$(GREEN)BOARD SELECTION:$(NC)"
	@echo "  Default: Tang Nano 9K"
	@echo "  For Tang Nano 20K: make <target> BOARD=20k"
	@echo ""
	@echo "$(GREEN)EXAMPLES:$(NC)"
	@echo "  make hello_world                # Build for Tang Nano 9K"
	@echo "  make hello_world BOARD=20k      # Build for Tang Nano 20K"
	@echo "  make sim-tutorial-step1         # Simulate tutorial step 1"
	@echo "  make wave-tutorial-step1        # View tutorial step 1 waveforms"
	@echo "  make prog-hello_world           # Program hello_world to FPGA"
	@echo ""
	@echo "$(BLUE)==============================================================================$(NC)"
