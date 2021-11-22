`default_nettype none

module chipInterface (
    input  logic       CLOCK_50, UART_RXD,
    input  logic [3:0] KEY,
    output logic       UART_TXD,
    output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4);
    logic        clock, reset, isNew_r;
    logic [19:0] message_r;

    logic        isNew_t, ready;
    logic [19:0] message_t;

    assign reset = ~KEY[0];

    Receiver rec (.clock, .reset, .isNew(isNew_r), .message(message_r), .serialIn(UART_RXD));

    Transmitter trans (.clock, .reset, .isNew(isNew_t), .message(message_t), .serialOut(UART_TXD), .ready);

    SevenSegmentControl ssc (.HEX7(), .HEX6(), .HEX5(), .HEX4, .HEX3, .HEX2, .HEX1, .HEX0,
                            .BCD7(), .BCD6(), .BCD5(), .BCD4(message_r[19:16]), .BCD3(message_r[15:12]), .BCD2(message_r[11:8]), .BCD1(message_r[7:4]), .BCD0(message_r[3:0]), .turn_on(7'b111_1111));
    // display the rec on the HEX and then send back something different?
    always_ff @(posedge clock, posedge reset) begin
        isNew_t <= 1'b0;
        if (reset) 
            message_t <= '0;
        if (ready && isNew_r) begin
            if (message_r[19:16] < 8'h61) 
                message_t[19:16] <= (message_r[19:16] + 8'h20)
            else
                message_t[19:16] <= (message_r[19:16] - 8'h20)
            
            if (message_r[15:12] < 8'h61) 
                message_t[15:12] <= (message_r[15:12] + 8'h20)
            else
                message_t[15:12] <= (message_r[15:12] - 8'h20)

            if (message_r[11:8] < 8'h61) 
                message_t[11:8] <= (message_r[11:8] + 8'h20)
            else
                message_t[11:8] <= (message_r[11:8] - 8'h20)

            if (message_r[7:4] < 8'h61) 
                message_t[7:4] <= (message_r[7:4] + 8'h20)
            else
                message_t[7:4] <= (message_r[7:4] - 8'h20)

            message_t[3:0] <= message_r[3:0];
            isNew_t <= 1'b1;

        end
    end


endmodule: chipInterface