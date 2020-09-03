
module core (
    input wire          clk,
    input wire          a_rst,
    input wire          i_mem_rdy,
    input wire[15:0]    i_mem_data,
    output wire[15:0]   i_mem_adr
);

reg halt_flag;

reg[1:0] pipe_status;

wire fetch_rdy;
wire op_is_stop;

wire hazard_detected = 1'b0;
wire hazard_clr = ~hazard_detected;

always @(posedge clk or negedge a_rst) begin
    if (~a_rst) begin
        pipe_status <= 1'b0;    // No steps in the pipeline are valid
    end else begin
        case (pipe_status)
        2'b00: pipe_status <= { 1'b0, fetch_rdy };       // All steps are invalid, next valid is fetch
        2'b01: pipe_status <= { fetch_rdy, ~fetch_rdy }; // Fetch status in the pipeline is valid, next valid is decode
        2'b10: pipe_status <= { 1'b1, hazard_clr & fetch_rdy };      // Decode status in the pipeline is valid, next valid is execute
        2'b11: pipe_status <= 2'b11;                     // All steps are valid
        endcase
    end
end

always @(posedge clk or negedge a_rst) begin
    if (~a_rst) begin
        halt_flag <= 1'b0;
    end else begin
        halt_flag <= op_is_stop & pipe_status[0];
    end
end

wire pc_hold = ~fetch_rdy | halt_flag;
wire qp_hold = ~fetch_rdy | halt_flag;
wire fe_hold = halt_flag;
wire ex_hold = ~fetch_rdy | halt_flag | ~hazard_clr | ~pipe_status[1];

wire fe_hold_clr = ex_wsp & (pipe_status[0] | pipe_status[1]);

reg ts_fetch;
reg ts_decode;
wire ts_execute;

always @(posedge clk or negedge a_rst) begin
    if (~a_rst) begin
        ts_fetch <= 1'b0;
    end else begin
        ts_decode <= ts_fetch;
        ts_fetch <= 1'b0;
    end
end

// State Modules

wire[15:0] id_pc;       // Decode Unit PC
wire id_q_dir;          // Decode Queue Direction, updated immediatly
wire id_q_sel_rd;        // Decode Queue Selector for Register Destination
wire id_q_sel_rb;        // Decode Queue Selector for Register B
wire[1:0] id_sel_a;     // Decode Selector for Operand A
wire id_sel_b;          // Decode Selector for Operand B
wire[1:0] id_sel_d;     // Decode Selector for Destination

wire[3:0] id_sel_ra;
wire[3:0] id_sel_rb;
wire[3:0] id_sel_rc;
wire[3:0] id_sel_rd;

wire ex_wsq;            // Write Select Queue
wire ex_wsr;            // Write Select Register
wire ex_wsp;            // Write Select PC

wire ex_result;         // Execution Result
wire[3:0] ex_sel_rd;    // Execution Select for Destination

wire[3:0] qp;

pc_file program_counter(
    .clk (clk),
    .a_rst (a_rst),
    .r_ts (ts_fetch),
    .w_ts (ts_execute),
    .ws (ex_wsp),
    .hold (pc_hold),
    .i_pc (ex_result),
    .o_pc (i_mem_adr),
    .o_prev_pc (id_pc)
);

queue_file queue(
    .clk (clk),    // Clock Signal
    .r_ts (ts_decode),    // Read Task Selector
    .w_ts (ts_execute),    // Write Task Selector
    .hold (qp_hold),    // Hold Value
    .ws (ex_wsq),    // Write Select
    .rs (id_q_sel_rb | id_sel_a[0] | id_q_sel_rd),    // Read Select
    .q_dir (id_q_dir),
    .i_qp (ex_result[3:0]),
    .o_qp (qp)
);

wire[15:0] ra_val;
wire[15:0] rb_val;

reg_file regs(
    .clk (clk),
    .ws (ex_wsr),
    .r_ts (ts_decode),
    .w_ts (ts_execute),
    .ra_sel (id_sel_ra),
    .rb_sel (id_sel_rb),
    .rd_sel (ex_sel_rd),
    .rd_val (ex_result),
    .ra_val (ra_val),
    .rb_val (rb_val)
);

// End of State Modules

// Pipeline modules

// Fetch Module

wire[15:0] fetch_ir;

fe_unit fetch(
    .clk (clk),
    .a_rst (a_rst),
    .i_hold (fe_hold),
    .i_hold_clr (fe_hold_clr),
    .i_rdy (i_mem_rdy),
    .i_data (i_mem_data),
    .o_rdy (fetch_rdy),
    .o_reg (fetch_ir)
);

// Decode Module

wire[15:0] z_ext_imm = { 8'b0, fetch_ir[7:0] };

wire op_type;
wire[2:0] sel_alu;

id_unit decode(
    .i_reg (fetch_ir),       // Operation to decode
    .is_stop (op_is_stop),     // The current Decoded Operation is STOP opcode
    .sel_a (id_sel_a),
    .sel_b (id_sel_b),
    .sel_ra (id_sel_ra),
    .sel_rb (id_sel_rb),
    .sel_rc (id_sel_rc),
    .rb_is_front (id_q_sel_rb),
    .rd_is_front (id_q_sel_rd),
    .sel_alu (sel_alu),
    .sel_d (id_sel_d),
    .sel_rd (id_sel_rd),
    .q_dir (id_q_dir),
    .op_type (op_type)
);

// Effective Operand Decision
wire[3:0] e_sel_ra = id_sel_a[0] ? qp : id_sel_ra;
wire[3:0] e_sel_rb = id_sel_q_rb ? qp : id_sel_rb;
wire[3:0] e_sel_rd = id_sel_q_rd ? qp : id_sel_rd;

reg[15:0] e_ra_val;
reg[15:0] e_rb_val;

always @(*) begin
    case(sel_a)
    2'b00: e_ra_val = ra_val;
    2'b01: e_ra_val = ra_val;
    2'b10: e_ra_val = id_pc;
    2'b11: e_ra_val = {12'b0, qp};
    endcase
end

always @(*) begin
    e_rb_val = sel_b ? z_ext_imm : rb_val;
end

wire[15:0] e_rc_val = rb_val;

// Execution Module

alu ex_alu(
    .clk (clk),
    .bs (~op_type),
    .opr_a (e_ra_val),
    .opr_b (e_rb_val),
    .i_sel_rd (e_sel_rd),
    .i_sel_d (id_sel_d),
    .i_ts (ts_decode),
    .alu_op (sel_alu),
    .result (ex_result),
    .ws_pc (ex_wsp),
    .ws_reg (ex_wsr),
    .ws_qp  (ex_wsq),
    .o_ts (ts_execute),
    .o_sel_rd (ex_sel_rd)
);

// End Of Pipeline modules

endmodule
