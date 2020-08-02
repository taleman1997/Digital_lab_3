# Module 9 Timing the world in decimal

## Aim:

Implement a decimal up timer that displays its result in seconds on the 7-segment display block.

## Preview

Following instruction, the whole task can be divided into several parts to increase the modularity which will make the debug easier. The structure of the module is as below:

![](https://github.com/taleman1997/Digital_lab_3/blob/master/Review_digit_lab_/graph/18.png)

17 bit counter takes the clock input (100MHz), counting clock cycles up to 99999 then reset to 0. So the output frequency of 17-bit counter is 1kHz
$$
\frac{100MHz}{100000} = 1kHz
$$
All the 4-bit counters count between 0 to 9. Therefore, they are all 10 frequency divider.

The last four 4-bit counter is corresponding to the four digits in the 7-segments display. And the frequency is 100Hz as 1kHz' s output has been divided by a 4-bit counter which counts from 0 to 9.
$$
\frac{1kHz}{10} = 100Hz
$$
Each of the outputs from the later four 4-bit counters are joined by an additional bit that describes the state of the 'DOT' after each 7-segments display.



## Time for lab

### Step1: create each module individually

There are 5 counters in the design. Therefore, creating a generic counter which can allow the creation of Verilog modules with variable characteristics which could be defined upon instantiation.

![](https://github.com/taleman1997/Digital_lab_3/blob/master/Review_digit_lab_/graph/19.png)

As the diagram shows, there are three inputs  ENABLE,RESET and CLK. The outputs of the counter are its current COUNT whose size is depending on the size of the counter. And a single bit TRIG_OUT which is set to 1 for a single clock cycle when ever the counter resets to 0.

**Parameter:** it can be defined upon instantiation, thereby allowing them to control the width of the buses. The code of the generic counter is as below:

```verilog
module Generic_counter(
	// it should be notice that I/Os are not defined here 
    CLK;
    RESET,
    ENABLE,
    TRIG_OUT,
    COUNT
);
    parameter COUNT_WIDTH;
    parameter COUNT_MAX;
    
    input CLK;
    input RESET;
    input ENABLE;
    output TRIG_OUT;
    output [COUNT_WIDTH-1:0] COUNT;
    
    reg [COUNT_WIDTH-1:0] count_value; // when simulation this should be set as 0
    reg Trigger_out;
    
    // synchronous logic for value of count_value
    always@(posedge CLK)begin
        if(RESET) begin
            count_value <=0;
        end
        
        else begin  
            if(ENABLE) begin
                if(count_value == COUNTER_MAX)
                    count_value <= 0;
                else
                    count_value <= count_value + 1;
            end
        end
    end
    
    
    //Synchronous logic for Trigger_out
    always@(posedge CLK) begin
        if(RESET)
            Trigger_out <= 0;
        else begin
            if(ENABLE && (count_value == COUNTER_MAX))
                Trigger_out <= 1;
            else
                Trigger_out <=0;
        end
    end
    
    assign COUNT = count_value;
    assign TRIG_OUT = Trigger_out;
    
endmodule
                    
    
```

### Step2: The multiplexer

As shown in the preview, I require a multiplexer to display all the digits of the counter. I will use a strobing technique where each segment is lit with its appropriate representation one after the other, but so fast that the human eye cannot see the strobing effect.

The code is as below:

```verilog
module Muliplexer_4way(

    input [1:0] CONTROL,
    input [4:0] IN0,
    input [4:0] IN1,
    input [4:0] IN2,
    input [4:0] IN3,
    output reg [4:0] OUT
   
);
    
    always@(CONTROL or IN0 or IN1 or IN2 or IN3) begin
        case(CONTROL)
            2'b00: OUT <= IN0;
            2'b01: OUT <= IN1;
            2'b10: OUT <= IN2;
            2'b11: OUT <= IN3;
            default : OUT <= 5'b00000;
        endcase
    end
endmodule
```

### Step3: tie the module

First I need to create a top module and give it an interface that includes CLK, RESET, ENABLE, SET_SELECT, DEC_OUT. The structure can check the picture below.

![](https://github.com/taleman1997/Digital_lab_3/blob/master/Review_digit_lab_/graph/18.png)

The code are as below

```verilog
// First instantiate 7 counters


wire Bit17Trigger;
wire Bit4Trigger0;
wire Bit4Trigger1;
wire Bit4Trigger2;
wire Bit4Trigger3;
wire Bit4Trigger4;
wire [1:0]StrobeCount;
wire [3:0] DecCount0;
wire [3:0] DecCount1;
wire [3:0] DecCount2;
wire [3:0] DecCount3;
wire [3:0] DecCount4;

Generic_counter #(

    .COUNTER_WIDTH(17),
    .COUNTER_MAX(99999)
	)
    Bit17counter(

        .CLK(CLK),
        .RESET(1'b0),
        .ENABLE(1'b1),
        .TRIG_OUT(Bit17Trigger)  // there is no need for count 
    )

Generic_counter #(

    .COUNTER_WIDTH(4),
    .COUNTER_MAX(9)
	)
    Bitcounter0(

        .CLK(CLK),
        .RESET(RESET),
        .ENABLE(ENABLE & Bit17Trigger),
        .TRIG_OUT(Bit4Trigger0),
        .COUNT(DecCount0)
    )

Generic_counter #(

    .COUNTER_WIDTH(4),
    .COUNTER_MAX(9)
	)
    Bitcounter1(

        .CLK(CLK),
        .RESET(RESET),
        .ENABLE(ENABLE & Bit4Trigger0),
        .TRIG_OUT(Bit4Trigger1),
        .COUNT(DecCount1)
    )

Generic_counter #(

    .COUNTER_WIDTH(4),
    .COUNTER_MAX(9)
	)
    Bitcounter2(

        .CLK(CLK),
        .RESET(RESET),
        .ENABLE(ENABLE & Bit4Trigger1),
        .TRIG_OUT(Bit4Trigger2),
        .COUNT(DecCount2)
    )

Generic_counter #(

    .COUNTER_WIDTH(4),
    .COUNTER_MAX(9)
	)
    Bitcounter3(

        .CLK(CLK),
        .RESET(RESET),
        .ENABLE(ENABLE & Bit4Trigger2),
        .TRIG_OUT(Bit4Trigger3),
        .COUNT(DecCount3)
    )

Generic_counter #(

    .COUNTER_WIDTH(4),
    .COUNTER_MAX(9)
	)
    Bitcounter4(

        .CLK(CLK),
        .RESET(RESET),
        .ENABLE(ENABLE & Bit4Trigger3),
        .TRIG_OUT(Bit4Trigger4),
        .COUNT(DecCount4)
    )

Generic_counter #(

    .COUNTER_WIDTH(2),
    .COUNTER_MAX(3)
	)
    Bitcounter5(

        .CLK(CLK),
        .RESET(RESET),
        .ENABLE(Bit17Trigger),
        .COUNT(StrobeCount)
    )

// Then we need to tie the multiplexer

wire [4:0] DecCountAndDot0;
wire [4:0] DecCountAndDot1;
wire [4:0] DecCountAndDot2;
wire [4:0] DecCountAndDot3;

assign DecCountAndDot0 = {1'b0,DecCount0};
assign DecCountAndDot1 = {1'b0,DecCount1};
assign DecCountAndDot2 = {1'b0,DecCount2};
assign DecCountAndDot3 = {1'b0,DecCount3};

wire [4:0] MuxOut;

Multiplexer_4way Mux4(

    .CONTROL(StrobeCount),
    .IN0(DecCountAndDot0),
    .IN1(DecCountAndDot1),
    .IN2(DecCountAndDot2),
    .IN3(DecCountAndDot3),
    .OUT(MuxOut)
);

// Finally instantiate the 7 segments decoder

Seg7Display seg7 (

    .SEG_SELECT_IN(StrobeCount),
    .BIN_IN(MuxOut[3:0]),
    .DOT_IN(MuxOut[4]),
    SEG_SELECT_OUT(SEG_SELECT),
    HEX_OUT(DEC_OUT)
);
```

Then run the synthesis and create the XDC file.

**Outcome:** After load the bit file to FPGA, I push the slide switch, the segment display shows a clock which counts in 10ms intervals up to99.99 seconds. And the ENABLES to pause and continue the counter at any time.
