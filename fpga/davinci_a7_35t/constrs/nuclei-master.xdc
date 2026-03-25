set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

##
## Davinci Artix-7 XC7A35T board constraints
##
## This file is intentionally conservative:
## - clock names and functional ports are fixed
## - actual PACKAGE_PIN values must be checked against the board schematic/manual
## - UART and soft-JTAG pins should be wired to board-accessible headers / USB-UART
##

## Clock definitions
## TODO: replace PACKAGE_PIN for the real 50 MHz oscillator input.
# set_property -dict { PACKAGE_PIN <CLK50_PIN> IOSTANDARD LVCMOS33 } [get_ports {CLK50MHZ}]
create_clock -add -name sys_clk_pin -period 20.00 -waveform {0 10} [get_ports {CLK50MHZ}]

## TODO: replace PACKAGE_PIN for the real 32.768 kHz RTC clock if present.
# set_property -dict { PACKAGE_PIN <CLK32768_PIN> IOSTANDARD LVCMOS33 } [get_ports {CLK32768KHZ}]
create_clock -add -name rtc_clk_pin -period 30517.58 -waveform {0 15258.79} [get_ports {CLK32768KHZ}]

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets dut_io_pads_jtag_TCK_i_ival]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets IOBUF_jtag_TCK/O]

## Reset inputs
## TODO: map to board reset key / button inputs.
# set_property PACKAGE_PIN <FPGA_RST_PIN> [get_ports fpga_rst]
# set_property PACKAGE_PIN <MCU_RST_PIN>  [get_ports mcu_rst]
set_property IOSTANDARD LVCMOS33 [get_ports fpga_rst]
set_property IOSTANDARD LVCMOS33 [get_ports mcu_rst]

## Soft-core JTAG exported to external FTDI/JTAG header
## TODO: assign four board header pins for TDO/TCK/TDI/TMS.
# set_property PACKAGE_PIN <SOFT_TDO_PIN> [get_ports mcu_TDO]
# set_property PACKAGE_PIN <SOFT_TCK_PIN> [get_ports mcu_TCK]
# set_property PACKAGE_PIN <SOFT_TDI_PIN> [get_ports mcu_TDI]
# set_property PACKAGE_PIN <SOFT_TMS_PIN> [get_ports mcu_TMS]
set_property IOSTANDARD LVCMOS33 [get_ports mcu_TDO]
set_property IOSTANDARD LVCMOS33 [get_ports mcu_TCK]
set_property IOSTANDARD LVCMOS33 [get_ports mcu_TDI]
set_property IOSTANDARD LVCMOS33 [get_ports mcu_TMS]

## PMU and wakeup
set_property IOSTANDARD LVCMOS33 [get_ports pmu_paden]
set_property IOSTANDARD LVCMOS33 [get_ports pmu_padrst]
set_property IOSTANDARD LVCMOS33 [get_ports mcu_wakeup]

## QSPI
set_property IOSTANDARD LVCMOS33 [get_ports qspi0_cs]
set_property IOSTANDARD LVCMOS33 [get_ports qspi0_sck]
set_property IOSTANDARD LVCMOS33 [get_ports {qspi0_dq[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {qspi0_dq[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {qspi0_dq[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {qspi0_dq[3]}]

## GPIO banks kept for compatibility with the existing shell.
## Recommended first use on Davinci:
## - gpioA[17] -> UART TX
## - gpioA[16] -> UART RX
## - gpioA[25:20] / gpioA[1:0] -> LEDs if available
## - a small subset of gpioB for future expansion
set_property IOSTANDARD LVCMOS33 [get_ports {gpioA[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {gpioB[*]}]
