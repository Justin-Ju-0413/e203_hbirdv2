# See LICENSE for license details.

# Required variables:
# - FPGA_DIR
# - INSTALL_RTL

CORE = e203
PATCHVERILOG ?= ""
SDK_APP_VERILOG ?= $(abspath ${base_dir}/../../riscv_cnn_accelerator/third_party/nuclei-sdk/application/baremetal/cnn_accel_demo/cnn_accel_demo.verilog)
SPLIT_SDK_VERILOG ?= $(abspath ${base_dir}/../tb/split_sdk_verilog.sh)
ITCM_VERILOG := $(patsubst %.verilog,%.itcm.verilog,$(SDK_APP_VERILOG))
DTCM_VERILOG := $(patsubst %.verilog,%.dtcm.verilog,$(SDK_APP_VERILOG))
FPGA_MEM_INIT_HEADER := $(INSTALL_RTL)/core/e203_fpga_mem_init.vh



base_dir := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))



# Install RTLs
install: 
	rm -rf ${INSTALL_RTL}
	mkdir -p ${base_dir}/install
	cp ${base_dir}/../rtl/${CORE} ${INSTALL_RTL} -rf
	cp ${FPGA_DIR}/src/system.v ${INSTALL_RTL}/system.v -rf
	sed -i '1i\`define FPGA_SOURCE\'  ${INSTALL_RTL}/core/${CORE}_defines.v
	bash "${SPLIT_SDK_VERILOG}" "${SDK_APP_VERILOG}"
	cp "${ITCM_VERILOG}" "${INSTALL_RTL}/core/cnn_accel_demo.itcm.verilog" -f
	cp "${DTCM_VERILOG}" "${INSTALL_RTL}/core/cnn_accel_demo.dtcm.verilog" -f
	printf '%s\n' '`ifndef E203_FPGA_MEM_INIT_VH' '`define E203_FPGA_MEM_INIT_VH' "\`define E203_ITCM_INIT_FILE \"`wslpath -m "${INSTALL_RTL}/core/cnn_accel_demo.itcm.verilog"`\"" "\`define E203_DTCM_INIT_FILE \"`wslpath -m "${INSTALL_RTL}/core/cnn_accel_demo.dtcm.verilog"`\"" '`endif' > "${FPGA_MEM_INIT_HEADER}"

EXTRA_FPGA_VSRCS := 
verilog := $(wildcard ${INSTALL_RTL}/*/*.v)
verilog += $(wildcard ${INSTALL_RTL}/*/*/*.v)
verilog += $(wildcard ${INSTALL_RTL}/*.v)


# Build .mcs
.PHONY: mcs
mcs : install
	BASEDIR=${base_dir} VSRCS="$(verilog)" EXTRA_VSRCS="$(EXTRA_FPGA_VSRCS)" $(MAKE) -C $(FPGA_DIR) mcs


# Build .bit
.PHONY: bit
bit : install
	BASEDIR=${base_dir} VSRCS="$(verilog)" EXTRA_VSRCS="$(EXTRA_FPGA_VSRCS)" $(MAKE) -C $(FPGA_DIR) bit


.PHONY: setup
setup: 
	BASEDIR=${base_dir} VSRCS="$(verilog)" EXTRA_VSRCS="$(EXTRA_FPGA_VSRCS)" $(MAKE) -C $(FPGA_DIR) setup





# Clean
.PHONY: clean
clean:
	$(MAKE) -C $(FPGA_DIR) clean
	rm -rf fpga_flist
	rm -rf install
	rm -rf vivado.*
	rm -rf novas.*
