`default_nettype none

module top(    
    input  logic        CLOCK_50, UART_RXD,
    input  logic [3:0]  KEY,
    output logic        UART_TXD,
	output logic [17:0] LEDR,
    output logic [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4);
    
	logic        clock, reset, isNew_r;
    logic [15:0] message_r;

    logic        isNew_t, ready;
    logic [19:0] message_t;
	
	PLL pll(.inclk0(CLOCK_50), .c0(clock));
	
    assign reset = ~KEY[0];

    Receiver_wrapper rec (.clock, .reset, .isNew(isNew_r), .message(message_r), .serialIn(UART_RXD));

    Transmitter_wrapper trans (.clock, .reset, .isNew(isNew_t), .message(message_t), .serialOut(UART_TXD), .ready);

    Core DUT(.clock(clock), .reset_n(KEY[0]), .instr_valid(isNew_r), .instr(message_r), .reg_dump(message_t));

    always_ff @(posedge clock, posedge reset) begin
        isNew_t <= isNew_r;
    end


endmodule: top