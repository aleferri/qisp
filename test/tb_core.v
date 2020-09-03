
module tb_core;

wire[15:0] op_goto_r0 = 16'h0010;   // goto r0
wire[15:0] op_ldu = 16'h2240;        // ld.u $40
wire[15:0] op_ldqu = 16'h2100;      // ldq $0
wire[15:0] op_add_ri = 16'h8190;    // add r1, $90 -> front
wire[15:0] op_sub_rr = 16'h0493;    // sub r4, r3 -> front
wire[15:0] op_ldq_r0 = 16'h0050;    // movs r0, qp

reg clk;
reg a_rst;

// Memory
reg[15:0] i_mem[0:15];

wire[15:0] i_mem_adr;

reg i_mem_rdy;

reg[15:0] i_mem_data;
reg i_mem_cnt; // 4 cycle latency memory

always @(posedge clk) begin
    i_mem_rdy <= ~i_mem_cnt;
    i_mem_data <= i_mem[i_mem_adr[4:1]];
    i_mem_cnt <= i_mem_cnt + 1'b1;
end

core core_instance(
    .clk (clk),
    .a_rst (a_rst),
    .i_mem_rdy (i_mem_rdy),
    .i_mem_data (i_mem_data),
    .i_mem_adr (i_mem_adr)
);

initial begin
    $dumpfile("dumps/tb_core_dump.vcd");
    $dumpvars(0, tb_core);
    i_mem[0] = op_ldu;
    i_mem[1] = op_ldq_r0;
    i_mem[2] = op_add_ri;
    i_mem[3] = op_sub_rr;
    i_mem[4] = op_add_ri;
    i_mem[5] = op_ldq_r0;
    i_mem[6] = op_add_ri;
    i_mem[7] = op_sub_rr;
    i_mem[8] = op_ldu;
    i_mem[9] = op_goto_r0;
    i_mem[10] = op_ldu;
    i_mem[11] = op_ldu;
    i_mem[12] = op_ldu;
    a_rst = 0;
    clk = 0;
    i_mem_rdy = 1'b0;
    i_mem_cnt = 1'b0;
    #4 a_rst = 1;
    #128 $finish();
end

always begin
    #2 clk <= ~clk;
end

endmodule