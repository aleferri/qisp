
module queue_file(
    input wire              clk,    // Clock Signal
    input wire             r_ts,    // Read Task Selector
    input wire             w_ts,    // Write Task Selector
    input wire             hold,    // Hold Value
    input wire               ws,    // Write Select
    input wire               rs,    // Read Select
    input wire            q_dir,    // Q Direction
    input wire[3:0]        i_qp,    // New Queue POinter
    output wire[3:0]       o_qp     // Current Queue Pointer
);

reg[3:0] qp_0;
reg[3:0] qp_1;

always @(posedge clk) begin
    if (rs & ~r_ts & ~hold) begin
        if (ws & ~w_ts) begin
            qp_0 <= i_qp;
        end else begin
            qp_0 <= qp_0 + {q_dir, q_dir, q_dir, 1'b1};
        end
    end
end

always @(posedge clk) begin
    if (rs & r_ts & ~hold) begin
        if (ws & w_ts) begin
            qp_1 <= i_qp;
        end else begin
            qp_1 <= qp_1 + {q_dir, q_dir, q_dir, 1'b1};
        end
    end
end

//Passthrough
wire [3:0] qp_0_ptr = (ws & ~hold & ~r_ts) ? i_qp : qp_0;
wire [3:0] qp_1_ptr = (ws & ~hold & r_ts) ? i_qp : qp_1;  

wire[3:0] selected = ( r_ts ? qp_1_ptr : qp_0_ptr );

assign o_qp = selected;

endmodule