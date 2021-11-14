/* Author: Grace Fieni, Ali Hoffmann
 * AndrewID: gfieni, alhoffma
 * Date: 11/13/21
 * Class: 18-500
 */
`default_nettype none

module SECDEDdecoder
//   (input logic clock,           // posedge
//    input logic [15:1] ham,
//    output logic [15:1] fixed);  // the corrected bit vector
//                                 // Must be Q output of a register
  (input logic [12:0] inCode,
   output logic [3:0] syndrome,
   output logic is1BitErr, is2BitErr,
   output logic [12:0] outCode);

  logic globalP;

  assign outCode = inCode ^ (1 << syndrome);
  assign is1BitErr = globalP != inCode[0];
  assign is2BitErr = (!is1BitErr) && (syndrome != 0);

  always_comb begin
    syndrome[0] = inCode[1] ^ inCode[3] ^ inCode[5] ^ inCode[7]
            ^ inCode[9] ^ inCode[11];
    syndrome[1] = inCode[2] ^ inCode[3] ^ inCode[6] ^ inCode[7]
            ^ inCode[10] ^ inCode[11];
    syndrome[2] = inCode[4] ^ inCode[5] ^ inCode[6] ^ inCode[7]
            ^ inCode[12];
    syndrome[3] = inCode[8] ^ inCode[9] ^ inCode[10] ^ inCode[11]
            ^ inCode[12];
    globalP = ^inCode[12:1];
  end

endmodule: SECDEDdecoder
