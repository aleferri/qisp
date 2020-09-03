module pc_file(
    input wire          clk,      // Clock Signal
    input wire          a_rst,    // Async Reset
    input wire          r_ts,     // Read Task Selector
    input wire          w_ts,     // Write Task Selector
    input wire          ws,       // Write Select
    input wire          hold,     // Hold Value
    input wire[15:0]    i_pc,     // New PC value
    output wire[15:0]   o_pc,     // Next Instruction Address
    output wire[15:0]   o_prev_pc // Previus PC (for use in decode stage)
);

reg[14:0] pc_0;
reg[14:0] pc_1;

reg prev_pc_ts;

reg[15:0] pc_next;

wire[14:0] selected = ( r_ts ? pc_1 : pc_0 );

always @(*) begin
    pc_next = selected + 1'b1;
end

always @(posedge clk) begin
    prev_pc_ts <= r_ts;
end

// PC 0
always @(posedge clk or negedge a_rst) begin
    if (~a_rst) begin
        pc_0 <= 15'h7FFF;
    end else begin
        case ({hold, ws & ~w_ts})
        2'b00: pc_0 <= pc_next;
        2'b01: pc_0 <= i_pc[15:1];
        2'b10: pc_0 <= pc_0;
        2'b11: pc_0 <= pc_0;
        endcase
    end
end

// PC 1
always @(posedge clk) begin
    case ({hold, ws & w_ts})
    2'b00: pc_1 <= pc_next;
    2'b01: pc_1 <= i_pc[15:1];
    2'b10: pc_1 <= pc_1;
    2'b11: pc_1 <= pc_1;
    endcase
end

assign o_pc = { pc_next, 1'b0 };
assign o_prev_pc = { prev_pc_ts ? pc_1 : pc_0, 1'b0 };

endmodule