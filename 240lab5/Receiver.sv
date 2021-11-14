/* Author: Grace Fieni, Ali Hoffmann
 * AndrewID: gfieni, alhoffma
 * Date: 11/13/21
 * Class: 18-500
 */
`default_nettype none

module Receiver 
  (input logic clock, reset, serialIn,
   output logic [7:0] messageByte,
   output logic isNew);

  logic en;  
  logic [3:0] count;
  logic countClear, countErr;
  logic [14:0] parallelOut;
  logic shiftErr;
  logic [12:0] decodedOut;
  
  Counter #(4) bitCounter(.D('0), 
                          .clock, 
                          .en, 
                          .clear(countClear), 
                          .load(1'd0), 
                          .up(1'd1), 
                          .Q(count));
  
  SIPORegister #(15) shiftReg(.clock, 
                              .reset, 
                              .en,
                              .in(serialIn),
                              .out(parallelOut));

  SECDEDdecoder dec(.inCode(parallelOut[13:1]),
                    .syndrome( ),
                    .is1BitErr( ), 
                    .is2BitErr(shiftErr),
                    .outCode(decodedOut));

  /* Counter Status and Control Bits */
  assign countErr = isNew && (parallelOut[0]);
  assign countClear = reset | (count == 'd14);
  assign en = ((count == '0) && serialIn) || (count > '0 && count <= 'd14);

  /* Output logic */
  assign messageByte = (shiftErr | countErr) ? 'h15 : {decodedOut[12:9], decodedOut[7:5], decodedOut[3]};
  always_ff @(posedge clock, posedge reset) begin
      if (reset) isNew <= 1'd0;
      else isNew <= count == 4'd14;
  end
    
endmodule: Receiver