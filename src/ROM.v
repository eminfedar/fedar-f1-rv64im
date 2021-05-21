module ROM(
    input [9:0] ADDRESS,    
    output [31:0] DATA
);
    reg [31:0] memory [1023:0]; // 10-bit address. 32-bit cell size.

    assign DATA = memory[ADDRESS];

    initial begin
        // Example program:

        memory[0] = 32'h00000013; // nop (add x0 x0 0)
        
        // start:
        memory[1] = 32'h00100093; // addi x1 x0 1
        memory[2] = 32'h00100313; // addi x6 x0 1
        memory[3] = 32'h00400613; // addi x12 x0 4
        memory[4] = 32'h0060A023; // sw x6 0(x1)        x6 R2 Dep (WB)

        // loop:
        memory[5] = 32'h0000A303; // lw x6 0(x1)        
        memory[6] = 32'h00130313; // addi x6 x6 1       LoadStall and x6 R1 Dep (WB)
        memory[7] = 32'h0060A023; // sw x6 0(x1)        x6 R2 Dep
        memory[8] = 32'hFEC34AE3; // blt x6 x12 -12     x6 R1 Dep (WB)

        // data_dep_test:
        memory[9] = 32'h03700413; // addi x8 x0 55
        memory[10] = 32'h00800433; // add x8 x0 x8      x8 R2 Dep
        memory[11] = 32'h00140413; // addi x8 x8 1      x8 R1 Dep
        
        // finish:
        memory[12] = 32'h00000013; // nop (add x0 x0 0)
    end
endmodule
