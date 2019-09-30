`include "ASTRA_RAM_BIST_MAIN_module.v"
`include "word_gen.v"
`include "RAM.v"

/* Module Properties:
 @author Stylianos Tsarsitalidis
 - Set RAM to have the generated 3-bit words FIRST.
 - DO THE MARCHING ALGORITHM AFTER THIS using ASTRA_RAM_BIST.
 - Route RAM inputs and outputs accordingly.
 */

// Tester module for the ASTRA RAM_BIST.
module ASTRA_RAM_BIST_tester ();
    parameter FALSE = 1'b0;
    parameter TRUE = 1'b1;

    integer i; // For simulation init.

    reg     clk = 1'b0;

    // Generator vars.
    reg        gen_next;
    wire [2:0] DATA_GEN;

    // RAM VARS
    reg [1:0]  ADDRESS; // For manual insertion of contents to RAM.
    wire [1:0] RAM_ADDRESS; // ACTUAL RAM ADDRESS INPUT.
    wire [2:0] DATA;
    wire [2:0] OUT;

    // RAM Control Pins: Chip Select, Write Enable, Output Enable..
    reg        CS, WE, OE; // Only TRUE/high "spikes" are sent. FOR TEST PREP!
    wire       CS_RAM, WE_RAM, OE_RAM; // ACTUAL RAM input.
    wire [2:0] DATA_BIST;

    //BIST VARS
    reg         start;
    wire        MARCHING;
    wire        SUCCESS;
    wire [1:0]  BIST_ADDRESS;
    wire        CS_BIST, WE_BIST, OE_BIST; // RAM CONTROL SOURCE FOR BIST.

    word_gen my_gen(gen_next, DATA_GEN);
    ASTRA_RAM_BIST my_BIST(clk, start, MARCHING, SUCCESS, BIST_ADDRESS,
        DATA_BIST, OUT, CS_BIST, WE_BIST, OE_BIST);
    RAM_module my_RAM(RAM_ADDRESS, DATA, OUT, CS_RAM, WE_RAM, OE_RAM);

    // Select source for RAM ADDRESS.
    assign RAM_ADDRESS = (MARCHING) ? BIST_ADDRESS : ADDRESS;
    // Select source for RAM Control Pins:
    assign CS_RAM = (MARCHING) ? CS_BIST : CS;
    assign WE_RAM = (MARCHING) ? WE_BIST : WE;
    assign OE_RAM = (MARCHING) ? OE_BIST : OE;
    // Select DATA source for RAM:
    assign DATA = (MARCHING) ? DATA_BIST : DATA_GEN;

    always begin
	clk <= ~clk; // Accumulation happens on clk.
	#5;
    end

    initial begin
        $dumpfile("ASTRA_RAM_BIST_test.vcd");
        $dumpvars(0); // All variables are monitored!

        // MANUAL INSERTION OF VALUES TO RAM
        i=0;
        OE = FALSE;
        WE = FALSE;
        CS = FALSE;
        gen_next = FALSE;
        ADDRESS = 2'b00;
        for (i = 0; i< 4; i = i + 1) begin
            #3 gen_next = FALSE;
            WE = TRUE;
            CS = TRUE;
            #1 WE = FALSE;
            CS = FALSE;
            #1 ADDRESS++;
            gen_next = TRUE;
        end
        #10 // Wait...
        //ASTRA RAM BIST TEST
        start = TRUE;
        start = FALSE;
        $display("BIST START INITIATED. :: time is %0t", $time);

        // 4 addresses * 6 March elements = 24 cycles for BIST
        //  + 2 half-cycles, for start and end.
        #250 $display("Simulation STOP. :: time is %0t", $time);
        $finish;
    end

endmodule // RAM_basic_tester
