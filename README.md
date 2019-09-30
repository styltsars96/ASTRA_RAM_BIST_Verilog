# ASTRA RAM BIST in Verilog
Implementation of the ASTRA RAM Bulit-In Self-Test algorithm, and a test bench for it, in verilog.
A marching algorithm as test for a word-organized RAM, based on an accumulator module. The way it works differs from usual self-test scenarios, as the RAM CONTENTS ARE NOT LOST at the end of the operation,
so the system can continue its normal operation at the end of the test. It has lower hardware overhead and less complicated control compared to the schemes proposed in the literature.

# Overview
Files:
* **RAM.v**: The **memory** on which the implementation of ASTRA BIST works.
* **word_gen.v**: A test **words generator**.
* **RAM_tester.v**: **Test bench** for generated words binge written to RAM.
* **Register.v**: Simple registers.
* **RippleCarryAdder.v**: Three-step ripple-carry adder.
* **Accumulator.v**: **Accumulator** composed of an adder and a set of registers.
* **accumulator_tester.v**: **Test bench** for the accumulator using the generator.
* **ACC_RAM_test.v**: **Test bench** for accumulator operation with RAM.
* **ASTRA_RAM_BIST_MAIN_module.v**: The unit that integrates the accumulator and **performs a RAM test based on the ASTRA algorithm** on the connected RAM unit, when the "start" signal is activated.
* **ASTRA_RAM_BIST_top_module.v**: **Test bench**  that connects the RAM to the control unit of the above file, initializes it with the words of the generator and gives a start signal to the main module.

The **ASTRA_RAM_BIST** module tests the connected **RAM_module**. It uses clock to execute the steps.
The sequence starts with the start signal, and the marching output is active while the test is running.
When the process finishes, the marching is disabled and if the test is successful, the success signal is activated.
When the step sequence of the algorithm is not executed, the modules that are integrated as the clock is switched off internally are also disabled.
It has an interface designed specifically for connecting to RAM_module. It integrates an accumulator instance.

# Overall Scheme
A high level view of an example RAM, its contents and the test module are seen bellow:
![alt text](https://github.com/styltsars96/ASTRA_RAM_BIST_Verilog/raw/master/example_overview.jpg "example" )

For the above case, the steps followed are the ones bellow:
![alt text](https://github.com/styltsars96/ASTRA_RAM_BIST_Verilog/raw/master/marching_algorithm.jpg "example_steps" )

# Algorithm Implementation
When the "start" signal is sent, the algorithm starts and the marching signal is activated.
As long as this signal is active, the entire circuit of the module is active.
If the process is already running and start is sent nothing changes so that the test will not stop and the contents of the memory will be corrupted / lost.
The clock given to the module is deactivated if the process is not started, as there is a tri-state buffer with continuous clk assignment, where the marching signal is triggered.
The properties of the algorithm that are remarkable relate to the reuse of the steps.
* With the exception of the first and last marching element, the reverse value is written to the RAM compared to the memory already in place.
* As the algorithm is symmetric, all the steps that need to be changed for each step are the memory address counter at the appropriate time, and when half marching elements are completed this time is reversed.
* In the first step the inverse value accumulator should be fed from the read value.

Based on the above, the algorithm the algorithm is split into 3 "operations" which are coded and kept stored in reg operation.
Code 0 is the memory reading by entering the inverse value in the battery, 1 is memory reading only, and 2 is reading and writing the inverse memory contents.
Note that direction control is separate from operations! To control the read direction, as well as the end of the algorithm, the march_count is kept as a counter whose value corresponds to a marching element, e.g. M0, M1 and so on.
The reading and writing of memory take place separately, but in the same clock cycle a whole step is read (and written, if necessary) of a memory location, and the accumulator is fed, depending on the marching element being performed.
Specifically, because RAM is asynchronous,  Chip-Select and Output-Enable control signals are handled appropriately to read RAM when the clock is in LOW and write (CS and WE) when in HIGH.
Accumulator feeding and memory writing are triggered at the positive edge, while selecting the appropriate operation, changing the memory position, and checks for the end of a marching element or the entire algorithm are triggered at the negative edge.
Reading operation starts at clk==LOW, regardless of when the circuit is triggered with the start signal, so that the test runs correctly and there is no malfunction. For synchronization reasons, there is the START register, which implies that the circuit must reach a negative clock edge to start ("start sequence").
Checks for proper accumulator supply by operation, and whether the process is generally started, are performed with 2 continuous-assignment tri-state buffers.
The end of the marching element is checked when all memory locations have been read, in which case the 2-bit (in this example) counter overflows and returns to the original state it had when the marching element was started. When march_element_done==1, the march element has changed operation and direction. If march_count becomes 6, then the process is over.
**If the accumulator output is 111, the success signal is activated, and all is well...**

Here is an example simulation in gtkwave.
![alt text](https://github.com/styltsars96/ASTRA_RAM_BIST_Verilog/raw/master/gtkwave_example.jpg "gtkwave_example" )
