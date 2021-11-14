/* Author: Grace Fieni, Ali Hoffmann
 * AndrewID: gfieni, alhoffma
 * Date: 11/13/21
 * Class: 18-500
 */
`default_nettype none

module Receiver_tb();

  logic clock, reset;
  logic serial, isNew;
  logic [7:0] messageByte;

  initial begin
      clock = 0;
      forever #1 clock = ~clock;
  end

  initial begin
      reset = 0;
      @(posedge clock);
      reset <= 1;
      @(posedge clock);
      reset <= 0; 
      #10000 $finish;
  end

  always_comb begin
      if (isNew) $display("%x", messageByte);
  end

  Receiver rec(.serialIn(serial), .*);

  Sender sen(.serialOut(serial), .*);
    
endmodule: Receiver_tb