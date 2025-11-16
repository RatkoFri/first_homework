
module top (
    input  logic        clk,        // System clock
    input  logic        rst,      // Active-low reset
    input  logic        uart_rx,    // UART receive line
    output logic        uart_tx,     // UART transmit line
    output logic        PWM_red,
    output logic        PWM_green,
    output logic        PWM_blue,
    output logic        done
);

    // Internal signals
    logic [7:0] rx_data;            // Data received from UART
    logic       tx_done, tx_done_next;           // Ready signal for UART transmitter
    logic       tx_start, tx_start_next;           // Start signal for UART transmitter
    logic [7:0] tx_data;            // Data to be transmitted via UART

    // To uart system receiver
    logic rx_read, rx_read_next; 
    logic rx_empty;
    logic rx_valid; 
    logic rx_done; // Data received from UART


    logic done_next;

    // UART Receiver instance
    uart_system_receiver uart_receiver (
        .clock     (clk),
        .reset     (rst),
        .rx        (uart_rx),
        .data_out  (rx_data),
        .rx_done (rx_done)       // Assuming rx_valid indicates if data is available
    );

    // UART Transmitter instance
    uart_system_transmitter uart_transmitter (
        .clock    (clk),
        .reset    (rst),
        .wr_data  (tx_data),
        .wr_uart  (tx_start),
        .tx_done  (tx_done),
        .tx       (uart_tx)
    );

    // Shift register with parallel read instance
    logic rd_en, rd_en_next;
    logic [47:0] token;
    logic shift_reg_reset;
    assign shift_reg_reset = rst | done;

    shift_reg_with_par_read #(
        .DATA_WIDTH (8),   
        .DEPTH      (6)
    ) u_shift_reg_with_par_read (
        .clk        (clk),
        .rst        (shift_reg_reset),
        .wr_en      (rx_done),
        .rd_en      (rd_en),
        .wr_data    (rx_data),
        .rd_data    (token)
    );


    // Control logic for RGB
    // on ctrl_valid signal we update the ctrl register 
    // ctrl register holds the 6 bit control signal for RGB controller 
    // extracted from the token
    logic [5:0] ctrl;
    logic ctrl_valid, ctrl_valid_next;

       // Instantiate the RGB controller

    logic rgb_controller_reset;
    logic rgb_controller_start;
    assign rgb_controller_reset = rst | rgb_controller_start;
    
    rgb_controller rgb_controller_inst (
        .clock  (clk),
        .reset  (rgb_controller_reset),
        .SW     (ctrl),
        .RGB    ({PWM_red, PWM_green, PWM_blue})
    );
 


    // Message bytes to be transmitted
    // "Ready\n" and "Control\n"
    logic [7:0] message_byte [0:15];
    initial begin
        message_byte[0]  = "R";
        message_byte[1]  = "e";
        message_byte[2]  = "a";
        message_byte[3]  = "d";
        message_byte[4]  = "y";
        message_byte[5]  = "\n";
        message_byte[6] = 8'h0; // Null terminator
        message_byte[7]  = "C";
        message_byte[8]  = "o";
        message_byte[9]  = "n";
        message_byte[10]  = "t";
        message_byte[11] = "r";
        message_byte[12] = "o";
        message_byte[13] = "l";
        message_byte[14] = "\n";
        message_byte[15] = 8'h0; // Null terminator
    end


 
    // control logic for UART transmission


    // define the states
    typedef enum logic [1:0] { // binary encoding
        PRINT1,
        AWAIT,
        CONTROL,
        PRINT2
    } state_echo;

    state_echo state, next_state;
    logic [3:0] tx_index, tx_index_next;


    // State transition logic
    



    logic stop_flag;
    // stop flag is equal to 1 if we receive new line
    assign stop_flag = (rx_data == 8'h0A && rx_done) ? 1 : 0; 

    // Next state logic
    always_comb begin
        
    end





endmodule