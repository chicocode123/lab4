`define PAUSE 2'b00
`define PLAY 2'b01
`define NEXT 2'b10

module mcu(
    input clk,
    input reset,
    input play_button,
    input next_button,
    output play,
    output reset_player,
    output [1:0] song,
    input song_done
);
    reg play_temp, reset_player_temp;
    reg [1:0] song_temp;
    wire [1:0] current_state;
    reg [1:0] next_state;    
    
    reg playing;
    wire play_cur;
    
    assign reset_player = (next_button || song_done || reset) ? 1'b1 : 1'b0;
 
    dffr #(2) song_reg (
        .clk(clk),
        .r(reset),
        .d(song_temp),
        .q(song)
    );
   
    always @(*) begin
        if (reset) begin
            song_temp = 2'b00;
        end else if (next_button || song_done) begin
            song_temp = song +1;
        end else begin
            song_temp = song;
        end
    end
    
    dffr #(1) play_reg (
        .clk(clk),
        .r(reset),
        .d(playing),
        .q(play)
    );
  
    always @(*) begin
        if (reset) begin
            playing = 1'b0;
        end else if (play_button) begin
            playing = play + 1;
        end else if (next_button || song_done) begin
            playing = 1'b0;
        end else begin
            playing = play;
        end
    end
  
   
    
    
    
   
endmodule
