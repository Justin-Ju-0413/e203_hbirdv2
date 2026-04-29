`timescale 1ns/1ps

module tb_bootvec;

  reg clk_16M;
  reg rst_n;
  reg uart_rxd;

  wire uart_txd;
  wire led0;
  wire [31:0] probe_pc;
  wire [31:0] probe_mem_cmd_addr;
  wire probe_mem_cmd_valid;
  wire probe_mem_cmd_ready;
  wire probe_mem_rsp_valid;
  wire probe_mem_rsp_ready;
  wire probe_core_clk;
  wire probe_ifu_cmd_valid;
  wire probe_ifu_cmd_ready;
  wire probe_ifu_rsp_valid;
  wire probe_ifu_rsp_ready;
  wire probe_commit_trap;
  wire probe_core_cgstop;
  wire probe_dbg_halt;

  // Generate 16 MHz clock
  initial clk_16M = 0;
  always #31.25 clk_16M = ~clk_16M;

  // Reset sequence: assert for 500 ns, then release
  initial begin
    rst_n = 0;
    uart_rxd = 1;
    #500;
    rst_n = 1;
  end

  // Monitor key signals
  initial begin
    $display("Time(us) | PC        | mem_cmd_addr | mem_cmd_vld/rdy | mem_rsp_vld/rdy | ifu_vld/rdy | trap cgstop halt");
    $monitor("%7.1f | %h | %h   | %b %b  | %b %b  | %b %b  | %b %b %b",
      $realtime/1000.0,
      probe_pc,
      probe_mem_cmd_addr,
      probe_mem_cmd_valid, probe_mem_cmd_ready,
      probe_mem_rsp_valid, probe_mem_rsp_ready,
      probe_ifu_cmd_valid, probe_ifu_cmd_ready,
      probe_commit_trap, probe_core_cgstop, probe_dbg_halt
    );
  end

  // Stop after 200 us
  initial begin
    #200000;
    $display("\n=== Final State ===");
    $display("PC = %h", probe_pc);
    $display("mem_cmd_addr = %h", probe_mem_cmd_addr);
    $display("core_clk = %b", probe_core_clk);
    $display("commit_trap = %b, cgstop = %b, halt = %b", probe_commit_trap, probe_core_cgstop, probe_dbg_halt);
    $display("=== Simulation Complete ===");
    $finish;
  end

  // Dump VCD
  initial begin
    $dumpfile("tb_bootvec.vcd");
    $dumpvars(0, tb_bootvec);
  end

  // Instantiate e203_soc_top directly (bypassing MMCM/ILA wrappers)
  // This tests pure RTL boot behavior
  // Tie bootrom_n = 0 (force mask-ROM boot)
  e203_soc_top dut (
    .hfextclk(clk_16M),
    .lfextclk(clk_16M),
    .hfxoscen(),
    .lfxoscen(),
    .io_pads_jtag_TCK_i_ival(1'b1),
    .io_pads_jtag_TMS_i_ival(1'b1),
    .io_pads_jtag_TDI_i_ival(1'b1),
    .io_pads_jtag_TDO_o_oval(),
    .io_pads_jtag_TDO_o_oe(),
    .io_pads_qspi0_sck_o_oval(),
    .io_pads_qspi0_cs_0_o_oval(),
    .io_pads_qspi0_dq_0_i_ival(1'b1),
    .io_pads_qspi0_dq_0_o_oval(),
    .io_pads_qspi0_dq_0_o_oe(),
    .io_pads_qspi0_dq_1_i_ival(1'b1),
    .io_pads_qspi0_dq_1_o_oval(),
    .io_pads_qspi0_dq_1_o_oe(),
    .io_pads_qspi0_dq_2_i_ival(1'b1),
    .io_pads_qspi0_dq_2_o_oval(),
    .io_pads_qspi0_dq_2_o_oe(),
    .io_pads_qspi0_dq_3_i_ival(1'b1),
    .io_pads_qspi0_dq_3_o_oval(),
    .io_pads_qspi0_dq_3_o_oe(),
    .io_pads_gpioA_i_ival({15'b0, uart_rxd, 16'b0}),
    .io_pads_gpioA_o_oval(),
    .io_pads_gpioA_o_oe(),
    .io_pads_gpioB_i_ival(32'b0),
    .io_pads_gpioB_o_oval(),
    .io_pads_gpioB_o_oe(),
    .io_pads_aon_erst_n_i_ival(rst_n),
    .io_pads_aon_pmu_dwakeup_n_i_ival(1'b1),
    .io_pads_aon_pmu_vddpaden_o_oval(),
    .io_pads_aon_pmu_padrst_o_oval(),
    .io_pads_bootrom_n_i_ival(1'b0),
    .io_pads_dbgmode0_n_i_ival(1'b1),
    .io_pads_dbgmode1_n_i_ival(1'b1),
    .io_pads_dbgmode2_n_i_ival(1'b1),
    .probe_pc(probe_pc),
    .probe_mem_cmd_addr(probe_mem_cmd_addr),
    .probe_mem_cmd_valid(probe_mem_cmd_valid),
    .probe_mem_cmd_ready(probe_mem_cmd_ready),
    .probe_mem_rsp_valid(probe_mem_rsp_valid),
    .probe_mem_rsp_ready(probe_mem_rsp_ready),
    .probe_core_clk(probe_core_clk),
    .probe_nice_csr_valid(),
    .probe_nice_csr_ready(),
    .probe_nice_csr_addr(),
    .probe_nice_csr_wr(),
    .probe_nice_csr_wdata(),
    .probe_nice_req_valid(),
    .probe_nice_req_ready(),
    .probe_nice_rsp_valid(),
    .probe_nice_rsp_ready(),
    .probe_commit_trap(probe_commit_trap),
    .probe_core_cgstop(probe_core_cgstop),
    .probe_dbg_halt(probe_dbg_halt),
    .probe_ifu_cmd_valid(probe_ifu_cmd_valid),
    .probe_ifu_cmd_ready(probe_ifu_cmd_ready),
    .probe_ifu_rsp_valid(probe_ifu_rsp_valid),
    .probe_ifu_rsp_ready(probe_ifu_rsp_ready)
  );

endmodule
