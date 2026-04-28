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

  reg [31:0] sysclk_counter;

  wire [31:0] probe0_counter;
  wire [3:0] probe1_reset;
  wire [2:0] probe2_inputs;
  wire [31:0] probe3_zero;
  wire [31:0] probe4_zero;
  wire [3:0] probe5_jtag;
  wire [2:0] probe6_status;

  always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
      sysclk_counter <= 32'b0;
    end else begin
      sysclk_counter <= sysclk_counter + 32'b1;
    end
  end

  assign led0 = sysclk_counter[25];
  assign uart_txd = 1'b1;
  assign mcu_TDO = 1'b1;

  assign probe0_counter = sysclk_counter;
  assign probe1_reset = {sys_rst_n, 1'b1, 1'b0, led0};
  assign probe2_inputs = {uart_rxd, mcu_TCK, mcu_TMS};
  assign probe3_zero = 32'b0;
  assign probe4_zero = 32'b0;
  assign probe5_jtag = {mcu_TCK, mcu_TMS, mcu_TDI, mcu_TDO};
  assign probe6_status = {sys_rst_n, 1'b0, led0};

  ila_runtime u_ila_runtime (
    .clk(sys_clk),
    .probe0(probe0_counter),
    .probe1(probe1_reset),
    .probe2(probe2_inputs),
    .probe3(probe3_zero),
    .probe4(probe4_zero),
    .probe5(probe5_jtag),
    .probe6(probe6_status)
  );

endmodule
