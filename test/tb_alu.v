
module tb_alu;

reg clk;

reg bs;
reg[15:0] opr_a;
reg[15:0] opr_b;
reg[3:0] i_sel_rd;
reg i_sel_d;
reg i_ts;
reg[2:0] alu_op;

wire[15:0] result;
wire wr_pc;
wire wr_reg;
wire wr_qp;
wire o_ts;
wire[3:0] o_sel_rd;

alu alu_module(
    .clk ( clk ),
    .bs ( bs ),
    .opr_a (opr_a),
    .opr_b (opr_b),
    .i_sel_rd (i_sel_rd),
    .i_sel_d (i_sel_d),
    .i_ts (i_ts),
    .alu_op (alu_op),
    .result (result),
    .wr_pc (wr_pc),
    .wr_reg (wr_reg),
    .wr_qp (wr_qp),
    .o_ts (o_ts),
    .o_sel_rd (o_sel_rd)
);

initial begin
    $dumpfile("dumps/tb_alu_dump.vcd");
    $dumpvars(1, tb_alu);
    $dumpvars(1, alu_module);
    clk = 0;
    bs = 0;
    opr_a = 16'h0F0F;
    opr_b = 16'hF0F1;
    i_sel_rd = 4'h4;
    i_sel_d = 0;
    i_ts = 0;
    alu_op = 3'h7;
    #2 bs = 1'b1;
    #14 opr_b = 16'h7FF1;
    #112 $finish();
end

always@(posedge clk) begin
    alu_op <= alu_op + 1'b1;
end

always begin
    #2 clk <= ~clk;
end

endmodule