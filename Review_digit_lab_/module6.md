# Module6: Counting World

## Aim:

Create a counter. A slide switch will decide whether the counter will increment or decrement while a Push Button will cause the counter to increase or decrease. The output will be shown in the 16 LEDs

## Preview:

**Analysis**: On the rising edge of the signal from the Button, if the control signal from the slide switch is '1' then the number stored in the register takes the value of the number stored in the register plus one. Else then the number stored in the register take the value of the number stored in the register minus one.

**HINT**: It is easy to think in the behavioral method

## Time for lab

### Step1: Create new project.

Create the new project and set 2 1-bit input `Button` and `Control_Switch`.Then based on the **analysis**, write the source code as below

```verilog
module Counting_the_world(
	input Button,
    input Control_Switch,
    output [15:0] LEDs
);
    reg [15:0] Values;
    
    always@(posedge Button) begin
        if(Control_Switch)
            Values <= Values + 1;
        else
            Values <= Values - 1;
    end
    
    assign LEDs = Values;
endmodule
```

Then run the synthesis and the RTL schematic and Technology schematic can be checked.



### Step2: Simulation

**Something need to mention first:** For the integer register `values` in the source code does not have a initial value which can cause the whole simulation to produce undefined results. To avoid that, an initial value can be assigned to internal integer like below:

```verilog
reg [15:0] Values = 0;
```

The testbench is as below:

```verilog
module Counting_the_world_TB(
);
	reg Button;
	reg Control_Switch;
    wire [15:0]LEDS;
    
    //instantiate the module
    Counting_the_world uut(
        .Button(Button),
        .Control_Switch(Control_Switch),
        .LEDs(LEDs)
    );
    
    //create a clock
    initial begin
        # 100
        Button = 0;
        forever #100 Button = ~Button;
    end
    
    initial begin
        Control_Switch = 0;
        #400 Control_Switch = 1;
        #400 Control_Switch = 0;
    end
    
```

Then from the output of the simulation result(LEDs), we can check whether the source code works.

**NOTE:** Since the initial value of `Control_Switch` is set as 1, then the `values` will decrease to -1. But in computer memory -1 is 1000 0000 0000 0001 in binary formation. 

### Step3: XDC file:

Then tie the slide switch to the `Control_Switch` and tie the button to the `Button` and tie all the LEDs to `LEDs`. It should be notice that in this module, we still do not use the dedicated clock pin so we need to add the following code:

```verilog
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets Button_IBUF]
```

 