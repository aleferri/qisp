
module tasks(
    input wire              clk,    // Clock Signal
    input wire            a_rst,    // Async Reset
    input wire              irq,    // Interrupt Request
    input wire[2:0]      irq_id,    // Interrupt Request ID
    output wire        ts_fetch,    // Task Selector Fetch
    output wire          ts_dec,    // Task Selector Decode
    output wire         ts_exec     // Task Selector Execute
);

reg ts_reg;
reg ts_dec_reg;
reg ts_exec_reg;

always @(posedge clk or negedge a_rst) begin
    if (~a_rst) begin
        ts_reg <= 1'b0;
    end else begin
        ts_exec_reg <= ts_dec_reg;
        ts_dec_reg <= ts_reg;
        ts_reg <= ts_reg;
    end
end

reg irq_enable;

always @(posedge clk or negedge a_rst) begin
    if (~a_rst) begin
        irq_enable <= 1'b0;
    end else begin
        irq_enable <= irq_enable & ~irq;
    end
end

assign ts_fetch = ts_reg;
assign ts_dec = ts_dec_reg;
assign ts_exec_reg = ts_exec_reg;

endmodule