# Module8: Decoding the World

## Aim 

Use 2 methods to built a 7-segments display decoder by using Boolean expression and case statement.

## Preview:

1. **Number Representation:**

   There are two ways of defining values. The first is Hexadecimal and the second is Binary. The following syntax can be used:

   ```verilog
   [number of bit] ' [type of number] [array of numbers of the appropriate type]
   ```

   For example, a four bit value of '1101' could be written as:

   4'b1101 or 4'hD or 4'd13

2. 7-segments display.

   There are 12 wires control the entire behavior of all four 7-segment display. AN0(AN1, AN2, AN3) controls which digit will be light up. All the LED's anodes are tied together but the LED cathodes remain separate.

   ![](C:\Users\taleman\Desktop\Review_digit_lab_\graph\14.png)

   **Attention:** As the anodes of the LED are tied together, logic '0' turns LED on.



## Time for lab

### Stpe1: Create a new project as below:

```verilog
module Decoding_the_world(


    input [1:0] SEG_SELECT_IN,
    input [3:0] BIN_IN,
    input DOT_IN,
    output [3:0] SEG_SELECT_OUT,
    output [7:0] HEX_OUT
     
);
```

### Step2: create the decoder

The figure below illustrate the segment display of 0-F

![](C:\Users\taleman\Desktop\Review_digit_lab_\graph\15.png)

For example, the top middle bit(called CA) will light up for the hexadecimal numbers: 0,2.3,5,6,7,8,9,A,C,E,F. So it is possible to use Karnaugh map to derive the Boolean expression that will correctly determine if an elelement should be on or off for each of the hexadecimal numbers

The Karnaugh map is as below:

![](C:\Users\taleman\Desktop\Review_digit_lab_\graph\16.png)

Then it allow us to derive all the Boolean expression from CA to CG.
$$
CA = \overline A  B \overline C \overline D + \overline A \overline B \overline C  D + \overline A  B  C  D +  A  B  C \overline D \\
CB = \overline B C D + \overline A B \overline C D + A B C + A \overline B  D \\
CC = \overline B C D + A C D + A \overline B \overline C \overline D \\
CD = \overline A \overline B \overline C D + \overline A B \overline D + A B D + A \overline B C \overline D \\
CE = \overline A \overline C D + \overline B C  + \overline A B \overline D \\
CF =  A  B \overline C  +  B \overline C \overline D +  A \overline C \overline D + \overline A  B  C  D \\
CG = \overline A \overline C \overline D + A B \overline C D + \overline A \overline B C D \\
$$
Then transfer it to the code:

```verilog
module Decoding_the_world(


    input [1:0] SEG_SELECT_IN,
    input [3:0] BIN_IN,
    input DOT_IN,
    output [3:0] SEG_SELECT_OUT,
    output [7:0] HEX_OUT
     
);
    wire A, B, C, D;
    // careful about the sequence of the BACD
    assign B = Bin_IN[0];
    assign A = Bin_IN[1];
    assign C = Bin_IN[2];
    assign D = Bin_IN[3];
    
    // logic of 4-bit input to 8-bit segment display.
    assign HEX_OUT[0] = ((~A)&B(~C)&(~D))|((~A)&(~B)(~C)&D)|((~A)&B&C&D)|(A&B&C(~D));
    assign HEX_OUT[1] = ((~B)&C&D)|((~A)&B&(~C)&D)|(A&B&C)|(A&(~B)&D);
    assign HEX_OUT[2] = ((~B)&C&D)|(A&C&D)|(A&(~B)&(~C)&(~D);
    assign HEX_OUT[3] = (~A)&(B)(~C)&D)|((~A)&B&(~D))|(A&B&D)|(A&(~B)&C(~D);
    assign HEX_OUT[4] = (~A)&(~C)&D)|(B&(~C)|(~A)&B&(~D);
    assign HEX_OUT[5] = (A&B&(~C))|(B&(~C)&(~D))|(A&(~C)&(~D))|((~A)&B&C&D);
    assign HEX_OUT[6] = ((~A)&(~C)&(~D))|(A&B&(~C)&D)|((~A)&(~B)&C&D);
    assign HEX_OUT[7] = DOT_IN;
```

Then SEG_SELECT_IN is used to control which digit should be chosen. It should be notice that it is a 2-bit signal input and SEG_SELECT_OUT is a 4-bit output. Then add the code as below:

```verilog
module Decoding_the_world(


    input [1:0] SEG_SELECT_IN,
    input [3:0] BIN_IN,
    input DOT_IN,
    output [3:0] SEG_SELECT_OUT,
    output [7:0] SEG_HEX_OUT
     
);
    wire A, B, C, D;
    // careful about the sequence of the BACD
    assign B = Bin_IN[0];
    assign A = Bin_IN[1];
    assign C = Bin_IN[2];
    assign D = Bin_IN[3];
    
    // logic of 4-bit input to 8-bit segment display.
    assign SEG_HEX_OUT[0] = ((~A)&B(~C)&(~D))|((~A)&(~B)(~C)&D)|((~A)&B&C&D)|(A&B&C(~D));
    assign SEG_HEX_OUT[1] = ((~B)&C&D)|((~A)&B&(~C)&D)|(A&B&C)|(A&(~B)&D);
    assign SEG_HEX_OUT[2] = ((~B)&C&D)|(A&C&D)|(A&(~B)&(~C)&(~D);
    assign SEG_HEX_OUT[3] = (~A)&(B)(~C)&D)|((~A)&B&(~D))|(A&B&D)|(A&(~B)&C(~D);
    assign SEG_HEX_OUT[4] = (~A)&(~C)&D)|(B&(~C)|(~A)&B&(~D);
    assign SEG_HEX_OUT[5] = (A&B&(~C))|(B&(~C)&(~D))|(A&(~C)&(~D))|((~A)&B&C&D);
    assign SEG_HEX_OUT[6] = ((~A)&(~C)&(~D))|(A&B&(~C)&D)|((~A)&(~B)&C&D);
    assign SEG_HEX_OUT[7] = DOT_IN;
    
    wire E,F;
    assign E = SEG_SELECT_IN[0];
    assign F = SEG_SELECT_IN[1];
    //segment selection
    assign SEG_SELECT_OUT[0] = ~((~F)&(~E));
    assign SEG_SELECT_OUT[1] = ~((~F)&E);
    assign SEG_SELECT_OUT[2] = ~(F&(~E));
    assign SEG_SELECT_OUT[3] = ~(F&E);
```

**A Module within a Module**: This Verilog module is being designed for reuse. This mean that it should have an easy to use generic interface that allows complete control over all four sections of the display. It should be notice that the code above is designed for light up only one digit. The  structure of the code is as below:

![](C:\Users\taleman\Desktop\Review_digit_lab_\graph\17.png)

If we want to reuse the code, we can use the wrapper:

```verilog
module wrapper(

    input [3:0] BIN_IN,
    output [3:0] SEG_OUT,
    output [3:0] HEX_OUT
);
    
    Decoding_the_world uut(
    
        .BIN_IN(BIN_IN),
        .SEG_SELECT_OUT(SEG_OUT),
        .SEG_HEX_OUT(HEX_OUT)
    );
    
endmodule
```

Then write the XDC files:

Tie 2-bit SEG_SELECT_IN and 4-bit BIN_IN to the slide-switches. Tie DOT_IN to another switch. And tie the displaying port properly. Then we can achieve choice the digit to light up and control the number to display.