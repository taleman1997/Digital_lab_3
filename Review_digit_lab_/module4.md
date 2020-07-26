#  Module 4: Shifting the world

## Aim:

Use the D-type flip flop to create a shift register. The shift register will be implemented in two ways but with the same functionality. Behavioral and structural level in this case.

## Previous of this module

**Shift Register:** A shift Register is a series of flip flops, synchronized to the same clock and connected in series so that the input signal will propagate to the last element of the shift register. And there are basically two ways to achieve that:

1. convert between serial and parallel interface
2. use the ring buffer and the pseudo random number generator 

**Level Abstraction:** There are two levels we can use. Gate level and behavior level. We can use two level to generate the same behavior. The difference between them is the load for synthesis tools. Gate level means using the basic gate logic. It requires effort when write the code while the synthesis tool has a easy task to do.

**Modular design and code reuse:** Modular design means you divide a problem into several part and solve it part by part. Each part can be regard as module. And finally what we need to do just combine them together.

## Time for lab:

### Part1: Structural Level Design:

From the view of structure, the shifting register consists of a series of D-type flip flop. So we can use modular design as we have create the D-type flip flop previously.

**Attention:** As we need to modify the previous module we need to pay attention to the interface list. The last one of interface list is not followed by a comma as we delete the QBAR.

### step1: Module design and code reuse(Generics & Generate Statement)

Just like previous exercise, the clock will be controlled by a slide switch and the input by a push button. Each of the wire that form part of the output 16-bits will be connected to one of the LEDs. Then it looks like

![](C:\Users\taleman\Desktop\Review_digit_lab_\graph\09.png)

It is time consuming and error prone to code them individually. Then we could reuse the previous module **Hello_synchronous_world**. Just copy the source code to our new project. Some points need to be mentioned when transfer the code:

1. Remove the QBAR from the module
2. The last entry in the interface is not followed with comma. For the last one does not need it.
3. Be careful about the 'begin' and 'end' syntax.

Then run the synthesis, then the schematic can as below.

![](C:\Users\taleman\Desktop\Review_digit_lab_\graph\10.png)

### Step2: Create the top module

Create a new module with two inputs and one output. The output get a bus with 15 bits. The input signal is a incoming signal IN and clock signal CLK.

```verilog
module Shift_register(
	input CLK;
	input IN;
	output [15:0] OUT
	);
	// something need to fill in here
endmodule
```

Then we need to transfer the previous module to the top module. Use the code below to fill in the blank.

```verilog
Hello_synchronous_world D0 (.CLK(CLK), .IN(IN), .OUT(OUT));
```

What need to be mentioned is that the D-type flip-flops are series. The output of one should be the input signal of the next. Then the code should like this.

```verilog
module Shift_register(
	input CLK;
	input IN;
	output [15:0] OUT
	);
	
	wire [15:0] W;
	
	Hello_synchronous_world D0 (.CLK(CLK), .IN(IN), .OUT(W[0]));
    Hello_synchronous_world D1 (.CLK(CLK), .IN(W[0]), .OUT(W[1]));
    Hello_synchronous_world D2 (.CLK(CLK), .IN(W[1]), .OUT(W[2]));
    Hello_synchronous_world D3 (.CLK(CLK), .IN(W[2]), .OUT(W[3]));
    Hello_synchronous_world D4 (.CLK(CLK), .IN(W[3]), .OUT(W[4]));
    Hello_synchronous_world D5 (.CLK(CLK), .IN(W[4]), .OUT(W[5]));
    Hello_synchronous_world D6 (.CLK(CLK), .IN(W[5]), .OUT(W[6]));
    Hello_synchronous_world D7 (.CLK(CLK), .IN(W[6]), .OUT(W[7]));
    Hello_synchronous_world D8 (.CLK(CLK), .IN(W[7]), .OUT(W[8]));
    Hello_synchronous_world D9 (.CLK(CLK), .IN(W[8]), .OUT(W[9]));
    Hello_synchronous_world D10 (.CLK(CLK), .IN(W[9]), .OUT(W[10]));
    Hello_synchronous_world D11 (.CLK(CLK), .IN(W[10]), .OUT(W[11]));
    Hello_synchronous_world D12 (.CLK(CLK), .IN(W[11]), .OUT(W[12]));
    Hello_synchronous_world D13 (.CLK(CLK), .IN(W[12]), .OUT(W[13]));
    Hello_synchronous_world D14 (.CLK(CLK), .IN(W[13]), .OUT(W[14]));
    Hello_synchronous_world D15 (.CLK(CLK), .IN(W[14]), .OUT(W[15]));

	assign OUT = W;
endmodule

```

But this code still clumsy, here is a better way:

```verilog
module Shift_register(
	input CLK;
	input IN;
	output [15:0] OUT
	);
	
    wire [16:0] W;
	
	genvar DtypeNo;
	
	generate
        for (DtypeNo = 0; DtypeNo < 16; DtypeNo++)
            begin DtypeInstantiation
                Hello_synchronous_world D (.CLK(CLK), .IN(W[DtypeNo]), .OUT(W[DtypeNo+1]));
            end
    endgenerate

    assign OUT = W[16:1];
    assign W[0] = IN;
endmodule

```

Some points need to be mentioned:

1. The begin and end is necessary in `DtypeInstantiation`.
2. Care about the assign sentence. For the wire we used is different.

Then run the synthesis, and check the schematic. We can see a chain consist by the D-flip-flop.

### Step3: simulation

The testbench is basically same with the previous one. 

### Part 2 Behavior design:

The picture below can explain well:

![](C:\Users\taleman\Desktop\Review_digit_lab_\graph\11.png)

Now we will try to make the same shift register as in the Gate Level section, but this time using behavioral level design principles. Just to recap, we are going to implement a serial in - parallel out shift register. Like the previous exercise, the clock will be controlled by a slide switch, and the input by a push button. Each of the wires that form part of the output 16-bit bus will be connected to one of the LEDs.

And this time registers are used to achieve this :

```verilog
module Shift_reg_behave(
	input CLK;
	input IN;
    output [15:0] OUT;
);
    reg [15:0] DTypes;
    // something here
endmodule
```

And then we can use code like below the achieve the shift

```verilog
module Shift_reg_behave(
	input CLK;
	input IN;
    output [15:0] OUT;
);
    reg [15:0] DTypes;
    
    always@(posedge CLK) begin
        DType[15] <= Dtype[14];
        DType[14] <= Dtype[13];
        DType[13] <= Dtype[12];
        DType[12] <= Dtype[11];
        DType[11] <= Dtype[10];
        DType[10] <= Dtype[9];
        DType[9] <= Dtype[8];
        DType[8] <= Dtype[7];
        DType[7] <= Dtype[6];
        DType[6] <= Dtype[5];
        DType[5] <= Dtype[4];
        DType[4] <= Dtype[3];
        DType[3] <= Dtype[2];
        DType[2] <= Dtype[1];
        DType[1] <= Dtype[0];
        DType[0] <= IN;
    end
    
    assign OUT = DTypes;  
    
endmodule
```

Again, the code above is clumsy. The concentration can help to improve that.

**Concentration:**  The concatenation syntax, '{' '}' combines (concatenates) the bits of two or more signals (registers or wires). The objects may be single bit (like the input 'IN') or multiple bit (like the array of registers 'DTypes'). For example, we could use concatenation syntax, combine elements from a wire bus, a register bus, and constants, and it would only take up a single line of code. Now look at the following arrangement carefully. 

The structure below can be done by `assin OUT =  { 1'b0 , A[7:8], R[0:2], A[1:3] };`

![](C:\Users\taleman\Desktop\Review_digit_lab_\graph\12.png)

Then for the shift register can be done by

```verilog
module Shift_reg_behave(
	input CLK;
	input IN;
    output [15:0] OUT;
);
    reg [15:0] DTypes;
    
    always@(posedge CLK) begin
       DTypes = {DTypes[14:0],IN};
    end
    
    assign OUT = DTypes;  
    
endmodule
```

