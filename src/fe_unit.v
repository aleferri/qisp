
/**
 * Fetch Phase:
 * IR <- IMemory Input
**/

/**
 * Commands:
 * i_hold     : positive high, set the fetch unit in hold mode and interrupt current fetch, at the next clock pulse until an i_hold_clr command is issued
 *              the i_status output should be clear and no new fetches should occour
 * i_hold_clr : positive high, set the fetch unit in fetch mode and allow current fetch, at the next clock pulse until an i_hold command is issued
 *              the i_status output should be set if fetch occurred
 * Signals:
 * i_rdy      : positive high, memory ready/not ready status signal, no fetch should occour when i_rdy is low
 * o_rdy      : positive high, a new instruction has been fetched
 * 
 * Data:
 * i_data     : Instruction Memory Data, contains the next to fetch instruction
 * o_reg      : Current Instruction Register, contains the full fetched instruction
**/

module fe_unit(
    input wire           clk,          // Clock signal
    input wire           a_rst,        // Async Reset
    input wire           i_hold,       // Issue Hold command
    input wire           i_hold_clr,   // Clear Hold command
    input wire           i_rdy,        // Instruction Memory Ready
    input wire[15:0]     i_data,       // Instruction Data
    output wire          o_rdy,        // Instruction Ready
    output wire[15:0]    o_reg         // Last Valid Fetched
);

reg [15:0] ir;

// Statuses
// invalid (00): transitional status, next clock goto valid
// reserve (01): transitional status, next clock goto invalid
// wait    (10): stable status, next clock goto valid if hold is cleared
// valid   (11): stable status, next clock goto wait if hazard happen

reg [1:0] status;

// Combinatorial
wire status_wait = status[1] & ~status[0];
wire status_valid = status[1] & status[0];

wire jump = ~ir[15] & ~ir[14] & ~ir[13] & ~ir[12] & ~ir[7] & ~ir[6] & ~ir[5];

// Next State
wire keep_wait = status_wait;
wire next_wait = (jump & status_valid) | i_hold;

wire status_next_wait = (keep_wait | next_wait) & ~i_hold_clr;

// Combinatorial
wire hold = status_next_wait | ~i_rdy;

always @(posedge clk or negedge a_rst) begin
    if (~a_rst) begin
        status <= 2'b0;
    end else begin
        case(status[1])
        1'b0: status <= {~hold, ~hold};
        1'b1: status <= {status[1], ~status_next_wait};
        endcase
    end
end

// IR, ready every cycle if can read
always @(posedge clk) begin
    if (~hold) begin
        ir <= i_data;
    end
end

// Ports assignment

assign o_reg = ir;
assign o_rdy = status_valid & ~hold;

endmodule
