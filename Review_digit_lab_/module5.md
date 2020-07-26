# module5 Shift many worlds

## Aims 

1. Create a 4-bit wide 16-bit deep shift register
2. Only finish the simulation

## Preview of the lab

**2-dimensional arrays** : In this module, a 4-bit wide, 16-bit deep array will be created.

## Lab time

### Step1: Create a new project:

In this project, set the input and output as below:

```verilog
module 2D-shift(
	input CLK,
    input [3:0] IN,
    output [3:0] OUT_0,
    output [3:0] OUT_1,
    output [3:0] OUT_2,
    output [3:0] OUT_3,
    output [3:0] OUT_4,
    output [3:0] OUT_5,
    output [3:0] OUT_6,
    output [3:0] OUT_7,
    output [3:0] OUT_8,
    output [3:0] OUT_9,
    output [3:0] OUT_10,
    output [3:0] OUT_11,
    output [3:0] OUT_12,
    output [3:0] OUT_13,
    output [3:0] OUT_14,
    output [3:0] OUT_15,

);
    reg [3:0] DType [15:0]; // means 4-bit wide 16-bit deep 
endmodule
```

And then tie the output to each registers in the 2-D array. And use sensitive list to describe the action of the register 

```verilog
module 2D-shift(
	input CLK,
    input [3:0] IN,
    output [3:0] OUT_0,
    output [3:0] OUT_1,
    output [3:0] OUT_2,
    output [3:0] OUT_3,
    output [3:0] OUT_4,
    output [3:0] OUT_5,
    output [3:0] OUT_6,
    output [3:0] OUT_7,
    output [3:0] OUT_8,
    output [3:0] OUT_9,
    output [3:0] OUT_10,
    output [3:0] OUT_11,
    output [3:0] OUT_12,
    output [3:0] OUT_13,
    output [3:0] OUT_14,
    output [3:0] OUT_15,

);
    reg [3:0] DType [15:0]; // means 4-bit wide 16-bit deep
    
    always@(posedge CLK) begin
        Dtype[15] <= Dtype[15]
        Dtype[14] <= Dtype[14]
        Dtype[13] <= Dtype[13]
        Dtype[12] <= Dtype[12]
        Dtype[11] <= Dtype[11]
        Dtype[10] <= Dtype[10]
        Dtype[9] <= Dtype[9]
        Dtype[8] <= Dtype[8]
        Dtype[7] <= Dtype[7]
        Dtype[6] <= Dtype[6]
        Dtype[5] <= Dtype[5]
        Dtype[4] <= Dtype[4]
        Dtype[3] <= Dtype[3]
        Dtype[2] <= Dtype[2]
        Dtype[1] <= Dtype[1]
        Dtype[0] <= IN
        
    end
    assign OUT_0 = DType[0];
    assign OUT_1 = DType[1];
    assign OUT_2 = DType[2];
    assign OUT_3 = DType[3];
    assign OUT_4 = DType[4];
    assign OUT_5 = DType[5];
    assign OUT_6 = DType[6];
    assign OUT_7 = DType[7];
    assign OUT_8 = DType[8];
    assign OUT_9 = DType[9];
    assign OUT_10 = DType[10];
    assign OUT_11 = DType[11];
    assign OUT_12 = DType[12];
    assign OUT_13 = DType[13];
    assign OUT_14 = DType[14];
    assign OUT_15 = DType[15];

        
endmodule
```

It should mention that, in this part, the code may seems clumsy, but it can not use concatenation to simplify the problem. It should be notice that Verilog is not a programming language but a description language. We design the circuit but not 

### Step2: synthesis, simulation

The simulation code is as below

```verilog
module Shift_reg2D(
);

    reg [3:0] IN;
    reg CLK;
    wire [3:0] OUT_0;
    wire [3:0] OUT_1;
    wire [3:0] OUT_2;
    wire [3:0] OUT_3;
    wire [3:0] OUT_4;
    wire [3:0] OUT_5;
    wire [3:0] OUT_6;
    wire [3:0] OUT_7;
    wire [3:0] OUT_8;
    wire [3:0] OUT_9;
    wire [3:0] OUT_10;
    wire [3:0] OUT_11;
    wire [3:0] OUT_12;
    wire [3:0] OUT_13;
    wire [3:0] OUT_14;
    wire [3:0] OUT_15;
    
    // instantiate shift_reg2D
    Shift_reg2D uut(
        .IN(IN),
        .CLK(CLK),
        .OUT_0(OUT_0),
        .OUT_1(OUT_1),
        .OUT_2(OUT_2),
        .OUT_2(OUT_2),
        .OUT_4(OUT_4),
        .OUT_5(OUT_5),
        .OUT_6(OUT_6),
        .OUT_7(OUT_7),
        .OUT_8(OUT_8),
        .OUT_9(OUT_9),
        .OUT_10(OUT_10),
        .OUT_11(OUT_11),
        .OUT_12(OUT_12),
        .OUT_13(OUT_13),
        .OUT_14(OUT_14),
        .OUT_15(OUT_15),
    );
    
    //Create the clock
    initial begin
        CLK = 0;
        forever #50 CLK = ~CLK;
    end
    
    initial begin
        IN = 0;
        #100
        #100 IN = 1;
        #100 IN = 2;
        #100 IN = 3;
        #100 IN = 4;
    end
    
endmodule
```

