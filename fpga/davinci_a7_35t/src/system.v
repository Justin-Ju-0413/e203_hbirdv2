`timescale 1ns/1ps

module system
(
  input wire CLK50MHZ,
  input wire CLK32768KHZ,

  input wire fpga_rst,
  input wire mcu_rst,

  output wire qspi0_cs,
  output wire qspi0_sck,
  inout wire [3:0] qspi0_dq,

  inout wire [31:0] gpioA,
  inout wire [31:0] gpioB,

  inout wire mcu_TDO,
  inout wire mcu_TCK,
  inout wire mcu_TDI,
  inout wire mcu_TMS,

  inout wire pmu_paden,
  inout wire pmu_padrst,
  inout wire mcu_wakeup
);

  wire mmcm_locked;
  wire reset_periph;
  wire ck_rst;
  wire clk_16M;

  wire dut_io_pads_jtag_TCK_i_ival;
  wire dut_io_pads_jtag_TMS_i_ival;
  wire dut_io_pads_jtag_TMS_o_oval;
  wire dut_io_pads_jtag_TMS_o_oe;
  wire dut_io_pads_jtag_TMS_o_ie;
  wire dut_io_pads_jtag_TMS_o_pue;
  wire dut_io_pads_jtag_TMS_o_ds;
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

  mmcm ip_mmcm (
    .resetn(ck_rst),
    .clk_in1(CLK50MHZ),
    .clk_out2(clk_16M),
    .locked(mmcm_locked)
  );

  assign ck_rst = fpga_rst & mcu_rst;

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

  PULLUP qspi0_pullup[3:0] (.O(qspi0_dq));

  IOBUF qspi0_iobuf[3:0] (
    .IO(qspi0_dq),
    .O({dut_io_pads_qspi0_dq_3_i_ival, dut_io_pads_qspi0_dq_2_i_ival, dut_io_pads_qspi0_dq_1_i_ival, dut_io_pads_qspi0_dq_0_i_ival}),
    .I({dut_io_pads_qspi0_dq_3_o_oval, dut_io_pads_qspi0_dq_2_o_oval, dut_io_pads_qspi0_dq_1_o_oval, dut_io_pads_qspi0_dq_0_o_oval}),
    .T(~{dut_io_pads_qspi0_dq_3_o_oe, dut_io_pads_qspi0_dq_2_o_oe, dut_io_pads_qspi0_dq_1_o_oe, dut_io_pads_qspi0_dq_0_o_oe})
  );

  IOBUF #(
    .DRIVE(12), .IBUF_LOW_PWR("TRUE"), .IOSTANDARD("LVCMOS33"), .SLEW("SLOW")
  ) gpioA_iobuf[31:0] (
    .O(dut_io_pads_gpioA_i_ival),
    .IO(gpioA),
    .I(dut_io_pads_gpioA_o_oval),
    .T(~dut_io_pads_gpioA_o_oe)
  );

  IOBUF #(
    .DRIVE(12), .IBUF_LOW_PWR("TRUE"), .IOSTANDARD("LVCMOS33"), .SLEW("SLOW")
  ) gpioB_iobuf[31:0] (
    .O(dut_io_pads_gpioB_i_ival),
    .IO(gpioB),
    .I(dut_io_pads_gpioB_o_oval),
    .T(~dut_io_pads_gpioB_o_oe)
  );

  wire iobuf_jtag_TCK_o;
  IOBUF #(
    .DRIVE(12), .IBUF_LOW_PWR("TRUE"), .IOSTANDARD("LVCMOS33"), .SLEW("SLOW")
  ) IOBUF_jtag_TCK (
    .O(iobuf_jtag_TCK_o), .IO(mcu_TCK), .I(1'b0), .T(1'b1)
  );
  assign dut_io_pads_jtag_TCK_i_ival = iobuf_jtag_TCK_o;
  PULLUP pullup_TCK (.O(mcu_TCK));

  wire iobuf_jtag_TMS_o;
  IOBUF #(
    .DRIVE(12), .IBUF_LOW_PWR("TRUE"), .IOSTANDARD("LVCMOS33"), .SLEW("SLOW")
  ) IOBUF_jtag_TMS (
    .O(iobuf_jtag_TMS_o), .IO(mcu_TMS), .I(1'b0), .T(1'b1)
  );
  assign dut_io_pads_jtag_TMS_i_ival = iobuf_jtag_TMS_o;
  PULLUP pullup_TMS (.O(mcu_TMS));

  wire iobuf_jtag_TDI_o;
  IOBUF #(
    .DRIVE(12), .IBUF_LOW_PWR("TRUE"), .IOSTANDARD("LVCMOS33"), .SLEW("SLOW")
  ) IOBUF_jtag_TDI (
    .O(iobuf_jtag_TDI_o), .IO(mcu_TDI), .I(1'b0), .T(1'b1)
  );
  assign dut_io_pads_jtag_TDI_i_ival = iobuf_jtag_TDI_o;
  PULLUP pullup_TDI (.O(mcu_TDI));

  IOBUF #(
    .DRIVE(12), .IBUF_LOW_PWR("TRUE"), .IOSTANDARD("LVCMOS33"), .SLEW("SLOW")
  ) IOBUF_jtag_TDO (
    .O(), .IO(mcu_TDO), .I(dut_io_pads_jtag_TDO_o_oval), .T(~dut_io_pads_jtag_TDO_o_oe)
  );

  assign qspi0_cs = dut_io_pads_qspi0_cs_0_o_oval;
  assign qspi0_sck = dut_io_pads_qspi0_sck_o_oval;
  assign pmu_paden = dut_io_pads_aon_pmu_vddpaden_o_oval;
  assign pmu_padrst = dut_io_pads_aon_pmu_padrst_o_oval;

  e203_soc_top dut (
    .hfextclk(clk_16M),
    .lfextclk(CLK32768KHZ),
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
    .io_pads_aon_pmu_dwakeup_n_i_ival(mcu_wakeup),
    .io_pads_aon_pmu_vddpaden_o_oval(dut_io_pads_aon_pmu_vddpaden_o_oval),
    .io_pads_aon_pmu_padrst_o_oval(dut_io_pads_aon_pmu_padrst_o_oval),
    .io_pads_bootrom_n_i_ival(1'b1),
    .io_pads_dbgmode0_n_i_ival(1'b1),
    .io_pads_dbgmode1_n_i_ival(1'b1),
    .io_pads_dbgmode2_n_i_ival(1'b1)
  );

endmodule
