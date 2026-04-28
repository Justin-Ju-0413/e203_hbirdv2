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
  wire clk_dbg;
  wire clk_16M;

  reg [31:0] heartbeat_counter;
  reg [31:0] dbg_counter;
  reg [31:0] clk16_edge_counter;
  reg clk16_activity_meta;
  reg clk16_activity_sync;
  reg clk16_activity_sync_d;
  reg mmcm_locked_meta;
  reg mmcm_locked_sync;
  reg reset_periph_meta;
  reg reset_periph_sync;

  wire clk16_activity = heartbeat_counter[20];

  wire [31:0] probe0_dbg_counter;
  wire [3:0] probe1_reset;
  wire [2:0] probe2_inputs;
  wire [31:0] probe3_clk16_edges;
  wire [31:0] probe4_zero;
  wire [3:0] probe5_jtag;
  wire [2:0] probe6_status;

  mmcm ip_mmcm (
    .resetn(sys_rst_n),
    .clk_in1(sys_clk),
    .clk_out1(clk_dbg),
    .clk_out2(clk_16M),
    .locked(mmcm_locked)
  );

  reset_sys ip_reset_sys (
    .slowest_sync_clk(clk_16M),
    .ext_reset_in(sys_rst_n),
    .aux_reset_in(1'b1),
    .mb_debug_sys_rst(1'b0),
    .dcm_locked(mmcm_locked),
    .mb_reset(),
    .bus_struct_reset(),
    .peripheral_reset(reset_periph),
    .interconnect_aresetn(),
    .peripheral_aresetn()
  );

  always @(posedge clk_16M) begin
    if (reset_periph) begin
      heartbeat_counter <= 32'b0;
    end else begin
      heartbeat_counter <= heartbeat_counter + 32'b1;
    end
  end

  always @(posedge clk_dbg or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
      dbg_counter <= 32'b0;
      clk16_edge_counter <= 32'b0;
      clk16_activity_meta <= 1'b0;
      clk16_activity_sync <= 1'b0;
      clk16_activity_sync_d <= 1'b0;
      mmcm_locked_meta <= 1'b0;
      mmcm_locked_sync <= 1'b0;
      reset_periph_meta <= 1'b1;
      reset_periph_sync <= 1'b1;
    end else begin
      dbg_counter <= dbg_counter + 32'b1;
      clk16_activity_meta <= clk16_activity;
      clk16_activity_sync <= clk16_activity_meta;
      clk16_activity_sync_d <= clk16_activity_sync;
      mmcm_locked_meta <= mmcm_locked;
      mmcm_locked_sync <= mmcm_locked_meta;
      reset_periph_meta <= reset_periph;
      reset_periph_sync <= reset_periph_meta;
      if (clk16_activity_sync ^ clk16_activity_sync_d) begin
        clk16_edge_counter <= clk16_edge_counter + 32'b1;
      end
    end
  end

  assign led0 = heartbeat_counter[23];
  assign uart_txd = 1'b1;
  assign mcu_TDO = 1'b1;

  assign probe0_dbg_counter = dbg_counter;
  assign probe1_reset = {sys_rst_n, mmcm_locked_sync, reset_periph_sync, led0};
  assign probe2_inputs = {uart_rxd, clk16_activity_sync, clk16_activity_sync_d};
  assign probe3_clk16_edges = clk16_edge_counter;
  assign probe4_zero = 32'b0;
  assign probe5_jtag = {mcu_TCK, mcu_TMS, mcu_TDI, mcu_TDO};
  assign probe6_status = {mmcm_locked_sync, reset_periph_sync, led0};

  ila_runtime u_ila_runtime (
    .clk(clk_dbg),
    .probe0(probe0_dbg_counter),
    .probe1(probe1_reset),
    .probe2(probe2_inputs),
    .probe3(probe3_clk16_edges),
    .probe4(probe4_zero),
    .probe5(probe5_jtag),
    .probe6(probe6_status)
  );

endmodule
