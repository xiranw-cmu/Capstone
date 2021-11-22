`default_nettype none
module BCDtoSevenSegment
  (input  logic [3:0] bcd,
   output logic [6:0] segment);
  always_comb begin
    case(bcd)
      4'b0000: segment = 7'b1000000;
      4'b0001: segment = 7'b1111001;
      4'b0010: segment = 7'b0100100;
      4'b0011: segment = 7'b0110000;
      4'b0100: segment = 7'b0011001;
      4'b0101: segment = 7'b0010010;
      4'b0110: segment = 7'b0000010;
      4'b0111: segment = 7'b1111000;
      4'b1000: segment = 7'b0000000;
      4'b1001: segment = 7'b0010000;
      4'b1010: segment = 7'b0001000;

      4'b1011: segment = 7'b0000011;
      4'b1100: segment = 7'b1000110;
      4'b1101: segment = 7'b0100001;
      4'b1110: segment = 7'b0000110;
      4'b1111: segment = 7'b0001110;
      default: segment = 7'b1111111;
    endcase
  end
endmodule: BCDtoSevenSegment

module SevenSegmentDigit
  (input  logic [3:0] bcd,
   output logic [6:0] segment,
   input  logic       blank);

   logic [6:0] decoded;
   
   BCDtoSevenSegment b2ss(.bcd(bcd), .segment(decoded));
   always_comb begin
     if (blank == 0) begin
       segment = 7'b1111111;
     end
     else begin
       segment = decoded;
     end 
   end 
endmodule: SevenSegmentDigit

module SevenSegmentControl
  (output logic [6:0] HEX7, HEX6, HEX5, HEX4,
   output logic [6:0] HEX3, HEX2, HEX1, HEX0,
   input  logic [3:0] BCD7, BCD6, BCD5, BCD4,
   input  logic [3:0] BCD3, BCD2, BCD1, BCD0,
   input  logic [7:0] turn_on);
   
  SevenSegmentDigit ssd7(.bcd(BCD7), .segment(HEX7), .blank(turn_on[7]));
  SevenSegmentDigit ssd6(.bcd(BCD6), .segment(HEX6), .blank(turn_on[6]));
  SevenSegmentDigit ssd5(.bcd(BCD5), .segment(HEX5), .blank(turn_on[5]));
  SevenSegmentDigit ssd4(.bcd(BCD4), .segment(HEX4), .blank(turn_on[4]));
  SevenSegmentDigit ssd3(.bcd(BCD3), .segment(HEX3), .blank(turn_on[3]));
  SevenSegmentDigit ssd2(.bcd(BCD2), .segment(HEX2), .blank(turn_on[2]));
  SevenSegmentDigit ssd1(.bcd(BCD1), .segment(HEX1), .blank(turn_on[1]));
  SevenSegmentDigit ssd0(.bcd(BCD0), .segment(HEX0), .blank(turn_on[0]));

endmodule: SevenSegmentControl
