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
#   make hello-world             - Build hello-world project for Tang Nano 9K
#   make hello-world BOARD=20k   - Build hello-world project for Tang Nano 20K
#   make sim-hello-world         - Simulate hello-world project
#   make wave-hello-world        - View hello-world waveforms in GTKWave
#   make prog-hello-world        - Program hello-world to Tang Nano
#   make clean                   - Clean all build files
# ==============================================================================

# ==============================================================================
# CONFIGURATION
# ==============================================================================

# Build directories
BUILD_DIR := build
PROJECTS_DIR := projects

# Function to get project-specific constraint file
define PROJECT_CONSTRAINTS
$(PROJECTS_DIR)/$(1)/constraints/tangnano$(2).cst
endef

# Board configuration (default: 9k, can override with BOARD=20k)
BOARD ?= 9k
ifeq ($(BOARD),20k)
    DEVICE := GW2A-LV18PG256C8/I7
    FAMILY := GW2A-18C
else
    DEVICE := GW1NR-LV9QN88PC6/I5
    FAMILY := GW1N-9C
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

.PHONY: all help clean clean-hello-world clean-6502-computer clean-video clean-sound clean-keyboard clean-simple-cpu
.DEFAULT_GOAL := help

all: hello-world

# Create build directory
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# ==============================================================================
# PROJECT BUILD TARGETS
# ==============================================================================

# Hello World Project
.PHONY: hello-world
hello-world: $(BUILD_DIR)/hello-world.fs
	@echo "$(GREEN)[OK] Hello World built successfully for Tang Nano $(BOARD)$(NC)"

$(BUILD_DIR)/hello-world.json: $(PROJECTS_DIR)/hello-world/src/hello-world.v | $(BUILD_DIR)
	@echo "$(BLUE)Synthesizing hello-world...$(NC)"
	$(ENV_SETUP) yosys -p "read_verilog $<; synth_gowin -json $@"

$(BUILD_DIR)/hello-world_pnr.json: $(BUILD_DIR)/hello-world.json
	@echo "$(BLUE)Place & Route for hello-world...$(NC)"
	$(ENV_SETUP) nextpnr-himbaechel --json $< --write $@ --device $(DEVICE) --vopt family=$(FAMILY) --vopt cst=$(call PROJECT_CONSTRAINTS,hello-world,$(BOARD))

$(BUILD_DIR)/hello-world.fs: $(BUILD_DIR)/hello-world_pnr.json
	@echo "$(BLUE)Generating bitstream for hello-world...$(NC)"
	$(ENV_SETUP) gowin_pack -d $(DEVICE) -o $@ $<

# 6502 Computer Project
.PHONY: 6502-computer
6502-computer: $(BUILD_DIR)/6502-computer.fs
	@echo "$(GREEN)[OK] 6502 Computer built successfully for Tang Nano $(BOARD)$(NC)"

$(BUILD_DIR)/6502-computer.json: $(PROJECTS_DIR)/6502-computer/src/top.v $(PROJECTS_DIR)/6502-computer/src/cpu.v $(PROJECTS_DIR)/6502-computer/src/ALU.v | $(BUILD_DIR)
	@echo "$(BLUE)Synthesizing 6502-computer...$(NC)"
	$(ENV_SETUP) yosys -p "read_verilog -nolatches $^; hierarchy -check -top top; proc; opt; memory; opt; techmap; opt; clean; write_json $@"

$(BUILD_DIR)/6502-computer_pnr.json: $(BUILD_DIR)/6502-computer.json
	@echo "$(BLUE)Place & Route for 6502-computer...$(NC)"
	$(ENV_SETUP) nextpnr-himbaechel --json $< --write $@ --device $(DEVICE) --vopt family=$(FAMILY) --vopt cst=$(call PROJECT_CONSTRAINTS,6502-computer,$(BOARD))

$(BUILD_DIR)/6502-computer.fs: $(BUILD_DIR)/6502-computer_pnr.json
	@echo "$(BLUE)Generating bitstream for 6502-computer...$(NC)"
	$(ENV_SETUP) gowin_pack -d $(DEVICE) -o $@ $<

# Video Project
.PHONY: video
video: $(BUILD_DIR)/video.fs
	@echo "$(GREEN)[OK] Video project built successfully for Tang Nano $(BOARD)$(NC)"

$(BUILD_DIR)/video.json: $(PROJECTS_DIR)/video/src/video.v | $(BUILD_DIR)
	@echo "$(BLUE)Synthesizing video...$(NC)"
	$(ENV_SETUP) yosys -p "read_verilog $<; synth_gowin -json $@"

$(BUILD_DIR)/video_pnr.json: $(BUILD_DIR)/video.json
	@echo "$(BLUE)Place & Route for video...$(NC)"
	$(ENV_SETUP) nextpnr-himbaechel --json $< --write $@ --device $(DEVICE) --vopt family=$(FAMILY) --vopt cst=$(call PROJECT_CONSTRAINTS,video,$(BOARD))

$(BUILD_DIR)/video.fs: $(BUILD_DIR)/video_pnr.json
	@echo "$(BLUE)Generating bitstream for video...$(NC)"
	$(ENV_SETUP) gowin_pack -d $(DEVICE) -o $@ $<

# Sound Project
.PHONY: sound
sound: $(BUILD_DIR)/sound.fs
	@echo "$(GREEN)[OK] Sound project built successfully for Tang Nano $(BOARD)$(NC)"

$(BUILD_DIR)/sound.json: $(PROJECTS_DIR)/sound/src/sound.v | $(BUILD_DIR)
	@echo "$(BLUE)Synthesizing sound...$(NC)"
	$(ENV_SETUP) yosys -p "read_verilog $<; synth_gowin -json $@"

$(BUILD_DIR)/sound_pnr.json: $(BUILD_DIR)/sound.json
	@echo "$(BLUE)Place & Route for sound...$(NC)"
	$(ENV_SETUP) nextpnr-himbaechel --json $< --write $@ --device $(DEVICE) --vopt family=$(FAMILY) --vopt cst=$(call PROJECT_CONSTRAINTS,sound,$(BOARD))

$(BUILD_DIR)/sound.fs: $(BUILD_DIR)/sound_pnr.json
	@echo "$(BLUE)Generating bitstream for sound...$(NC)"
	$(ENV_SETUP) gowin_pack -d $(DEVICE) -o $@ $<

# Keyboard Project
.PHONY: keyboard
keyboard: $(BUILD_DIR)/keyboard.fs
	@echo "$(GREEN)[OK] Keyboard project built successfully for Tang Nano $(BOARD)$(NC)"

$(BUILD_DIR)/keyboard.json: $(PROJECTS_DIR)/keyboard/src/keyboard.v | $(BUILD_DIR)
	@echo "$(BLUE)Synthesizing keyboard...$(NC)"
	$(ENV_SETUP) yosys -p "read_verilog $<; synth_gowin -json $@"

$(BUILD_DIR)/keyboard_pnr.json: $(BUILD_DIR)/keyboard.json
	@echo "$(BLUE)Place & Route for keyboard...$(NC)"
	$(ENV_SETUP) nextpnr-himbaechel --json $< --write $@ --device $(DEVICE) --vopt family=$(FAMILY) --vopt cst=$(call PROJECT_CONSTRAINTS,keyboard,$(BOARD))

$(BUILD_DIR)/keyboard.fs: $(BUILD_DIR)/keyboard_pnr.json
	@echo "$(BLUE)Generating bitstream for keyboard...$(NC)"
	$(ENV_SETUP) gowin_pack -d $(DEVICE) -o $@ $<

# Simple CPU Project
.PHONY: simple-cpu
simple-cpu: $(BUILD_DIR)/simple-cpu.fs
	@echo "$(GREEN)[OK] Simple CPU project built successfully for Tang Nano $(BOARD)$(NC)"

$(BUILD_DIR)/simple-cpu.json: $(PROJECTS_DIR)/simple-cpu/src/simple-cpu.v | $(BUILD_DIR)
	@echo "$(BLUE)Synthesizing simple-cpu...$(NC)"
	$(ENV_SETUP) yosys -p "read_verilog $<; synth_gowin -json $@"

$(BUILD_DIR)/simple-cpu_pnr.json: $(BUILD_DIR)/simple-cpu.json
	@echo "$(BLUE)Place & Route for simple-cpu...$(NC)"
	$(ENV_SETUP) nextpnr-himbaechel --json $< --write $@ --device $(DEVICE) --vopt family=$(FAMILY) --vopt cst=$(call PROJECT_CONSTRAINTS,simple-cpu,$(BOARD))

$(BUILD_DIR)/simple-cpu.fs: $(BUILD_DIR)/simple-cpu_pnr.json
	@echo "$(BLUE)Generating bitstream for simple-cpu...$(NC)"
	$(ENV_SETUP) gowin_pack -d $(DEVICE) -o $@ $<

# ==============================================================================
# SIMULATION TARGETS  
# ==============================================================================

.PHONY: sim-hello-world sim-6502-computer sim-video sim-sound sim-keyboard sim-simple-cpu

# Standard simulation targets (check if VCD exists)
sim-hello-world: $(BUILD_DIR)/hello-world.vcd
	@echo "$(GREEN)[OK] Hello World simulation completed$(NC)"

sim-6502-computer: $(BUILD_DIR)/6502-computer.vcd
	@echo "$(GREEN)[OK] 6502 Computer simulation completed$(NC)"

sim-video: $(BUILD_DIR)/video.vcd
	@echo "$(GREEN)[OK] Video simulation completed$(NC)"

sim-sound: $(BUILD_DIR)/sound.vcd
	@echo "$(GREEN)[OK] Sound simulation completed$(NC)"

sim-keyboard: $(BUILD_DIR)/keyboard.vcd
	@echo "$(GREEN)[OK] Keyboard simulation completed$(NC)"

sim-simple-cpu: $(BUILD_DIR)/simple-cpu.vcd
	@echo "$(GREEN)[OK] Simple CPU simulation completed$(NC)"

# Simulation build rules
$(BUILD_DIR)/hello-world_sim: $(PROJECTS_DIR)/hello-world/testbench/hello-world_tb.v $(PROJECTS_DIR)/hello-world/src/hello-world.v | $(BUILD_DIR)
	@echo "$(BLUE)Compiling hello-world simulation...$(NC)"
	$(ENV_SETUP) iverilog -o $@ $^

$(BUILD_DIR)/6502-computer_sim: $(PROJECTS_DIR)/6502-computer/testbench/cpu_6502_tb.v $(PROJECTS_DIR)/6502-computer/src/cpu.v $(PROJECTS_DIR)/6502-computer/src/ALU.v | $(BUILD_DIR)
	@echo "$(BLUE)Compiling 6502 CPU simulation...$(NC)"
	$(ENV_SETUP) iverilog -o $@ $^

$(BUILD_DIR)/video_sim: $(PROJECTS_DIR)/video/testbench/video_tb.v $(PROJECTS_DIR)/video/src/video.v | $(BUILD_DIR)
	@echo "$(BLUE)Compiling video simulation...$(NC)"
	$(ENV_SETUP) iverilog -o $@ $^

$(BUILD_DIR)/sound_sim: $(PROJECTS_DIR)/sound/testbench/sound_tb.v $(PROJECTS_DIR)/sound/src/sound.v | $(BUILD_DIR)
	@echo "$(BLUE)Compiling sound simulation...$(NC)"
	$(ENV_SETUP) iverilog -o $@ $^

$(BUILD_DIR)/keyboard_sim: $(PROJECTS_DIR)/keyboard/testbench/keyboard_tb.v $(PROJECTS_DIR)/keyboard/src/keyboard.v | $(BUILD_DIR)
	@echo "$(BLUE)Compiling keyboard simulation...$(NC)"
	$(ENV_SETUP) iverilog -o $@ $^

$(BUILD_DIR)/simple-cpu_sim: $(PROJECTS_DIR)/simple-cpu/testbench/simple-cpu_tb.v $(PROJECTS_DIR)/simple-cpu/src/simple-cpu.v | $(BUILD_DIR)
	@echo "$(BLUE)Compiling simple-cpu simulation...$(NC)"
	$(ENV_SETUP) iverilog -o $@ $^

# VCD generation rules
$(BUILD_DIR)/%.vcd: $(BUILD_DIR)/%_sim
	@echo "$(BLUE)Running simulation for $*...$(NC)"
	$(ENV_SETUP) vvp $< && echo "$(GREEN)Waveform saved to $@$(NC)"

# ==============================================================================
# GTKWAVE TARGETS
# ==============================================================================

.PHONY: wave-hello-world wave-6502-computer wave-video wave-sound wave-keyboard wave-simple-cpu

wave-hello-world: $(BUILD_DIR)/hello-world.vcd
	@echo "$(BLUE)Opening GTKWave for hello-world...$(NC)"
	$(ENV_SETUP) gtkwave $<

wave-6502-computer: $(BUILD_DIR)/6502-computer.vcd
	@echo "$(BLUE)Opening GTKWave for 6502-computer...$(NC)"
	$(ENV_SETUP) gtkwave $<

wave-video: $(BUILD_DIR)/video.vcd
	@echo "$(BLUE)Opening GTKWave for video...$(NC)"
	$(ENV_SETUP) gtkwave $<

wave-sound: $(BUILD_DIR)/sound.vcd
	@echo "$(BLUE)Opening GTKWave for sound...$(NC)"
	$(ENV_SETUP) gtkwave $<

wave-keyboard: $(BUILD_DIR)/keyboard.vcd
	@echo "$(BLUE)Opening GTKWave for keyboard...$(NC)"
	$(ENV_SETUP) gtkwave $<

wave-simple-cpu: $(BUILD_DIR)/simple-cpu.vcd
	@echo "$(BLUE)Opening GTKWave for simple-cpu...$(NC)"
	$(ENV_SETUP) gtkwave $<

# ==============================================================================
# PROGRAMMING TARGETS
# ==============================================================================

.PHONY: prog-hello-world prog-6502-computer prog-video prog-sound prog-keyboard prog-simple-cpu

prog-hello-world: $(BUILD_DIR)/hello-world.fs
	@echo "$(BLUE)Programming hello-world to Tang Nano...$(NC)"
	$(ENV_SETUP) openFPGALoader -b tangnano $<
	@echo "$(GREEN)[OK] hello-world programmed successfully$(NC)"

prog-6502-computer: $(BUILD_DIR)/6502-computer.fs
	@echo "$(BLUE)Programming 6502-computer to Tang Nano...$(NC)"
	$(ENV_SETUP) openFPGALoader -b tangnano $<
	@echo "$(GREEN)[OK] 6502-computer programmed successfully$(NC)"

prog-video: $(BUILD_DIR)/video.fs
	@echo "$(BLUE)Programming video to Tang Nano...$(NC)"
	$(ENV_SETUP) openFPGALoader -b tangnano $<
	@echo "$(GREEN)[OK] video programmed successfully$(NC)"

prog-sound: $(BUILD_DIR)/sound.fs
	@echo "$(BLUE)Programming sound to Tang Nano...$(NC)"
	$(ENV_SETUP) openFPGALoader -b tangnano $<
	@echo "$(GREEN)[OK] sound programmed successfully$(NC)"

prog-keyboard: $(BUILD_DIR)/keyboard.fs
	@echo "$(BLUE)Programming keyboard to Tang Nano...$(NC)"
	$(ENV_SETUP) openFPGALoader -b tangnano $<
	@echo "$(GREEN)[OK] keyboard programmed successfully$(NC)"

prog-simple-cpu: $(BUILD_DIR)/simple-cpu.fs
	@echo "$(BLUE)Programming simple-cpu to Tang Nano...$(NC)"
	$(ENV_SETUP) openFPGALoader -b tangnano $<
	@echo "$(GREEN)[OK] simple-cpu programmed successfully$(NC)"

# ==============================================================================
# UTILITY TARGETS
# ==============================================================================

clean:
	@echo "$(YELLOW)Cleaning build directory...$(NC)"
	$(ENV_SETUP) $(CLEAN_ALL)
	@echo "$(GREEN)[OK] Build directory cleaned$(NC)"

# Project-specific clean targets
.PHONY: clean-hello-world clean-6502-computer clean-video clean-sound clean-keyboard clean-simple-cpu

clean-hello-world:
	@echo "$(YELLOW)Cleaning Hello World build files...$(NC)"
	$(ENV_SETUP) $(call CLEAN_PROJECT,hello-world)
	@echo "$(GREEN)[OK] Hello World build files cleaned$(NC)"

clean-6502-computer:
	@echo "$(YELLOW)Cleaning 6502 Computer build files...$(NC)"
	$(ENV_SETUP) $(call CLEAN_PROJECT,6502-computer)
	@echo "$(GREEN)[OK] 6502 Computer build files cleaned$(NC)"

clean-video:
	@echo "$(YELLOW)Cleaning Video build files...$(NC)"
	$(ENV_SETUP) $(call CLEAN_PROJECT,video)
	@echo "$(GREEN)[OK] Video build files cleaned$(NC)"

clean-sound:
	@echo "$(YELLOW)Cleaning Sound build files...$(NC)"
	$(ENV_SETUP) $(call CLEAN_PROJECT,sound)
	@echo "$(GREEN)[OK] Sound build files cleaned$(NC)"

clean-keyboard:
	@echo "$(YELLOW)Cleaning Keyboard build files...$(NC)"
	$(ENV_SETUP) $(call CLEAN_PROJECT,keyboard)
	@echo "$(GREEN)[OK] Keyboard build files cleaned$(NC)"

clean-simple-cpu:
	@echo "$(YELLOW)Cleaning Simple CPU build files...$(NC)"
	$(ENV_SETUP) $(call CLEAN_PROJECT,simple-cpu)
	@echo "$(GREEN)[OK] Simple CPU build files cleaned$(NC)"

list-projects:
	@echo "$(BLUE)Available Projects:$(NC)"
	@echo "  hello-world     - Basic LED Hello World"
	@echo "  6502-computer   - 6502 CPU Computer"
	@echo "  video           - Video Generation Module"
	@echo "  sound           - Sound Generation Module"
	@echo "  keyboard        - Keyboard Input Module"
	@echo "  simple-cpu      - Simple CPU Implementation"

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
	@echo "  hello-world          Build Hello World project"
	@echo "  6502-computer        Build 6502 Computer project"
	@echo "  video                Build Video project"
	@echo "  sound                Build Sound project"
	@echo "  keyboard             Build Keyboard project"
	@echo "  simple-cpu           Build Simple CPU project"
	@echo ""
	@echo "$(GREEN)SIMULATION TARGETS:$(NC)"
	@echo "  sim-hello-world      Simulate Hello World"
	@echo "  sim-6502-computer    Simulate 6502 Computer"
	@echo "  sim-video            Simulate Video"
	@echo "  sim-sound            Simulate Sound"
	@echo "  sim-keyboard         Simulate Keyboard"
	@echo "  sim-simple-cpu       Simulate Simple CPU"
	@echo ""
	@echo "$(GREEN)GTKWAVE TARGETS:$(NC)"
	@echo "  wave-hello-world     View Hello World waveforms"
	@echo "  wave-6502-computer   View 6502 Computer waveforms"
	@echo "  wave-video           View Video waveforms"
	@echo "  wave-sound           View Sound waveforms"
	@echo "  wave-keyboard        View Keyboard waveforms"
	@echo "  wave-simple-cpu      View Simple CPU waveforms"
	@echo ""
	@echo "$(GREEN)PROGRAMMING TARGETS:$(NC)"
	@echo "  prog-hello-world     Program Hello World to Tang Nano"
	@echo "  prog-6502-computer   Program 6502 Computer to Tang Nano"
	@echo "  prog-video           Program Video to Tang Nano"
	@echo "  prog-sound           Program Sound to Tang Nano"
	@echo "  prog-keyboard        Program Keyboard to Tang Nano"
	@echo "  prog-simple-cpu      Program Simple CPU to Tang Nano"
	@echo ""
	@echo "$(GREEN)UTILITY TARGETS:$(NC)"
	@echo "  clean                Clean build directory"
	@echo "  clean-hello-world    Clean Hello World build files"
	@echo "  clean-6502-computer  Clean 6502 Computer build files"
	@echo "  clean-video          Clean Video build files"
	@echo "  clean-sound          Clean Sound build files"
	@echo "  clean-keyboard       Clean Keyboard build files"
	@echo "  clean-simple-cpu     Clean Simple CPU build files"
	@echo "  list-projects        List all available projects"
	@echo "  list-boards          List supported boards"
	@echo "  help                 Show this help"
	@echo ""
	@echo "$(GREEN)BOARD SELECTION:$(NC)"
	@echo "  Default: Tang Nano 9K"
	@echo "  For Tang Nano 20K: make <target> BOARD=20k"
	@echo ""
	@echo "$(GREEN)EXAMPLES:$(NC)"
	@echo "  make hello-world                # Build for Tang Nano 9K"
	@echo "  make hello-world BOARD=20k      # Build for Tang Nano 20K"
	@echo "  make sim-6502-computer          # Simulate 6502 computer"
	@echo "  make wave-6502-computer         # View 6502 computer waveforms"
	@echo "  make prog-hello-world           # Program hello-world to FPGA"
	@echo ""
	@echo "$(BLUE)==============================================================================$(NC)"
