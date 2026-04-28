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
  wire clk_16M;
  reg [31:0] heartbeat_counter;

  wire [31:0] probe0_counter;
  wire [3:0] probe1_reset;
  wire [2:0] probe2_inputs;
  wire [31:0] probe3_zero;
  wire [31:0] probe4_zero;
  wire [3:0] probe5_jtag;
  wire [2:0] probe6_status;

  mmcm ip_mmcm (
    .resetn(sys_rst_n),
    .clk_in1(sys_clk),
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

  assign led0 = heartbeat_counter[23];
  assign uart_txd = 1'b1;
  assign mcu_TDO = 1'b1;

  assign probe0_counter = heartbeat_counter;
  assign probe1_reset = {sys_rst_n, mmcm_locked, reset_periph, led0};
  assign probe2_inputs = {uart_rxd, mcu_TCK, mcu_TMS};
  assign probe3_zero = 32'b0;
  assign probe4_zero = 32'b0;
  assign probe5_jtag = {mcu_TCK, mcu_TMS, mcu_TDI, mcu_TDO};
  assign probe6_status = {mmcm_locked, reset_periph, led0};

  ila_runtime u_ila_runtime (
    .clk(clk_16M),
    .probe0(probe0_counter),
    .probe1(probe1_reset),
    .probe2(probe2_inputs),
    .probe3(probe3_zero),
    .probe4(probe4_zero),
    .probe5(probe5_jtag),
    .probe6(probe6_status)
  );

endmodule
