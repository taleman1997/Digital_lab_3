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
