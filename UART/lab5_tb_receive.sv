/* Author: Grace Fieni, Ali Hoffmann
 * AndrewID: gfieni, alhoffma
 * Date: 11/13/21
 * Class: 18-500
 */
`default_nettype none

module Receiver_tb();

  logic clock, reset, clock2;
  logic serial, isNew, isValid;
  logic [7:0] message;

  initial begin
      clock = 0;
      forever #2 clock = ~clock;
  end

  initial begin
    clock2 = 0;
    #27;
    forever #20 clock2 = ~clock2;
  end

  initial begin
      reset = 0;
      @(posedge clock2);
      reset <= 1;
      @(posedge clock2);
      reset <= 0; 
      #5000 $finish;
  end

  always_comb begin
    if (isNew) $display("%b", message);
  end
  initial begin
    //$monitor($time,,"serial: %b isNew: %b isValid: %b reset: %b\n", serial, isNew, rec.isValid,reset);
  end
  Receiver_wrapper rec(.serialIn(serial), .*);

  Sender sen(.serialOut(serial), .clock(clock2), .*);
    
endmodule: Receiver_tb
