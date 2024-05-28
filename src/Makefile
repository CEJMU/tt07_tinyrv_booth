GHDL_OPTS = --workdir=build --std=93c --ieee=standard
TARGET ?= synth_ice40
TOP ?= toplevel
CPU_PROGRAM ?= 1
.PHONY: visualize validation synthesis pnr_ice40 pack_bin prog_up all deploy_ice40 flash_upduino

simulation: design/$(TOP).vhd testbenches/$(TOP)tb.vhd
	if [ ! -d "build" ]; then mkdir build; fi
# HACK VHDL-93 can't process environment variables, but it can read files
	echo $(CPU_PROGRAM) > testbenches/cpu_env.txt

	ghdl -i $(GHDL_OPTS) design/*.vhd*
	ghdl -m $(GHDL_OPTS) $(TOP)

	ghdl -i $(GHDL_OPTS) testbenches/commons.vhd
	ghdl -i $(GHDL_OPTS) testbenches/$(TOP)tb.vhd
	ghdl -m $(GHDL_OPTS) -fsynopsys $(TOP)tb
	ghdl -r $(GHDL_OPTS) $(TOP)tb --wave=build/$(TOP).ghw

# Moving build files to build/ that can't be generated there in the first place
	@mv $(TOP) $(TOP)tb *.o build/
# cpu_env.txt is only used to select the loaded program
	@rm testbenches/cpu_env.txt

verify: design/$(TOP).vhd formal/$(TOP).psl
	sby --yosys "yosys -m ghdl" -f formal/$(TOP).sby

synthesis: design/$(TOP).vhd
	ghdl -i $(GHDL_OPTS) design/*.vhd*
	ghdl -m $(GHDL_OPTS) $(TOP)
	yosys '-mghdl' -p 'ghdl $(GHDL_OPTS) $(TOP); $(TARGET) -dsp -spram -top $(TOP); write_json build/$(TOP).json'

convert: design/$(TOP).vhd
	ghdl -i $(GHDL_OPTS) design/*.vhd*
	ghdl -m $(GHDL_OPTS) $(TOP)
	yosys '-mghdl' -p 'ghdl $(GHDL_OPTS) $(TOP); write_verilog build/$(TOP).v'

visualize:
	sed -i -e 's/inout/output/g' build/$(TOP).json
	netlistsvg build/$(TOP).json -o build/$(TOP).svg
	svgo build/$(TOP).svg
	rsvg-convert -f pdf -o build/$(TOP).pdf build/$(TOP).svg

pnr_ice40:
	nextpnr-ice40 --up5k --package sg48 --asc build/$(TOP).asc --json build/$(TOP).json

pack_bin:
	icepack build/$(TOP).asc build/$(TOP).bin

prog_up:
	iceprog build/$(TOP).bin

all: simulation synthesis visualize
deploy_ice40: simulation synthesis pnr_ice40
flash_upduino: deploy_ice40 pack_bin prog_up

# clean:
# 	rm -r build/* formal/*_bmc formal/*_cover

help:
	@echo "Available targets:"
	@echo "\tsimulation: \tsimulate TOP"
	@echo "\tverify: \tformal verification for TOP"
	@echo "\tsynthesis: \tsynthesize TOP for TARGET"
	@echo "\tconvert: \tconvert TOP to Verilog"
	@echo "\tvisualize: \tvisualize TOP as pdf"
	@echo "\tpnr_ice40: \tplace & route TOP for ice_40"
	@echo "\tdeploy_ice40: \tsimulate, synthesize and pnr for ice_40"
	@echo "\tpack_bin: \tcompile pnr result to binary"
	@echo "\tprog_up: \tprogram Upduino with binary"
	@echo "\tclean: \t\tclean all build files"
	@echo "\thelp: \t\tshow this help"
	@echo "Available variables:"
	@echo "\tTOP: \t\tName of the top level design"
	@echo "\tTARGET: \tTarget for yosys (optional)"
	@echo "\tCPU_PROGRAM: \tCPU program used for testing (1-1)"


# defaults
SIM ?= ghdl
TOPLEVEL_LANG ?= vhdl
SIM_ARGS+=--wave=build/tt_um_cejmu_riscv.ghw

VHDL_SOURCES += $(PWD)/design/*.vhd
# use VHDL_SOURCES for VHDL files

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = tt_um_cejmu_riscv

# MODULE is the basename of the Python test file
MODULE = test_toplevel

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
