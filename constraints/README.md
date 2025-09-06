# FPGA Constraint Files for Tang Nano Boards
# ============================================
#
# This directory contains pin constraint files for Tang Nano FPGA boards:
#
# tangnano9k.cst      - Tang Nano 9K (GW1NR-LV9QN88PC6/I5, QN88 package)
# tangnano20k.cst     - Tang Nano 20K (GW2A-LV18PG256C8/I7, PG256 package)
#
# Key Differences:
# - Tang Nano 9K uses numeric pin numbers (e.g., IO_LOC "clk" 52;)
# - Tang Nano 20K uses BGA pin names (e.g., IO_LOC "clk" H11;)
# - Both boards use 27MHz crystals
# - Pin assignments differ between boards
#
# Usage:
# The build script automatically selects the correct constraint file
# based on the -Board parameter (9k or 20k).
