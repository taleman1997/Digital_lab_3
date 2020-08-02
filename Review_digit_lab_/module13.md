# module13： Snake Game

## Aim:

Implement a simplified version of a SNAKE GAME. 

In this version, I add all the extra features including length grow, speed change, second count down and score recording

The structure is as below:

![](C:\Users\taleman\Desktop\Review_digit_lab_\graph\30.png)



The wrapper code is as below: the most complex part is some logic part, this control the speed of the direction and the moving of the snake.

```verilog
module Wrapper(
    input   CLK,
    input   [11:0] COLOUR_IN,
    input   down_button,
    input   up_button,
    input   right_button,
    input   left_button,
    input   RESET,
    input   pause,
    output  LED,
    output  [11:0] COLOUR_OUT,
    output [3:0] SEG_SELECT,
    output [7:0] DEC_OUT,
    output  HS,
    output  VS
    );

// define the wire and reg used in the wrapper    
    wire [9:0]X;
    wire [8:0]Y;
    wire [11:0]COLOUR_TRANSFER;    
    wire double_tirg;
    wire [1:0]double_counter;
    wire [1:0]Master_State_sig;
    wire [5:0]score;
    wire score_detector;
    wire [7:0] random_x;
    wire [6:0] random_y;
    wire [7:0] head_pos_x;
    wire [6:0] head_pos_y;
    wire [1:0] direction;
    wire dead_sig;
    wire reset_detector;
    wire pause;
    wire dead_sig_time;
    wire score_flag;
       
    //DownSpeed for VGA interface
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
    .direction(direction),
    .RESET(RESET),
    .Master_state_sig(Master_State_sig),
    .score(score),
    .score_detector(score_detector),
    .random_num_x(random_x),
    .random_num_y(random_y),
    .dead_sig(dead_sig),
    .pause(pause),
    .score_flag(score_flag),
    .head_pos_y(head_pos_y),
    .head_pos_x(head_pos_x),
    .reset_detector(reset_detector),
    .SOME_X(X),
    .SOME_Y(Y)
    );

// the master state machine, this control the mode of the game
    Master_State_Machine D2(
    .Button_right(right_button),
    .Button_left(left_button),
    .Button_up(up_button),
    .Button_down(down_button),
    .RESET(RESET),
    .CLK(CLK),
    .score(score),
    .dead_sig(dead_sig),
    .dead_sig_time(dead_sig_time),
    .reset_detector(reset_detector),
    .Master_State_sig(Master_State_sig)
    );

//This is used for the score counter and 
    score_counter D3(
    .CLK(CLK),
    .score(score),
    .score_detector(score_detector),              
    .SEG_SELECT(SEG_SELECT),
    .state_sig(Master_State_sig),
    .pause(pause),
    .score_flag(score_flag),
    .RESET(RESET),
    .death_sig(dead_sig_time),
    .DEC_OUT(DEC_OUT)
    );

// The random number generator, this is used to locate the target
    random_number D4(
    .CLK(CLK),
    .head_pos_y(head_pos_y),
    .head_pos_x(head_pos_x),
    .random_num_x(random_x),
    .random_num_y(random_y)
    );


// This is used for the control snake's direction
    Navigation_State_Machine D5(
    .Button_right(right_button),
    .Button_left(left_button),
    .Button_up(up_button),
    .Button_down(down_button),
    .CLK(CLK),
    .Direction(direction)
    );
         
endmodule

```

There are some modules are used based on the pervious modules. Such as VGA interface and 7-segment deployment and multiplexer. The coed are as follow

```verilog
module Multiplexer_4way(
    input [1:0] CONTROL,
    input [4:0] IN0,
    input [4:0] IN1,
    input [4:0] IN2,
    input [4:0] IN3,
    output reg [4:0] OUT
    );
    
    
    always@(CONTROL or IN0 or IN1 or IN2 or IN3) begin
        case(CONTROL)
            2'b00 : OUT <= IN0; 
            2'b01 : OUT <= IN1;
            2'b10 : OUT <= IN2;
            2'b11 : OUT <= IN3;
            default : OUT <= 5'b00000;
        endcase
     end
    
endmodule
```

```verilog
module Seg7Display_Seg7(
    input [1:0] SEG_SELECT_IN,
    input [3:0] BIN_IN,
    input DOT_IN,
    output [3:0] SEG_SELECT_OUT,
    output [7:0] HEX_OUT
    );
    
    
    wire A, B, C, D;
    
    
    assign B = BIN_IN[0];
    assign A = BIN_IN[1];
    assign D = BIN_IN[2];
    assign C = BIN_IN[3];
    
    

    assign HEX_OUT[0] = ((~A)&B&(~C)&(~D)) | ((~A)&(~B)&(~C)&D) |((~A)&B&C&D) |(A&B&C&(~D));
    assign HEX_OUT[1] = ((~B)&C&D) | ((~A)&B&(~C)&D) | (A&B&C) |(A&(~B)&D);
    assign HEX_OUT[2] = ((~B)&C&D) | (A&C&D) |(A&(~B)&(~C)&(~D));
    assign HEX_OUT[3] = ((~A)&(~B)&(~C)&D) | ((~A)&B&(~D)) | (A&B&D) |(A&(~B)&C&(~D));
    assign HEX_OUT[4] = ((~A)&(~C)&D) | (B&(~C)) |((~A)&(~D)&B);
    assign HEX_OUT[5] = ((~A)&B&(~C)&(~D)) | (A&B&(~C)&(~D)) | (A&(~B)&(~C)&(~D)) |(A&B&(~C)&D) | ((~A)&B&C&D);
    assign HEX_OUT[6] = ((~A)&(~B)&(~C)&(~D)) | ((~A)&B&(~C)&(~D)) | (A&B&(~C)&D) | ((~A)&(~B)&C&D) ;
    assign HEX_OUT[7] = DOT_IN;
    
    
    wire E, F;
    assign E = SEG_SELECT_IN[0];
    assign F = SEG_SELECT_IN[1];
    
    assign SEG_SELECT_OUT[0] = ~((~F)&(~E));
    assign SEG_SELECT_OUT[1] = ~((~F)&(E));
    assign SEG_SELECT_OUT[2] = ~((F)&(~E));
    assign SEG_SELECT_OUT[3] = ~((F)&(E));
    
    
endmodule

```

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

```verilog
module Generic_counter(
CLK,
RESET,
ENABLE,
TRIG_OUT,
COUNT

    );
    parameter COUNTER_WIDTH =4;
    parameter COUNTER_MAX   =9;
    
    input CLK;
    input RESET;
    input ENABLE;
    output TRIG_OUT;
    output [COUNTER_WIDTH-1:0] COUNT;
    
    reg [COUNTER_WIDTH-1:0] count_value;
    reg Trigger_out;
    
    //
    initial begin
    count_value=0;
    Trigger_out=0;
    end
    //
  
  //count_value  
  
    always@(posedge CLK) begin
            if(RESET)
                count_value<=0;
            else begin
                if(ENABLE) begin
                if(count_value == COUNTER_MAX)
                count_value<=0;
            else
                count_value<= count_value+1;
            end
        end
    end
  
  // trigger_out
    
    always@(posedge CLK) begin
        if(RESET)
            Trigger_out <=0;
        else begin
            if(ENABLE && (count_value == COUNTER_MAX))
                Trigger_out <=1;
            else 
                Trigger_out <=0;
        end
    end
      
     assign COUNT = count_value;
     assign TRIG_OUT = Trigger_out;    
     
endmodule     
```

**The master state machine:** This is the top state machine. It control the different of state of the game from IDEL to game to die or win. Different states have different conditions. Code as follow:

```verilog
module Master_State_Machine(
    input Button_right,
    input Button_left,
    input Button_up,
    input Button_down,
    input RESET,
    input CLK,
    input [5:0] score,
    input dead_sig,
    input dead_sig_time,
    input reset_detector,
    output [1:0] Master_State_sig
    );
// define the parameter used in the project  
    parameter IDLE = 2'b00;
    parameter PLAY = 2'b01;
    parameter WIN = 2'b10; 
    parameter DEAD = 2'b11;

// define teh regester used in the project   
    reg [1:0] Curr_State = IDLE;
    reg [1:0] Next_state = IDLE;
      
    always@(posedge CLK) begin 
        Curr_State <= Next_state;
    end
    
// state shift code  
    always@(Button_right or Button_left or Button_up or Button_down or score or dead_sig or reset_detector) begin
    case (Curr_State)  
        IDLE: begin
            if(Button_right||Button_left||Button_up||Button_down)begin
               Next_state <= PLAY;
               end
            else
               Next_state <= IDLE;                  
        end
        
        PLAY: begin
            if(score == 3)begin
               Next_state <= WIN;
            end
            else if((dead_sig == 1)||(dead_sig_time == 1))begin
               Next_state <= DEAD;
            end
            else begin
               Next_state <= PLAY;
            end
        end
        
        WIN: begin
        if(reset_detector)
           Next_state <= IDLE;
        else
           Next_state <= WIN;
        end
        
        DEAD: begin
        if(reset_detector)
           Next_state <= IDLE;
        else
           Next_state <= DEAD;   
        end
    endcase
      
    end
    assign Master_State_sig = Curr_State;
    
endmodule
```

**Score_counter:** This module is used for display the score and game time on the 7-segment display. It should be notice that the skill for time increase when reach the target is quiet fake. I create three clock and display differently when reach the target.  The code is as followed.

```verilog
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.11.2019 20:48:32
// Design Name: 
// Module Name: score_counter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module score_counter(
    input CLK,
    input [5:0] score,
    input   score_detector,
    input [1:0] state_sig,
    input pause,
    input RESET,
    input score_flag,
    output [3:0] SEG_SELECT,
    output reg death_sig = 0,
    output [7:0] DEC_OUT
    );
    
    wire  Bit4TriggOut_0;
    wire  Bit4TriggOut_1;
    wire  Bit4TriggOut_2;
    wire  Bit4TriggOut_3;
    wire  Bit4TriggOut_4;
    wire [3:0] Bit4Count1;
    wire [3:0] Bit4Count2;
    wire [3:0] Bit4Count3;
    wire [3:0] Bit4Count4;
    wire [3:0] Bit4Count0;
    reg [3:0] Bit4Count1_score;
    reg [3:0] Bit4Count0_score;
    reg [3:0] a = 5;
    reg [3:0] b = 5;
    wire Bit2TriggOut;
    wire [1:0] StrobeCount;
    wire [16:0] Bit17Count;
    
    
    wire [4:0] DecCounterAndDOT0 ;
    wire [4:0] DecCounterAndDOT1 ;
    wire [4:0] DecCounterAndDOT2 ;
    wire [4:0] DecCounterAndDOT3 ;
    
    
    wire [4:0] MuxOut;
    reg flag;
    reg reset;
    reg [1:0] selector;
    
    
    
    wire [6:0] Bit4Count3_2;
    wire [5:0] Bit4Count3_1;
    wire [5:0] Bit4Count3_0;
    wire Bit4TriggOut_3_0;
    wire Bit4TriggOut_3_1;
    wire Bit4TriggOut_3_2;
    reg [6:0] timer;
    
    
    always@(CLK)begin
        if((state_sig == 2'b01)&&(pause == 0))begin
            reset<= 1'b0;
        if(score == 0)begin
            timer <= 60- Bit4Count3_0;
            a <= timer/10;
            b <= timer-(timer/10)*10;
            flag <= 1;
            if((a == 0)&&(b == 0))
                death_sig <= 1;
        end
        
        else if(score == 1)begin 
            timer <= 63- Bit4Count3_1;
            a <= timer/10;
            b <= timer-(timer/10)*10;
            flag <= 1;
            if((a == 0)&&(b == 0))
                death_sig <= 1;
        end 
        
        else if(score == 2)begin 
            timer <= 66- Bit4Count3_2;
            a <= timer/10;
            b <= timer-(timer/10)*10;
            flag <= 1;
            if((a == 0)&&(b == 0))
                death_sig <= 1;
        end 
        end
        
        else if((state_sig == 2'b01)&&(pause == 1))begin
            reset<= 1'b0;
            flag <=1;
            a <= timer/10;
            b <= timer-(timer/10)*10;
        end
        
        else begin
            reset<= 1'b1;
            a<=6;
            b<=0;
            flag <= 0; // used in the enable part
            death_sig <= 0;
        end
    
    if(StrobeCount == 2'b01) //turn off the segments
        selector <=  2'b00;
    else 
        selector <=  StrobeCount;   
    end
   
      
    Generic_counter #(
                      .COUNTER_WIDTH(17),
                      .COUNTER_MAX(99999) 
                      )
                      Bit17Counter(
                      .CLK(CLK),
                      .RESET(1'b0),
                      .ENABLE(1'b1),
                      .TRIG_OUT(Bit17TriggOut),
                      .COUNT(Bit17Count)
                      );
    Generic_counter #(
                    .COUNTER_WIDTH(2),
                    .COUNTER_MAX(3) 
                    )
                    Bit2Counter(
                    .CLK(CLK),
                    .RESET(1'b0),
                    .ENABLE(Bit17TriggOut),
                    .TRIG_OUT(Bit2TriggOut),
                    .COUNT(StrobeCount)
                    );
                    


    always@(score)begin
        if(score <= 9)begin
            Bit4Count1_score <= 0;
            Bit4Count0_score <= score;
        end
        else begin
            Bit4Count1_score <= 1;
            Bit4Count0_score <= 0;
        end
    end
                    
                    
                    
                    
                    
    Generic_counter #(
                    .COUNTER_WIDTH(4),
                    .COUNTER_MAX(9) 
                    )
                    Bit4Counter_0(
                    .CLK(CLK),  
                    .RESET(RESET&reset),
                    .ENABLE(Bit17TriggOut&flag&(~pause)),//flag is there flag before the change
                    .TRIG_OUT(Bit4TriggOut_0),
                    .COUNT(Bit4Count0)
                    );
                    
                    
    Generic_counter #(
                    .COUNTER_WIDTH(4),
                    .COUNTER_MAX(9) 
                    )
                    Bit4Counter_1(
                    .CLK(CLK),
                    .RESET(RESET&reset),
                    .ENABLE(Bit4TriggOut_0),
                    .TRIG_OUT(Bit4TriggOut_1),
                    .COUNT(Bit4Count1)
                    );
    
    Generic_counter #(
                    .COUNTER_WIDTH(4),
                    .COUNTER_MAX(9) 
                    )
                    Bit4Counter_2(
                    .CLK(CLK),
                    .RESET(RESET&reset),
                    .ENABLE(Bit4TriggOut_1),
                    .TRIG_OUT(Bit4TriggOut_2),
                    .COUNT(Bit4Count2)
                    );
                                     

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//New counter starts here time 24/11 12:37
//the counter value max is 60
 
    Generic_counter #(
                    .COUNTER_WIDTH(6),
                    .COUNTER_MAX(60) 
                    )
                    Bit4Counter_3_0(
                    .CLK(CLK),
                    .RESET(RESET&reset),
                    .ENABLE(Bit4TriggOut_2),
                    .TRIG_OUT(Bit4TriggOut_3_0),
                    .COUNT(Bit4Count3_0)
                    );   
    
    
    Generic_counter #(
                    .COUNTER_WIDTH(6),
                    .COUNTER_MAX(63) 
                    )
                    Bit4Counter_3_1(
                    .CLK(CLK),
                    .RESET(RESET&reset),
                    .ENABLE(Bit4TriggOut_2),
                    .TRIG_OUT(Bit4TriggOut_3_1),
                    .COUNT(Bit4Count3_1)
                    );   
    
    
    Generic_counter #(
                    .COUNTER_WIDTH(6),
                    .COUNTER_MAX(66) 
                    )
                    Bit4Counter_3_2(
                    .CLK(CLK),
                    .RESET(RESET&reset),
                    .ENABLE(Bit4TriggOut_2),
                    .TRIG_OUT(Bit4TriggOut_3_2),
                    .COUNT(Bit4Count3_2)
                    );        

    assign DecCounterAndDOT0 =  {1'b1, Bit4Count0_score};
    assign DecCounterAndDOT1 =  {1'b0, Bit4Count1_score};
    assign DecCounterAndDOT2 =  {1'b0, a};
    assign DecCounterAndDOT3 =  {1'b0, b};

        
        
        
    Multiplexer_4way Mux4(
                    .CONTROL(selector),
                    .IN0(DecCounterAndDOT0),                           
                    .IN1(DecCounterAndDOT1),
                    .IN2(DecCounterAndDOT2),
                    .IN3(DecCounterAndDOT3),
                    .OUT(MuxOut)
                    );
        
        
    Seg7Display_Seg7 Seg7(
                    .SEG_SELECT_IN(selector),
                    .BIN_IN(MuxOut[3:0]),
                    .DOT_IN(1'b1),
                    .SEG_SELECT_OUT(SEG_SELECT),
                    .HEX_OUT(DEC_OUT) 
                    );
                        

endmodule

```

And this is some logic part, this part is quiet complex. The speed control and color control are defined here. It should be notice that the snake grow here is very important. Be careful with the for loop here and you may cover the snake body by   mistake. So be careful when color the snake and the background color. The code is as follow

```verilog
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: The university of Edinburgh
// Engineer: Jianing Li(s1997612)
// 
// Create Date: 22.10.2019 16:39:03
// Design Name: Snake Game
// Module Name: SomeLogic
// Project Name: Snake Game
// Target Devices: Basys 3 board
// Tool Versions: Vivado 2015.2
// Description: This module is the control part for the snake and the function of it is used to control 
// the snake's head moving and the body and change the speed of the sanke. Besides it can also add the score
// of the snake and display the target and the snake.
// It should be notice that the judge frequency should be same with the moving. And the signal should be transfer
// to the other module
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module SomeLogic(
    input CLK,
    input [9:0]SOME_X,
    input [8:0]SOME_Y,
    input [11:0]COLOUR_IN_SOME,
    input VS,
    input [1:0] direction,
    input RESET,
    input [7:0]random_num_x,
    input [6:0]random_num_y,
    input [1:0]Master_state_sig,
    input pause,
    output reg reset_detector,
    output reg [5:0] score,
    output reg score_detector,
    output reg score_flag,
    output reg dead_sig,
    output reg [7:0]head_pos_x,
    output reg [6:0]head_pos_y,
    output reg [11:0]COLOUR_OUT_SOME
    );
     
//  define the wire or reg used in this module       
    wire [19:0] firstcount;
    wire first_trig;
    wire [4:0] secondcount;
    wire second_trig;
    wire [4:0] secondcount_1;
    wire second_trig_1;
    wire [11:0] thirdcount;
    wire third_trig;
      
    reg [7:0] SnakeState_X [0:snakelength-1];
    reg [6:0] SnakeState_Y [0:snakelength-1];
    reg [7:0]apple_x = 80;
    reg [6:0]apple_y = 80;    
    parameter snakelength = 40;
    parameter length = 5;
    reg [5:0] length_reg = 15;
    reg [5:0] number;
    reg [5:0] div = 1;
    reg flag = 0;
    
                    
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
   if(Master_state_sig == 2'b00)begin
       COLOUR_OUT_SOME <= 12'b000000001111;
   end
   else if(Master_state_sig == 2'b10)begin
       COLOUR_OUT_SOME <= thirdcount;
   end
  else if(Master_state_sig == 2'b11)begin
       COLOUR_OUT_SOME <= 12'b111000001111;
   end
   else begin
   if((SOME_X[9:2] == 60)&&(SOME_Y[8:2] >= 10)&&(SOME_Y[8:2] <= 80)) 
       COLOUR_OUT_SOME <= 12'b111111111111+10*score;   
   else if((SOME_X[9:2] == apple_x)&&(SOME_Y[8:2] == apple_y))
   COLOUR_OUT_SOME <= 12'b001000011111;
   else
   COLOUR_OUT_SOME <= 12'b000000000000;
   for(number = 0; number <length_reg; number = number+1)begin
   if((SOME_X[9:2]==SnakeState_X[number])&&(SOME_Y[8:2]==SnakeState_Y[number]))
   COLOUR_OUT_SOME <= 12'b000110101111;
   end
   end              
end


//generate the regester of the snake 
genvar PixNo;
generate 
for(PixNo = 0; PixNo < snakelength-1; PixNo = PixNo + 1)
   begin: PixShift
          always@(posedge flag) begin
            if(pause == 0)begin
           SnakeState_X[PixNo + 1] <= SnakeState_X[PixNo];
           SnakeState_Y[PixNo + 1] <= SnakeState_Y[PixNo];
           head_pos_x<=SnakeState_X[0];
           head_pos_y<=SnakeState_Y[0];
           end

       end
   end
endgenerate

//define the head movement     
always@(posedge flag) begin 

if(pause == 0)begin
      case(direction)
          2'b00: begin
          if(SnakeState_Y[0] == 119)
             SnakeState_Y[0] <=0;
          else 
             SnakeState_Y[0] <= SnakeState_Y[0]+1;
          end
          
          2'b01: begin
          if(SnakeState_Y[0] == 0)
             SnakeState_Y[0] <=119;
          else
             SnakeState_Y[0] <= SnakeState_Y[0]-1; 
          end
          
          2'b10: begin
          if(SnakeState_X[0] == 0)
             SnakeState_X[0] <= 159;
          else
             SnakeState_X[0] <= SnakeState_X[0]-1; 
          end
          
          2'b11: begin
          if(SnakeState_X[0] == 159)
             SnakeState_X[0] <= 0;
          else
             SnakeState_X[0] <= SnakeState_X[0]+1; 
          end

   endcase
   end

end
      
//The logic definination
always@(posedge flag) begin

if(Master_state_sig == 2'b01)begin
    reset_detector<= 0;
   if ((apple_x == SnakeState_X[0])&&(apple_y == SnakeState_Y[0])) begin 
       apple_x <= random_num_x;
       apple_y <= random_num_y;
       score <= score + 1;
       score_flag <= 1;
       score_detector <= 1;
       length_reg <= length_reg + 3; 
   end
   else begin
       apple_x <= apple_x;
       apple_y <= apple_y;
       score_flag <= 0;
       score_detector <= 0;       
   end
   
   if((SnakeState_X[0] == 60)&&(SnakeState_Y[0] >=10)&&(SnakeState_Y[0] <= 80))
        dead_sig <= 1;
   
   for(number = 4; number <length_reg; number = number+1)begin
       if((SnakeState_X[0]==SnakeState_X[number])&&(SnakeState_Y[0]==SnakeState_Y[number])&&(thirdcount > 5))begin
            dead_sig <= 1;
       end
   end
    
end
  
else if(Master_state_sig == 2'b10)begin
    if(RESET)begin
        score <= 0;
        reset_detector<= 1; 
    end
end
   
   
   
else if(Master_state_sig == 2'b11)begin
    if(RESET)begin
        score <= 0;        
        dead_sig <= 0;
        reset_detector<= 1;

    end
end 
 
end



//The speed controller
always@(posedge first_trig) begin
    if(score == 0)begin
        if(div <25)begin
            div <= div +1;
            flag <= 0;
        end
        else if(div ==25) begin
            div <= 0;
            flag <= 1;
        end
    end
    
    else if(score == 1)begin
        if(div <12)begin
            div <= div +1;
            flag <= 0;
        end
        else if(div == 12) begin
            div <= 0;
            flag <= 1;
        end
    end
    
    else if(score == 2)begin
        if(div <6)begin
            div <= div +1;
            flag <= 0;
        end
        else if(div == 6)begin
            div <= 0;
            flag <= 1;
        end
    end
    
    else if(score == 3)begin
        if(div <3)begin
            div <= div +1;
            flag <= 0;
        end
        else if(div == 3) begin
            div <= 0;
            flag <= 1;
        end
    end
end
          
endmodule
```

**Target Generator:** In the game, the position of the target is generated randomly. Therefore, it is important to create a random number generator to generator the location.

The principle of the random generator is that the value of time for a player to reach the target. Then we can use this random time to generate the random position. **It should be notice that the location should be outside of the body of the snake and area of barrier(if exist in the game). Besides the location of the target should on the screen.**

```verilog
module random_number(
    input CLK,
    input [7:0] head_pos_x,
    input [6:0] head_pos_y,

    output reg [7:0] random_num_x,
    output reg [6:0] random_num_y
    );
        
    always@(posedge CLK) begin
        if(random_num_x <= 150) begin
            if((random_num_x >= head_pos_x-20)&&(random_num_x <= head_pos_x+20))
                random_num_x <= random_num_x + 42;
            else if (random_num_x == 60)
                random_num_x <= random_num_x + 5;
            else
                random_num_x <= random_num_x + 1;
        end        
        else 
            random_num_x <=10;
    end
    
    
    
    always@(posedge CLK) begin
    if(random_num_y <= 100)begin
        if((random_num_y >= head_pos_y-20)&&(random_num_y <= head_pos_y+20))
            random_num_y <= random_num_y + 42;
        else
            random_num_y <= random_num_y + 1;
    end   
    else
        random_num_y <= 10;
    end

        
endmodule
```

****

**Navigation_State_Machine:** This module is used to control the direction of the snake. It should input the signal from the button and output the direction to the somelogic submodule. The code is as below:

```verilog
module Navigation_State_Machine(
    input Button_right,
    input Button_left,
    input Button_up,
    input Button_down,
    input CLK,
    output reg [1:0] Direction
    );
    
    always@(posedge CLK) begin
    if((Button_down)&&(Direction != 1))
        Direction <= 2'b00;
    else if((Button_up)&&(Direction != 0))
        Direction <= 2'b01;
    else if((Button_right)&&(Direction != 2))
        Direction <= 2'b11;
    else if((Button_left)&&(Direction != 3))
        Direction <= 2'b10;
    end
endmodule
```

