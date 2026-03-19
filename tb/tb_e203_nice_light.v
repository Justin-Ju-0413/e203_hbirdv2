`include "e203_defines.v"

module tb_e203_nice_light;

  reg clk;
  reg rst_n;

  reg nice_i_xs_off;
  reg nice_i_valid;
  reg [`E203_XLEN-1:0] nice_i_instr;
  reg [`E203_XLEN-1:0] nice_i_rs1;
  reg [`E203_XLEN-1:0] nice_i_rs2;
  reg [`E203_ITAG_WIDTH-1:0] nice_i_itag;

  wire nice_i_ready;
  wire nice_o_longpipe;
  wire nice_o_valid;
  reg  nice_o_ready;
  wire nice_o_itag_valid;
  reg  nice_o_itag_ready;
  wire [`E203_ITAG_WIDTH-1:0] nice_o_itag;

  wire nice_req_valid;
  wire nice_req_ready;
  wire [`E203_XLEN-1:0] nice_req_instr;
  wire [`E203_XLEN-1:0] nice_req_rs1;
  wire [`E203_XLEN-1:0] nice_req_rs2;

  wire nice_rsp_multicyc_valid;
  wire nice_rsp_multicyc_ready;
  wire [`E203_XLEN-1:0] nice_rsp_multicyc_rdat;
  wire nice_rsp_multicyc_err;

  wire nice_active;
  wire nice_mem_holdup;
  wire nice_icb_cmd_valid;
  wire [`E203_ADDR_SIZE-1:0] nice_icb_cmd_addr;
  wire nice_icb_cmd_read;
  wire [`E203_XLEN-1:0] nice_icb_cmd_wdata;
  wire [1:0] nice_icb_cmd_size;
  wire nice_icb_rsp_ready;

  integer cycle_count;
  reg seen_req;
  reg seen_ready_low;
  reg seen_rsp_320;

  localparam [6:0] NICE_OPCODE = 7'h0b;
  localparam [2:0] F3_WLOAD = 3'b000;
  localparam [2:0] F3_DLOAD = 3'b001;
  localparam [2:0] F3_COMP  = 3'b010;
  localparam [2:0] F3_RSTAT = 3'b011;
  localparam [2:0] F3_CLEAR = 3'b100;

  function [31:0] make_nice_instr;
    input [2:0] funct3;
    begin
      make_nice_instr = {17'b0, funct3, 5'b0, NICE_OPCODE};
    end
  endfunction

  task automatic issue_req;
    input [31:0] instr;
    input [31:0] rs1_val;
    input [31:0] rs2_val;
    input [`E203_ITAG_WIDTH-1:0] itag_val;
    begin
      @(negedge clk);
      nice_i_instr <= instr;
      nice_i_rs1   <= rs1_val;
      nice_i_rs2   <= rs2_val;
      nice_i_itag  <= itag_val;
      nice_i_valid <= 1'b1;
      while (!(nice_i_valid && nice_i_ready)) begin
        @(posedge clk);
      end
      @(negedge clk);
      nice_i_valid <= 1'b0;
    end
  endtask

  e203_exu_nice u_e203_exu_nice (
    .nice_i_xs_off(nice_i_xs_off),
    .nice_i_valid(nice_i_valid),
    .nice_i_ready(nice_i_ready),
    .nice_i_instr(nice_i_instr),
    .nice_i_rs1(nice_i_rs1),
    .nice_i_rs2(nice_i_rs2),
    .nice_i_itag(nice_i_itag),
    .nice_o_longpipe(nice_o_longpipe),
    .nice_o_valid(nice_o_valid),
    .nice_o_ready(nice_o_ready),
    .nice_o_itag_valid(nice_o_itag_valid),
    .nice_o_itag_ready(nice_o_itag_ready),
    .nice_o_itag(nice_o_itag),
    .nice_rsp_multicyc_valid(nice_rsp_multicyc_valid),
    .nice_rsp_multicyc_ready(nice_rsp_multicyc_ready),
    .nice_req_valid(nice_req_valid),
    .nice_req_ready(nice_req_ready),
    .nice_req_instr(nice_req_instr),
    .nice_req_rs1(nice_req_rs1),
    .nice_req_rs2(nice_req_rs2),
    .clk(clk),
    .rst_n(rst_n)
  );

  e203_subsys_nice_core u_e203_subsys_nice_core (
    .nice_clk(clk),
    .nice_rst_n(rst_n),
    .nice_active(nice_active),
    .nice_mem_holdup(nice_mem_holdup),
    .nice_req_valid(nice_req_valid),
    .nice_req_ready(nice_req_ready),
    .nice_req_inst(nice_req_instr),
    .nice_req_rs1(nice_req_rs1),
    .nice_req_rs2(nice_req_rs2),
    .nice_rsp_valid(nice_rsp_multicyc_valid),
    .nice_rsp_ready(nice_rsp_multicyc_ready),
    .nice_rsp_rdat(nice_rsp_multicyc_rdat),
    .nice_rsp_err(nice_rsp_multicyc_err),
    .nice_icb_cmd_valid(nice_icb_cmd_valid),
    .nice_icb_cmd_ready(1'b0),
    .nice_icb_cmd_addr(nice_icb_cmd_addr),
    .nice_icb_cmd_read(nice_icb_cmd_read),
    .nice_icb_cmd_wdata(nice_icb_cmd_wdata),
    .nice_icb_cmd_size(nice_icb_cmd_size),
    .nice_icb_rsp_valid(1'b0),
    .nice_icb_rsp_ready(nice_icb_rsp_ready),
    .nice_icb_rsp_rdata(32'b0),
    .nice_icb_rsp_err(1'b0)
  );

  always #5 clk = ~clk;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      cycle_count <= 0;
      seen_req <= 1'b0;
      seen_ready_low <= 1'b0;
      seen_rsp_320 <= 1'b0;
    end else begin
      cycle_count <= cycle_count + 1;
      if (nice_req_valid && nice_req_ready) begin
        seen_req <= 1'b1;
        $display("[LIGHT_REQ] cycle=%0d instr=%h rs1=%h rs2=%h",
                 cycle_count, nice_req_instr, nice_req_rs1, nice_req_rs2);
      end
      if (seen_req && !nice_req_ready) begin
        seen_ready_low <= 1'b1;
      end
      if (nice_rsp_multicyc_valid && nice_rsp_multicyc_ready) begin
        $display("[LIGHT_RSP] cycle=%0d rdat=%0d err=%0d itag=%0d",
                 cycle_count, nice_rsp_multicyc_rdat, nice_rsp_multicyc_err, nice_o_itag);
        if (!nice_rsp_multicyc_err && (nice_rsp_multicyc_rdat == 32'd320)) begin
          seen_rsp_320 <= 1'b1;
        end
      end
    end
  end

  initial begin
    clk = 1'b0;
    rst_n = 1'b0;
    nice_i_xs_off = 1'b0;
    nice_i_valid = 1'b0;
    nice_i_instr = 32'b0;
    nice_i_rs1 = 32'b0;
    nice_i_rs2 = 32'b0;
    nice_i_itag = {`E203_ITAG_WIDTH{1'b0}};
    nice_o_ready = 1'b1;
    nice_o_itag_ready = 1'b1;

    repeat (4) @(posedge clk);
    rst_n = 1'b1;
    $display("[LIGHT] reset released");

    issue_req(make_nice_instr(F3_CLEAR), 32'b0, 32'd0, 0);

    issue_req(make_nice_instr(F3_WLOAD), 32'h0a0a0a0a, 32'd0, 1);
    issue_req(make_nice_instr(F3_WLOAD), 32'h0a0a0a0a, 32'd1, 2);
    issue_req(make_nice_instr(F3_WLOAD), 32'h0a0a0a0a, 32'd2, 3);
    issue_req(make_nice_instr(F3_WLOAD), 32'h0a0a0a0a, 32'd3, 4);

    issue_req(make_nice_instr(F3_DLOAD), 32'h02020202, 32'd0, 5);
    issue_req(make_nice_instr(F3_DLOAD), 32'h02020202, 32'd1, 6);
    issue_req(make_nice_instr(F3_DLOAD), 32'h02020202, 32'd2, 7);
    issue_req(make_nice_instr(F3_DLOAD), 32'h02020202, 32'd3, 8);

    issue_req(make_nice_instr(F3_COMP), 32'b0, 32'd0, 9);
    while (nice_req_ready) @(posedge clk);
    while (!nice_req_ready) @(posedge clk);
    repeat (2) @(posedge clk);
    issue_req(make_nice_instr(F3_RSTAT), 32'b0, 32'd0, 10);

    repeat (20) @(posedge clk);

    $display("[LIGHT_SUMMARY] req=%0d ready_low=%0d rsp320=%0d active=%0d",
             seen_req, seen_ready_low, seen_rsp_320, nice_active);

    if (seen_req && seen_ready_low && seen_rsp_320) begin
      $display("[LIGHT_PASS]");
    end else begin
      $display("[LIGHT_FAIL]");
    end
    $finish;
  end

  initial begin
    #5000;
    $display("[LIGHT_TIMEOUT]");
    $finish;
  end

endmodule
