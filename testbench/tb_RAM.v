`include "RAM.v"
`timescale 1ns / 100ps 

module tb_RAM;
    reg [9:0] ADDRESS;
    reg [63:0] DATA_IN;
    reg WRITE_ENABLE;
    reg CLK;

    reg [63:0] DATA_OUT;

    RAM ram(ADDRESS, DATA_IN, WRITE_ENABLE, CLK, DATA_OUT);

    initial begin
        // Write #1
        ADDRESS = 1;
        DATA_IN = 55;
        WRITE_ENABLE = 1;
        CLK = 1; #20; CLK = 0; #20;

        // Write #2
        ADDRESS = 2;
        DATA_IN = 99;
        WRITE_ENABLE = 1;
        CLK = 1; #20; CLK = 0; #20;

        // Read #1
        ADDRESS = 1;
        WRITE_ENABLE = 0;
        DATA_IN = 0;
        CLK = 1; #20; CLK = 0; #20;

        // Read #2
        ADDRESS = 2;
        WRITE_ENABLE = 0;
        DATA_IN = 0;
        CLK = 1; #20; CLK = 0; #20;
    end

    initial begin
        $dumpfile("vcd/ram.vcd");
        $dumpvars(0, tb_RAM);
    end
endmodule