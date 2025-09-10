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
#   make sim_hello_world         - Simulate hello_world project
#   make wave_hello_world        - View hello_world waveforms in GTKWave
#   make prog_hello_world        - Program hello_world to Tang Nano
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
$(PROJECTS_DIR)/$(1)/constraints/tangnano_$(2).cst
endef

# Board configuration (default: 9k, can override with BOARD=20k)
BOARD ?= 9k
ifeq ($(BOARD),20k)
    DEVICE := GW2A-LV18QN88C8/I7
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

.PHONY: all help clean clean_hello_world clean_6502_computer clean_hdmi_video clean_composite_video clean_sound clean_input_devices clean_simple_cpu clean_debug_uart
.DEFAULT_GOAL := help

all: hello_world

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
	$(ENV_SETUP) nextpnr-himbaechel --json $< --write $@ --device $(DEVICE) --vopt family=$(FAMILY) --vopt cst=$(call PROJECT_CONSTRAINTS,hello_world,$(BOARD)) --top hello_world

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
	$(ENV_SETUP) nextpnr-himbaechel --json $< --write $@ --device $(DEVICE) --vopt family=$(FAMILY) --vopt cst=$(call PROJECT_CONSTRAINTS,6502_computer,$(BOARD))

$(BUILD_DIR)/6502_computer.fs: $(BUILD_DIR)/6502_computer_pnr.json
	@echo "$(BLUE)Generating bitstream for 6502_computer...$(NC)"
	$(ENV_SETUP) gowin_pack -d $(DEVICE) -o $@ $<

# HDMI Video Project
.PHONY: hdmi_video
hdmi_video: $(BUILD_DIR)/hdmi_video.fs
	@echo "$(GREEN)[OK] HDMI Video project built successfully for Tang Nano $(BOARD)$(NC)"

$(BUILD_DIR)/hdmi_video.json: $(PROJECTS_DIR)/hdmi_video/src/video.v | $(BUILD_DIR)
	@echo "$(BLUE)Synthesizing hdmi_video...$(NC)"
	$(ENV_SETUP) yosys -p "read_verilog $<; synth_gowin -json $@"

$(BUILD_DIR)/hdmi_video_pnr.json: $(BUILD_DIR)/hdmi_video.json
	@echo "$(BLUE)Place & Route for hdmi_video...$(NC)"
	$(ENV_SETUP) nextpnr-himbaechel --json $< --write $@ --device $(DEVICE) --vopt family=$(FAMILY) --vopt cst=$(call PROJECT_CONSTRAINTS,hdmi_video,$(BOARD)) --top hdmi_video

$(BUILD_DIR)/hdmi_video.fs: $(BUILD_DIR)/hdmi_video_pnr.json
	@echo "$(BLUE)Generating bitstream for hdmi_video...$(NC)"
	$(ENV_SETUP) gowin_pack -d $(DEVICE) -o $@ $<

# Composite Video Project
.PHONY: composite_video
composite_video: $(BUILD_DIR)/composite_video.fs
	@echo "$(GREEN)[OK] Composite Video project built successfully for Tang Nano $(BOARD)$(NC)"

$(BUILD_DIR)/composite_video.json: $(PROJECTS_DIR)/composite_video/src/composite_video.v | $(BUILD_DIR)
	@echo "$(BLUE)Synthesizing composite_video...$(NC)"
	$(ENV_SETUP) yosys -p "read_verilog $<; synth_gowin -json $@"

$(BUILD_DIR)/composite_video_pnr.json: $(BUILD_DIR)/composite_video.json
	@echo "$(BLUE)Place & Route for composite_video...$(NC)"
	$(ENV_SETUP) nextpnr-himbaechel --json $< --write $@ --device $(DEVICE) --vopt family=$(FAMILY) --vopt cst=$(call PROJECT_CONSTRAINTS,composite_video,$(BOARD)) --top composite_video

$(BUILD_DIR)/composite_video.fs: $(BUILD_DIR)/composite_video_pnr.json
	@echo "$(BLUE)Generating bitstream for composite_video...$(NC)"
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

# Input Devices Project
.PHONY: input_devices
input_devices: $(BUILD_DIR)/input_devices.fs
	@echo "$(GREEN)[OK] Input Devices project built successfully for Tang Nano $(BOARD)$(NC)"

$(BUILD_DIR)/input_devices.json: $(PROJECTS_DIR)/input_devices/src/keyboard.v | $(BUILD_DIR)
	@echo "$(BLUE)Synthesizing input_devices...$(NC)"
	$(ENV_SETUP) yosys -p "read_verilog $<; synth_gowin -json $@"

$(BUILD_DIR)/input_devices_pnr.json: $(BUILD_DIR)/input_devices.json
	@echo "$(BLUE)Place & Route for input_devices...$(NC)"
	$(ENV_SETUP) nextpnr-himbaechel --json $< --write $@ --device $(DEVICE) --vopt family=$(FAMILY) --vopt cst=$(call PROJECT_CONSTRAINTS,input_devices,$(BOARD))

$(BUILD_DIR)/input_devices.fs: $(BUILD_DIR)/input_devices_pnr.json
	@echo "$(BLUE)Generating bitstream for input_devices...$(NC)"
	$(ENV_SETUP) gowin_pack -d $(DEVICE) -o $@ $<

# Simple CPU Project
.PHONY: simple_cpu
simple_cpu: $(BUILD_DIR)/simple_cpu.fs
	@echo "$(GREEN)[OK] Simple CPU project built successfully for Tang Nano $(BOARD)$(NC)"

$(BUILD_DIR)/simple_cpu.json: $(PROJECTS_DIR)/simple_cpu/src/simple_cpu.v | $(BUILD_DIR)
	@echo "$(BLUE)Synthesizing simple_cpu...$(NC)"
	$(ENV_SETUP) yosys -p "read_verilog $<; synth_gowin -json $@"

$(BUILD_DIR)/simple_cpu_pnr.json: $(BUILD_DIR)/simple_cpu.json
	@echo "$(BLUE)Place & Route for simple_cpu...$(NC)"
	$(ENV_SETUP) nextpnr-himbaechel --json $< --write $@ --device $(DEVICE) --vopt family=$(FAMILY) --vopt cst=$(call PROJECT_CONSTRAINTS,simple_cpu,$(BOARD))

$(BUILD_DIR)/simple_cpu.fs: $(BUILD_DIR)/simple_cpu_pnr.json
	@echo "$(BLUE)Generating bitstream for simple_cpu...$(NC)"
	$(ENV_SETUP) gowin_pack -d $(DEVICE) -o $@ $<

# Debug UART Project
.PHONY: debug_uart
debug_uart: $(BUILD_DIR)/debug_uart.fs
	@echo "$(GREEN)[OK] Debug UART project built successfully for Tang Nano $(BOARD)$(NC)"

$(BUILD_DIR)/debug_uart.json: $(PROJECTS_DIR)/debug_uart/src/debug_uart.v | $(BUILD_DIR)
	@echo "$(BLUE)Synthesizing debug_uart...$(NC)"
	$(ENV_SETUP) yosys -p "read_verilog $<; synth_gowin -json $@"

$(BUILD_DIR)/debug_uart_pnr.json: $(BUILD_DIR)/debug_uart.json
	@echo "$(BLUE)Place & Route for debug_uart...$(NC)"
	$(ENV_SETUP) nextpnr-himbaechel --json $< --write $@ --device $(DEVICE) --vopt family=$(FAMILY) --vopt cst=$(call PROJECT_CONSTRAINTS,debug_uart,$(BOARD)) --top debug_uart

$(BUILD_DIR)/debug_uart.fs: $(BUILD_DIR)/debug_uart_pnr.json
	@echo "$(BLUE)Generating bitstream for debug_uart...$(NC)"
	$(ENV_SETUP) gowin_pack -d $(DEVICE) -o $@ $<

# ==============================================================================
# SIMULATION TARGETS  
# ==============================================================================

.PHONY: sim_hello_world sim_6502_computer sim_hdmi_video sim_composite_video sim_sound sim_input_devices sim_simple_cpu sim_debug_uart

# Standard simulation targets (check if VCD exists)
sim_hello_world: $(BUILD_DIR)/hello_world.vcd
	@echo "$(GREEN)[OK] Hello World simulation completed$(NC)"

sim_6502_computer: $(BUILD_DIR)/6502_computer.vcd
	@echo "$(GREEN)[OK] 6502 Computer simulation completed$(NC)"

sim_hdmi_video: $(BUILD_DIR)/hdmi_video.vcd
	@echo "$(GREEN)[OK] HDMI Video simulation completed$(NC)"

sim_composite_video: $(BUILD_DIR)/composite_video.vcd
	@echo "$(GREEN)[OK] Composite Video simulation completed$(NC)"

sim_sound: $(BUILD_DIR)/sound.vcd
	@echo "$(GREEN)[OK] Sound simulation completed$(NC)"

sim_input_devices: $(BUILD_DIR)/input_devices.vcd
	@echo "$(GREEN)[OK] Input Devices simulation completed$(NC)"

sim_simple_cpu: $(BUILD_DIR)/simple_cpu.vcd
	@echo "$(GREEN)[OK] Simple CPU simulation completed$(NC)"

sim_debug_uart: $(BUILD_DIR)/debug_uart.vcd
	@echo "$(GREEN)[OK] Debug UART simulation completed$(NC)"

# Simulation build rules
$(BUILD_DIR)/hello_world_sim: $(PROJECTS_DIR)/hello_world/testbench/hello_world_tb.v $(PROJECTS_DIR)/hello_world/src/hello_world.v | $(BUILD_DIR)
	@echo "$(BLUE)Compiling hello_world simulation...$(NC)"
	$(ENV_SETUP) iverilog -o $@ $^

$(BUILD_DIR)/6502_computer_sim: $(PROJECTS_DIR)/6502_computer/testbench/cpu_6502_tb.v $(PROJECTS_DIR)/6502_computer/src/cpu.v $(PROJECTS_DIR)/6502_computer/src/ALU.v | $(BUILD_DIR)
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

$(BUILD_DIR)/simple_cpu_sim: $(PROJECTS_DIR)/simple_cpu/testbench/simple_cpu_tb.v $(PROJECTS_DIR)/simple_cpu/src/simple_cpu.v | $(BUILD_DIR)
	@echo "$(BLUE)Compiling simple_cpu simulation...$(NC)"
	$(ENV_SETUP) iverilog -o $@ $^

$(BUILD_DIR)/debug_uart_sim: $(PROJECTS_DIR)/debug_uart/testbench/debug_uart_tb.v $(PROJECTS_DIR)/debug_uart/src/debug_uart.v | $(BUILD_DIR)
	@echo "$(BLUE)Compiling debug_uart simulation...$(NC)"
	$(ENV_SETUP) iverilog -o $@ $^

# VCD generation rules
$(BUILD_DIR)/%.vcd: $(BUILD_DIR)/%_sim
	@echo "$(BLUE)Running simulation for $*...$(NC)"
	$(ENV_SETUP) vvp $< && echo "$(GREEN)Waveform saved to $@$(NC)"

# ==============================================================================
# GTKWAVE TARGETS
# ==============================================================================

.PHONY: wave_hello_world wave_6502_computer wave_video wave_sound wave_keyboard wave_simple_cpu wave_debug_uart

wave_hello_world: $(BUILD_DIR)/hello_world.vcd
	@echo "$(BLUE)Opening GTKWave for hello_world...$(NC)"
	$(ENV_SETUP) gtkwave $<

wave_6502_computer: $(BUILD_DIR)/6502_computer.vcd
	@echo "$(BLUE)Opening GTKWave for 6502_computer...$(NC)"
	$(ENV_SETUP) gtkwave $<

wave_video: $(BUILD_DIR)/video.vcd
	@echo "$(BLUE)Opening GTKWave for video...$(NC)"
	$(ENV_SETUP) gtkwave $<

wave_sound: $(BUILD_DIR)/sound.vcd
	@echo "$(BLUE)Opening GTKWave for sound...$(NC)"
	$(ENV_SETUP) gtkwave $<

wave_keyboard: $(BUILD_DIR)/keyboard.vcd
	@echo "$(BLUE)Opening GTKWave for keyboard...$(NC)"
	$(ENV_SETUP) gtkwave $<

wave_simple_cpu: $(BUILD_DIR)/simple_cpu.vcd
	@echo "$(BLUE)Opening GTKWave for simple_cpu...$(NC)"
	$(ENV_SETUP) gtkwave $<

wave_debug_uart: $(BUILD_DIR)/debug_uart.vcd
	@echo "$(BLUE)Opening GTKWave for debug_uart...$(NC)"
	$(ENV_SETUP) gtkwave $<

# ==============================================================================
# PROGRAMMING TARGETS
# ==============================================================================

.PHONY: prog_hello_world prog_6502_computer prog_video prog_sound prog_keyboard prog_simple_cpu prog_debug_uart

prog_hello_world: $(BUILD_DIR)/hello_world.fs
	@echo "$(BLUE)Programming hello_world to Tang Nano...$(NC)"
	$(ENV_SETUP) openFPGALoader -b tangnano $<
	@echo "$(GREEN)[OK] hello_world programmed successfully$(NC)"

prog_6502_computer: $(BUILD_DIR)/6502_computer.fs
	@echo "$(BLUE)Programming 6502_computer to Tang Nano...$(NC)"
	$(ENV_SETUP) openFPGALoader -b tangnano $<
	@echo "$(GREEN)[OK] 6502_computer programmed successfully$(NC)"

prog_video: $(BUILD_DIR)/video.fs
	@echo "$(BLUE)Programming video to Tang Nano...$(NC)"
	$(ENV_SETUP) openFPGALoader -b tangnano $<
	@echo "$(GREEN)[OK] video programmed successfully$(NC)"

prog_sound: $(BUILD_DIR)/sound.fs
	@echo "$(BLUE)Programming sound to Tang Nano...$(NC)"
	$(ENV_SETUP) openFPGALoader -b tangnano $<
	@echo "$(GREEN)[OK] sound programmed successfully$(NC)"

prog_keyboard: $(BUILD_DIR)/keyboard.fs
	@echo "$(BLUE)Programming keyboard to Tang Nano...$(NC)"
	$(ENV_SETUP) openFPGALoader -b tangnano $<
	@echo "$(GREEN)[OK] keyboard programmed successfully$(NC)"

prog_simple_cpu: $(BUILD_DIR)/simple_cpu.fs
	@echo "$(BLUE)Programming simple_cpu to Tang Nano...$(NC)"
	$(ENV_SETUP) openFPGALoader -b tangnano $<
	@echo "$(GREEN)[OK] simple_cpu programmed successfully$(NC)"

prog_debug_uart: $(BUILD_DIR)/debug_uart.fs
	@echo "$(BLUE)Programming debug_uart to Tang Nano...$(NC)"
	$(ENV_SETUP) openFPGALoader -b tangnano $<
	@echo "$(GREEN)[OK] debug_uart programmed successfully$(NC)"

# ==============================================================================
# UTILITY TARGETS
# ==============================================================================

clean:
	@echo "$(YELLOW)Cleaning build directory...$(NC)"
	$(ENV_SETUP) $(CLEAN_ALL)
	@echo "$(GREEN)[OK] Build directory cleaned$(NC)"

# Project-specific clean targets
.PHONY: clean_hello_world clean_6502_computer clean_video clean_sound clean_keyboard clean_simple_cpu clean_debug_uart

clean_hello_world:
	@echo "$(YELLOW)Cleaning Hello World build files...$(NC)"
	$(ENV_SETUP) $(call CLEAN_PROJECT,hello_world)
	@echo "$(GREEN)[OK] Hello World build files cleaned$(NC)"

clean_6502_computer:
	@echo "$(YELLOW)Cleaning 6502 Computer build files...$(NC)"
	$(ENV_SETUP) $(call CLEAN_PROJECT,6502_computer)
	@echo "$(GREEN)[OK] 6502 Computer build files cleaned$(NC)"

clean_video:
	@echo "$(YELLOW)Cleaning Video build files...$(NC)"
	$(ENV_SETUP) $(call CLEAN_PROJECT,video)
	@echo "$(GREEN)[OK] Video build files cleaned$(NC)"

clean_sound:
	@echo "$(YELLOW)Cleaning Sound build files...$(NC)"
	$(ENV_SETUP) $(call CLEAN_PROJECT,sound)
	@echo "$(GREEN)[OK] Sound build files cleaned$(NC)"

clean_keyboard:
	@echo "$(YELLOW)Cleaning Keyboard build files...$(NC)"
	$(ENV_SETUP) $(call CLEAN_PROJECT,keyboard)
	@echo "$(GREEN)[OK] Keyboard build files cleaned$(NC)"

clean_simple_cpu:
	@echo "$(YELLOW)Cleaning Simple CPU build files...$(NC)"
	$(ENV_SETUP) $(call CLEAN_PROJECT,simple_cpu)
	@echo "$(GREEN)[OK] Simple CPU build files cleaned$(NC)"

clean_debug_uart:
	@echo "$(YELLOW)Cleaning Debug UART build files...$(NC)"
	$(ENV_SETUP) $(call CLEAN_PROJECT,debug_uart)
	@echo "$(GREEN)[OK] Debug UART build files cleaned$(NC)"

list-projects:
	@echo "$(BLUE)Available Projects:$(NC)"
	@echo "  hello_world     - Basic LED Hello World"
	@echo "  debug_uart      - UART Debug Output for Learning"
	@echo "  6502_computer   - 6502 CPU Computer"
	@echo "  video           - Video Generation Module"
	@echo "  sound           - Sound Generation Module"
	@echo "  keyboard        - Keyboard Input Module"
	@echo "  simple_cpu      - Simple CPU Implementation"

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
	@echo "  debug_uart           Build Debug UART project"
	@echo "  6502_computer        Build 6502 Computer project"
	@echo "  video                Build Video project"
	@echo "  sound                Build Sound project"
	@echo "  keyboard             Build Keyboard project"
	@echo "  simple_cpu           Build Simple CPU project"
	@echo ""
	@echo "$(GREEN)SIMULATION TARGETS:$(NC)"
	@echo "  sim_hello_world      Simulate Hello World"
	@echo "  sim_debug_uart       Simulate Debug UART"
	@echo "  sim_6502_computer    Simulate 6502 Computer"
	@echo "  sim_video            Simulate Video"
	@echo "  sim_sound            Simulate Sound"
	@echo "  sim_keyboard         Simulate Keyboard"
	@echo "  sim_simple_cpu       Simulate Simple CPU"
	@echo ""
	@echo "$(GREEN)GTKWAVE TARGETS:$(NC)"
	@echo "  wave_hello_world     View Hello World waveforms"
	@echo "  wave_debug_uart      View Debug UART waveforms"
	@echo "  wave_6502_computer   View 6502 Computer waveforms"
	@echo "  wave_video           View Video waveforms"
	@echo "  wave_sound           View Sound waveforms"
	@echo "  wave_keyboard        View Keyboard waveforms"
	@echo "  wave_simple_cpu      View Simple CPU waveforms"
	@echo ""
	@echo "$(GREEN)PROGRAMMING TARGETS:$(NC)"
	@echo "  prog_hello_world     Program Hello World to Tang Nano"
	@echo "  prog_debug_uart      Program Debug UART to Tang Nano"
	@echo "  prog_6502_computer   Program 6502 Computer to Tang Nano"
	@echo "  prog_video           Program Video to Tang Nano"
	@echo "  prog_sound           Program Sound to Tang Nano"
	@echo "  prog_keyboard        Program Keyboard to Tang Nano"
	@echo "  prog_simple_cpu      Program Simple CPU to Tang Nano"
	@echo ""
	@echo "$(GREEN)UTILITY TARGETS:$(NC)"
	@echo "  clean                Clean build directory"
	@echo "  clean_hello_world    Clean Hello World build files"
	@echo "  clean_debug_uart     Clean Debug UART build files"
	@echo "  clean_6502_computer  Clean 6502 Computer build files"
	@echo "  clean_video          Clean Video build files"
	@echo "  clean_sound          Clean Sound build files"
	@echo "  clean_keyboard       Clean Keyboard build files"
	@echo "  clean_simple_cpu     Clean Simple CPU build files"
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
	@echo "  make sim_6502_computer          # Simulate 6502 computer"
	@echo "  make wave_6502_computer         # View 6502 computer waveforms"
	@echo "  make prog_hello_world           # Program hello_world to FPGA"
	@echo ""
	@echo "$(BLUE)==============================================================================$(NC)"
