
module reg_file(
    input wire           clk,       // Clock Signal
    input wire           ws,        // Write Select
    input wire           r_ts,      // Read Task Selector
    input wire           w_ts,      // Write Task Selector
    input wire[3:0]      ra_sel,    // Register A Selector
    input wire[3:0]      rb_sel,    // Register B Selector
    input wire[3:0]      rd_sel,    // Destination Register Selector
    input wire[15:0]     rd_val,    // Destination Register Value
    output wire[15:0]    ra_val,    // Register A Value
    output wire[15:0]    rb_val     // Register B Value
);

reg [15:0] file[0:15];

reg [15:0] ra_fetched;
reg [15:0] rb_fetched;

// Pass Through
wire ptr_ra = ra_sel == rd_sel & r_ts == w_ts;
wire ptr_rb = rb_sel == rd_sel & r_ts == w_ts;

always@(*) begin
    ra_fetched = ( ptr_ra ) ? rd_val : file[{r_ts, ra_sel}];
    rb_fetched = ( ptr_rb ) ? rd_val : file[{r_ts, rb_sel}];
end

always @(posedge clk) begin
    if (ws) begin 
        file[{w_ts, rd_sel}] <= rd_val;
    end
end

assign ra_val = ra_fetched;
assign rb_val = rb_fetched;

endmodule
