/* Author: Grace Fieni, Ali Hoffmann
 * AndrewID: gfieni, alhoffma
 * Date: 11/13/21
 * Class: 18-500
 */
`default_nettype none

module Receiver_wrapper 
  (input logic clock, reset, serialIn,
   output logic isNew,
   output logic [7:0] message);
   
  logic isValid, clear, serialSync, edgeDetected, tempSync, en;
  logic [4:0] count; 
  Receiver rec(.*);
  
  // counter/ sampler
  Counter #(5,1) sampleCounter (.D(5'd0),
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
    if (reset) begin
      clear <= 1;
      isValid <= 0;
      en <= 0;
    end
    else if (edgeDetected) begin
      clear <= 1;
      en <= 1;
    end
    else if (count == 3) begin
      isValid <= 1;
      clear <= 0;
    end
    else if (count == 9) begin
      clear <= 1;
      isValid <= 0;
    end
    else if (isNew) begin
      en <= 0;
      clear <= 0;
      isValid <= 0;
    end
    else begin
      clear <= 0;
      isValid <= 0;
    end
  end
     
endmodule: Receiver_wrapper

// handles serial input to parallel output
module Receiver 
  (input logic clock, reset, serialIn, isValid,
   output logic [7:0] message,
   output logic isNew);

  logic en;  
  logic [3:0] count;
  logic countClear, countErr;
  logic [9:0] parallelOut;
  logic shiftErr;

  
  Counter #(4,0) bitCounter(.D('0), 
                          .clock, 
                          .en, 
                          .clear(countClear), 
                          .load(1'd0), 
                          .up(1'd1), 
                          .Q(count));
  
  // changing register so that it's sent LSB-> MSB
  SIPORegister #(10) shiftReg(.clock,
                              .reset, 
                              .en,
                              .in(serialIn),
                              .out(parallelOut));

  /* Counter Status and Control Bits */
  // assign countErr = isNew && (parallelOut[0]);
  assign countClear = reset | (count == 'd10);
  assign en = (((count == '0) && !serialIn) || (count > '0 && count <= 'd10)) && isValid;

  /* Output logic */
  assign message = parallelOut[8:1];
  always_ff @(posedge clock, posedge reset) begin
      if (reset) isNew <= 1'd0;
      else isNew <= count == 5'd10;
  end
    
endmodule: Receiver
