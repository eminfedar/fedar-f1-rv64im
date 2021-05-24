module ALU(
    input [63:0]X,
    input [63:0]Y,
    input [3:0]OP,

    output reg [63:0]result_reg,
    output isEqual
);
    wire signed [63:0] X_signed = X;
    wire signed [63:0] Y_signed = Y;

    assign isEqual = X == Y;

    always @(*) begin
        case (OP)
            0:  result_reg <= X + Y; // add
            1:  result_reg <= X - Y; // sub
            2:  result_reg <= X & Y; // and
            3:  result_reg <= X | Y; // or
            4:  result_reg <= X ^ Y; // xor
            5:  result_reg <= X << Y; // shift left logical
            6:  result_reg <= X >> Y; // shift right logical
            7:  result_reg <= X_signed >>> Y; // shift right arithmetic
            8:  result_reg <= X * Y; // mul
            9:  result_reg <= X * Y; // mulh will be implemented
            10: result_reg <= X / Y; // div
            11: result_reg <= X % Y; // rem
            12: result_reg <= (X_signed < Y_signed ? 1 : 0); // set less than (slt)
            13: result_reg <= (X < Y ? 1 : 0); // set less than (sltu)
        endcase
    end
endmodule