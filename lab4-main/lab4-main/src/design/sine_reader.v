module sine_reader(
    input clk,
    input reset,
    input [19:0] step_size,
    input generate_next,

    output sample_ready,
    output wire [15:0] sample
);
    
    reg[21:0] next_address;
    wire[21:0] current_address;
    
    dffr #(22) sine_dff(
        .clk (clk),
        .r (reset), 
        .d (next_address), .q (current_address)
        );
    
    always @(*) begin
        if (reset) begin
            next_address = 22'd0;
        end else if(generate_next) begin
            next_address = current_address + step_size;
        end else begin
            next_address = current_address;
        end
    end
    wire[9:0] flip_to_rom;
    wire[15:0] rom_to_out;
    
    assign flip_to_rom = current_address[20] ? ~current_address[19:10]
                                                : current_address[19:10];
    
    sine_rom sine_rom1(.clk(clk),
              .addr(flip_to_rom),
              .dout(rom_to_out));
              
    assign sample = current_address[21] ? - rom_to_out : rom_to_out;
    
    wire next_ready;
    wire current_ready;
    
    dffr #(1) sine_dff2(
        .clk (clk),
        .r (reset),
        .d (generate_next), .q (next_ready)
        );
    dffr #(1) sine_dff3(
        .clk (clk),
        .r (reset),
        .d (next_ready), .q (sample_ready)
        );
        
    
    
endmodule
