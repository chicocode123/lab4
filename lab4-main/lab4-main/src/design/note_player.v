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
    
    dffr #(6) note_player_dff(
        .clk (clk),
        .r (reset),
        .d (time_next), .q (cur_time)
        );
    
    assign done_with_note = ((cur_time == 6'd0) && (beat)) ? 1'b1: 1'b0;
    
    always @(*) begin
        if (reset || done_with_note) begin
            time_next = duration_to_load;
        end else if (load_new_note) begin
            time_next = duration_to_load;         
        end else if (play_enable && beat) begin
            time_next = cur_time -1;
        end else begin   
            time_next = cur_time;
        end
    end
    
    wire[19:0] rom_to_sine_reader;
    
    wire[5:0] player_to_rom;
    
    
   
    reg [5:0] next_note;
    wire [5:0] cur_note;
    
    dffr #(6) note_dff(
        .clk (clk),
        .r (reset),
        .d (next_note), .q (cur_note)
        );
    
    always@(*) begin
        if (reset || load_new_note) begin
            next_note = note_to_load;
        end else begin
            next_note = cur_note;
        end
    end
    
    
    
    frequency_rom note_player_insta1(
                        .clk(clk),
                        .addr(cur_note),
                        .dout(rom_to_sine_reader));
   
    wire[15:0] sine_reader_to_out;
    
    wire sample_sine_reader =1'b0;
    
    sine_reader note_player_insta(
                    .clk(clk),
                    .reset(reset),
                    .step_size(rom_to_sine_reader),
                    .generate_next(generate_next_sample),
                    .sample_ready(new_sample_ready),
                    .sample(sine_reader_to_out));
    
 
    
   assign sample_out = play_enable ? sine_reader_to_out: 16'd0;
    
   
    
  
endmodule
    


