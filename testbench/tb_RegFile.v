`include "RegFile.v"
`timescale 1ns / 100ps 

module tb_RegFile;
    reg [4:0]R1;
    reg [4:0]R2;
    reg [4:0]RD;
    reg [63:0]RD_DATA;
    reg reg_write_enable;

    wire [63:0]R1_data;
    wire [63:0]R2_data;

    RegFile regfile(R1, R2, RD, RD_DATA, reg_write_enable, R1_data, R2_data );

    initial begin
        R1 = 0;
        R2 = 0;
        RD = 0;
        RD_DATA = 0;
        reg_write_enable = 0;
        #20;

        R1 = 0;
        R2 = 0;
        RD = 1;
        RD_DATA = 5;
        reg_write_enable = 1;
        #20;

        R1 = 1;
        R2 = 0;
        RD = 2;
        RD_DATA = 10;
        reg_write_enable = 1;
        #20;

        R1 = 1;
        R2 = 2;
        RD = 0;
        RD_DATA = 0;
        reg_write_enable = 0;
        #20;
    end

    initial begin
        $dumpfile("vcd/regfile.vcd");
        $dumpvars(0, tb_RegFile);
    end
endmodule