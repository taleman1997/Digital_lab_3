# Module12：The World of Linked State Machine

## Aim:

Link multiple state machines with the state of one being the input of another. This module involves the previous state maze problem with VGA interface and another simple state machines.

The structure of the state machine is as below.

![](C:\Users\taleman\Desktop\Review_digit_lab_\graph\28.png)

The above diagram shows all the states and corresponding sub-system functions. First, I need to create a state machine to represent the above diagram. Before we start coding, we need to number the state

|      IDLE       | **state 0** |
| :-------------: | :---------: |
| **LED Display** | **state 1** |
| **State Maze**  | **state 2** |
|  **VGA Demo**   | **state 3** |

The process of creating the state machine is much similar to that in module 11. It contains 2 ports, one is synchronous logic that is used to store the current state, the other is combinational logic that is used to decide the next state.

The sequence of the LED is as below. It should be notice that to let the LED light for a while, there should be a counter to control it.

![](C:\Users\taleman\Desktop\Review_digit_lab_\graph\29.png)

```verilog
module LED_DisplaySM(

    input CLK,
    input RESET,
    input [1:0] MSM_State,
    output [7:0] LED_OUT,
    output [3:0] LED_DisplaySM_ouot
);
    
    reg [25:0] Curr_Count;
    reg [25:0] Next_Count;
    
    reg [3:0] Curr_State;
    reg [3:0] Next_State;
    
    reg [7:0] Curr_LEDs;
    reg [7:0] Next_LEDs;
    
    always@(posedge CLK) begin
        if(RESET) begin
            Curr_State <= 0'4h0;
            Curr_Count <= 0;
            Curr_LEDs <= 8'h00;
        end
        else begin
            Curr_State <= Next_State;
            Curr_Count <= Next_Count;
            Curr_LEDs <= Next_LEDs;
        end
    end
    
    
    always@(Curr_State or MSM_State or Curr_Count) begin
        case(Curr_State)
            4'h0:begin
                if(MSM_State == 4'b11)
                    Next_State <= 4'h1;
                else
                    Next_State <= 4'h0;
                Next_Count <= 0;
                Next_LEDs <= 8'h00;
            end
            
            4'h1: begin
                if(Curr_Count == 50000000)begin
                    Next_State <= 4'h2;
                    Next_Count <= 0;
                end
                else begin
                    Next_State <= Curr_State;
                    Next_Count <= Curr_Count + 1;
                end
                Next_LEDs < =8'b10000000;
            end
            //the other cases can be generated based on that
```

**VGA and MAZE:** In this part, I can reuse the module developed in previous lab. I just make some minor adjustment. For example, remove the interface to the slide switches and instead use a counter to alter the color on the screen.

Then create a wrapper to connect them together.