`define PAUSED    2'b00
`define PLAYING   2'b01
`define NOTE_DONE 2'b10

module song_reader(
    input clk,
    input reset,
    input play,
    input [1:0] song,
    input note_done,
    output reg song_done,
    output reg [5:0] note,
    output reg [5:0] duration,
    output reg new_note
);
    wire [11:0] dout;
    reg [6:0] start;
    
    // for ffs
    wire [1:0] curr_state;
    reg  [1:0] next_state;
    
    wire [6:0] addr;
    reg  [6:0] next_addr;
    
    wire curr_song_done;
    reg  next_song_done;
    
    wire curr_new_note;
    reg  next_new_note;
    
    wire [5:0] curr_note;
    reg  [5:0] next_note;
    
    wire [5:0] curr_duration;
    reg  [5:0] next_duration;
    
    song_rom rom_insta (
        .clk(clk),
        .addr(addr),
        .dout(dout)
    );
    
    // song id
    always @(*) begin
        case(song)
            2'b00 : start = 7'd0;
            2'b01 : start = 7'd32;
            2'b10 : start = 7'd64;
            2'b11 : start = 7'd96;
            default: start = 7'd0;
        endcase
    end

    // state machine
    always @(*) begin
        // Default: hold current values
        next_state     = curr_state;
        next_addr      = addr;
        next_song_done = curr_song_done;
        next_note      = curr_note;
        next_duration  = curr_duration;
        next_new_note  = 0;
        
        if (reset) begin
            next_state     = `PAUSED;
            next_addr      = start; 
            next_song_done = 0;
            next_note      = 6'b000000;
            next_duration  = 6'b000000;
            next_new_note  = 0;
        end else begin
            case (curr_state)
                `PAUSED: begin
                    // start playing if play is asserted.
                    if (play) begin
                        next_state = `PLAYING;
                        next_addr  = start;
                    end
                end
                
                `PLAYING: begin
                    // update the note/duration from the ROM.
                    next_song_done = 0;
                    next_note      = dout[11:6];
                    next_duration  = dout[5:0];
                    // move to NOTE_DONE.
                    if (note_done)
                        next_state = `NOTE_DONE;
                end
                
                `NOTE_DONE: begin
                    // Check if the song is finished.
                    if ((song == 2'b00 && addr == 7'd31) ||
                        (song == 2'b01 && addr == 7'd63) ||
                        (song == 2'b10 && addr == 7'd95) ||
                        (song == 2'b11 && addr == 7'd127)) begin
                        next_song_done = 1;
                        next_state     = `PAUSED;
                    end else begin
                        // Otherwise, move to the next note.
                        next_addr     = addr + 1;
                        next_new_note = 1;
                        next_state    = `PLAYING;
                    end
                end
                
                default: begin
                    next_state = `PAUSED;
                end
            endcase
        end
        
        // Drive outputs from the current registers.
        song_done = curr_song_done;
        note      = curr_note;
        duration  = curr_duration;
        new_note  = curr_new_note;
    end
    
    //Flip-flops
    dffr #(2) state_reg ( //ff1
        .clk(clk),
        .r(reset),
        .d(next_state),
        .q(curr_state)
    );
    
    dffr #(7) addr_reg ( //ff2
        .clk(clk),
        .r(reset),
        .d(next_addr),
        .q(addr)
    );
    
    dffr #(1) song_done_ff ( //ff3
        .clk(clk),
        .r(reset),
        .d(next_song_done),
        .q(curr_song_done)
    );
    
    dffr #(1) new_note_ff ( //ff4
        .clk(clk),
        .r(reset),
        .d(next_new_note),
        .q(curr_new_note)
    );
    
    dffr #(6) note_ff ( //ff5
        .clk(clk),
        .r(reset),
        .d(next_note),
        .q(curr_note)
    );
    
    dffr #(6) duration_ff ( //ff6
        .clk(clk),
        .r(reset),
        .d(next_duration),
        .q(curr_duration)
    );
    
endmodule
