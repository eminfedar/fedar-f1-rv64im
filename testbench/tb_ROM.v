`include "ROM.v"
`timescale 1ns / 100ps 

module tb_ROM;
    reg [9:0] ADDRESS;
    reg [31:0] DATA_OUT;

    ROM rom(ADDRESS, DATA_OUT);

    initial begin
        ADDRESS = 0; #20;
        ADDRESS = 1; #20;
        ADDRESS = 2; #20;
        ADDRESS = 3; #20;
        ADDRESS = 4; #20;
        ADDRESS = 5; #20;
        ADDRESS = 20; #20;
    end

    initial begin
        $dumpfile("vcd/rom.vcd");
        $dumpvars(0, tb_ROM);
    end
endmodule