
module tb_pc_file;

reg clk;
reg a_rst;

reg[15:0] npc;
reg hold;
reg r_ts;
reg w_ts;
reg ws;

wire[15:0] pc_val;
wire[15:0] prev_pc_val;

pc_file pc(
    .clk (clk),    // Clock Signal
    .a_rst (a_rst),    // Async Reset
    .r_ts (r_ts),
    .w_ts (w_ts),
    .ws (ws),
    .hold (hold),
    .i_pc (npc),
    .o_pc (pc_val),
    .o_prev_pc (prev_pc_val)
);

initial begin
    $dumpfile("dumps/tb_pc_file_dump.vcd");
    $dumpvars(0, tb_pc_file);
    clk = 0;
    a_rst = 0;
    npc = 15'h4FF0;
    hold = 1;
    r_ts = 0;
    w_ts = 0;
    ws = 0;
    #1 a_rst = 1;
    #3
    hold = 0;
    #4
    ws = 1;
    #4
    hold = 1;
    #4
    ws = 0;
    #4
    hold = 0;
    #18
    $finish();
end

always begin
    #2 clk <= ~clk;
end

endmodule