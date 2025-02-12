module song_reader_tb();

    reg clk, reset, play, note_done;
    reg [1:0] song;
    wire [5:0] note;
    wire [5:0] duration;
    wire song_done, new_note;

    song_reader dut(
        .clk(clk),
        .reset(reset),
        .play(play),
        .song(song),
        .song_done(song_done),
        .note(note),
        .duration(duration),
        .new_note(new_note),
        .note_done(note_done)
    );

    // Clock and reset
    initial begin
        clk = 1'b0;
        reset = 1'b1;
        repeat (4) #5 clk = ~clk;
        reset = 1'b0;
        forever #5 clk = ~clk;
    end

    // Tests
    initial begin
    song = 01;
    play = 1;
    note_done = 0;
    #40 note_done = 1;
    #10 note_done = 0;
    #15
    repeat (32) begin
    $display("Addr %d %d", note, duration); // note, duration 0-31
    #30 note_done = 1;
    #10 note_done = 0;
    end
    #50
    $display("Song Done: %d", song_done);
    $display("---Next Song---");
    song = 2'b10;
    repeat (33) begin
    $display("Addr %d %d", note, duration); // note, duration 1-32
    #30 note_done = 1;
    #10 note_done = 0;
    end
    play = 0;
    end
endmodule





