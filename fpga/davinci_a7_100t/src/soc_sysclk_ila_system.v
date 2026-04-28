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
  wire sys_clk_ibuf;
  wire sys_clk_raw;
  wire clk_16M;
  wire clk_16M_mmcm;
  wire clkfb_mmcm;
  wire clkfb_buf;
  wire lfextclk_fallback;
  wire clkout0_unused;
  wire clkout0b_unused;
  wire clkout1b_unused;
  wire clkout2_unused;
  wire clkout2b_unused;
  wire clkout3_unused;
  wire clkout3b_unused;
  wire clkout4_unused;
  wire clkout5_unused;
  wire clkout6_unused;
  wire clkfboutb_unused;
  wire [15:0] do_unused;
  wire drdy_unused;
  wire psdone_unused;
  wire clkinstopped_unused;
  wire clkfbstopped_unused;

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

  reg [31:0] pc_cpu;
  reg [31:0] pc_last_cpu;
  reg [31:0] pc_change_count_cpu;
  reg pc_change_toggle_cpu;
  reg [31:0] nice_csr_addr_cpu;
  reg [31:0] nice_csr_wdata_cpu;
  reg [15:0] nice_event_count_cpu;
  reg [15:0] mem_event_count_cpu;

  reg [31:0] pc_meta;
  reg [31:0] pc_sync;
  reg [31:0] pc_change_count_meta;
  reg [31:0] pc_change_count_sync;
  reg pc_change_toggle_meta;
  reg pc_change_toggle_sync;
  reg pc_change_toggle_sync_d;
  reg mmcm_locked_meta;
  reg mmcm_locked_sync;
  reg reset_periph_meta;
  reg reset_periph_sync;
  reg uart_txd_meta;
  reg uart_txd_sync;
  reg trap_meta;
  reg trap_sync;
  reg cgstop_meta;
  reg cgstop_sync;
  reg halt_meta;
  reg halt_sync;
  reg [3:0] mem_bus_meta;
  reg [3:0] mem_bus_sync;
  reg [2:0] csr_flags_meta;
  reg [2:0] csr_flags_sync;
  reg [3:0] nice_hs_meta;
  reg [3:0] nice_hs_sync;
  reg [31:0] nice_csr_addr_meta;
  reg [31:0] nice_csr_addr_sync;
  reg [31:0] nice_csr_wdata_meta;
  reg [31:0] nice_csr_wdata_sync;
  reg [15:0] nice_event_count_meta;
  reg [15:0] nice_event_count_sync;
  reg [15:0] mem_event_count_meta;
  reg [15:0] mem_event_count_sync;

  wire [31:0] probe0_pc;
  wire [3:0] probe1_reset_uart;
  wire [2:0] probe2_liveness;
  wire [31:0] probe3_pc_activity;
  wire [31:0] probe4_nice_csr;
  wire [3:0] probe5_nice_hs;
  wire [2:0] probe6_mem_status;

  assign ck_rst = sys_rst_n;
  assign lfextclk_fallback = clk_16M;

  IBUF u_sys_clk_ibuf (
    .I(sys_clk),
    .O(sys_clk_ibuf)
  );

  BUFG u_sys_clk_bufg (
    .I(sys_clk_ibuf),
    .O(sys_clk_raw)
  );

  MMCME2_ADV #(
    .BANDWIDTH("OPTIMIZED"),
    .CLKOUT4_CASCADE("FALSE"),
    .COMPENSATION("ZHOLD"),
    .STARTUP_WAIT("FALSE"),
    .DIVCLK_DIVIDE(1),
    .CLKFBOUT_MULT_F(16.000),
    .CLKFBOUT_PHASE(0.000),
    .CLKFBOUT_USE_FINE_PS("FALSE"),
    .CLKOUT0_DIVIDE_F(95.375),
    .CLKOUT0_PHASE(0.000),
    .CLKOUT0_DUTY_CYCLE(0.500),
    .CLKOUT0_USE_FINE_PS("FALSE"),
    .CLKOUT1_DIVIDE(50),
    .CLKOUT1_PHASE(0.000),
    .CLKOUT1_DUTY_CYCLE(0.500),
    .CLKOUT1_USE_FINE_PS("FALSE"),
    .CLKIN1_PERIOD(20.000)
  ) u_mmcm (
    .CLKFBOUT(clkfb_mmcm),
    .CLKFBOUTB(clkfboutb_unused),
    .CLKOUT0(clkout0_unused),
    .CLKOUT0B(clkout0b_unused),
    .CLKOUT1(clk_16M_mmcm),
    .CLKOUT1B(clkout1b_unused),
    .CLKOUT2(clkout2_unused),
    .CLKOUT2B(clkout2b_unused),
    .CLKOUT3(clkout3_unused),
    .CLKOUT3B(clkout3b_unused),
    .CLKOUT4(clkout4_unused),
    .CLKOUT5(clkout5_unused),
    .CLKOUT6(clkout6_unused),
    .CLKFBIN(clkfb_buf),
    .CLKIN1(sys_clk_ibuf),
    .CLKIN2(1'b0),
    .CLKINSEL(1'b1),
    .DADDR(7'h0),
    .DCLK(1'b0),
    .DEN(1'b0),
    .DI(16'h0),
    .DO(do_unused),
    .DRDY(drdy_unused),
    .DWE(1'b0),
    .PSCLK(1'b0),
    .PSEN(1'b0),
    .PSINCDEC(1'b0),
    .PSDONE(psdone_unused),
    .LOCKED(mmcm_locked),
    .CLKINSTOPPED(clkinstopped_unused),
    .CLKFBSTOPPED(clkfbstopped_unused),
    .PWRDWN(1'b0),
    .RST(~ck_rst)
  );

  BUFG u_mmcm_feedback_bufg (
    .I(clkfb_mmcm),
    .O(clkfb_buf)
  );

  BUFG u_clk16_bufg (
    .I(clk_16M_mmcm),
    .O(clk_16M)
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

  assign dut_io_pads_gpioA_i_ival = {15'b0, uart_rxd, 16'b0};
  assign uart_txd = dut_io_pads_gpioA_o_oe[17] ? dut_io_pads_gpioA_o_oval[17] : 1'b1;
  assign led0 = dut_io_pads_gpioA_o_oe[0] ? dut_io_pads_gpioA_o_oval[0] : 1'b0;

  assign dut_io_pads_gpioB_i_ival = 32'b0;
  assign dut_io_pads_qspi0_dq_0_i_ival = 1'b1;
  assign dut_io_pads_qspi0_dq_1_i_ival = 1'b1;
  assign dut_io_pads_qspi0_dq_2_i_ival = 1'b1;
  assign dut_io_pads_qspi0_dq_3_i_ival = 1'b1;
  assign probe_mem_bus = {probe_mem_cmd_valid, probe_mem_cmd_ready, probe_mem_rsp_valid, probe_mem_rsp_ready};
  assign probe_csr_flags = {probe_nice_csr_valid, probe_nice_csr_ready, probe_nice_csr_wr};
  assign probe_nice_hs = {probe_nice_req_valid, probe_nice_req_ready, probe_nice_rsp_valid, probe_nice_rsp_ready};
  assign probe_status = {probe_commit_trap, probe_core_cgstop, probe_dbg_halt};

  always @(posedge clk_16M) begin
    if (reset_periph) begin
      pc_cpu <= 32'b0;
      pc_last_cpu <= 32'b0;
      pc_change_count_cpu <= 32'b0;
      pc_change_toggle_cpu <= 1'b0;
      nice_csr_addr_cpu <= 32'b0;
      nice_csr_wdata_cpu <= 32'b0;
      nice_event_count_cpu <= 16'b0;
      mem_event_count_cpu <= 16'b0;
    end else begin
      pc_cpu <= probe_pc;
      pc_last_cpu <= probe_pc;
      nice_csr_addr_cpu <= probe_nice_csr_addr;
      nice_csr_wdata_cpu <= probe_nice_csr_wdata;
      if (probe_pc != pc_last_cpu) begin
        pc_change_count_cpu <= pc_change_count_cpu + 32'b1;
        pc_change_toggle_cpu <= ~pc_change_toggle_cpu;
      end
      if (|probe_nice_hs || |probe_csr_flags) begin
        nice_event_count_cpu <= nice_event_count_cpu + 16'b1;
      end
      if (|probe_mem_bus) begin
        mem_event_count_cpu <= mem_event_count_cpu + 16'b1;
      end
    end
  end

  always @(posedge sys_clk_raw or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
      pc_meta <= 32'b0;
      pc_sync <= 32'b0;
      pc_change_count_meta <= 32'b0;
      pc_change_count_sync <= 32'b0;
      pc_change_toggle_meta <= 1'b0;
      pc_change_toggle_sync <= 1'b0;
      pc_change_toggle_sync_d <= 1'b0;
      mmcm_locked_meta <= 1'b0;
      mmcm_locked_sync <= 1'b0;
      reset_periph_meta <= 1'b1;
      reset_periph_sync <= 1'b1;
      uart_txd_meta <= 1'b1;
      uart_txd_sync <= 1'b1;
      trap_meta <= 1'b0;
      trap_sync <= 1'b0;
      cgstop_meta <= 1'b0;
      cgstop_sync <= 1'b0;
      halt_meta <= 1'b0;
      halt_sync <= 1'b0;
      mem_bus_meta <= 4'b0;
      mem_bus_sync <= 4'b0;
      csr_flags_meta <= 3'b0;
      csr_flags_sync <= 3'b0;
      nice_hs_meta <= 4'b0;
      nice_hs_sync <= 4'b0;
      nice_csr_addr_meta <= 32'b0;
      nice_csr_addr_sync <= 32'b0;
      nice_csr_wdata_meta <= 32'b0;
      nice_csr_wdata_sync <= 32'b0;
      nice_event_count_meta <= 16'b0;
      nice_event_count_sync <= 16'b0;
      mem_event_count_meta <= 16'b0;
      mem_event_count_sync <= 16'b0;
    end else begin
      pc_meta <= pc_cpu;
      pc_sync <= pc_meta;
      pc_change_count_meta <= pc_change_count_cpu;
      pc_change_count_sync <= pc_change_count_meta;
      pc_change_toggle_meta <= pc_change_toggle_cpu;
      pc_change_toggle_sync <= pc_change_toggle_meta;
      pc_change_toggle_sync_d <= pc_change_toggle_sync;
      mmcm_locked_meta <= mmcm_locked;
      mmcm_locked_sync <= mmcm_locked_meta;
      reset_periph_meta <= reset_periph;
      reset_periph_sync <= reset_periph_meta;
      uart_txd_meta <= uart_txd;
      uart_txd_sync <= uart_txd_meta;
      trap_meta <= probe_commit_trap;
      trap_sync <= trap_meta;
      cgstop_meta <= probe_core_cgstop;
      cgstop_sync <= cgstop_meta;
      halt_meta <= probe_dbg_halt;
      halt_sync <= halt_meta;
      mem_bus_meta <= probe_mem_bus;
      mem_bus_sync <= mem_bus_meta;
      csr_flags_meta <= probe_csr_flags;
      csr_flags_sync <= csr_flags_meta;
      nice_hs_meta <= probe_nice_hs;
      nice_hs_sync <= nice_hs_meta;
      nice_csr_addr_meta <= nice_csr_addr_cpu;
      nice_csr_addr_sync <= nice_csr_addr_meta;
      nice_csr_wdata_meta <= nice_csr_wdata_cpu;
      nice_csr_wdata_sync <= nice_csr_wdata_meta;
      nice_event_count_meta <= nice_event_count_cpu;
      nice_event_count_sync <= nice_event_count_meta;
      mem_event_count_meta <= mem_event_count_cpu;
      mem_event_count_sync <= mem_event_count_meta;
    end
  end

  assign probe0_pc = pc_sync;
  assign probe1_reset_uart = {sys_rst_n, mmcm_locked_sync, reset_periph_sync, uart_txd_sync};
  assign probe2_liveness = {pc_change_toggle_sync ^ pc_change_toggle_sync_d, trap_sync, cgstop_sync | halt_sync};
  assign probe3_pc_activity = pc_change_count_sync;
  assign probe4_nice_csr = (|csr_flags_sync) ? nice_csr_addr_sync : nice_csr_wdata_sync;
  assign probe5_nice_hs = nice_hs_sync;
  assign probe6_mem_status = {mem_bus_sync[3], mem_bus_sync[1], |mem_event_count_sync};

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
    .clk(sys_clk_raw),
    .probe0(probe0_pc),
    .probe1(probe1_reset_uart),
    .probe2(probe2_liveness),
    .probe3(probe3_pc_activity),
    .probe4(probe4_nice_csr),
    .probe5(probe5_nice_hs),
    .probe6(probe6_mem_status)
  );

endmodule
