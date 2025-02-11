module note_player(
    input clk,
    input reset,
    input play_enable,  // When high we play, when low we don't.
    input [5:0] note_to_load,  // The note to play
    input [5:0] duration_to_load,  // The duration of the note to play
    input load_new_note,  // Tells us when we have a new note to load
    output done_with_note,  // When we are done with the note this stays high.
    input beat,  // This is our 1/48th second beat
    input generate_next_sample,  // Tells us when the codec wants a new sample
    output [15:0] sample_out,  // Our sample output
    output new_sample_ready  // Tells the codec when we've got a sample
);

    // Implementation goes here!
    reg[5:0] time_next;
    wire[5:0] cur_time;
    
    dffre #(6) note_player_dff(
        .clk (clk),
        .r (reset), .en(beat),
        .d (time_next), .q (cur_time)
        );
    
    reg timer_done = 1'b0;
    
    always @(*) begin
        if (reset || (load_new_note && timer_done) || generate_next_sample) begin
            time_next = duration_to_load;
            timer_done = 1'b0;
        end else if (play_enable) begin
            timer_done = 1'b0;
            time_next = cur_time -1;
        end else if(cur_time == 0) begin
            timer_done =1'b1;
            time_next = cur_time;
        end
    end
    
    wire[19:0] rom_to_sine_reader;
    
    
    frequency_rom note_player_insta1(
                        .clk(clk),
                        .addr(note_to_load),
                        .dout(rom_to_sine_reader));

    sine_reader note_player_insta(
                    .clk(clk),
                    .reset(reset),
                    .step_size(rom_to_sine_reader),
                    .generate_next(generate_next_sample),
                    .sample_ready(new_sample_ready),
                    .sample(sample_out));
    
    assign done_with_note = timer_done;
    
  
endmodule
