# Module 10 Color the world

## Aim:

Design and implement a VGA interface that allows the control of individual pixel elements of the display.

## Preview:

**VGA:** Video Graphic Array

![](https://github.com/taleman1997/Digital_lab_3/blob/master/Review_digit_lab_/graph/20.png)

The diagram above shows the pin distribution of VGA. It is based on RGB and each color four bits. Therefore, it can display 4096 different color. From manual, it is important to create a circuit to derive sync and the color signal with the correct timing.

The structure of the VGA is as below.

![](https://github.com/taleman1997/Digital_lab_3/blob/master/Review_digit_lab_/graph/21.png)

The logic process the coordinate and give it back to the interface to let it display on the screen.

**VGA system timing:** 

A video controller circuit must generate the HS and VS timings signal and coordinate the delivery of video data based on pixel clock. The VS signal defines the refresh frequency of the display or the frequency at which all information on the display is redrawn. The minimum refresh frequency is a function of the display's phosphor and electron beam intensity, with practical refresh frequencies falling in the 50Hz to 120Hz range. The number of lines to be displayed at a given refresh frequency defines the horizontal "retrace" frequency. For a 640-pixel by 480-row display using a 25 MHz pixel clock and 60 +/-1Hz refresh. Timings for sync pulse width and front and back porch intervals (porch intervals are the pre- and post-sync pulse times during which information cannot be displayed) are based on observations taken from actual VGA displays.

![](https://github.com/taleman1997/Digital_lab_3/blob/master/Review_digit_lab_/graph/22.png)

The beam scan horizontally first and then vertically. The graph below may help:

![](https://github.com/taleman1997/Digital_lab_3/blob/master/Review_digit_lab_/graph/23.png)

Based on that the relationship can be derived:
$$
T_s = T_{pw} + T_{bp} + T_{display}
$$
The input of the VGA interface has two incoming signals(CLK,COLOUR_IN) and five outgoing signals(COLOUR_OUT,HS,VS,ADDRH,ADDRY).  Internally, the interface will consist of two counters that have a range of 0 to 800 and 0 to 521 respectively, corresponding to the number of clock cycles or lines that make up a single horizontal or vertical sweep.

The COLOUR_OUT signal is required to mimic COLOUR_IN except when not within the display range, and hence logic is required to determine when this is so through the implementation of a "Valid" signal that is '1' when within the display range.

Additionally, two other counters are required to transmit the address of the next pixel to be displayed so that external modules can present the correct colour after the next rising edge of the clock.

The code is as below:

```verilog
module VGA_interface(
    input   CLK,
    input   [11:0] COLOUR_IN,
    output  reg [9:0] ADDRH,
    output  reg [8:0] ADDRV,
    output  reg [11:0] COLOUR_OUT,
    output  reg HS,
    output  reg VS
    );
    

    parameter VertTimeToPulseWidthEnd  = 10'd2;
    parameter VertTimeToBackPorchEnd   = 10'd31;
    parameter VertTimeToDisplayTimeEnd = 10'd511;
    parameter VertTimeToFrontPorchEnd  = 10'd521;
   

    parameter HorzTimeToPulseWidthEnd  = 10'd96;
    parameter HorzTimeToBackPorchEnd   = 10'd144;
    parameter HorzTimeToDisplayTimeEnd = 10'd784;
    parameter HorzTimeToFrontPorchEnd  = 10'd800;
       
    wire Horz_trig;
    wire Vert_trig;
    wire [9:0]VertCounter;
    wire [9:0]HorzCounter;





    Generic_counter # (.COUNTER_WIDTH(10),
                        .COUNTER_MAX(799)
                        )
                        HorzCounter_1(
                        .CLK(CLK),
                        .RESET(1'b0),
                        .ENABLE(1'b1),
                        .TRIG_OUT(Horz_trig),
                        .COUNT(HorzCounter)
                        );
    
    Generic_counter # (.COUNTER_WIDTH(10),
                        .COUNTER_MAX(520)
                        )
                        VertCounter_1(
                        .CLK(Horz_trig),
                        .RESET(1'b0),
                        .ENABLE(1'b1),
                        .TRIG_OUT(Vert_trig),
                        .COUNT(VertCounter)
                        );
   
   
   
   
   
                          
     always@(posedge CLK) begin     
      if (HorzCounter < HorzTimeToPulseWidthEnd)
          HS <= 0;
      else
          HS <= 1;
      end
      
     always@(posedge CLK) begin  
      if (VertCounter < VertTimeToPulseWidthEnd)
          VS <= 0;
      else
          VS <= 1;
      end  
      
 // To ensure the the counter in the display area       
     always@(posedge CLK) begin      
      if ((VertTimeToBackPorchEnd < VertCounter) && (VertCounter < VertTimeToDisplayTimeEnd) && (HorzTimeToBackPorchEnd < HorzCounter) &&(HorzCounter < HorzTimeToDisplayTimeEnd))
        COLOUR_OUT <= COLOUR_IN;
      else
         COLOUR_OUT <= 0;
     end
     
     always@(posedge CLK) begin     
      if((VertTimeToBackPorchEnd <= VertCounter) && (VertCounter <= VertTimeToDisplayTimeEnd))
        ADDRV <= VertCounter- VertTimeToBackPorchEnd;
      else
         ADDRV <= 0;
      end   
         
     always@(posedge CLK) begin           
      if ((HorzTimeToBackPorchEnd <= HorzCounter) && (HorzCounter <= HorzTimeToDisplayTimeEnd))
        ADDRH <= HorzCounter-HorzTimeToBackPorchEnd;            
      else 
         ADDRH <= 0;
     end   
                       
endmodule
```

**It should be notice that when run the simulation for the VGA interface, the output register need to be set a initial value.**

**Attention: The pixel clock needs 25MHz while the clock on the BASYS 3 board is 100MHz a slow down counter is needed.**

**Next step: create some logic:**

What we need to do is to control the COLOR_IN signal such that it can take an 12-bit value from slide switch. Besides, in some logic, 4 corner squares are needed to be colored different from the remaining part. Based on the structure above, the code for some logic is as below:

```verilog
module SomeLogic(
    input CLK,
    input [9:0]SOME_X,
    input [8:0]SOME_Y,
    input [11:0]COLOUR_IN_SOME,
    input VS,
    input [1:0] direction,
    input RESET,
    output reg [11:0]COLOUR_OUT_SOME
    );
     
                    
     Generic_counter # (.COUNTER_WIDTH(20),  // This counter is used to slow down the frequency
                    .COUNTER_MAX(99999)
                    )
                    FIRST_1(
                    .CLK(CLK),
                    .RESET(1'b0),
                    .ENABLE(1'b1),
                    .TRIG_OUT(first_trig),
                    .COUNT(firstcount)
                    );
                               
     Generic_counter # (.COUNTER_WIDTH(5),
                    .COUNTER_MAX(25)
                    )
                    SECOND_1(
                    .CLK(CLK),
                    .RESET(1'b0),
                    .ENABLE(first_trig),
                    .TRIG_OUT(second_trig),
                    .COUNT(secondcount)
                    );   // 1 Hz counter
                        
  Generic_counter # (.COUNTER_WIDTH(12),
                       .COUNTER_MAX(4095)
                       )
                       THIRD_1(
                       .CLK(CLK),
                       .RESET(1'b0),
                       .ENABLE(second_trig),
                       .TRIG_OUT(third_trig),
                       .COUNT(thirdcount)
                       );   // colour change
 
// This part is used to display the snake and the traget      
always@(posedge CLK) begin 

    if (SOME_X >=0) &&(SOME_X <=10) &&(SOME_Y >=0) &&(SOME_Y <=10) begin
        COLOUR_OUT_SOME <= COLOUR_IN_SOME;
        else
            COLOUR_OUT_SOME <= ~COLOUR_IN_SOME;
    end
    
    
end
    
endmodule
```

 Then write the wrapper to tie all the module together.

```verilog
module Wrapper(
    input   CLK,
    input   [11:0] COLOUR_IN,
    output  [11:0] COLOUR_OUT,
    output  HS,
    output  VS
    );

// define the wire and reg used in the wrapper    
    wire [9:0]X;
    wire [8:0]Y;
    wire [11:0]COLOUR_TRANSFER;    
       
    //DownSpeed
    Generic_counter # (.COUNTER_WIDTH(2),
    .COUNTER_MAX(3)
    )
    doublecounter(
    .CLK(CLK),
    .RESET(1'b0),
    .ENABLE(1'b1),
    .TRIG_OUT(double_tirg),
    .COUNT(double_counter)
    );

//The VGA interface is used to display the 
    VGA_interface D0 (
    .CLK(double_tirg),
    .COLOUR_IN(COLOUR_TRANSFER),
    .ADDRH(X),
    .ADDRV(Y),
    .COLOUR_OUT(COLOUR_OUT),
    .HS(HS),
    .VS(VS)
    );     
    
    
// This is used for the control of the snake 
    SomeLogic D1 (
    .CLK(double_tirg),
    .COLOUR_IN_SOME(COLOUR_IN),
    .COLOUR_OUT_SOME(COLOUR_TRANSFER),
    .VS(VS),
    .RESET(RESET),
    .SOME_X(X),
    .SOME_Y(Y)
    );
         
endmodule

```

Then write the XDC file. And we can see a square on the top left with different color with respect other part. Some more functions can achieved by develop more sophisticated logic.
