`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.11.2019 10:51:51
// Design Name: 
// Module Name: score_counter_detect
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


module score_counter_detect(
        CLK,
        RESET,
        ENABLE,
        TRIG_OUT,
        SCORE_DET,
        COUNT
    );
    
        parameter COUNTER_WIDTH =4;
        parameter COUNTER_MIN   =0;
        
        input CLK;
        input RESET;
        input ENABLE;
        input [5:0]SCORE_DET;
        output TRIG_OUT;
        output [COUNTER_WIDTH-1:0] COUNT;
        
        reg [COUNTER_WIDTH-1:0] count_value = 9;
        reg Trigger_out;
        reg [1:0] plus_time;
        reg flag = 0;
        reg flag_1 = 0;
        
        //
        initial begin
        count_value = 0;
        Trigger_out = 0;
        plus_time = 0;
        end
        //
      
      always@(SCORE_DET)begin
      if(RESET)
        plus_time <= 0;
      else begin
        if(ENABLE)begin
            if(plus_time == 5)
                plus_time <=0;
            else begin
                if(flag_1 == 1)begin
                plus_time<= plus_time+2;
                flag <= 1;
                end
                else flag = 0;
                end
            end
        end
      end

      
      
      //count_value  
      
        always@(posedge CLK) begin
         if(RESET)
          count_value<=0;
         else begin
          if(ENABLE) begin
           if(count_value == COUNTER_MIN)
            count_value<=9;
           else begin
           if(flag == 1)begin
               count_value <= count_value+ plus_time;
               flag_1 <= 0;
           end
           else if(flag == 0)begin
                count_value<= count_value-1;
                flag_1 =1;
           end
           end
          end
         end
        end
      
      // trigger_out
        
        always@(posedge CLK) begin
          if(RESET)
            Trigger_out <=0;
          else begin
            if(ENABLE && (count_value == COUNTER_MIN))
              Trigger_out <=1;
            else 
              Trigger_out <=0;
            end
          end
          
         assign COUNT = count_value;
         assign TRIG_OUT = Trigger_out;    
         
  
    
endmodule
