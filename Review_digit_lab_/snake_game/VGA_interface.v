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
// Description: This is the VGA interface which is used for displaying
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


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
