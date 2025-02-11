module mcu_tb();
    reg clk, reset, play_button, next_button, song_done;
    wire play, reset_player;
    wire [1:0] song;

    mcu dut(
        .clk(clk),
        .reset(reset),
        .play_button(play_button),
        .next_button(next_button),
        .play(play),
        .reset_player(reset_player),
        .song(song),
        .song_done(song_done)
    );

    // Clock and reset
    initial begin
        clk = 1'b0;
        reset = 1'b1;
        repeat (4) #5 clk = ~clk;
        reset = 1'b0;
        forever #5 clk = ~clk;
    end

    
    initial begin
    next_button = 0; // Initializing everything to 0
    play_button = 0;
    song_done = 0;
    
    #20
    play_button = 1; // Playing song 1
    #10 play_button = 0;
    
    #405
    next_button = 1; // Next to song 2
    #10 next_button = 0;
    
    #100
    play_button = 1; // Playing song 2
    #10 play_button = 0;
    
    #400
    song_done = 1; // Song 2 Finishes so move to song 3
    #10 song_done = 0;
    
    #100
    play_button = 1; // Play song 3
    #10 play_button = 0;
    
    #400
    song_done = 1; // Song 3 is done move to song 4
    #10 song_done = 0;
    
    #100
    play_button = 1; // play song 4
    #10 play_button = 0;
    
    #400
    song_done = 1; // song 4 done, move back to start
    #10 song_done = 0;
    
    #100
    play_button = 1; // playing (should be song 1)
    #10 play_button = 0;
    end

endmodule
