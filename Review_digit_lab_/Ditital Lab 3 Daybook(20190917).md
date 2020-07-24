# Digital Lab 3 Daybook(20190917)

## Location: TLD

## Aim

Use the Xilinx Vivado Design to write a piece of HDL code and then implement it with in the configurable hardware, which is BASYS3 FPGA board.

## Preview about today's task

Field Programmable Gate Array(FPGA)  is widely used in the field of electronics. Therefore, it is important for electronics and electrical Engineering students to manipulate it. In this lab, I will be taught to use a standard Hardware Description Language called Verilog for FPGA hardware programming.

## In the lab:

## Module 1 Hello World

### **Step 1: Loading the software and create the new project**

What is used in this lab is Xilinx Vivado Design. And the student version can be download [here](https://www.xilinx.com/support/download.html). And the following steps show the flow to create a new project.

Open the Vivado software and click the "create new project" tab

![01](https://github.com/taleman1997/Digital_lab_3/blob/master/Review_digit_lab_/graph/01.png)

Then create a new project and input the correct path. After that choose "RTL project" which allows you to run RTL analysis, synthesis, implementation and other function. Besides tick the box "Do not specify source". Then go next.

In the Default part, set the parameters as below.

![02](https://github.com/taleman1997/Digital_lab_3/blob/master/Review_digit_lab_/graph/02.png)

These settings are related to the board we used. After that the project is created

### **Step 2: Create a new source**

Use the button "Add Source" in the project manager to add a source and we choose "Add or create design source" and there are three options: 

**Add files:** this option is to add existing files to your project.

**Create files:** this is used to create a new source files.

**Add dictionaries:** similar to the add files. Just specify the path of the files.

In this lab we use **Create files** and choose the type fo file as **Verilog** and set the prupose name to the file.

After that we need to define the module for the source. You need to define the input or output. Define the name of the input and output, use bus or not and the bits.

![03](https://github.com/taleman1997/Digital_lab_3/blob/master/Review_digit_lab_/graph/03.png)



After that the source code is created:

![04](https://github.com/taleman1997/Digital_lab_3/blob/master/Review_digit_lab_/graph/04.png)

`timescale 1ns / 1ps` relates to how the wait syntax `#` is handled by the simulator. For example:

```verilog
timescale 1ns / 1ps
# 500
```

This means the program will wait for 500 ns and then implement the following code.

`module` is a key word followed by file name. What insides is the input and output list called **Module interface**. `endmodule` consistent with `module` showing the end of program.

Now we add the first instruction into the source file. **It should be noticed that: the code added is outside the Module interface. Do not add anything in the Module Interface.**

```verilog
assign OUT = IN;
```

`assign` statement is used to tie one variable to another. Using this sentence, we connect our input(push button) to our output(LED). **It should be notice that the reg type can not be assigned for reg can store data but it can not be driven.**

### **Step 3: Synthesis**

After we add the code to the source file, click the button "Run Synthesis" under the "RTL analysis".  Then the synthesis will run. If the "Synthesis completed" appears, then we can go on. If "Synthesis failed" appears, then we need to check the message in the "Console Window" to see the mistakes.

**About Synthesis:**

Synthesis is the process of converting a high-level description of a design into an optimized gate-level representation. Once synthesis is completed, the **"Open Synthesized Design"** is available to use and then we can see the technology schematics, which shows how your design would be implemented using standard device elements, such as LUTs,registers and input/output buffers. Based on the code we add into the source file, the schematic should be like this:

![05](https://github.com/taleman1997/Digital_lab_3/blob/master/Review_digit_lab_/graph/05.png)

**Note:** there is also RTL schematics which is available to check before synthesis. RTL schematic illustrate your design in  terms of registers and logic gates.(This can be tested in the exam!)

### **Step4: Simulation**

Before simulate the design, the input and output signal are needed to drive the simulation. And this is done by testbench. Then we need to add source file and choose the file type as **"Add or create simulation file"**, set a purpose file name and set the type of file as **"Verilog"** . In the define module window, do not add any ports. After all settings, the source code file should like this:

![06](https://github.com/taleman1997/Digital_lab_3/blob/master/Review_digit_lab_/graph/06.png)



Then we define two signals here(**Not in the module interface**)

```verilog
reg IN; // inputs
wire OUT; //outputs
```

I think the explain about the `reg` and `wire` is not clear enough(at least for me). Then this is my own understanding. **Wire** means conduction. Once the input changed, the output change directly. While **reg** can have original value and the value of **reg** can only be changed when a **trigger** activates on it.

**Note: wire can be set by `assign`  but reg can only be set in `initial`or `always` sentence**

The next step is to design instantiation for the testbench. The code are as below:

```verilog
Hello_world uut{
	.IN(IN),
	.OUT(OUT)
};
```

the structure of the sentence should be like: **.IO name('Connect register or wire name'),** and it shoule be noticed that comma here is used to seperate.

The next step is to activate the testbench. Enter the code below:

```verilog
initial begin
    # 100; // wait 100 ns the global reset finish
    IN = 0; //initialise the input
    # 500 IN = 1; //set in as 1 after 500ns
end
```

It should be notice that it is not actually 100ns to react, it depends on the timescale on the top of the source code. 
$$
1ns = 1ps
$$
Then the whole testbench should like this:

```verilog
`timescale 1ms / 1ps

module Helloworld_TB{
    // define the input and output
    reg IN; 
    wire OUT;
    
    Hello_world uut{ // It should be notice that the file name should be consist with the source file
        .IN(IN),
        .OUT(OUT)
    }
    
    initial begin
        #100; // wait 100ns to global reset
        IN = 0; // give the initial value to input
        #500 IN = 1; // after 500ns change the initial value
    end
    
   endmodule
    
}
```

After that click **"Run Simulation"** and choose **"Run Behavioral Simulation"**. 

### Step 5:  Create the design constrains

XDC is used to recognize the pin-out of the device. We need to write XDC to tell the tool which pins are connected to which outputs of the FPGA.

Then create the new source file and choose the **"add or generate constraints"**  choose the file type as **XDC** and set purpose file name. After that add the code below into the source file.

```verilog
set_property PACKAGE_PIN V17 [get_ports IN]
set_property IONSTADARD LVCMOS33 [get_ports IN]

set_property PACKAGE_PIN V16 [get_ports OUT]
set_property IONSTADARD LVCMOS33 [get_ports OUT]
```

This is just connect the input signal in pin V17 and output pin in V16.

### **Step 6: The rest process:**

Run the implementation, generate the bitstream file, open the new target and program the devices. Then we can use the switch to control the LED.



## Attention:

The first time program the FPGA may have some problems. But in most case the mistakes focus on the spelling issue and coding. If mistakes occurs, just check the code especially spelling.