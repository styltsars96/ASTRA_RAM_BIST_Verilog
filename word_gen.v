/* Module Properties:
 @author Stylianos Tsarsitalidis
 - A TEST PATTERN GENERATOR, following the given instructions.
 - Generate test values for word, on gen_next signal.
 */

module word_gen (gen_next, word);
    parameter Word_size = 3;

    input wire gen_next;
    output wire [Word_size-1:0] word;
    reg [1:0] 			count = 2'b00;

    // Select a word to continuously assign as a test value!
    assign word = (count == 2'b00) ? 3'b010 :
		  (count == 2'b01) ? 3'b111 :
		  (count == 2'b10) ? 3'b011 :
		  (count == 2'b11) ? 3'b100 :
		  {Word_size{1'bz}};

    always @ ( posedge gen_next ) begin
        count = count + 1;
    end

endmodule // word_gen
