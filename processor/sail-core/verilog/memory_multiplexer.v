module  memory_multiplexer(
	input [1:0]	addr_lsb,
	input [31:0]	word_buf,
	input [31:0]	write_data_buffer,
	input [3:0]	sign_mask_buf,
	output [31:0]	read_buf,
	output [31:0]	replacement_word
);
	/*
	 *	Regs for multiplexer output
	 */
	wire [7:0]		buf0;
	wire [7:0]		buf1;
	wire [7:0]		buf2;
	wire [7:0]		buf3;

	assign 			buf0	= word_buf[7:0];
	assign 			buf1	= word_buf[15:8];
	assign 			buf2	= word_buf[23:16];
	assign 			buf3	= word_buf[31:24];

	/*
	 *	Byte select decoder
	 */
	wire bdec_sig0;
	wire bdec_sig1;
	wire bdec_sig2;
	wire bdec_sig3;

	assign bdec_sig0 = (addr_lsb == 2'b00);
	assign bdec_sig1 = (addr_lsb == 2'b01);
	assign bdec_sig2 = (addr_lsb == 2'b10);
	assign bdec_sig3 = (addr_lsb == 2'b11);

	/*
	 *	Constructing the word to be replaced for write byte
	 */
	wire[7:0] byte_r0;
	wire[7:0] byte_r1;
	wire[7:0] byte_r2;
	wire[7:0] byte_r3;

	assign byte_r0 = (bdec_sig0 == 1'b1) ? write_data_buffer[7:0] : buf0;
	assign byte_r1 = (bdec_sig1 == 1'b1) ? write_data_buffer[7:0] : buf1;
	assign byte_r2 = (bdec_sig2 == 1'b1) ? write_data_buffer[7:0] : buf2;
	assign byte_r3 = (bdec_sig3 == 1'b1) ? write_data_buffer[7:0] : buf3;

	/*
	 *	For write halfword
	 */
	wire[15:0] halfword_r0;
	wire[15:0] halfword_r1;

	assign halfword_r0 = (addr_lsb[1] == 1'b1) ? {buf1, buf0} : write_data_buffer[15:0];
	assign halfword_r1 = (addr_lsb[1] == 1'b1) ? write_data_buffer[15:0] : {buf3, buf2};

	/*
	 * a is sign_mask_buf[2], b is sign_mask_buf[1], c is sign_mask_buf[0]
	 *
	 * From sign_mask_gen:
	 *
	 * 3'b001;			// byte only
	 * 3'b011;			// halfword
	 * 3'b111;			// word
	 * default: mask = 3'b000;	// should not happen for loads/stores
	 */
	wire write_select_byte;
	wire write_select_word;

	assign write_select_byte = ~sign_mask_buf[1];
	assign write_select_word = sign_mask_buf[2];

	wire [31:0] write_out_partial;

	assign write_out_partial = write_select_byte ?
		{byte_r3, byte_r2, byte_r1, byte_r0} :
		{halfword_r1, halfword_r0};

	assign replacement_word = write_select_word ?
		write_data_buffer : write_out_partial;

	/*
	 *	Combinational logic for generating 32-bit read data
	 *	TODO: Figure out what this does and make it readable.
	 */
	wire select0;
	wire select1;
	wire select2;

	wire[31:0] out1;
	wire[31:0] out2;
	wire[31:0] out3;
	wire[31:0] out4;
	wire[31:0] out5;
	wire[31:0] out6;

	/*
	 * a is sign_mask_buf[2], b is sign_mask_buf[1], c is sign_mask_buf[0],
	 * d is addr_lsb[1], e is addr_lsb[0]
	 */

	assign select0 = (~sign_mask_buf[2] & ~sign_mask_buf[1] & ~addr_lsb[1] & addr_lsb[0]) | (~sign_mask_buf[2] & addr_lsb[1] & addr_lsb[0]) | (~sign_mask_buf[2] & sign_mask_buf[1] & addr_lsb[1]); //~a~b~de + ~ade + ~abd
	assign select1 = (~sign_mask_buf[2] & ~sign_mask_buf[1] & addr_lsb[1]) | (sign_mask_buf[2] & sign_mask_buf[1]); // ~a~bd + ab
	assign select2 = sign_mask_buf[1]; //b

	assign out1 = select0 ? ((sign_mask_buf[3]==1'b1) ? {{24{buf1[7]}}, buf1} : {24'b0, buf1}) : ((sign_mask_buf[3]==1'b1) ? {{24{buf0[7]}}, buf0} : {24'b0, buf0});
	assign out2 = select0 ? ((sign_mask_buf[3]==1'b1) ? {{24{buf3[7]}}, buf3} : {24'b0, buf3}) : ((sign_mask_buf[3]==1'b1) ? {{24{buf2[7]}}, buf2} : {24'b0, buf2});
	assign out3 = select0 ? ((sign_mask_buf[3]==1'b1) ? {{16{buf3[7]}}, buf3, buf2} : {16'b0, buf3, buf2}) : ((sign_mask_buf[3]==1'b1) ? {{16{buf1[7]}}, buf1, buf0} : {16'b0, buf1, buf0});
	assign out4 = select0 ? 32'b0 : {buf3, buf2, buf1, buf0};

	assign out5 = select1 ? out2 : out1;
	assign out6 = select1 ? out4 : out3;

	assign read_buf = select2 ? out6 : out5;
endmodule
