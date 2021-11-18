/* Author: Grace Fieni, Ali Hoffmann
 * AndrewID: gfieni, alhoffma
 * Date: 11/13/21
 * Class: 18-500
 */
`default_nettype none

module Transmitter_wrapper 
  (input logic clock, reset, isNew,
   input logic [19:0] message,
   output logic serialOut, ready);
   
  // logic isValid, clear, serialSync, edgeDetected, tempSync, en;
  logic clear, clearCount;
  logic [4:0] count; 
  Transmitter transmit(.en(clearCount), .*);
  
  // counter/ sampler
  Counter #(5) sampleCounter (.D(5'd0),
                              .clock,
                              .en(1'd1),
                              .clear(clearCount),
                              .load(1'b0),
                              .up(1'b1),
                              .Q(count));
  
  // // synchronize serialIn
  // Synchronizer sync(.D(serialIn), .Q(serialSync), .*);
  // // edge detection  
  // dFlipFlop edgeDetect(.D(serialSync), .Q(tempSync), .*);
  // assign edgeDetected = tempSync ^ serialSync;

  assign clearCount = clear | isNew;
  
  always_ff @(posedge clock, posedge reset) begin
    clear <= 0;
    if (reset) begin
      clear <= 1;
    end
    else if (count == 8) // might need to change
      clear <= 1;
     
endmodule: Transmitter_wrapper

// handles serial input to parallel output
module Transmitter 
  (input logic clock, reset, isNew, en,
   input logic [19:0] message,
   output logic serialOut, ready);

  // logic en;  
  logic [4:0] count;
  logic countClear; //, countErr;
  // logic [21:0] parallelOut;
  // logic shiftErr;

  
  Counter #(5) bitCounter(.D('0), 
                          .clock, 
                          .en, 
                          .clear(countClear), 
                          .load(1'd0), 
                          .up(1'd1), 
                          .Q(count));
  
  PISORegister #(22) shiftReg(.clock, 
                              .reset, 
                              .en,
                              .load(isNew),
                              .in(message),
                              .out(serialOut));

  /* Counter Status and Control Bits */
  // assign countErr = isNew && (parallelOut[0]);
  assign countClear = reset | (count == 'd21);
  // assign en = (((count == '0) && isNew) || (count > '0 && count <= 'd21));

  /* Output logic */
  assign ready = count == '0;
  // always_ff @(posedge clock, posedge reset) begin
  //     if (reset) isNew <= 1'd0;
  //     else isNew <= count == 5'd21;
  // end
    
endmodule: Transmitter
