`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: The university of Edinburgh
// Engineer: Jianing Li(s1997612)
// 
// Create Date: 22.10.2019 16:39:03
// Design Name: Snake Game
// Module Name: random_number
// Project Name: Snake Game
// Target Devices: Basys 3 board
// Tool Versions: Vivado 2015.2 
// Description: 
// This is used to generate the random number it should be notice that the random number should be display in the purpose range 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


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
