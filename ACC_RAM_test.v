`include "Accumulator.v"
`include "word_gen.v"
`include "RAM.v"

/* Module Properties:
 @author Stylianos Tsarsitalidis
 - Test the 3-bit accumulator on RAM contents.
 - Set accumulator to 000(0).
 - Set RAM to have the generated values.
 - Test the values 010, 111, 011, 100 (from word_gen) in it.
 */

// Tester module for the Accumulator's functionality on RAM's contents.
module Accumulator_for_RAM_tester ();
    parameter FALSE = 1'b0;
    parameter TRUE = 1'b1;

    integer i;

    reg     clk = 1'b0;

    // Generator vars.
    reg     gen_next;

    //Accumulator vars.
    wire [2:0] Output;
    wire       carry;
    reg        reset;

    // RAM VARS
    reg [1:0]  ADDRESS;
    wire [2:0] DATA;
    wire [2:0] OUT;
    // RAM Control Pins: Chip Select, Write Enable, Output Enable..
    reg        CS, WE, OE; // Only TRUE/high "spikes" are sent.

    word_gen my_gen(gen_next, DATA);
    RAM_module my_RAM(ADDRESS, DATA, OUT, CS, WE, OE);
    accumulator my_acc(clk, reset, OUT, Output);

    always begin
	clk <= ~clk; // Accumulation happens on clk.
	#5;
    end

    initial begin
        $dumpfile("Accumulator_RAM_test.vcd");
        $dumpvars(0); // All variables are monitored!
        // $display("\t\ttime \tclk\treset\tInput\tOutput");
        // $monitor($time, "\t%b\t%b\t%b\t%b", clk, reset, Input, Output);
        i=0;
        OE = FALSE;
        WE = FALSE;
        CS = FALSE;
        gen_next = FALSE;
        reset = FALSE;

        ADDRESS = 2'b00;
        // MANUAL INSERTION OF VALUES TO RAM
        for (i = 0; i< 4; i = i + 1) begin
            #3 gen_next = FALSE;
            WE = TRUE;
            CS = TRUE;
            #1 WE = FALSE;
            CS = FALSE;
            #1 ADDRESS++;
            gen_next = TRUE;
        end

        // Set accumulator to all zero.
        #10 reset = TRUE;
        #5 reset = FALSE;
        #5 ADDRESS = 2'b00;
        OE = TRUE;
        CS = TRUE;
        // START USING VALUES FROM RAM IN ACCUMULATOR.
        for (i = 0; i< 4; i = i + 1) begin
            #5 if(i == 3) begin
                #5 OE = FALSE;
                CS = FALSE;
		        $finish;
            end
            #5 ADDRESS++;
            CS = FALSE;
            CS = TRUE;
        end
        #5 $finish;
    end

endmodule // RAM_basic_tester
