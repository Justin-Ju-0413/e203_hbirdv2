`include "e203_defines.v"

`ifdef E203_HAS_NICE
module e203_subsys_nice_core (
    input                         nice_clk,
    input                         nice_rst_n,
    output                        nice_active,
    output                        nice_mem_holdup,
    input                         nice_req_valid,
    output                        nice_req_ready,
    input  [`E203_XLEN-1:0]       nice_req_inst,
    input  [`E203_XLEN-1:0]       nice_req_rs1,
    input  [`E203_XLEN-1:0]       nice_req_rs2,
    output                        nice_rsp_valid,
    input                         nice_rsp_ready,
    output [`E203_XLEN-1:0]       nice_rsp_rdat,
    output                        nice_rsp_err,
    output                        nice_icb_cmd_valid,
    input                         nice_icb_cmd_ready,
    output [`E203_ADDR_SIZE-1:0]  nice_icb_cmd_addr,
    output                        nice_icb_cmd_read,
    output [`E203_XLEN-1:0]       nice_icb_cmd_wdata,
    output [1:0]                  nice_icb_cmd_size,
    input                         nice_icb_rsp_valid,
    output                        nice_icb_rsp_ready,
    input  [`E203_XLEN-1:0]       nice_icb_rsp_rdata,
    input                         nice_icb_rsp_err
);
    wire [3:0] nice_icb_cmd_wmask_unused;

    assign nice_active = nice_req_valid | nice_rsp_valid | ~nice_req_ready;

    cnn_nice_core u_cnn_nice_core (
        .clk(nice_clk),
        .rst_n(nice_rst_n),
        .nice_req_valid(nice_req_valid),
        .nice_req_ready(nice_req_ready),
        .nice_req_instr(nice_req_inst),
        .nice_req_rs1(nice_req_rs1),
        .nice_req_rs2(nice_req_rs2),
        .nice_rsp_valid(nice_rsp_valid),
        .nice_rsp_ready(nice_rsp_ready),
        .nice_rsp_rdat(nice_rsp_rdat),
        .nice_rsp_err(nice_rsp_err),
        .nice_mem_holdup(nice_mem_holdup),
        .nice_icb_cmd_valid(nice_icb_cmd_valid),
        .nice_icb_cmd_ready(nice_icb_cmd_ready),
        .nice_icb_cmd_addr(nice_icb_cmd_addr),
        .nice_icb_cmd_read(nice_icb_cmd_read),
        .nice_icb_cmd_size(nice_icb_cmd_size),
        .nice_icb_cmd_wdata(nice_icb_cmd_wdata),
        .nice_icb_cmd_wmask(nice_icb_cmd_wmask_unused),
        .nice_icb_rsp_valid(nice_icb_rsp_valid),
        .nice_icb_rsp_ready(nice_icb_rsp_ready),
        .nice_icb_rsp_err(nice_icb_rsp_err),
        .nice_icb_rsp_rdata(nice_icb_rsp_rdata)
    );
endmodule
`endif
