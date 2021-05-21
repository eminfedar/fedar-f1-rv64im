module RAM(
    input [9:0] ADDRESS,
    input [63:0] DATA_IN,
    input WRITE_ENABLE,
    input CLK,
    
    output [63:0] DATA_OUT
);
    reg [63:0] memory [1023:0];

    initial begin
        for(int i=0; i<1024; i=i+1) begin
            memory[i] <= 0;
        end
    end

    assign DATA_OUT = memory[ADDRESS];

    always @(posedge CLK) begin
        if (WRITE_ENABLE)
            memory[ADDRESS] <= DATA_IN;
    end

endmodule