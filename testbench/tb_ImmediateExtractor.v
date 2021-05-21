`include "ImmediateExtractor.v"
`timescale 1ns / 100ps 

module tb_ImmediateExtractor;
    reg [31:0] INSTRUCTION;
    reg [2:0] SELECTION;
    reg signed [63:0] VALUE;

    ImmediateExtractor ie(INSTRUCTION, SELECTION, VALUE);

    initial begin
        INSTRUCTION = 32'h00A00613; // addi x12 x0 10  // Expects: 10
        SELECTION = 1; // I Type
        #20;

        INSTRUCTION = 32'h00001337; // lui x6 1  // Expects: 4096
        SELECTION = 2; // U Type
        #20;

        INSTRUCTION = 32'h00B323A3; // sw x11 7(x6) // Expects: 7
        SELECTION = 3; // S Type
        #20;

        INSTRUCTION = 32'hFEC5CAE3; // blt x11 x12 -12 // Expects: -12
        SELECTION = 4; // B Type
        #20;

        INSTRUCTION = 32'h4000006F; // jal x0 1024 // Expects: 1024
        SELECTION = 5; // UJ Type
        #20;
    end

    initial begin
        $dumpfile("vcd/immediateextractor.vcd");
        $dumpvars(0, tb_ImmediateExtractor);
    end
endmodule