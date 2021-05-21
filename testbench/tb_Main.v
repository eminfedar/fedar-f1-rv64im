`include "CPU.v"
`include "RAM.v"
`include "ROM.v"
`timescale 1ns / 100ps 

module tb_Main;
    wire [9:0] RAM_ADDR;
    wire [63:0] RAM_READ_DATA;
    wire [63:0] RAM_WRITE_DATA;
    wire RAM_WRITE_ENABLE;

    wire [9:0] INSTRUCTION_ADDR;
    wire [31:0] INSTRUCTION;
    reg CLK = 1;
    
    CPU cpu(
        .RAM_READ_DATA(RAM_READ_DATA),
        .INSTRUCTION(INSTRUCTION),
        .CLK(CLK),

        .RAM_ADDR(RAM_ADDR),
        .RAM_WRITE_DATA(RAM_WRITE_DATA),
        .RAM_WRITE_ENABLE(RAM_WRITE_ENABLE),
        .INSTRUCTION_ADDR(INSTRUCTION_ADDR)
    );
    
    ROM rom(
        .ADDRESS(INSTRUCTION_ADDR),

        .DATA(INSTRUCTION)
    );

    RAM ram(
        .ADDRESS(RAM_ADDR),
        .DATA_IN(RAM_WRITE_DATA),
        .WRITE_ENABLE(RAM_WRITE_ENABLE),
        .CLK(CLK),

        .DATA_OUT(RAM_READ_DATA)    
    );

    initial begin
        for(int i=0; i<40; i=i+1) begin
            CLK=1; #20; CLK=0; #20;
        end
    end

    initial begin
        $dumpfile("vcd/main.vcd");
        $dumpvars(0, tb_Main);
    end
    
endmodule