
module tb_queue;

reg clk;

reg r_ts;
reg w_ts;
reg hold;
reg ws;
reg rs;
reg q_dir;

reg [3:0] i_qp;

wire [3:0] q_val;

queue_file queue(
    .clk (clk),   // Clock Signal
    .r_ts (r_ts),    // Read Task Selector
    .w_ts (w_ts),    // Write Task Selector
    .hold (hold),    // Hold Value
    .ws (ws),    // Write Select
    .rs (rs),    // Read Select
    .q_dir (q_dir),    // Q Direction
    .i_qp (i_qp),    // New Queue POinter
    .o_qp (q_val)     // Current Queue Pointer
);

initial begin
    $dumpfile("dumps/tb_queue_dump.vcd");
    $dumpvars(0, tb_queue);
    clk = 0;
    r_ts = 0;
    w_ts = 0;
    hold = 0;
    ws = 0;
    rs = 0;
    q_dir = 0;
    i_qp = 4'h7;
    #2
    ws = 1;
    #4
    rs = 1;
    #4
    ws = 0;
    q_dir = 1;
    #36
    $finish();
end

always begin
    #2 clk <= ~clk;
end

endmodule