
module tb_fetch;

reg clk;
reg a_rst;
reg hold;
reg i_rdy;
reg[15:0] i_data;
reg clr_jump;

wire i_status;
wire[15:0] opc;

fe_unit fe_module(
    .clk ( clk ),
    .a_rst ( a_rst ),
    .i_hold ( hold ),
    .i_hold_clr ( clr_jump ),
    .i_rdy ( i_rdy ),
    .i_data ( i_data ),
    .o_rdy ( i_status ),
    .o_reg ( opc )
);

initial begin
    $dumpfile("dumps/tb_fetch_dump.vcd");
    $dumpvars(1, tb_fetch, fe_module);
    clk = 0;
    a_rst = 0;
    hold = 0;
    i_rdy = 0;
    i_data = 0;
    clr_jump = 0;
    #1
    a_rst = 1;
    #1
    i_data = 16'b0111011101110111;
    #1
    i_rdy = 1'b1;
    #4
    hold = 1'b1;
    i_rdy = 1'b0;
    #4
    hold = 1'b0;
    #6
    clr_jump = 1'b1;
    i_rdy = 1'b1;
    #10 $finish();
end

always begin
    #2 clk <= ~clk;
end

endmodule
