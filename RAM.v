/* Module Properties:
 @author Stylianos Tsarsitalidis
 - An asynchronous RAM module.
 - 3 bits word.
 - 4 addresses -> 2-bit address.
 - ADDRESS is the address bus input.
 - DATA is the data bus input.
 - OUT is the data bus output.
 - CS = Chip Select: Any operation is conducted only when HIGH.
 - AT LEAST SPIKE ON CS NECESSARY FOR ADDRESS BUS CHANGE.
 - WE = Write Enable: HIGH = write DATA input to the specified ADDRESS.
 - OE = Output Enable: HIGH = OUTput the contents of the specified ADDRESS.
 */

// Basic RAM module.
module RAM_module (ADDRESS, DATA, OUT, CS, WE, OE);

    // RAM size here (Static)...
    parameter Address_size = 2;
    parameter Word_size = 3;

    input [Address_size-1:0] ADDRESS;
    input [Word_size-1:0]    DATA;
    output [Word_size-1:0]   OUT;
    // RAM Control Pins: Chip Select, Write Enable, Output Enable...
    input 		     CS, WE, OE;


    // The memory, array of multi-bit registers, itself.
    reg [Word_size-1:0]      Mem [0:(1<<Address_size)-1];

    // Variable to hold the registered read address
    reg [Address_size-1:0]   addr_reg;

    // Send output when output enabled.
    assign OUT = (CS && OE) ?  Mem[addr_reg] : {Word_size{1'bz}};

    always @(CS) begin
	if (WE) begin
            Mem[ADDRESS] = DATA;
            $display("%b, address: %b", Mem[ADDRESS], ADDRESS);
	end
	addr_reg = ADDRESS;
    end

    always @(WE or OE)
      if (WE && OE) $display("Notice: OE and WE both HIGH");

endmodule
