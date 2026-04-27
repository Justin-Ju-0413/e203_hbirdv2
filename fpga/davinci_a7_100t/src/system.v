`timescale 1ns/1ps

module system
(
  input  wire sys_clk,
  input  wire sys_rst_n,

  input  wire uart_rxd,
  output wire uart_txd,
  output wire led0,

  output wire mcu_TDO,
  input  wire mcu_TCK,
  input  wire mcu_TDI,
  input  wire mcu_TMS
);

  wire mmcm_locked;
  wire reset_periph;
  wire ck_rst;
  wire clk_16M;
  wire lfextclk_fallback;

  wire dut_io_pads_jtag_TCK_i_ival;
  wire dut_io_pads_jtag_TMS_i_ival;
  wire dut_io_pads_jtag_TDI_i_ival;
  wire dut_io_pads_jtag_TDO_o_oval;
  wire dut_io_pads_jtag_TDO_o_oe;

  wire [31:0] dut_io_pads_gpioA_i_ival;
  wire [31:0] dut_io_pads_gpioA_o_oval;
  wire [31:0] dut_io_pads_gpioA_o_oe;
  wire [31:0] dut_io_pads_gpioB_i_ival;
  wire [31:0] dut_io_pads_gpioB_o_oval;
  wire [31:0] dut_io_pads_gpioB_o_oe;

  wire dut_io_pads_qspi0_sck_o_oval;
  wire dut_io_pads_qspi0_cs_0_o_oval;
  wire dut_io_pads_qspi0_dq_0_i_ival;
  wire dut_io_pads_qspi0_dq_0_o_oval;
  wire dut_io_pads_qspi0_dq_0_o_oe;
  wire dut_io_pads_qspi0_dq_1_i_ival;
  wire dut_io_pads_qspi0_dq_1_o_oval;
  wire dut_io_pads_qspi0_dq_1_o_oe;
  wire dut_io_pads_qspi0_dq_2_i_ival;
  wire dut_io_pads_qspi0_dq_2_o_oval;
  wire dut_io_pads_qspi0_dq_2_o_oe;
  wire dut_io_pads_qspi0_dq_3_i_ival;
  wire dut_io_pads_qspi0_dq_3_o_oval;
  wire dut_io_pads_qspi0_dq_3_o_oe;

  wire dut_io_pads_aon_pmu_vddpaden_o_oval;
  wire dut_io_pads_aon_pmu_padrst_o_oval;
  wire [31:0] probe_pc;
  wire probe_mem_cmd_valid;
  wire probe_mem_cmd_ready;
  wire probe_mem_rsp_valid;
  wire probe_mem_rsp_ready;
  wire probe_core_clk;
  wire probe_nice_csr_valid;
  wire probe_nice_csr_ready;
  wire [31:0] probe_nice_csr_addr;
  wire probe_nice_csr_wr;
  wire [31:0] probe_nice_csr_wdata;
  wire probe_nice_req_valid;
  wire probe_nice_req_ready;
  wire probe_nice_rsp_valid;
  wire probe_nice_rsp_ready;
  wire probe_commit_trap;
  wire probe_core_cgstop;
  wire probe_dbg_halt;
  wire [3:0] probe_mem_bus;
  wire [2:0] probe_csr_flags;
  wire [3:0] probe_nice_hs;
  wire [2:0] probe_status;

  // The Davinci Pro board reference material exposes a 50 MHz user clock and a
  // single active-low reset input. For the first bring-up pass we reuse the
  // generated 16 MHz system clock as lfextclk so the shell does not depend on
  // a separate 32.768 kHz source.
  assign ck_rst = sys_rst_n;
  assign lfextclk_fallback = clk_16M;

  mmcm ip_mmcm (
    .resetn(ck_rst),
    .clk_in1(sys_clk),
    .clk_out2(clk_16M),
    .locked(mmcm_locked)
  );

  reset_sys ip_reset_sys (
    .slowest_sync_clk(clk_16M),
    .ext_reset_in(ck_rst),
    .aux_reset_in(1'b1),
    .mb_debug_sys_rst(1'b0),
    .dcm_locked(mmcm_locked),
    .mb_reset(),
    .bus_struct_reset(),
    .peripheral_reset(reset_periph),
    .interconnect_aresetn(),
    .peripheral_aresetn()
  );

  assign dut_io_pads_jtag_TCK_i_ival = mcu_TCK;
  assign dut_io_pads_jtag_TMS_i_ival = mcu_TMS;
  assign dut_io_pads_jtag_TDI_i_ival = mcu_TDI;
  assign mcu_TDO = dut_io_pads_jtag_TDO_o_oe ? dut_io_pads_jtag_TDO_o_oval : 1'b1;

  // gpioA[17] drives the board UART TX pin, gpioA[16] samples UART RX.
  assign dut_io_pads_gpioA_i_ival = {15'b0, uart_rxd, 16'b0};
  assign uart_txd = dut_io_pads_gpioA_o_oe[17] ? dut_io_pads_gpioA_o_oval[17] : 1'b1;
  assign led0 = dut_io_pads_gpioA_o_oe[0] ? dut_io_pads_gpioA_o_oval[0] : 1'b0;

  // Keep the remaining GPIO and QSPI inputs in benign states for ILM download.
  assign dut_io_pads_gpioB_i_ival = 32'b0;
  assign dut_io_pads_qspi0_dq_0_i_ival = 1'b1;
  assign dut_io_pads_qspi0_dq_1_i_ival = 1'b1;
  assign dut_io_pads_qspi0_dq_2_i_ival = 1'b1;
  assign dut_io_pads_qspi0_dq_3_i_ival = 1'b1;
  assign probe_mem_bus = {probe_mem_cmd_valid, probe_mem_cmd_ready, probe_mem_rsp_valid, probe_mem_rsp_ready};
  assign probe_csr_flags = {probe_nice_csr_valid, probe_nice_csr_ready, probe_nice_csr_wr};
  assign probe_nice_hs = {probe_nice_req_valid, probe_nice_req_ready, probe_nice_rsp_valid, probe_nice_rsp_ready};
  assign probe_status = {probe_commit_trap, probe_core_cgstop, probe_dbg_halt};

  e203_soc_top dut (
    .hfextclk(clk_16M),
    .lfextclk(lfextclk_fallback),
    .hfxoscen(),
    .lfxoscen(),
    .io_pads_jtag_TCK_i_ival(dut_io_pads_jtag_TCK_i_ival),
    .io_pads_jtag_TMS_i_ival(dut_io_pads_jtag_TMS_i_ival),
    .io_pads_jtag_TDI_i_ival(dut_io_pads_jtag_TDI_i_ival),
    .io_pads_jtag_TDO_o_oval(dut_io_pads_jtag_TDO_o_oval),
    .io_pads_jtag_TDO_o_oe(dut_io_pads_jtag_TDO_o_oe),
    .io_pads_qspi0_sck_o_oval(dut_io_pads_qspi0_sck_o_oval),
    .io_pads_qspi0_cs_0_o_oval(dut_io_pads_qspi0_cs_0_o_oval),
    .io_pads_qspi0_dq_0_i_ival(dut_io_pads_qspi0_dq_0_i_ival),
    .io_pads_qspi0_dq_0_o_oval(dut_io_pads_qspi0_dq_0_o_oval),
    .io_pads_qspi0_dq_0_o_oe(dut_io_pads_qspi0_dq_0_o_oe),
    .io_pads_qspi0_dq_1_i_ival(dut_io_pads_qspi0_dq_1_i_ival),
    .io_pads_qspi0_dq_1_o_oval(dut_io_pads_qspi0_dq_1_o_oval),
    .io_pads_qspi0_dq_1_o_oe(dut_io_pads_qspi0_dq_1_o_oe),
    .io_pads_qspi0_dq_2_i_ival(dut_io_pads_qspi0_dq_2_i_ival),
    .io_pads_qspi0_dq_2_o_oval(dut_io_pads_qspi0_dq_2_o_oval),
    .io_pads_qspi0_dq_2_o_oe(dut_io_pads_qspi0_dq_2_o_oe),
    .io_pads_qspi0_dq_3_i_ival(dut_io_pads_qspi0_dq_3_i_ival),
    .io_pads_qspi0_dq_3_o_oval(dut_io_pads_qspi0_dq_3_o_oval),
    .io_pads_qspi0_dq_3_o_oe(dut_io_pads_qspi0_dq_3_o_oe),
    .io_pads_gpioA_i_ival(dut_io_pads_gpioA_i_ival),
    .io_pads_gpioA_o_oval(dut_io_pads_gpioA_o_oval),
    .io_pads_gpioA_o_oe(dut_io_pads_gpioA_o_oe),
    .io_pads_gpioB_i_ival(dut_io_pads_gpioB_i_ival),
    .io_pads_gpioB_o_oval(dut_io_pads_gpioB_o_oval),
    .io_pads_gpioB_o_oe(dut_io_pads_gpioB_o_oe),
    .io_pads_aon_erst_n_i_ival(ck_rst),
    .io_pads_aon_pmu_dwakeup_n_i_ival(1'b1),
    .io_pads_aon_pmu_vddpaden_o_oval(dut_io_pads_aon_pmu_vddpaden_o_oval),
    .io_pads_aon_pmu_padrst_o_oval(dut_io_pads_aon_pmu_padrst_o_oval),
    .io_pads_bootrom_n_i_ival(1'b1),
    .io_pads_dbgmode0_n_i_ival(1'b1),
    .io_pads_dbgmode1_n_i_ival(1'b1),
    .io_pads_dbgmode2_n_i_ival(1'b1),
    .probe_pc(probe_pc),
    .probe_mem_cmd_valid(probe_mem_cmd_valid),
    .probe_mem_cmd_ready(probe_mem_cmd_ready),
    .probe_mem_rsp_valid(probe_mem_rsp_valid),
    .probe_mem_rsp_ready(probe_mem_rsp_ready),
    .probe_core_clk(probe_core_clk),
    .probe_nice_csr_valid(probe_nice_csr_valid),
    .probe_nice_csr_ready(probe_nice_csr_ready),
    .probe_nice_csr_addr(probe_nice_csr_addr),
    .probe_nice_csr_wr(probe_nice_csr_wr),
    .probe_nice_csr_wdata(probe_nice_csr_wdata),
    .probe_nice_req_valid(probe_nice_req_valid),
    .probe_nice_req_ready(probe_nice_req_ready),
    .probe_nice_rsp_valid(probe_nice_rsp_valid),
    .probe_nice_rsp_ready(probe_nice_rsp_ready),
    .probe_commit_trap(probe_commit_trap),
    .probe_core_cgstop(probe_core_cgstop),
    .probe_dbg_halt(probe_dbg_halt)
  );

  ila_runtime u_ila_runtime (
    .clk(clk_16M),
    .probe0(probe_pc),
    .probe1(probe_mem_bus),
    .probe2(probe_csr_flags),
    .probe3(probe_nice_csr_addr),
    .probe4(probe_nice_csr_wdata),
    .probe5(probe_nice_hs),
    .probe6(probe_status)
  );

endmodule
