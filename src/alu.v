
module alu(
    input wire         clk,        // Clock signal
    input wire         bs,         // Block Select
    input wire[15:0]   opr_a,      // Operand A value
    input wire[15:0]   opr_b,      // Operand B value
    input wire[3:0]    i_sel_rd,   // Select RD
    input wire[1:0]    i_sel_d,    // Destination Select
    input wire         i_ts,       // Task Selector
    input wire[2:0]    alu_op,     // ALU Operation
    output reg[15:0]   result,     // Result
    output wire        ws_pc,      // Write PC
    output wire        ws_reg,     // Write Register
    output wire        ws_qp,      // Write Queue Pointer
    output wire        o_ts,       // Task Selector
    output wire[3:0]   o_sel_rd    // Reg Select  
);

reg selected;

always@(posedge clk) begin
    selected <= bs;
end

reg[15:0] src_a;
reg[15:0] src_b;
reg[2:0] opcode;
reg[1:0] sel_d;
reg[3:0] sel_rd;
reg ts;

always@(posedge clk) begin
    if (bs | ~selected) begin
        src_a <= opr_a;
        src_b <= opr_b;
        opcode <= alu_op;
        sel_d <= i_sel_d;
        sel_rd <= i_sel_rd;
        ts <= i_ts;
    end
end

assign ws_pc = sel_d[1] & ~sel_d[0] & selected;
assign ws_reg = ~sel_d[1] & ~sel_d[0] & selected;
assign ws_qp = ~sel_d[1] & sel_d[0] & selected;

assign o_sel_rd = sel_rd;
assign o_ts = ts;

wire op_subtract = opcode[0];
wire bit = op_subtract;
wire c_in = op_subtract;

wire[14:0] xor_val = { bit, bit, bit, bit, bit, bit, bit, bit, bit, bit, bit, bit, bit, bit, bit };

reg low_carry;
reg [14:0] sum_low;

reg high_carry;
reg sum_high;

wire v_flag = high_carry ^ low_carry;

always @(*) begin
    {low_carry, sum_low} = src_a[14:0] + (src_b[14:0] ^ xor_val) + c_in;
    {high_carry, sum_high} = src_a[15] + (src_b[15] ^ bit) + low_carry;
    case (opcode)
    3'b000: result = {sum_high, sum_low[14:0]};
    3'b001: result = {sum_high, sum_low[14:0]};
    3'b010: result = { 14'b0, v_flag, high_carry };
    3'b011: result = { 14'b0, v_flag, high_carry };
    3'b100: result = src_a & src_b;
    3'b101: result = src_a | src_b;
    3'b110: result = src_a ^ src_b;
    3'b111: result = src_b;
    endcase
end

endmodule