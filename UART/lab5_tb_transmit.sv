/* Author: Grace Fieni, Ali Hoffmann
 * AndrewID: gfieni, alhoffma
 * Date: 11/13/21
 * Class: 18-500
 */
`default_nettype none

module Transmitter_tb();

  logic clock, reset, clock2, ready, serialOut;
  logic serial, isNew, isValid;
  logic [19:0] message;

  initial begin
      clock = 0;
      forever #2 clock = ~clock;
  end

  // initial begin
  //   clock2 = 0;
  //   #27;
  //   forever #20 clock2 = ~clock2;
  // end

  initial begin
      reset = 0;
      @(posedge clock);
      reset <= 1;
      @(posedge clock);
      reset <= 0;
      message <= 20'b10100011000101001111;
      isNew <= 1'b1;
      @(posedge clock);
      isNew <= 1'b0;
      #5000 $finish;
  end

  always_comb begin
    // if (isNew) $display("%b", message);
  end
  initial begin
    $monitor($time,,"serial: %b ready: %b reset: %b\n", serialOut, ready, reset);
  end
  Transmitter_wrapper rec(.*);

  // Sender sen(.serialOut(serial), .clock(clock2), .*);
    
endmodule: Transmitter_tb
