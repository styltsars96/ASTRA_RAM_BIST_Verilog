`include "RAM.v"
`include "word_gen.v"

/* Module Properties:
 @author Stylianos Tsarsitalidis
 - Basic Test for RAM, nothing related to part 2! (Astra)
 */

// Tester module for the RAM basic functionality.
module RAM_basic_tester ();
    parameter FALSE = 1'b0;
    parameter TRUE = 1'b1;

    // RAM size here (Static)...
    parameter Address_size = 2;
    parameter Word_size = 3;

    // Tester vars.
    integer i;

    // RAM VARS
    reg [Address_size-1:0] ADDRESS;
    wire [Word_size-1:0]   DATA;
    wire [Word_size-1:0]   OUT;
    // RAM Control Pins: Chip Select, Write Enable, Output Enable..
    reg 		   CS, WE, OE; // Only TRUE/high "spikes" are sent.

    reg [Word_size-1:0]    word_reg; // KEEP LAST OUTPUT WORD...

    // Generator vars.
    reg 		   gen_next;

    RAM_module my_RAM(ADDRESS, DATA, OUT, CS, WE, OE);
    word_gen my_gen(gen_next, DATA);

    // EVENTS
    // When there is a word output!
    always @ ( OUT != {Word_size{1'bz}} && CS ) begin
        if (OE) begin
            $display("Entered the block!");
            word_reg <= OUT ;
        end
    end

    initial begin
        $dumpfile("simple_RAM_test.vcd");
        $dumpvars(0); // All variables are monitored!
        $display("\t\ttime \tCS\tWE\tOE\tADDRESS\tDATA\tOUT\tword_reg");
        $monitor($time, "\t%b\t%b\t%b\t%b\t%b\t%b\t%b", CS, WE, OE, ADDRESS, DATA, OUT, word_reg);

        OE = FALSE;
        WE = FALSE;
        CS = FALSE;
        gen_next = FALSE;
        word_reg = {Word_size{1'bx}};
        ADDRESS = {Address_size{1'b0}};
        // MANUAL INSERTION OF VALUES
        for (i = 0; i< Address_size ** 2; i = i + 1) begin
            #3 gen_next = FALSE;
            WE = TRUE;
            CS = TRUE;
            #1 WE = FALSE;
            CS = FALSE;
            #1 ADDRESS++;
            gen_next = TRUE;
        end

        // BASIC OUTPUT OF STORED VALUES
        #5 ADDRESS = {Address_size{1'b0}};
        for (i = 0; i< Address_size ** 2; i = i + 1) begin
            #3 OE = TRUE;
            CS = TRUE;
            #1 OE = FALSE;
            CS = FALSE;
            #1 ADDRESS++;
        end
        #5 $finish;
    end

endmodule // RAM_basic_tester
