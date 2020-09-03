
module tb_reg_file;

reg clk;

reg ws;
reg r_ts;
reg w_ts;

reg [3:0] i_dest;

reg[3:0] ra_sel;
reg[3:0] rb_sel;
reg[3:0] rd_sel;
reg[15:0] rd_val;

wire[15:0] ra_val;
wire[15:0] rb_val;

reg_file regs(
    .clk (clk),    // Clock Signal
    .ws (ws),      // Halt Signal
    .r_ts (r_ts),        // Task Selector
    .w_ts (w_ts),
    .i_dest (i_dest),
    .ra_sel (ra_sel),    // Register A Selector
    .rb_sel (rb_sel),    // Register B Selector
    .rd_sel (rd_sel),    // Destination Register Selector
    .rd_val (rd_val),    // Destination Register Value
    .ra_val (ra_val),    // Register A Value
    .rb_val (rb_val)
);

initial begin
    $dumpfile("dumps/tb_reg_file_dump.vcd");
    $dumpvars(0, tb_reg_file);
    clk = 0;
    ws = 0;
    i_dest = 4'b0;
    r_ts = 0;
    w_ts = 0;
    ra_sel = 4'b0100;
    rb_sel = 4'b1000;
    rd_sel = 4'b0000;
    rd_val = 16'h0200;
    #3 ws <= 1'b1;
    rs <= 1'b1;
    #124
    $finish();
end

always begin
    #2 clk <= ~clk;
end

always @(posedge clk) begin
    i_dest <= rd_sel;
    rd_sel <= rd_sel + 1'b1;
    rd_val <= {12'h020, rd_sel};
end

always @(posedge clk) begin
    ra_sel <= ra_sel + 4'hF;
    rb_sel <= rb_sel + 4'h1;
end

endmodule
