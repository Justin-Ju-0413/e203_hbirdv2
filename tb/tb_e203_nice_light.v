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
  integer pass_count;
  reg seen_req;
  reg seen_ready_low;
  reg seen_rsp_320;
  reg fail_seen;

  localparam [6:0] NICE_OPCODE = 7'h0b;
  localparam [6:0] BAD_OPCODE = 7'h13;
  localparam [2:0] X_NONE    = 3'b000;
  localparam [2:0] X_RS1RS2  = 3'b011;
  localparam [2:0] X_RD      = 3'b100;
  localparam [6:0] FN_WLOAD  = 7'd0;
  localparam [6:0] FN_DLOAD  = 7'd1;
  localparam [6:0] FN_COMP   = 7'd2;
  localparam [6:0] FN_RSTAT  = 7'd3;
  localparam [6:0] FN_CLEAR  = 7'd4;
  localparam [6:0] FN_BAD    = 7'd127;

  function [31:0] make_nice_instr;
    input [2:0] xspec;
    input [6:0] funct7;
    begin
      make_nice_instr = {funct7, 5'b0, 5'b0, xspec, 5'b0, NICE_OPCODE};
    end
  endfunction

  function [31:0] make_bad_opcode_instr;
    begin
      make_bad_opcode_instr = {7'd0, 5'b0, 5'b0, X_NONE, 5'b0, BAD_OPCODE};
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

  task automatic expect_rsp_case;
    input [8*40-1:0] case_name;
    input [31:0] expected_rdat;
    input expected_err;
    reg [31:0] got_rdat;
    reg got_err;
    begin
      while (!(nice_rsp_multicyc_valid && nice_rsp_multicyc_ready)) begin
        @(posedge clk);
      end
      got_rdat = nice_rsp_multicyc_rdat;
      got_err = nice_rsp_multicyc_err;
      if ((got_rdat !== expected_rdat) || (got_err !== expected_err)) begin
        $display("[LIGHT_CASE_FAIL] %0s expected=%0d err=%0d got=%0d err=%0d",
                 case_name, expected_rdat, expected_err, got_rdat, got_err);
        fail_seen = 1'b1;
      end else begin
        pass_count = pass_count + 1;
        $display("[LIGHT_CASE_PASS] %0s rdat=%0d err=%0d",
                 case_name, got_rdat, got_err);
      end
      @(posedge clk);
    end
  endtask

  task automatic load_dot320_vectors;
    input integer base_itag;
    begin
      issue_req(make_nice_instr(X_RS1RS2, FN_WLOAD), 32'h0a0a0a0a, 32'd0, base_itag + 0);
      issue_req(make_nice_instr(X_RS1RS2, FN_WLOAD), 32'h0a0a0a0a, 32'd1, base_itag + 1);
      issue_req(make_nice_instr(X_RS1RS2, FN_WLOAD), 32'h0a0a0a0a, 32'd2, base_itag + 2);
      issue_req(make_nice_instr(X_RS1RS2, FN_WLOAD), 32'h0a0a0a0a, 32'd3, base_itag + 3);
      issue_req(make_nice_instr(X_RS1RS2, FN_DLOAD), 32'h02020202, 32'd0, base_itag + 4);
      issue_req(make_nice_instr(X_RS1RS2, FN_DLOAD), 32'h02020202, 32'd1, base_itag + 5);
      issue_req(make_nice_instr(X_RS1RS2, FN_DLOAD), 32'h02020202, 32'd2, base_itag + 6);
      issue_req(make_nice_instr(X_RS1RS2, FN_DLOAD), 32'h02020202, 32'd3, base_itag + 7);
    end
  endtask

  task automatic do_reset_pulse;
    begin
      @(negedge clk);
      rst_n <= 1'b0;
      nice_i_valid <= 1'b0;
      nice_i_instr <= 32'b0;
      nice_i_rs1 <= 32'b0;
      nice_i_rs2 <= 32'b0;
      nice_i_itag <= {`E203_ITAG_WIDTH{1'b0}};
      repeat (2) @(posedge clk);
      rst_n <= 1'b1;
      repeat (2) @(posedge clk);
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
    cycle_count = 0;
    pass_count = 0;
    seen_req = 1'b0;
    seen_ready_low = 1'b0;
    seen_rsp_320 = 1'b0;
    fail_seen = 1'b0;

    repeat (4) @(posedge clk);
    rst_n = 1'b1;
    $display("[LIGHT] reset released");

    issue_req(make_nice_instr(X_NONE, FN_CLEAR), 32'b0, 32'd0, 0);
    load_dot320_vectors(1);
    issue_req(make_nice_instr(X_NONE, FN_COMP), 32'b0, 32'd0, 9);
    while (nice_req_ready) @(posedge clk);
    while (!nice_req_ready) @(posedge clk);
    repeat (2) @(posedge clk);
    issue_req(make_nice_instr(X_RD, FN_RSTAT), 32'b0, 32'd0, 10);
    expect_rsp_case("normal_path", 32'd320, 1'b0);

    issue_req(make_nice_instr(X_RD, FN_RSTAT), 32'b0, 32'd0, 11);
    expect_rsp_case("rstat_repeat_read", 32'd320, 1'b0);

    issue_req(make_nice_instr(X_NONE, FN_CLEAR), 32'b0, 32'd0, 12);
    issue_req(make_nice_instr(X_RS1RS2, FN_WLOAD), 32'h0a0a0a0a, 32'd4, 13);
    expect_rsp_case("invalid_index", 32'd0, 1'b1);

    issue_req(make_nice_instr(X_NONE, FN_CLEAR), 32'b0, 32'd0, 14);
    issue_req(make_nice_instr(X_RS1RS2, FN_WLOAD), 32'h01020304, 32'd0, 15);
    issue_req(make_nice_instr(X_RS1RS2, FN_DLOAD), 32'h01010101, 32'd0, 16);
    issue_req(make_nice_instr(X_NONE, FN_COMP), 32'b0, 32'd0, 17);
    expect_rsp_case("comp_without_full_load", 32'd0, 1'b1);

    issue_req(make_nice_instr(X_NONE, FN_BAD), 32'b0, 32'd0, 18);
    expect_rsp_case("illegal_funct7", 32'd0, 1'b1);

    issue_req(make_bad_opcode_instr(), 32'b0, 32'd0, 19);
    expect_rsp_case("illegal_opcode", 32'd0, 1'b1);

    issue_req(make_nice_instr(X_NONE, FN_CLEAR), 32'b0, 32'd0, 20);
    load_dot320_vectors(21);
    issue_req(make_nice_instr(X_NONE, FN_COMP), 32'b0, 32'd0, 29);
    do_reset_pulse();
    issue_req(make_nice_instr(X_RD, FN_RSTAT), 32'b0, 32'd0, 30);
    expect_rsp_case("reset_clears_state", 32'd0, 1'b1);

    repeat (20) @(posedge clk);

    $display("[LIGHT_SUMMARY] req=%0d ready_low=%0d rsp320=%0d active=%0d pass_count=%0d fail=%0d",
             seen_req, seen_ready_low, seen_rsp_320, nice_active, pass_count, fail_seen);

    if (seen_req && seen_ready_low && seen_rsp_320 && !fail_seen && (pass_count == 7)) begin
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
