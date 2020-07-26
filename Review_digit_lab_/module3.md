# Module3: Hello Synchronous World

## Aims:

Implement a single D-type flip-flop using the synchronous module design. In this module, synchronous logic and the sensitivity list will be introduced as with as corresponding syntax.

## Previous about lab:

**Synchronous logic:** Synchronous logic involves the use of registers that hold a signal state during clock cycles. The output of registers can change only at specific times during the clock cycle, the rising or falling edge.

**D-type flip flop:** The output of D only change when the clock edge changed.

![](C:\Users\taleman\Desktop\Review_digit_lab_\graph\08.png)

**The function of `always@`:**  The sensitivity list is contained within the brackets of the `always@(...)` syntax. The statement within the begin and end is only executed if the signals with the bracket change.  It should  be notice that the `always` code must have begin and end.

```verilog
always@(poseedge CLK) begin:
	OUT <= IN;
	OUTBAR <= ~IN;
end
```

**The difference between wire and reg:** 

1. Wire derives their value from their connection and do not have an internal state. It is often used in continuous assignment. When define inputs or outputs in a module, all the inputs and outputs are wire by default. If the wire is undriven, the value is regarded as Z(high impedance) in simulation.
2. Reg, means register as mention previously. It has an internal state so it can hold their value between simulation time slices. Therefore, a signal within a `always@()` statement must be define as a register.

## Time for lab:

## Step 1: create a project with the purpose name

It should be notice that the inputs and outputs should be defined properly. Inputs: CLK,IN. Outputs: Q, QBAR.

## Step2: write the source code

It should be notice that the value of "IN" will be assign to the "Q". Then we need to define the "Q" as reg.

## Step3: Synthesis

When look at the Technology Schematic, it is obvious hat there are two flip flops. The reason is that FPGA does not include D-types with two outputs. So two flip flops are required to produce Q and QBAR.

## Stpe4: Simulation

**Instantiation:** 

1. At the beginning of the instantiation, the name of module that we want to instantiate need to be done, followed by a unique name for instantiation.

2. The next step is to connect the interface signals to the module to those of the current module.

3. After instantiation,there will create a hierarchy. That means what we want to instantiate is below testbench

4. Then in the testbench we need to create a clock signal.

   ```verilog
   initial begin 
   	clk = 0;
   	forever #100 clk = ~clk;  // 'forever' means repeat forever
   end
   ```

   From the simulation figure, we can derive that signal "Q" and "QBAR" only change when the clock is on the rising edge.

## Step5: Design Constraints

In XDC file, the input signal need to connect with the push button and the output to the LED and tie the clock to the slide switch. After that the code below is needed

```verilog
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets CLK_IBUF]
```

Because what we use "clk" here is not a physical clock inside the board we use the slide switch to replace the actual clock.

## Outcome

After generating the bitstream then play the board. The switch back and forth to act as clk and use the button like input signal. Then the change in output LEDs can be observed.

