/* Module Properties:
 @author Stylianos Tsarsitalidis
 - Adder circuit with ripple carry.
 - It is made of many 1-bit full adders.
 - It can have the carry (re)fed. (the Cin port)
 */

// 1-bit full adder, used in the ripple carry full adder.
module full_adder(input X, input Y, input Cin, output  S, output  Cout);
    wire   w0,w1,w2;

    xor GX0(w0, X, Y);
    xor GX1(S, w0, Cin);
    and GA0(w1, w0, Cin);
    and GA1(w2, X, Y);
    or GO0(Cout, w1, w2);
endmodule

module rippe_carry_adder(input [2:0] X,
			 input [2:0]  Y,
			 input Cin,
			 output [2:0] S,
			 output       Cout);

    wire 			      w0, w1;

    full_adder fa0(X[0], Y[0], Cin, S[0], w0);
    full_adder fa1(X[1], Y[1], w0, S[1], w1);
    full_adder fa2(X[2], Y[2], w1, S[2], Cout);
endmodule
