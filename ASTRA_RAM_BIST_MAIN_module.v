`include "Accumulator.v"

/* Module Properties:
 @author Stylianos Tsarsitalidis
 - Module that connects with a RAM module to test it.
 - Is made for testing instances of RAM_module in file RAM.v
 but only connects to one, does not contain the RAM instance.
 - Has an interface for actions.
 - start: Starts the ASTRA BIST march. Fired @posedge clock or before posedge after negedge.
 - marching: TRUE Indicates that the ASTRA BIST module is active and marching is currently underway.
 - success: Default output FALSE. Outputs TRUE after marching (TEST) ends and no error was found.
 If after march ends and accumulator contents aren't all ones, then arrors are found and output remains FALSE.
 - clk: A clock for when to do operations in a synchronous manner.
 - The rest of the inputs and outputs are exactly what a RAM needs to communicate, check RAM.v.
 - Made for RAM with 2-bit address and 3-bit word.
 - Read and Write operations are encoded.
 */

// Accumulator-based Symmetric TRAnsparent RAM BIST module.
module ASTRA_RAM_BIST (
		       // Module Interface:
		       input wire 	in_clk,
		       input wire 	start,
		       output reg 	marching,
		       output reg 	success,
		       // RAM connection points, correspond to RAM pins:
		       output reg [1:0] ADDRESS, // acts as a COUNTER!
		       output reg [2:0] DATA, // The RAM's input, NOT ACC's or ASTRA_RAM_BIST's...
		       input wire [2:0] OUT, // The RAM's output, NOT ACC's or ASTRA_RAM_BIST's...
		       output reg 	CS,
		       output reg 	WE,
		       output reg 	OE
		       );

    parameter FALSE = 1'b0;
    parameter TRUE = 1'b1;

    reg 				reset;  // Resets the accumulator, initializes to 0.
    reg 				direction; // Order of counting: TRUE is ascending, FALSE is descending.
    reg 				march_element_done; // TRUE when Mn march element is done.
	reg 				START;

    wire [2:0] 				acc_in; // Accumulator's input (continuously assigned).
    wire [2:0] 				acc_out; // Accumulator's output (continuously assigned).

	reg [2:0] 				current_RAM_out; // RAM current step ooutput.
	reg [2:0] 				march_count; // The march step M0 until M5.
    reg [1:0] 				operation; // Encodes the read or write operation to be performed on each address.
    // 0 = ((ra)c) or Initial or read the contents of a word of the RAM and feed the complement
    // value to the compressor.
    // 1 = ra or read the contents of a word of the RAM, no compressor input.
    // 2 = rac, wa or ra, wac or Write the complement value of the current RAM address contents to the next address.

	// Clock DISABLED WHEN INACTIVE!
	wire clk;
	assign clk = (marching) ? in_clk : 1'b0;

	accumulator ACC(clk, reset, acc_in, acc_out);

	initial begin
		marching = FALSE;
		START = TRUE;
		success = FALSE;
		current_RAM_out = 3'b111; // Inverse of initial input to the Accumulator.
	end

    always @ ( posedge start ) begin
	if (!marching) begin
		START = TRUE;
        success = FALSE;

        ADDRESS = 2'b00; // Counter init to 00.
        DATA = 3'bzzz; // Data is sent to ram only at appropriate times in march.

        march_count = 3'd0; // First step.
        operation = 2'd0; // Initial operation.
        direction = TRUE; // ascending.
		march_element_done = FALSE;

        // RAM control signals.
        WE = FALSE;
        CS <= FALSE;
        OE = FALSE;

		marching = TRUE;
	end
	end

	// Save the RAM adress contents temporarily, when reading.
	always @ (CS) begin
		if (OE) begin
			current_RAM_out = OUT;
		end
	end

	// negedge = Prepare step, Start Reading RAM.
	// negedge @START = Reset ACC, Start Reading RAM.
	always @ ( negedge clk ) begin
	CS <= FALSE;
	if (!START) begin // NORMAL MARCHING.
		// If writing to RAM, stop.
		WE = FALSE;
		$display("Stop Writing RAM. :: time is %0t", $time);
		// Next address or signal end of Marching element.
		if (direction) begin
			ADDRESS++;
			if(ADDRESS == 2'b00) march_element_done = TRUE; // Overflown, means end.
		end else begin
			ADDRESS--;
			if(ADDRESS == 2'b11) march_element_done = TRUE; // Overflown, means end.
		end
		// Prepare next march element if done.
        if (march_element_done) begin
	    	march_count++;
			march_element_done = FALSE;
            //Set operations
            if (march_count == 3'd0) begin
                operation = 2'd0;
            end else if (march_count < 3'd5) begin
                operation = 2'd2;
            end else begin
                operation =2'd1;
            end

            // Marching count and direction.
            if (march_count < 3'd3) begin
				// Ascending order, starting with min.
				ADDRESS = 2'b00;
                direction = TRUE;
            end else if (march_count < 3'd6) begin
				// Descending order, starting with max.
				ADDRESS = 2'b11;
                direction = FALSE;
            end else begin
                // END OF BIST----------------------------------------------------------:
            	$display("END OF BIST :: time is %0t", $time);
                if (acc_out == 3'b111) begin
                    success = TRUE;
					$display("ASTRA RAM BIST SUCCESSFUL! :: time is %0t", $time);
                end
				marching = FALSE; // Disable the rest of the circuit...
                // but first RESET ASTRA BIST internal state to initial.
				reset = FALSE;

				START = TRUE;

                ADDRESS = 2'b00; // Counter init to 00.
                DATA = 3'bzzz; // Data is sent to ram only at appropriate times in march.

                march_count = 3'd0; // First step.
                operation = 2'd0; // Initial operation.
                direction = TRUE; // ascending.

                // RAM control signals.
                CS <= FALSE;
                OE = FALSE;
                WE = FALSE;
				// ---------------------------------------------------------------------
            end
        end
	end else begin //STARTING SEQUENCE.
		$display("START SEQUENCE ENDED! :: time is %0t", $time);
		START = FALSE;
		// Initialize accumulator to all zeros.
        reset = TRUE;
	end
	if(marching) begin
		$display("Start Reading RAM. :: time is %0t", $time);
		// Read from RAM.
		OE = TRUE;
		CS = TRUE;
		current_RAM_out <= OUT;
	end
	end

	// Feed the correct input to the accumulator.
	assign acc_in = (marching) ?
		(operation == 2'd0) ? ~current_RAM_out : current_RAM_out // For INITIAL OP, complement value to ACC...
		: 3'b000; // No input if not marching!

	// posedge = Write to ACC, and Start Writing to RAM.
	always @ ( posedge clk) begin
	reset = FALSE;
	if (!START) begin
		// Stop Reading RAM.
		OE = FALSE;
		CS <= FALSE;
		$display("Stop Reading RAM. :: time is %0t", $time);
		// !Accumulator operation happens here!----------------------

		if (operation == 2'd2) begin // On the right marching elements...
			// READ RAM Contents, WRITE COMPLEMENT VALUE TO RAM INPUT.
			$display("Start Writing RAM. :: time is %0t", $time);
			DATA = ~current_RAM_out;
			// WRITE TO RAM.
			WE = TRUE;
			CS = TRUE;
		end
	end
	end

endmodule //ASTRA_RAM_BIST
