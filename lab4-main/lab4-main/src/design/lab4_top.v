module lab4_top(
    // System Clock (125MHz)
    input sysclk,

    // ADAU1761 interface
    output  AC_ADR0,            // I2C Address pin (DO NOT CHANGE)
    output  AC_ADR1,            // I2C Address pin (DO NOT CHANGE)

    output  AC_DOUT,           // I2S Signals
    input   AC_DIN,           // I2S Signals
    input   AC_BCLK,           // I2S Byte Clock
    input   AC_WCLK,           // I2S Channel Clock

    output  AC_MCLK,            // Master clock (48MHz)
    output  AC_SCK,             // I2C SCK
    inout   AC_SDA,             // I2C SDA

    // Push button interface
    input [2:0] btn,

    // LEDs
    output wire [2:0] leds_rgb_0,
    output wire [2:0] leds_rgb_1,
    output wire [3:0] leds
);
    // button_press_unit's WIDTH parameter is exposed here so that you can
    // reduce it in simulation.  Setting it to 1 effectively disables it.
    parameter BPU_WIDTH = 20;
    // The BEAT_COUNT is parameterized so you can reduce this in simulation.
    // If you reduce this to 100 your simulation will be 10x faster.
    parameter BEAT_COUNT = 1000;

    // Our reset
    wire reset = btn[2];
    wire play_button = btn[1];
    wire next_button = btn[0];

    // Clock converter
    wire clk_100;
    wire LED0;      // TODO: assign this to a real LED
 
    clk_wiz_0 U2 (
        .clk_out1(clk_100),     // 100 MHz
        .reset(reset),
        .locked(LED0),
        .clk_in1(sysclk)
    );


//
//  ****************************************************************************
//      Button processor units
//  ****************************************************************************
//
    wire play;
    button_press_unit #(.WIDTH(BPU_WIDTH)) play_button_press_unit(
        .clk(clk_100),
        .reset(reset),
        .in(play_button),
        .out(play)
    );

    wire next;
    button_press_unit #(.WIDTH(BPU_WIDTH)) next_button_press_unit(
        .clk(clk_100),
        .reset(reset),
        .in(next_button),
        .out(next)
    );

//
//  ****************************************************************************
//      The music player
//  ****************************************************************************
//
    wire new_frame, new_frame1;
    wire [15:0] codec_sample;
    wire new_sample;
    music_player #(.BEAT_COUNT(BEAT_COUNT)) music_player(
        .clk(clk_100),
        .reset(reset),
        .play_button(play),
        .next_button(next),
        .new_frame(new_frame1),
        .sample_out(codec_sample),
        .new_sample_generated(new_sample)
    );

//
//  ****************************************************************************
//      Codec interface
//  ****************************************************************************
//
    // Output the sample onto the LEDs for the fun of it.
    assign leds_rgb_0 = codec_sample[15:13];
    assign leds_rgb_1 = codec_sample[11:9];
    assign leds = codec_sample[15:12];

    wire [23:0] hphone_r = 0;
    wire [23:0] line_in_l = 0;
    wire [23:0] line_in_r = 0;

    dffr pipeline_ff_new_frame (.clk(clk_100), .r(reset), .d(new_frame), .q(new_frame1));

	// INST_TAG
    adau1761_codec adau1761_codec(
        .clk_100(clk_100),
        .reset(reset),
        .AC_ADR0(AC_ADR0),
        .AC_ADR1(AC_ADR1),
        .I2S_MISO(AC_DOUT),
        .I2S_MOSI(AC_DIN),
        .I2S_bclk(AC_BCLK),
        .I2S_LR(AC_WCLK),
        .AC_MCLK(AC_MCLK),
        .AC_SCK(AC_SCK),
        .AC_SDA(AC_SDA),
        .hphone_l({codec_sample, 8'h00}),
        .hphone_r(hphone_r),
        .line_in_l(line_in_l),
        .line_in_r(line_in_r),
        .new_sample(new_frame)
    );
endmodule
