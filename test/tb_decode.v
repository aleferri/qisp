
module tb_decode;

reg clk;
reg[15:0] i_reg;

wire is_stop;
wire[1:0] sel_a;
wire[3:0] sel_ra;
wire sel_b;
wire rb_is_front;
wire[3:0] sel_rb;
wire[3:0] sel_rc;
wire op_type;
wire[2:0] sel_alu;
wire[1:0] sel_d;
wire rd_is_front;
wire[3:0] sel_rd;

id_unit id_module(
    .i_reg ( i_reg ),      // Operation to decode
    .is_stop ( is_stop ),
    .sel_a ( sel_a ),       // Select A
    .sel_ra (sel_ra),      // Register A selector
    .sel_b (sel_b),       // Select B
    .rb_is_front (rb_is_front), // If sel_b is register ignore sel_rb and use front queue pointer as register address
    .sel_rb (sel_rb),      // Register B selector
    .sel_rc (sel_rb),       // Register C selector
    .op_type (op_type),     // Op Type: ALU Operation/Memory
    .sel_alu (sel_alu),     // ALU operation
    .sel_d (sel_d),       // Select Destination
    .rd_is_front (rd_is_front), // if sel_d is register ignore sel_rd and use front queue pointer as register address
    .sel_rd (sel_rd)       // Select D register
);

wire[15:0] op_goto_r0 = 16'h0010;   // goto r0
wire[15:0] op_ldu = 16'h2240;        // ld.u $40
wire[15:0] op_add_ri = 16'h8190;    // add r1, $90 -> front
wire[15:0] op_sub_rr = 16'h0493;    // sub r4, r3 -> front

initial begin
    $dumpfile("dumps/tb_decode_dump.vcd");
    $dumpvars(0, tb_decode);
    clk = 0;
    i_reg = op_goto_r0;
    #4
    i_reg = op_sub_rr;
    #4
    i_reg = op_add_ri;
    #4
    i_reg = op_ldu;
    #4 $finish();
end

always begin
    #2 clk <= ~clk;
end

endmodule