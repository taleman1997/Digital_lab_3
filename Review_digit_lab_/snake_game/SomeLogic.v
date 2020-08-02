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