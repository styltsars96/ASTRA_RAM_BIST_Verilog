`include "RippleCarryAdder.v"
`include "Register.v"

/* Module Properties:
 @author Stylianos Tsarsitalidis
 - Acumulator for 3 bit input.
 - Is comprized of Ripple Carry adder and Register.
 - Reset effectively makes it all zeros.
 - Output is the accumulator contents themselves.
 - Carry is fed back to the adder at the next stage.
 */

module accumulator (
            input wire clk,
            input wire reset,
		    input wire [2:0] content,
		    output [2:0]     acc
		    );

    wire [2:0] forward;
    reg carry_in;
    wire carry_out;

    initial begin
        carry_in = 1'b0;
    end

    rippe_carry_adder my_adder(content, acc, carry_in, forward, carry_out);
    three_bit_reg my_reg(clk, reset, forward, acc);

    always @ ( posedge clk or posedge reset) begin
        if (reset) begin
            carry_in <= 1'b0;
        end else begin
            carry_in <= carry_out;
        end
    end

endmodule //accumulator
