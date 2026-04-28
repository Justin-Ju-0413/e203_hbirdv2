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
  wire sys_clk_ibuf;
  wire sys_clk_raw;
  wire clk_16M;
  wire clk_16M_mmcm;
  wire clkfb_mmcm;
  wire clkfb_buf;
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

  reg [31:0] heartbeat_counter;
  reg heartbeat_toggle;

  reg [31:0] sysclk_counter;
  reg heartbeat_toggle_meta;
  reg heartbeat_toggle_sync;
  reg heartbeat_toggle_sync_d;
  reg [31:0] heartbeat_edge_counter;
  reg mmcm_locked_meta;
  reg mmcm_locked_sync;
  reg reset_periph_meta;
  reg reset_periph_sync;
  reg [7:0] heartbeat_high_meta;
  reg [7:0] heartbeat_high_sync;

  wire [31:0] probe0_sysclk_counter;
  wire [3:0] probe1_reset;
  wire [2:0] probe2_inputs;
  wire [31:0] probe3_clk16_edges;
  wire [31:0] probe4_clk16_state;
  wire [3:0] probe5_jtag;
  wire [2:0] probe6_status;

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
    .RST(~sys_rst_n)
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
      heartbeat_toggle <= 1'b0;
    end else begin
      heartbeat_counter <= heartbeat_counter + 32'b1;
      heartbeat_toggle <= heartbeat_counter[7];
    end
  end

  always @(posedge sys_clk_raw or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
      sysclk_counter <= 32'b0;
      heartbeat_toggle_meta <= 1'b0;
      heartbeat_toggle_sync <= 1'b0;
      heartbeat_toggle_sync_d <= 1'b0;
      heartbeat_edge_counter <= 32'b0;
      mmcm_locked_meta <= 1'b0;
      mmcm_locked_sync <= 1'b0;
      reset_periph_meta <= 1'b1;
      reset_periph_sync <= 1'b1;
      heartbeat_high_meta <= 8'b0;
      heartbeat_high_sync <= 8'b0;
    end else begin
      sysclk_counter <= sysclk_counter + 32'b1;

      heartbeat_toggle_meta <= heartbeat_toggle;
      heartbeat_toggle_sync <= heartbeat_toggle_meta;
      heartbeat_toggle_sync_d <= heartbeat_toggle_sync;
      if (heartbeat_toggle_sync ^ heartbeat_toggle_sync_d) begin
        heartbeat_edge_counter <= heartbeat_edge_counter + 32'b1;
      end

      mmcm_locked_meta <= mmcm_locked;
      mmcm_locked_sync <= mmcm_locked_meta;
      reset_periph_meta <= reset_periph;
      reset_periph_sync <= reset_periph_meta;
      heartbeat_high_meta <= heartbeat_counter[15:8];
      heartbeat_high_sync <= heartbeat_high_meta;
    end
  end

  assign led0 = heartbeat_counter[23];
  assign uart_txd = 1'b1;
  assign mcu_TDO = 1'b1;

  assign probe0_sysclk_counter = sysclk_counter;
  assign probe1_reset = {sys_rst_n, mmcm_locked_sync, reset_periph_sync, led0};
  assign probe2_inputs = {uart_rxd, heartbeat_toggle_sync, heartbeat_toggle_sync_d};
  assign probe3_clk16_edges = heartbeat_edge_counter;
  assign probe4_clk16_state = {heartbeat_high_sync, 8'b0, heartbeat_edge_counter[15:0]};
  assign probe5_jtag = {mcu_TCK, mcu_TMS, mcu_TDI, mcu_TDO};
  assign probe6_status = {mmcm_locked_sync, reset_periph_sync, led0};

  ila_runtime u_ila_runtime (
    .clk(sys_clk_raw),
    .probe0(probe0_sysclk_counter),
    .probe1(probe1_reset),
    .probe2(probe2_inputs),
    .probe3(probe3_clk16_edges),
    .probe4(probe4_clk16_state),
    .probe5(probe5_jtag),
    .probe6(probe6_status)
  );

endmodule
