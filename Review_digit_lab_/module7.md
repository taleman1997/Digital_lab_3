# module7： Timing the world

## Aim

Use the dedicated clock source to create an accurate timer which can count up and down.

## Preview:

The manual suggest to reuse the code, but in this module, I choose to rebuild the code.

It should be noticed that the on-board clock(W5) is 100MHz which is too fast to be used in our module. Then it is necessary for us to slow it down.

**How to slow down the clock?**

According to the tutorial, the first piece logic control is a 27-bit counter.

**Why 27-bit ?** $\ 2^{27} = 134217728$ . Then $\ 2^{27}$ is the most effective binary form for $\ 10^{8}$ . The diagram is as below.

![](https://github.com/taleman1997/Digital_lab_3/blob/master/Review_digit_lab_/graph/13.pngng)

Then we can generate the code for the module

```verilog
module Counter(

    input CLK,
    input RESET,
    input COUNT_CTRL,
    input COUNT_ENABLE,
    output [7:0] LEDs
);
    
    reg [7:0] Values;
    reg [26:0] Bit_27_counter;
    
    // This counter is to slow down the frequency
    always@(posedge CLK) begin
        if(RESET)
            Bit_27_counter <= 0;
        else begin
            if(COUNT_ENABLE) begin
                if(COUNT_CTRL) begin
                    if(Bit_27_counter == 100000000)
                        Bit_27_counter <= 0;
                    else
                        Bit_27_counter <= Bit_27_counter + 1;
                end
                else begin
                    if(Bit_27_counter == 0)
                        Bit_27_counter <= 100000000;
                    else 
                        Bit_27_counter <= Bit_27_counter - 1;
                end
            end
        end
    end
    
    
    // Then next we need to create the 8 bit counter.
    
    always@(posedge CLK) begin
        if (RESET)
            values <= 0;
        else begin
            if(COUNT_CTRL) begin
                if(Bit_27_counter == 0)
                    values <= values + 1;
                else 
                    values <= values;
            end
        end
    end
    
```

It should be notice that all the `COUNT_CTRL` control the direction of the counter.

**Write the XDC file:** In this XDC file, LEDs are used for output. 2 slide-switch to control the counter and use a button for RESET.
