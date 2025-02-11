`define PAUSE 2'b00
`define PLAY 2'b01
`define NEXT 2'b10

module mcu(
    input clk,
    input reset,
    input play_button,
    input next_button,
    output reg play,
    output reg reset_player,
    output reg [1:0] song,
    input song_done
);

    wire [1:0 ]current_state;
    reg [1:0] next_state;    
    
    dffr #(2) state_reg (
        .clk(clk),
        .r(reset),
        .d(next_state),
        .q(current_state)
    );
    always @(*) begin
        if (reset) begin
            song = 2'b00;
        end
    end
    always @(*) begin
        reset_player = (next_button || song_done);

        if (play_button) begin
            next_state = (current_state == `PAUSE || `NEXT) ? `PLAY : `PAUSE;
        end else if (next_button || song_done) begin
            next_state = `NEXT;
        end else begin
            next_state = current_state;
        end
    end
    
    always @(*) begin
        case (current_state)
            `PLAY : begin
                play = 1;
            end
            `PAUSE : begin
                play = 0;
            end
            `NEXT : begin
                song = song + 1;
                play = 0;
                next_state = `PAUSE;
            end
            default : begin
                play = 0;
            end
        endcase
    end
endmodule
