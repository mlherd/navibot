module navibot_controller ( input uart_rx, input clk_in, input [15:0] sw, output [15:0] led, output l_blinker, output r_blinker, output l_mtr_en, output r_mtr_en);

wire l_mtr_ctrl, r_mtr_ctrl, l_led_en, r_led_en;
wire clk_8khz, clk_2hz;
wire slow0_fast1;

wire [7:0] led_tmp;
reg [7:0] pwm_counter;
wire [7:0] speed_setting_pwm_dr;
wire [7:0] slow_pwm_nr;

uart6_a7 u0 ( 	
			.uart_rx(uart_rx), 
			.clk_in(clk_in), 
			.led(led_tmp[7:0]),
			.l_mtr_ctrl(l_mtr_ctrl), 
			.r_mtr_ctrl(r_mtr_ctrl), 
			.l_led_en(l_led_en), 
			.r_led_en(r_led_en),
			.slow0_fast1(slow0_fast1)
		);
                

assign led = {16{sw[15]}} & {l_mtr_ctrl, r_mtr_ctrl, l_led_en, r_led_en, 4'b0, led_tmp};


clk_divider ( 
				.clk_in(clk_in),
				.clk_8khz(clk_8khz),
				.clk_2hz(clk_2hz)
			);

assign l_blinker = l_led_en && clk_2hz;
assign r_blinker = r_led_en && clk_2hz;


always @(posedge clk_8khz)
	pwm_counter <= pwm_counter + 1'b1;
	
assign slow_pwm_nr[7:0] = (sw[7:0] >> 1);	
assign speed_setting_pwm_dr[7:0] = slow0_fast1 ? sw : slow_pwm_nr ;
	
assign l_mtr_en = (pwm_counter <= speed_setting_pwm_dr) ? ~l_mtr_ctrl : 1'b1;
assign r_mtr_en = (pwm_counter <= speed_setting_pwm_dr) ? ~r_mtr_ctrl : 1'b1;

endmodule