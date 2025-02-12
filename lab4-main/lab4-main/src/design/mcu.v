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
    reg play_temp;
    reg reset_player_temp;
    reg [1:0] song_temp;
    wire [1:0] current_state;
    reg [1:0] next_state;    
    
    dffr #(2) state_reg (
        .clk(clk),
        .r(reset),
        .d(next_state),
        .q(current_state)
    );

    always @(*) begin
        reset_player_temp = (next_button || song_done);

        if (reset) begin
            song_temp = 2'b00;
        end else if (play_button) begin
            next_state = (current_state == `PAUSE || `NEXT) ? `PLAY : `PAUSE;
        end else if (next_button || song_done) begin
            next_state = `NEXT;
        end else if (current_state == `PLAY) begin
            play_temp = 1;
        end else if (current_state == `PAUSE) begin
            play_temp = 0;
        end else if (current_state == `NEXT) begin
            song_temp = song_temp + 1;
            play_temp = 0;
        end else begin
            next_state = current_state;
        end
    end
        
    assign play = play_temp;
    assign reset_player = reset_player_temp;
    assign song = song_temp;
endmodule
