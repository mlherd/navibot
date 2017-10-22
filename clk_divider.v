module clk_divider ( input clk_in, output clk_8khz, clk_2hz);

wire clk_8khz, clk_2hz;

reg [25:0] countval;


always @(posedge clk_in)
	countval <= countval + 1'b1;

assign clk_8khz = countval[13]; //was 16 earlier
assign clk_2hz = countval[25];


endmodule