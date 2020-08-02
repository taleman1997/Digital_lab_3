`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: The university of Edinburgh
// Engineer: Jianing Li(s1997612)
// 
// Create Date: 22.10.2019 16:39:03
// Design Name: Snake Game
// Module Name: Navigation_State_Machine
// Project Name: Snake Game
// Target Devices: Basys 3 board
// Tool Versions: Vivado 2015.2
// Description: This is used for the navagation of the snake head
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


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
