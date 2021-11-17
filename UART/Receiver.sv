/* Author: Grace Fieni, Ali Hoffmann
 * AndrewID: gfieni, alhoffma
 * Date: 11/13/21
 * Class: 18-500
 */
`default_nettype none

module Receiver_wrapper 
  (input logic clock, reset, serialIn,
   output logic isNew,
   output logic [19:0] message);
   
  logic isValid, clear, serialSync, edgeDetected, tempSync, en;
  logic [4:0] count; 
  Receiver rec(.*);
  
  // counter/ sampler
  Counter #(5) sampleCounter (.D(5'd0),
                              .clock,
                              .en(en),
                              .clear,
                              .load(1'b0),
                              .up(1'b1),
                              .Q(count));
  
  // synchronize serialIn
  Synchronizer sync(.D(serialIn), .Q(serialSync), .*);
  // edge detection  
  dFlipFlop edgeDetect(.D(serialSync), .Q(tempSync), .*);
  assign edgeDetected = tempSync ^ serialSync;
  
  always_ff @(posedge clock, posedge reset) begin
    clear <= 0;
    isValid <= 0;
    if (reset) begin
      clear <= 1;
      isValid <= 0;
      en <= 0;
    end
    else if (edgeDetected) begin
      $display("edge detected!\n");
      clear <= 1;
      en <= 1;
    end
    else if ( count == 2)
      isValid <= 1;
    else if (count == 7)
      clear <= 1;
    else if (isNew)
      en <= 0;
    end
     
endmodule: Receiver_wrapper

// handles serial input to parallel output
module Receiver 
  (input logic clock, reset, serialIn, isValid,
   output logic [19:0] message,
   output logic isNew);

  logic en;  
  logic [4:0] count;
  logic countClear, countErr;
  logic [21:0] parallelOut;
  logic shiftErr;

  
  Counter #(5) bitCounter(.D('0), 
                          .clock, 
                          .en, 
                          .clear(countClear), 
                          .load(1'd0), 
                          .up(1'd1), 
                          .Q(count));
  
  SIPORegister #(22) shiftReg(.clock, 
                              .reset, 
                              .en,
                              .in(serialIn),
                              .out(parallelOut));

  /* Counter Status and Control Bits */
  assign countErr = isNew && (parallelOut[0]);
  assign countClear = reset | (count == 'd21);
  assign en = (((count == '0) && serialIn) || (count > '0 && count <= 'd21)) && isValid;

  /* Output logic */
  assign message = (countErr) ? 'h15 : parallelOut[20:1];
  always_ff @(posedge clock, posedge reset) begin
      if (reset) isNew <= 1'd0;
      else isNew <= count == 5'd21;
  end
    
endmodule: Receiver
