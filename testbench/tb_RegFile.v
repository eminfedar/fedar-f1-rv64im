`include "RegFile.v"
`timescale 1ns / 100ps 

module tb_RegFile;
    reg [4:0]reg1;
    reg [4:0]reg2;
    reg [4:0]reg_write;
    reg [63:0]reg_write_data;
    reg reg_write_enable;

    wire [63:0]reg1_data;
    wire [63:0]reg2_data;

    RegFile regfile(reg1, reg2, reg_write, reg_write_data, reg_write_enable, reg1_data, reg2_data );

    initial begin
        reg1 = 0;
        reg2 = 0;
        reg_write = 0;
        reg_write_data = 0;
        reg_write_enable = 0;
        #20;

        reg1 = 0;
        reg2 = 0;
        reg_write = 1;
        reg_write_data = 5;
        reg_write_enable = 1;
        #20;

        reg1 = 1;
        reg2 = 0;
        reg_write = 2;
        reg_write_data = 10;
        reg_write_enable = 1;
        #20;

        reg1 = 1;
        reg2 = 2;
        reg_write = 0;
        reg_write_data = 0;
        reg_write_enable = 0;
        #20;
    end

    initial begin
        $dumpfile("vcd/regfile.vcd");
        $dumpvars(0, tb_RegFile);
    end
endmodule