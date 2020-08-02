`timescale 1ns / 1ps
// Company: The university of Edinburgh
// Engineer: Jianing Li(s1997612)
// 
// Create Date: 22.10.2019 16:39:03
// Design Name: Snake Game
// Module Name: SomeLogic
// Project Name: Snake Game
// Target Devices: Basys 3 board
// Tool Versions: Vivado 2015.2 
// Description:This is the top module for the project. And the  
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
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

// the master state machine 
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

// The random number generator
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
