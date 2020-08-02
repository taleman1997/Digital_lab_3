`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: The university of Edinburgh
// Engineer: Jianing Li(s1997612)
// 
// Create Date: 22.10.2019 16:39:03
// Design Name: Snake Game
// Module Name: Master_State_Machine
// Project Name: Snake Game
// Target Devices: Basys 3 board
// Tool Versions: Vivado 2015.2
// Description: This is the used for the shift the state 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


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
