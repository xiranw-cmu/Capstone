`default_nettype none

module top(    
    input  logic       CLOCK_50, UART_RXD,
    input  logic [3:0] KEY,
    output logic       UART_TXD,
	 output logic [17:0] LEDR,
    output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4);
    
	 logic        clock, reset, isNew_r, isNew_r_delay, isNew_r_delay_2, isNew_r_delay_3, isNew_r_delay_4, delay_5;
    logic [15:0] message_r;

    logic        isNew_t, ready;
    logic [19:0] message_t;
	
	 PLL pll(.inclk0(CLOCK_50), .c0(clock));
	
    assign reset = ~KEY[0];
	 assign LEDR[0] = ready;

    Receiver_wrapper rec (.clock, .reset, .isNew(isNew_r), .message(message_r), .serialIn(UART_RXD));

    Transmitter_wrapper trans (.clock, .reset, .isNew(isNew_t), .message(message_t), .serialOut(UART_TXD), .ready);

    Core DUT(.clock(clock), .reset_n(KEY[0]), .instr_valid(isNew_r), .instr(message_r), .reg_dump(message_t), .isNew_t);
	 
	 SevenSegmentControl ssc (.HEX7(), .HEX6(), .HEX5(), .HEX4, .HEX3, .HEX2, .HEX1, .HEX0,
                            .BCD7(), .BCD6(), .BCD5(), .BCD4(message_t[19:16]), .BCD3(message_t[15:12]), .BCD2(message_t[11:8]), .BCD1(message_t[7:4]), .BCD0(message_t[3:0]), .turn_on(7'b111_1111));
endmodule: top