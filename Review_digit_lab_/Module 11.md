# Module 11 The World of State Machine

## Aim 

Use the concept of state machine through the creation of state machine maze.

## Preview:

A state machine is a synchronous system that has a memory. Therefore, it can not only know the current action but know the next action combined with its current state and incoming stimulus.

 **Typically, there are two logic blocks, one is synchronous the other is asynchronous.** 

![](https://github.com/taleman1997/Digital_lab_3/blob/master/Review_digit_lab_/graph/24.png)

The diagram above show how a state machine works. The synchronous logic latches the state of the OUTPUTS and CURRENT STATE upon the rising edge of each clock. The asynchronous logic determines what the next state is going to be.

In this module, I create a Moore machine which the output depends only on the states. There is also another state machine called Mealy machine that the output is determined by input and states.

When describing the state machine, this can be represented as two `always` statement, one clocked the other not.

```verilog
// Sequential logic is like the following:
always @ (posedge CLK) begin
    if(RESET) begin
        Curr_State <= 3'b000;
        Curr_Outputs <=  ;//RESET conditions for outputs
    end
    
    else begin
        Curr_State <= Next_state;
        Curr_Outputs <= Next_outputs;
    end
end

        
```

 

The asynchronous combinational logic is important as ti makes all the decisions regarding the value of the next state. If we have the structure below, we can achieve by this code:

![](https://github.com/taleman1997/Digital_lab_3/blob/master/Review_digit_lab_/graph/25.png)

```verilog
always@（IN or Curr_state) begin
    case(Curr_state)
        2'd0: begin
            if(IN)
                Next_state <= 2'd1;
            else
                Nexxt_state <= Curr_state;
        end
        
        2'd1: begin
            if(IN)
                Next_state <= 2'd2;
            else 
                Next_state <= Curr_state;
        end
        
        2'd2: begin
            if(IN)
                Next_state <= 2'd3;
            else
                Next_state <= Curr_state;
        end
        
        2'd3 begin
            if(IN)
                Next_state <= 2'd0;
            else
                Next_state <= Curr_state;
        end
        
        default: 
            Next_state <= 2'd0;
    endcase
end

                
```

Then create a maze game like this:

![](https://github.com/taleman1997/Digital_lab_3/blob/master/Review_digit_lab_/graph/26.png)

Then the structure of the program is as below.

![](https://github.com/taleman1997/Digital_lab_3/blob/master/Review_digit_lab_/graph/27.png)

**NOTE:** After loading the bitstream to the board, I find that the state is not stable. When I press the button, ti change to a new state but when loose it, it go back to zero or other state. The reason is that there is not `else` in one case. Then need to add

```verilog
3'd0: begin
    if(BTNC)
        next_state <= 3'd6;
    else   // this contains 3 sitations BTNL,BTNR,nothing
        next_state <= curr_state;
end
```

Besides we can still build state machine with memory

For there are finite number of combinations of state and inputs, there are also a finte number of next states and output combinations. When using memory to describe a sate machine a block of memory is needed. For example, our state machine has a 3-bit state, as well as three 1-bit inputs, a total of 6-bits. This equates to a memory depth of 2 to the power of 6, or 64 different combinations. The width of the memory must equal to the sum total number of bits needed to represent the next state (3-bits), and any additional output signals (none in our case). With this type of state machine, the combinatorial and sequential aspects of the previous design are merged together.

The code is as below:

```verilog
module BasicSM_Mem(

    input CLK,
    input RESET,
    input BTNL,
    input BTNC,
    input BTNR,
    output [2:0] OUT
    
);
    
    // ROM declarartion
    reg [2:0] Nest_state_Mem[0:63];
    reg [2:0] Curr_state;
    
    initial
        $readmemb("SM_Mem.list",Next_state_Mem); //load the memory
    
    alwyas@(posedge CLK)begin
        if(RESET)
            Curr_state <= 3'h0;
        else
            Curr_state <= Next_stateMem[(Curr_state,BTNR,BTNC,BTNL)];
    end
    
    assign OUT = Curr_State;
    
endmodule
```

The key piece of code here is the '\$readmemb' statement, which loads a memory configuration file into the designated memory array. The 'b' at the end of '​\$readmemb' means that this command expects the file to be written in binary. There is also a '$readmemh' version of the statement for hex.

About the rewriting memory in the tutorial. The sequence is

| BTNR | BTNC | BTNL |
| :--: | :--: | :--: |
|  0   |  0   |  0   |
|  0   |  0   |  1   |
|  0   |  1   |  0   |
|  0   |  1   |  1   |
|  1   |  0   |  0   |
|  1   |  0   |  1   |
|  1   |  1   |  0   |
|  1   |  1   |  1   |

For each state, there are 8 situation for button press. Then based on the maze game structure, we can finish the whole memory. Then put this file in the working directory of the project.

Then write the XDC and see what will happen.
