
/**
 * Load Store Unit
 * Commands:
 * cmd_trns: positive high, start transfer and lock i_address, i_rt_sel, ls_sel
 * 
 * Signals:
 * d_mem_rdy: positive high, memory operation complete in this cycle
**/
module ls_unit(
    input wire        clk,         // Clock
    input wire        a_rst,       // Async Reset
    input wire        bs,          // Block Select
    input wire[15:0]  i_address,   // Memory Address
    input wire        i_ts,        // Task Selector
    input wire[3:0]   i_rt_sel,    // Target Register Selector Input 
    input wire        i_ls_sel,    // Load/Store selector
    input wire        d_mem_rdy,   // Data Memory Ready
    output wire[15:0] d_mem_adr,   // Data Memory Address
    output wire       d_mem_w,     // Data Memory Write
    output wire       d_mem_r,     // Data Memory Read
    output wire[3:0]  o_rt_sel,    // Target Register Out Selector
    output wire       o_ts,        // Task Selector
    output wire       o_rdy        // Operation Done
);

/**
 * idle     (0): no transfer, if cmd_trns send address and send/receive data then goto wait
 * wait     (1): send operation, if d_mem_rdy is received goto idle, else stay
**/

reg status;

reg selected;

always @(posedge clk or negedge a_rst) begin
    if (~a_rst) begin
        status <= 1'b0;
    end else begin
        case (status)
        1'b0: status <= bs;
        1'b1: status <= ~d_mem_rdy;
        endcase
    end
end

wire idle_status = ~status;
wire busy_status = status;

reg[15:0] address;
reg[3:0] rt_sel;
reg ls_sel;
reg ts;

always @(posedge clk) begin
    selected <= bs & idle_status;
    if (idle_status) begin
        address <= i_address;
        rt_sel <= i_rt_sel;
        ls_sel <= i_ls_sel;
        ts <= i_ts;
    end
end

assign d_mem_adr = address;
assign o_rt_sel = rt_sel;
assign o_ts = ts;

assign d_mem_w = busy_status & ~ls_sel;
assign d_mem_r = busy_status & ls_sel;

assign o_rdy = selected & idle_status;

endmodule
