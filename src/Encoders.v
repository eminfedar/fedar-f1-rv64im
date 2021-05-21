module Encoder_4 (
    input [3:0] in,
    output reg [1:0] out
  );
  initial begin
    out = 0;
  end

  always @(in) begin
    casex (in)
      4'b1xxx : out = 3;
      4'b01xx : out = 2;
      4'b001x : out = 1;
      4'b0001 : out = 0;
      4'b0000 : out = 0;
      default: out = 0;
    endcase
  end
endmodule

module Encoder_8 (
    input [7:0] in,
    output reg [2:0] out
  );
  initial begin
    out = 0;
  end
  
  always @(in) begin
    casex (in)
      8'b1xxxxxxx : out = 7;
      8'b01xxxxxx : out = 6;
      8'b001xxxxx : out = 5;
      8'b0001xxxx : out = 4;
      8'b00001xxx : out = 3;
      8'b000001xx : out = 2;
      8'b0000001x : out = 1;
      8'b00000001 : out = 0;
      8'b00000000 : out = 0;
      default: out = 0;
    endcase
  end
  
endmodule

module Encoder_16 (
    input [15:0] in,
    output reg [3:0] out
  );
  initial begin
    out = 0;
  end
  
  always @(in) begin
    casex (in)
      16'b1xxxxxxxxxxxxxxx : out = 15;
      16'b01xxxxxxxxxxxxxx : out = 14;
      16'b001xxxxxxxxxxxxx : out = 13;
      16'b0001xxxxxxxxxxxx : out = 12;
      16'b00001xxxxxxxxxxx : out = 11;
      16'b000001xxxxxxxxxx : out = 10;
      16'b0000001xxxxxxxxx : out = 9;
      16'b00000001xxxxxxxx : out = 8;
      16'b000000001xxxxxxx : out = 7;
      16'b0000000001xxxxxx : out = 6;
      16'b00000000001xxxxx : out = 5;
      16'b000000000001xxxx : out = 4;
      16'b0000000000001xxx : out = 3;
      16'b00000000000001xx : out = 2;
      16'b000000000000001x : out = 1;
      16'b0000000000000001 : out = 0;
      16'b0000000000000000 : out = 0;
      default: out = 0;
    endcase
  end
  
endmodule