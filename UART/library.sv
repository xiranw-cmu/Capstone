//used file from hw7 solutions

`default_nettype none

module MagComp
  #(parameter   WIDTH = 8)
  (output logic             AltB, AeqB, AgtB,
   input  logic [WIDTH-1:0] A, B);

  assign AeqB = (A == B);
  assign AltB = (A <  B);
  assign AgtB = (A >  B);

endmodule: MagComp

module Adder
  #(parameter WIDTH=8)
  (input  logic [WIDTH-1:0] A, B,
   input  logic             Cin,
   output logic [WIDTH-1:0] S,
   output logic             Cout);
   
   assign {Cout, S} = A + B + Cin;
   
endmodule : Adder

module Multiplexer
  #(parameter WIDTH=8)
  (input  logic [WIDTH-1:0]         I,
   input  logic [$clog2(WIDTH)-1:0] S,
   output logic                     Y);
   
   assign Y = I[S];
   
endmodule : Multiplexer

module Mux2to1
  #(parameter WIDTH = 8)
  (input  logic [WIDTH-1:0] I0, I1,
   input  logic             S,
   output logic [WIDTH-1:0] Y);
   
  assign Y = (S) ? I1 : I0;
  
endmodule : Mux2to1

module Decoder
  #(parameter WIDTH=8)
  (input  logic [$clog2(WIDTH)-1:0] I,
   input  logic                     en,
   output logic [WIDTH-1:0]         D);
   
  always_comb begin
    D = 0;
    if (en)
      D = 1'b1 << I;
  end
  
endmodule : Decoder

module Register
  #(parameter WIDTH=8)
  (input  logic [WIDTH-1:0] D,
   input  logic             en, clear, clock,
   output logic [WIDTH-1:0] Q);
   
  always_ff @(posedge clock)
    if (clear)
      Q <= 0;
    else if (en)
      Q <= D;
      
endmodule : Register

module Demux
  (input logic D,
   input logic [1:0] sel,
   output logic q1, q2, q3, q4);

  always_comb begin
    q1 = 0; q2 = 0; q3 = 0; q4 = 0;
    if (sel == 2'd0)
      q1 = D;
    else if (sel == 2'd1)
      q2 = D;
    else if (sel == 2'd2)
      q3 = D;
    else
      q4 = D;
  end

endmodule: Demux

module Counter
  #(parameter WIDTH=8, parameter START=0)
  (input logic [WIDTH - 1:0] D,
   input logic clock, en, clear, load, up,
   output logic [WIDTH - 1:0] Q);

  always_ff @(posedge clock)
    if (clear)
      Q <= START;
    else if (load)
      Q <= D;
    else if (en)
      if (up)
        Q <= Q + 1;
      else
        Q <= Q - 1;

endmodule: Counter

module ShiftRegister
  #(parameter WIDTH=8)
  (input logic [WIDTH - 1:0] D,
   input logic clock, en, left, load,
   output logic [WIDTH - 1:0] Q);

  always_ff @(posedge clock)
    if (load)
      Q <= D;
    else if (en)
      if (left)
        Q <= {Q[WIDTH - 2:0], 1'b0};
      else
        Q <= {1'b0, Q[WIDTH - 1:1]};

endmodule: ShiftRegister

module BarrelShiftRegister
  #(parameter WIDTH=8)
  (input logic [WIDTH - 1:0] D,
   input logic clock, en, load,
   input logic [1:0] by,
   output logic [WIDTH - 1:0] Q);

  always_ff @(posedge clock)
    if (load)
      Q <= D;
    else if (en)
      if (by == 2'b0)
        Q <= Q;
      else if (by == 2'b01)
        Q <= {Q[WIDTH - 2:0], 1'b0};
      else if (by == 2'b10)
        Q <= {Q[WIDTH - 3:0], 2'b0};
      else
        Q <= {Q[WIDTH - 4:0], 3'b0};

endmodule: BarrelShiftRegister

// LSB to MSB
module SIPORegister 
  #(parameter  WIDTH = 8)
  (input logic clock, reset, en,
   input logic in,
   output logic [WIDTH - 1:0] out);
  
  always_ff @(posedge clock, posedge reset) begin
    if (reset) out <= '0;
    else if (en) out <= (out >> 1) | (in << (WIDTH - 1));
  end

  
endmodule: SIPORegister

module PISORegister 
  #(parameter  WIDTH = 8)
  (input logic clock, reset, en, load,
   input logic [WIDTH - 1:0] in,
   output logic out);

  logic [WIDTH - 1:0] Q;
  assign out = Q[WIDTH-1];
  
  always_ff @(posedge clock, posedge reset) begin
    if (reset) Q <= '0;
    else if (load) Q <= in;
    else if (en) Q <= Q << 1;
  end
  
endmodule: PISORegister

module Memory
  #(parameter W = 256, AW = $clog2(W), DW = 16)
  (input logic [AW - 1:0] Addr,
   input logic clock, re, we,
   inout tri [DW - 1:0] Data);

  logic [DW - 1:0] M[W];
  logic [DW - 1:0] out;

  assign Data = (re) ? out : 'bz;

  always_ff @(posedge clock)
    if (we)
      M[Addr] <= Data;

  always_comb begin
    out = M[Addr];
  end

endmodule: Memory

module RangeCheck
  #(parameter WIDTH = 8)
  (input logic [WIDTH-1:0] val, high, low,
   output logic is_between);

  always_comb begin
    if (val <= high & val >= low)
      is_between = 1;
    else
      is_between = 0;
  end

endmodule: RangeCheck

module OffsetCheck
  #(parameter WIDTH = 8)
  (input logic [WIDTH-1:0] val, delta, low,
   output logic is_between);

  logic [WIDTH-1:0] high;

  assign high = low + delta;

  RangeCheck #(WIDTH) rc(.*);

endmodule: OffsetCheck

// creates flipflop with variable input and output sizes
module dFlipFlop
  (input  logic  D,
   input  logic  clock, reset,
   output logic  Q);

  always_ff @(posedge clock, posedge reset)
    if (reset)  Q <= 0;
    else        Q <= D;
endmodule: dFlipFlop

module Synchronizer
  (input  logic D, clock, reset,
   output logic Q);
    
  logic temp;
  dFlipFlop ff1(.Q(temp), .*);
  dFlipFlop ff2(.D(temp), .*);
endmodule: Synchronizer
