`include "Accumulator.v"
`include "word_gen.v"

/* Module Properties:
 @author Stylianos Tsarsitalidis
 - Test the 3-bit accumulator.
 - Set to (0)000, carry in the parentheses.
 - Test the values 010, 111, 011, 100 (from word_gen) in it.
 */

// Tester module for the Accumulator basic functionality.
module Accumulator_tester ();
    parameter FALSE = 1'b0;
    parameter TRUE = 1'b1;

    integer i;

    reg     clk = 1'b0;

    // Generator vars.
    reg     gen_next;
    wire [2:0] Input;

    //Accumulator vars.
    wire [2:0] Output;
    wire carry;
    reg    reset;

    word_gen my_gen(gen_next, Input);
    accumulator my_acc(clk, reset, Input, Output);

    always begin
	clk <= ~clk; // Accumulation happens on clk.
	#5;
    end

    initial begin
        $dumpfile("Basic_Accumulator_test.vcd");
        $dumpvars(0); // All variables are monitored!
        $display("\t\ttime \tclk\treset\tInput\tOutput");
        $monitor($time, "\t%b\t%b\t%b\t%b", clk, reset, Input, Output);
        i=0;
        reset = FALSE;
        // Set to all zero.
        #10 reset = TRUE;
        #5 reset = FALSE;
        #5
        for (i = 0; i< 4; i = i + 1) begin
            #1 gen_next = FALSE;
            if (i==3) #5 $finish;
            #9 gen_next = TRUE;
        end
        #5 $finish;
    end

endmodule // RAM_basic_tester
