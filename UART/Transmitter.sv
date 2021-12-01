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
   
  logic clear, clearCount, sample;
  logic [4:0] count; 
  Transmitter transmit(.*);
  
  // counter/ sampler
  Counter #(5,0) sampleCounter (.D(5'd0),
                              .clock,
                              .en(1'd1), // probably dont want to hardcode
                              .clear(clearCount),
                              .load(1'b0),
                              .up(1'b1),
                              .Q(count));
  assign sample = clear;
  assign clearCount = clear | isNew;
  assign clear = count == 9;
  
  // always_ff @(posedge clock, posedge reset) begin
  //   if (reset) begin
  //     clear <= 1;
  //   end
  //   else if (count == 8) // might need to change
  //     clear <= 1;
  //   else
  //     clear <= 0;
  // end
     
endmodule: Transmitter_wrapper

// handles serial input to parallel output
module Transmitter 
  (input logic clock, reset, isNew, sample,
   input logic [19:0] message,
   output logic serialOut, ready);

  logic en, out;  
  logic [4:0] count;
  logic countClear; 
  
  Counter #(5,0) bitCounter(.D('0), 
                          .clock, 
                          .en, 
                          .clear(countClear), 
                          .load(1'd0), 
                          .up(1'd1), 
                          .Q(count));
  
  PISORegister #(30) shiftReg(.clock, 
                              .reset, 
                              .en,
                              .load(isNew),
                              .in({1'b1, message[3:0], 4'b0, 1'b0, // LSB sends last
                                   1'b1, message[11:4],      1'b0, 
                                   1'b1, message[19:12],     1'b0}), // MSB sends first
                              .out(out));

	assign serialOut = ready ? 1'b1 : out;				
  /* Counter Status and Control Bits */
  assign countClear = reset | ((count == 'd29) && sample);

  enum logic [1:0] {WAIT, FIRSTBIT, BODY} state, nextState;
  always_ff @(posedge clock, posedge reset)
    if (reset)
      state <= WAIT;
    else 
      state <= nextState;
    
  always_comb begin
    en = 0;
    ready = 0;
    case (state) 
      WAIT: begin
        nextState = isNew ? FIRSTBIT : WAIT;
        ready = isNew ? 0 : 1;
      end
      FIRSTBIT: begin
        nextState = sample ? BODY : FIRSTBIT;
        en = sample;
      end
      BODY: begin
        nextState = (count == 'd29) && sample ? WAIT : BODY;
		    ready = (count == 'd29) && sample ? 1 : 0;
        en = sample;
      end
    endcase
  end
    
endmodule: Transmitter
