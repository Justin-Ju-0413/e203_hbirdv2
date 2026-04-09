# Davinci A7-100T Bring-Up Status V2.0

> Version: `V2.0`  
> Updated: `2026-04-10`

## Goal

Record the current board-shell and Route A implementation state for the
Davinci Pro A7-100T target in `e203_hbirdv2`.

## Current Hardware Baseline

- Board target: `fpga/davinci_a7_100t`
- FPGA part: `xc7a100tfgg484-2`
- Top module: `system`
- Board clock strategy:
  - board `50 MHz` input on `sys_clk`
  - MMCM derives `16 MHz` for the SoC
- Reset strategy:
  - board active-low `sys_rst_n`
  - board shell adapts reset into the SoC-facing reset tree

## Verified Pin Map In Use

- `sys_clk -> R4` (`LVCMOS15`)
- `sys_rst_n -> U7` (`LVCMOS15`)
- `uart_rxd -> E14` (`LVCMOS33`)
- `uart_txd -> D17` (`LVCMOS33`)
- `led0 -> V9` (`LVCMOS15`)
- `mcu_TCK -> D16` (`LVCMOS33`)
- `mcu_TMS -> E13` (`LVCMOS33`)
- `mcu_TDI -> E16` (`LVCMOS33`)
- `mcu_TDO -> F14` (`LVCMOS33`)

Important note:

- `led0` originally failed place/route when constrained as `LVCMOS33`
- official vendor constraints confirm `V9` must stay in the `LVCMOS15` bank

## Route A Implementation Present

### Program Image Pre-Initialization

The FPGA install/build flow now:

1. regenerates a clean `fpga/install/rtl`
2. splits `cnn_accel_demo.verilog` into:
   - `cnn_accel_demo.itcm.verilog`
   - `cnn_accel_demo.dtcm.verilog`
3. emits `e203_fpga_mem_init.vh`
4. feeds those paths into ITCM/DTCM RAM wrappers

Relevant files:

- `fpga/common.mk`
- `rtl/e203/general/sirv_gnrl_ram.v`
- `rtl/e203/general/sirv_sim_ram.v`
- `rtl/e203/core/e203_itcm_ram.v`
- `rtl/e203/core/e203_dtcm_ram.v`

### Runtime Observability

The board shell currently provides:

- UART exposure through `gpioA[16]` / `gpioA[17]`
- LED0 stage output through `gpioA[0]`
- runtime ILA `ila_runtime`

Current ILA probes include:

- program counter
- memory command/response activity
- NICE CSR write flags and payload
- NICE request/response handshake
- core status summary bits

Relevant files:

- `fpga/davinci_a7_100t/src/system.v`
- `fpga/davinci_a7_100t/script/ip.tcl`
- `rtl/e203/core/e203_cpu.v`
- `rtl/e203/core/e203_cpu_top.v`
- `rtl/e203/soc/e203_soc_top.v`
- `rtl/e203/subsys/e203_subsys_main.v`
- `rtl/e203/subsys/e203_subsys_top.v`

## Build Status

The latest Route A bitstream build succeeds.

Current outputs:

- `fpga/davinci_a7_100t/obj/davinci_a7_100t.runs/impl_1/system.bit`
- `fpga/davinci_a7_100t/obj/system.bit`

The latest successful build already includes:

- memory pre-initialization
- LED0 output
- runtime ILA

## Known Warnings

The current build still emits warnings, but not fatal errors:

- debug-hub / ILA related warnings
- BRAM async-control timing warnings from inferred RAM structure

These do not currently block `write_bitstream`.

## Route B Status

No `BSCANE2` bridge has been implemented yet.

Current debug state:

- `PTD04` is confirmed for FPGA native JTAG download
- CPU software debug through the same JTAG chain is still a follow-up research task

## Next Board Steps

1. Reprogram the board with the latest `obj/system.bit`
2. Capture UART milestones from the rebuilt demo
3. Use Vivado Hardware Manager to arm `ila_runtime`
4. Confirm:
   - PC activity
   - NICE CSR write phase
   - NICE start handshake
   - NICE completion handshake
