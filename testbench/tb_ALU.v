`include "ALU.v"
`timescale 1ns / 100ps 

module tb_ALU;
    reg [63:0]a;
    reg [63:0]b;
    reg [3:0]op;

    wire [63:0]result;
    wire isEqual;

    ALU alu(a, b, op, result, isEqual );

    initial begin
        // ADD
        a = 5;
        b = 5;
        op = 0;
        #20;

        // SUB
        a = 66;
        b = 11;
        op = 1;
        #20;

        // AND
        a = 3'b101;
        b = 3'b110;
        op = 2;
        #20;

        // OR
        a = 3'b101;
        b = 3'b110;
        op = 3;
        #20;

        // XOR
        a = 3'b110;
        b = 3'b010;
        op = 4;
        #20;

        // Shift Left Logical
        a = 1;
        b = 3;
        op = 5;
        #20;

        // Shift Right Logical
        a = 8;
        b = 2;
        op = 6;
        #20;

        // Shift Right Arithmetic
        a = -8;
        b = 2;
        op = 7;
        #20;

        // Multiply
        a = 6;
        b = 5;
        op = 8;
        #20;

        // Multiply High
        a = 5;
        b = 3;
        op = 9;
        #20;

        // Divide
        a = 66;
        b = 11;
        op = 10;
        #20;

        // Remainder
        a = 62;
        b = 3;
        op = 11;
        #20;

        // Signed Less Than
        a = -1;
        b = 9;
        op = 12;
        #20;

        // Unsigned Less Than
        a = -1;
        b = 9;
        op = 13;
        #20;
    end

    initial begin
        $dumpfile("vcd/alu.vcd");
        $dumpvars(0, tb_ALU);
    end
endmodule