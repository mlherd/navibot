
module uart6_a7 (  input   uart_rx,
                   output  uart_tx,
                   input   clk_in,
                   output [7:0] led, 
				   output l_mtr_ctrl,
				   output r_mtr_ctrl,
				   output l_led_en,
				   output r_led_en,
				   output slow0_fast1
                );

//
///////////////////////////////////////////////////////////////////////////////////////////
// Signals
///////////////////////////////////////////////////////////////////////////////////////////
//

wire        clk100;
wire        clk;

// Signal used to specify the clock frequency in megahertz.

wire [7:0]  clock_frequency_in_MHz; 
reg l_mtr_ctrl, r_mtr_ctrl, r_led_en, l_led_en;

// Signals used to connect KCPSM6

wire [11:0] address;
wire [17:0] instruction;
wire        bram_enable;
reg  [7:0]  in_port;
wire [7:0]  out_port;
wire [7:0]  port_id;
wire        write_strobe;
wire        k_write_strobe;
wire        read_strobe;
wire        interrupt;   
wire        interrupt_ack;
wire        kcpsm6_sleep;  
wire        kcpsm6_reset;
wire        rdl;

// Signals used to connect UART_TX6

wire [7:0]  uart_tx_data_in;
wire        write_to_uart_tx;
reg         pipe_port_id0;
wire        uart_tx_data_present;
wire        uart_tx_half_full;
wire        uart_tx_full;
reg         uart_tx_reset;

// Signals used to connect UART_RX6


wire [7:0]  uart_rx_data_out;
reg         read_from_uart_rx;
wire        uart_rx_data_present;
wire        uart_rx_half_full;
wire        uart_rx_full;
reg         uart_rx_reset;

// Signals used to define baud rate
reg [7:0]   led;
reg [7:0]   set_baud_rate;
//reg [7:0]   baud_rate_counter;
reg         en_16_x_baud;
reg slow0_fast1;


  /////////////////////////////////////////////////////////////////////////////////////////
  // Assign constant value which specifies the clock frequency in megahertz. 
  /////////////////////////////////////////////////////////////////////////////////////////

  assign clock_frequency_in_MHz = 8'd100;


  /////////////////////////////////////////////////////////////////////////////////////////
  // Create and distribute an internal 100MHz clock
  /////////////////////////////////////////////////////////////////////////////////////////
  // BUFG used to reach the entire device with 100MHz

  BUFG clock_divide ( 
      .I(clk_in),
      .O(clk));

  /////////////////////////////////////////////////////////////////////////////////////////
  // Instantiate KCPSM6 and connect to program ROM
  /////////////////////////////////////////////////////////////////////////////////////////
  //
  // The generics can be defined as required. In this case the 'hwbuild' value is used to 
  // define a version using the ASCII code for the desired letter. 
  //


  kcpsm6 #(
	.interrupt_vector	(12'h7FF),
	.scratch_pad_memory_size(64),
	.hwbuild		(8'h41))            // 41 hex is ASCII Character "A"
  processor (
	.address 		(address),
	.instruction 	(instruction),
	.bram_enable 	(bram_enable),
	.port_id 		(port_id),
	.write_strobe 	(write_strobe),
	.k_write_strobe 	(k_write_strobe),
	.out_port 		(out_port),
	.read_strobe 	(read_strobe),
	.in_port 		(in_port),
	.interrupt 		(interrupt),
	.interrupt_ack 	(interrupt_ack),
	.reset 		(kcpsm6_reset),
	.sleep		(kcpsm6_sleep),
	.clk 			(clk)); 

  // Reset connected to JTAG Loader enabled Program Memory

  assign kcpsm6_reset = rdl;

  // Unused signals tied off until required.
  // Tying to other signals used to minimise warning messages.
 
  assign kcpsm6_sleep = write_strobe && k_write_strobe;  // Always '0'
  assign interrupt = interrupt_ack;

  
  // Development Program Memory 
  //   JTAG Loader enabled for rapid code development. 
  
  d8btx_v1 #(
	.C_FAMILY		   ("7S"),  
	.C_RAM_SIZE_KWORDS	(2),  
	.C_JTAG_LOADER_ENABLE	(1))
  program_rom (
 	.rdl 			(rdl),
	.enable 		(bram_enable),
	.address 		(address),
	.instruction 	(instruction),
	.clk 			(clk));


  /////////////////////////////////////////////////////////////////////////////////////////
  // UART Transmitter with integral 16 byte FIFO buffer
  /////////////////////////////////////////////////////////////////////////////////////////
  //
  // Write to buffer in UART Transmitter at port address 01 hex
  // 

  uart_tx6 tx(
      .data_in(uart_tx_data_in),
      .en_16_x_baud(en_16_x_baud),
      .serial_out(uart_tx),
      .buffer_write(write_to_uart_tx),
      .buffer_data_present(uart_tx_data_present),
      .buffer_half_full(uart_tx_half_full ),
      .buffer_full(uart_tx_full),
      .buffer_reset(uart_tx_reset),              
      .clk(clk));


  /////////////////////////////////////////////////////////////////////////////////////////
  // UART Receiver with integral 16 byte FIFO buffer
  /////////////////////////////////////////////////////////////////////////////////////////
  //
  // Read from buffer in UART Receiver at port address 01 hex.
  //
  // When KCPMS6 reads data from the receiver a pulse must be generated so that the 
  // FIFO buffer presents the next character to be read and updates the buffer flags.
  // 

  uart_rx6 rx(
      .serial_in(uart_rx),
      .en_16_x_baud(en_16_x_baud ),
      .data_out(uart_rx_data_out ),
      .buffer_read(read_from_uart_rx ),
      .buffer_data_present(uart_rx_data_present ),
      .buffer_half_full(uart_rx_half_full ),
      .buffer_full(uart_rx_full ),
      .buffer_reset(uart_rx_reset ),              
      .clk(clk ));

  //
  /////////////////////////////////////////////////////////////////////////////////////////
  // RS232 (UART) baud rate 
  /////////////////////////////////////////////////////////////////////////////////////////
  //
  // The baud rate is defined by the frequency of 'en_16_x_baud' pulses. These should occur  
  // at 16 times the desired baud rate. KCPSM6 computes and sets an 8-bit value into 
  // 'set_baud_rate' which is used to divide the clock frequency appropriately.
  // 
  // For example, if the clock frequency is 200MHz and the desired serial communication 
  // baud rate is 115200 then PicoBlaze will set 'set_baud_rate' to 6C hex (108 decimal). 
  // This circuit will then generate an 'en_16_x_baud' pulse once every 109 clock cycles 
  // (note that 'baud_rate_counter' will include state zero). This would actually result 
  // in a baud rate of 114,679 baud but that is only 0.45% low and well within limits.
  //

reg [11:0]   baud_rate_counter;

  always @ (posedge clk )
  begin
    if (baud_rate_counter == 12'd650) begin    
      baud_rate_counter <= 12'd0;
      en_16_x_baud <= 1'b1;                 // single cycle enable pulse
    end
    else begin
      baud_rate_counter <= baud_rate_counter + 12'd1;
      en_16_x_baud <= 1'b0;
    end
  end

  //
  /////////////////////////////////////////////////////////////////////////////////////////
  // General Purpose Input Ports. 
  /////////////////////////////////////////////////////////////////////////////////////////
  //
  // Three input ports are used with the UART macros. 
  // 
  // The first is used to monitor the flags on both the transmitter and receiver.
  // The second is used to read the data from the receiver and generate a 'buffer_read' 
  //   pulse. 
  // The third is used to read a user defined constant that enabled KCPSM6 to know the 
  //   clock frequency so that it can compute values which will define the BAUD rate 
  //   for UART communications (as well as values used to define software delays).
  //

  always @ (posedge clk)
  begin
    case (port_id[1:0]) 
      
        // Read UART status at port address 00 hex
        2'b00 : in_port <= { 2'b00,
                             uart_rx_full,
                             uart_rx_half_full,
                             uart_rx_data_present,
                             uart_tx_full, 
                             uart_tx_half_full,
                             uart_tx_data_present };


        // Read UART_RX6 data at port address 01 hex
        // (see 'buffer_read' pulse generation below) 
        2'b01 : in_port <= uart_rx_data_out;

        // Read clock frequency contant at port address 02 hex
        2'b10 : in_port <= clock_frequency_in_MHz;

        // Specify don't care for all other inputs to obtain optimum implementation
        default : in_port <= 8'bXXXXXXXX ;  

    endcase;

    // Generate 'buffer_read' pulse following read from port address 01

    if ((read_strobe == 1'b1) && (port_id[1:0] == 2'b01)) begin
        read_from_uart_rx <= 1'b1;
      end
      else begin
        read_from_uart_rx <= 1'b0;
      end

  end


  //
  /////////////////////////////////////////////////////////////////////////////////////////
  // General Purpose Output Ports 
  /////////////////////////////////////////////////////////////////////////////////////////
  //
  // In this design there are two general purpose output ports. 
  //
  //   A port used to write data directly to the FIFO buffer within 'uart_tx6' macro.
  // 
  //   A port used to define the communication BAUD rate of the UART.
  //
  // Note that the assignment and decoding of 'port_id' is a one-hot resulting 
  // in the minimum number of signals actually being decoded for a fast and 
  // optimum implementation.  
  // 

  always @ (posedge clk)
  begin

      // 'write_strobe' is used to qualify all writes to general output ports.
      if (write_strobe == 1'b1) begin

        // Write to UART at port addresses 01 hex
        // See below this clocked process for the combinatorial decode required.

        // Write to 'set_baud_rate' at port addresses 02 hex     
        // This value is set by KCPSM6 to define the BAUD rate of the UART. 
        // See the 'UART baud rate' section for details.

        if (port_id == 8'd2) begin
          set_baud_rate <= out_port;
        end
        if (port_id == 8'd4) begin
          led <= out_port;
        end
		if (port_id == 8'd8) begin
          l_mtr_ctrl <= out_port[0];
        end
		if (port_id == 8'd16) begin
          r_mtr_ctrl <= out_port[0];
        end
		if (port_id == 8'd32) begin
          l_led_en <= out_port[0];
        end
		if (port_id == 8'd64) begin
          r_led_en <= out_port[0];
        end
        if (port_id == 8'd128) begin
          slow0_fast1 <= out_port[0];
        end

      end

      //
      // *** To reliably achieve 200MHz performance when writing to the FIFO buffer
      //     within the UART transmitter, 'port_id' is pipelined to exploit both of  
      //     the clock cycles that it is valid.
      //

      pipe_port_id0 <= port_id[0];


  end

  //
  // Write directly to the FIFO buffer within 'uart_tx6' macro at port address 01 hex.
  // Note the direct connection of 'out_port' to the UART transmitter macro and the 
  // way that a single clock cycle write pulse is generated to capture the data.
  // 

  assign uart_tx_data_in = out_port;

  // See *** above for definition of 'pipe_port_id0'. 

  assign write_to_uart_tx = write_strobe & pipe_port_id0;


  //
  /////////////////////////////////////////////////////////////////////////////////////////
  // Constant-Optimised Output Ports 
  /////////////////////////////////////////////////////////////////////////////////////////
  //
  // One constant-optimised output port is used to facilitate resetting of the UART macros.
  //

  always @ (posedge clk)
  begin

    if (k_write_strobe == 1'b1) begin

      if (port_id[0] == 1'b1) begin
          uart_tx_reset <= out_port[0];
          uart_rx_reset <= out_port[1];
      end

    end
  end

  /////////////////////////////////////////////////////////////////////////////////////////


endmodule

//
///////////////////////////////////////////////////////////////////////////////////////////
// END OF FILE uart6_kc705.v
///////////////////////////////////////////////////////////////////////////////////////////
//
