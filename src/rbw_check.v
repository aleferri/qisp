
module rbw_check(
    input wire          clk,        // Clock
    input wire          a_rst,      // Async Reset
    input wire          i_rbw,      // Read Before Write notice
    input wire[L:0]     i_rbw_adr,  // RBW address of the notice
    input wire          rs,         // Read Select of the instance to check
    input wire          r_ts,       // Read Task Selector
    input wire[L:0]     rs_adr,     // Read Select Address
    input wire          ws,         // Write Select of the instance to check
    input wire          w_ts,       // Write Task Selector
    input wire[L:0]     ws_adr,     // Write Select Address
    output wire         o_rbw       // RBW detected
);
parameter L = 0;
parameter PT = 1;

reg rbw_ts;
reg rbw_exists;
reg[L:0] rbw_adr;

//Write can clear ?
wire rbw_clr = (w_ts == r_ts) & ws & (rbw_adr == ws_adr);

wire ptr_solve = rbw_clr & PT;

always @(posedge clk or negedge a_rst) begin
    if (~a_rst) begin
        rbw_exists <= 1'b0;
        rbw_ts <= 1'b0;
    end else begin
        rbw_exists <= rbw_exists & ~(rbw_clr) | i_rbw;
        rbw_ts <= i_rbw ? r_ts :  rbw_ts;
    end
end

always @(posedge clk) begin
    if (i_rbw) begin
        rbw_adr <= i_rbw_adr;
    end
end

assign o_rbw = rbw_exists & rs & rbw_ts == r_ts & ~ptr_solve;
// Translate to "issue has been notified" and "has not been cleared" and "this case is that case" and "a passthrough cannot resolve the issue", 
// then we have a problem and then our problem become everyone problem

endmodule
