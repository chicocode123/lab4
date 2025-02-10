module adau1761_codec(
	clk_100,
	reset,
	AC_ADR0,
	AC_ADR1,
	I2S_MISO,
	I2S_MOSI,
	I2S_bclk,
	I2S_LR,
	AC_MCLK,
	AC_SCK,
	AC_SDA,
	hphone_l,
	hphone_r,
	line_in_l,
	line_in_r,
	new_sample
);
	input	clk_100;
	input	reset;

	output	AC_ADR0;
	output	AC_ADR1;

	output	I2S_MISO;
	input	I2S_MOSI;
	input	I2S_bclk;
	input	I2S_LR;

	output	AC_MCLK;
	output	AC_SCK;
	inout	AC_SDA;

	input [23:0] hphone_l;
	input [23:0] hphone_r;
	output [23:0] line_in_l;
	output [23:0] line_in_r;
	output new_sample;

	wire clk_48;
	wire locked;

	wire [23:0] hphone_l1;
	wire [23:0] hphone_r1;
	dffr #(.WIDTH(24)) pipeline_ff_l (.clk(clk_100), .r(reset), .d(hphone_l), .q(hphone_l1));
	dffr #(.WIDTH(24)) pipeline_ff_r (.clk(clk_100), .r(reset), .d(hphone_r), .q(hphone_r1));

	adau1761_izedboard i2c_interface(
		.clk_48(clk_48),
		.AC_GPIO0(I2S_MISO),
		.AC_GPIO1(I2S_MOSI),
		.AC_GPIO2(I2S_bclk),
		.AC_GPIO3(I2S_LR),
		.AC_SDA(AC_SDA),
		.AC_ADR0(AC_ADR0),
		.AC_ADR1(AC_ADR1),
		.AC_MCLK(AC_MCLK),
		.AC_SCK(AC_SCK),
		.hphone_l(hphone_l1),
		.hphone_r(hphone_r1),
		.line_in_l(line_in_l),
		.line_in_r(line_in_r),
		.new_sample(new_sample)
  );

	clocking codec_clock_gen(
		.CLK_100(clk_100),
		.CLK_48(clk_48),
		.RESET(reset),
		.LOCKED(locked)
	);
	
endmodule