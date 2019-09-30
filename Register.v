/* Module Properties:
 @author Stylianos Tsarsitalidis
 - Uses 3 D-flip-flops.
 - Each D Flip Flop can be reset asynchronously.
 - All sequential modules have non-blocking assignment (Verilog)!
 - A simple register module.
 */

// Positive edge D flip flop with Asynchronous Reset @High
module D_FlipFlop(input D, // Data input
		  input      clk, // clock input
		  input      async_reset, // asynchronous reset @High
		  output reg Q // Q output
		  );

    always @(posedge clk or posedge async_reset)
      begin
	  if(async_reset==1'b1)
	    Q <= 1'b0;
	  else
	    Q <= D;
      end
endmodule

// The three bit register.
module three_bit_reg( input clk,
		      input 	   reset,
		      input [2:0]  in,
		      output [2:0] out
		      );

	wire [2:0]  _in;

    D_FlipFlop DFF0(in[0], clk, reset, out[0]);
    D_FlipFlop DFF1(in[1], clk, reset, out[1]);
    D_FlipFlop DFF2(in[2], clk, reset, out[2]);

endmodule //three_bit_reg
