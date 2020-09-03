
/**
 * sel_a is mux signal for register source A, possible values: Register/QP Indirect Register/Program Counter/QP
 * sel_b is mux signal for register source B, possible values: Register/Immediate
 * sel_d is mux signal for destionation, possible values: Register/Queue Pointer/Program Counter/Memory
**/

module id_unit(
    input wire[15:0]   i_reg,       // Operation to decode
    output wire        is_stop,     // The current Decoded Operation is STOP opcode
    output wire[1:0]   sel_a,       // Select A
    output wire        sel_b,       // Select B
    output wire[1:0]   sel_d,       // Select Destination
    output wire        rb_is_front, // If sel_b is register ignore sel_rb and use front queue pointer as register address
    output wire        rd_is_front, // if sel_d is register ignore sel_rd and use front queue pointer as register address
    output wire[3:0]   sel_ra,      // Register A selector 
    output wire[3:0]   sel_rb,      // Register B selector
    output wire[3:0]   sel_rc,      // Register C selector
    output wire[3:0]   sel_rd,      // Select D register
    output wire[2:0]   sel_alu,     // ALU operation
    output wire        q_dir,       // Queue Direction
    output wire        op_type      // Op Type: ALU Operation/Memory
);

wire maybe_movr = i_reg[6] & i_reg[5] & i_reg[4];
wire maybe_movi = i_reg[14] & i_reg[13] & i_reg[12];

wire is_alu_r_q = 1'b0;

// 0000 aaaa 1fff bbbb where fff != 111     alu r,r -> front
wire is_alu_rr_q = ~i_reg[15] & ~i_reg[14] & ~i_reg[13] & ~i_reg[12] & i_reg[7] & ~maybe_movr;

// 1fff aaaa iiii iiii where fff != 111     alu r,i -> front
wire is_alu_ri_q = i_reg[15] & ~maybe_movi;

wire is_alu_r_r = ~i_reg[15] & ~i_reg[14] & ~i_reg[13] & ~i_reg[12] & i_reg[7] & maybe_movr;    // variant with fff = 111
wire is_alu_i_r = i_reg[15] & maybe_movi;                                                       // variant with fff = 111

// 0000 aaaa 0001 0000 goto
wire is_jump_r = ~i_reg[15] & ~i_reg[14] & ~i_reg[13] & ~i_reg[12] & ~i_reg[7] & ~i_reg[6];
wire is_jump_i = 1'b0; // next version

// 0010 0010 iiii iiii   u -> front
wire is_ld = ~i_reg[15] & ~i_reg[14] & i_reg[13] & ~i_reg[12];
wire is_ld_q = is_ld & i_reg[8];
wire is_ld_mem = ~i_reg[15] & i_reg[14] & i_reg[13];
wire is_st_mem = ~i_reg[15] & i_reg[14] & ~i_reg[13];

wire is_control_op = ~i_reg[15] & ~i_reg[14] & ~i_reg[13] & ~i_reg[12] & ~i_reg[7] & ~i_reg[6] & ~i_reg[5] & ~i_reg[4];

// TODO check privilege
/* 0000 xxxx 0000 0000   stop     -- 0 level -- stop the cpu */
assign is_stop = is_control_op & ~i_reg[3] & ~i_reg[2] & ~i_reg[1] & ~i_reg[0];

assign op_type = is_ld_mem | is_st_mem;

assign sel_a = {is_jump_i, 1'b0}; //complete
assign sel_b = is_jump_i | is_ld_mem | is_st_mem | is_ld | is_alu_i_r | is_alu_ri_q;

assign rb_is_front = 0; // next version

assign sel_alu = is_alu_rr_q ? i_reg[6:4] : ( is_alu_ri_q ? i_reg[14:12] : { is_ld, is_ld, is_ld } );

assign sel_ra = i_reg[11:8];
assign sel_rb = i_reg[3:0];
assign sel_rc = i_reg[11:8];

assign sel_d = {is_jump_r | is_jump_i, is_st_mem | is_ld_q};

assign rd_is_front = ~(is_alu_r_r | is_alu_i_r | is_jump_i | is_jump_r);

assign sel_rd = is_ld_mem ? i_reg[11:8] : i_reg[3:0];

assign q_dir = 1'b0;

endmodule
