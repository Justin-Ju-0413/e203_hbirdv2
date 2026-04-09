set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

##
## Davinci Pro A7-100T first-pass bring-up constraints
##
## Sources:
## - DaVinci_Pro_PIN.xdc from the vendor board package
## - Project choice: first pass only needs clock, reset, UART and soft JTAG
##

## 50 MHz system clock from vendor pin map: sys_clk -> R4
set_property -dict { PACKAGE_PIN R4 IOSTANDARD LVCMOS15 } [get_ports {sys_clk}]
create_clock -add -name sys_clk_pin -period 20.00 -waveform {0 10} [get_ports {sys_clk}]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets sys_clk]

## Active-low system reset from vendor pin map: sys_rst_n -> U7
set_property -dict { PACKAGE_PIN U7 IOSTANDARD LVCMOS15 } [get_ports {sys_rst_n}]

## Board USB-UART pins from vendor pin map.
## uart_rxd is sampled through gpioA[16], uart_txd is driven from gpioA[17].
set_property -dict { PACKAGE_PIN E14 IOSTANDARD LVCMOS33 } [get_ports {uart_rxd}]
set_property -dict { PACKAGE_PIN D17 IOSTANDARD LVCMOS33 } [get_ports {uart_txd}]

## Simple phase LED for first-pass runtime visibility.
set_property -dict { PACKAGE_PIN V9 IOSTANDARD LVCMOS15 } [get_ports {led0}]

## Soft-core JTAG routed to the board ATK module header pins so an external
## debugger can be wired in for the first bring-up pass.
set_property -dict { PACKAGE_PIN D16 IOSTANDARD LVCMOS33 } [get_ports {mcu_TCK}]
set_property -dict { PACKAGE_PIN E13 IOSTANDARD LVCMOS33 } [get_ports {mcu_TMS}]
set_property -dict { PACKAGE_PIN E16 IOSTANDARD LVCMOS33 } [get_ports {mcu_TDI}]
set_property -dict { PACKAGE_PIN F14 IOSTANDARD LVCMOS33 } [get_ports {mcu_TDO}]
set_property PULLUP true [get_ports {mcu_TCK}]
set_property PULLUP true [get_ports {mcu_TMS}]
set_property PULLUP true [get_ports {mcu_TDI}]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets {mcu_TCK_IBUF}]
