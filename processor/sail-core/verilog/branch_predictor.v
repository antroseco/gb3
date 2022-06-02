/*
	Authored 2018-2019, Ryan Voo.

	All rights reserved.
	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions
	are met:

	*	Redistributions of source code must retain the above
		copyright notice, this list of conditions and the following
		disclaimer.

	*	Redistributions in binary form must reproduce the above
		copyright notice, this list of conditions and the following
		disclaimer in the documentation and/or other materials
		provided with the distribution.

	*	Neither the name of the author nor the names of its
		contributors may be used to endorse or promote products
		derived from this software without specific prior written
		permission.

	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
	"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
	LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
	FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
	COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
	INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
	BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
	CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
	LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
	ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
	POSSIBILITY OF SUCH DAMAGE.
*/



/*
 *		Branch Predictor FSM
 */

module branch_predictor(
		clk,
		actual_branch_decision,
		request_prediction,
		update_state,
		in_addr,
		offset,
		branch_addr,
		prediction
	);

	/*
	 *	Inputs
	 */
	input		clk;
	input		actual_branch_decision;
	input		request_prediction;
	input		update_state;
	input [31:0]	in_addr;
	input [31:0]	offset;

	/*
	 *	Outputs
	 */
	output [31:0]	branch_addr;
	output		prediction;

	/*
	 *	Internal state.
	 *
	 *	The instruction memory can store up to 0x1000 instructions. We'd
	 *	like to keep separate state for each instruction, but that would
	 *	take up too much area. Hence, assume that we'll stay in the same
	 *	function for some time and use bits 5:2 to identify 16 states
	 *	(the 2 LSBs are always 0 because instructions are word-aligned).
	 *	The 6 MSBs could be stored and verified, but that is probably
	 *	not worth the effort---we would still need to make a random
	 *	prediction, so might as well use the pre-existing state.
	 */
	localparam	STRONGLY_NOT_TAKEN	= 2'b00;
	localparam	WEAKLY_NOT_TAKEN	= 2'b01;
	localparam	WEAKLY_TAKEN		= 2'b10;
	localparam	STRONGLY_TAKEN		= 2'b11;

	reg [1:0]	state[15:0];
	reg [3:0]	last_tag;
	wire [3:0]	tag;

	/*
	 *	The `initial` statement below uses Yosys's support for nonzero
	 *	initial values:
	 *
	 *		https://github.com/YosysHQ/yosys/commit/0793f1b196df536975a044a4ce53025c81d00c7f
	 *
	 *	Rather than using this simulation construct (`initial`),
	 *	the design should instead use a reset signal going to
	 *	modules in the design and to thereby set the values.
	 */
	integer i;
	initial begin
		for (i = 0; i < 16; i = i + 1) begin
			state[i] = 2'b10;
			/* Need to explicitly dump arrays. */
			$dumpvars(0, state[i]);
		end
	end

	always @(negedge clk) begin
		/*
		 * negedge executes after posedge, so we can't use last_tag
		 * later when assigning to output reg prediction.
		 */
		if (request_prediction)
			last_tag <= tag;
	end

	/*
	 *	Using this microarchitecture, branches can't occur consecutively
	 *	therefore can use branch_mem_sig as every branch is followed by
	 *	a bubble, so a 0 to 1 transition.
	 *
	 *	branch_mem_sig should thus be assigned to update_state.
	 */
	always @(posedge clk) begin
		if (update_state) begin
			case (state[last_tag])
				STRONGLY_NOT_TAKEN: begin
					if (actual_branch_decision == 1)
						state[last_tag] <= WEAKLY_NOT_TAKEN;
				end

				WEAKLY_NOT_TAKEN: begin
					if (actual_branch_decision == 1)
						state[last_tag] <= WEAKLY_TAKEN;
					else
						state[last_tag] <= STRONGLY_NOT_TAKEN;
				end

				WEAKLY_TAKEN: begin
					if (actual_branch_decision == 1)
						state[last_tag] <= STRONGLY_TAKEN;
					else
						state[last_tag] <= WEAKLY_NOT_TAKEN;
				end

				STRONGLY_TAKEN: begin
					if (actual_branch_decision == 0)
						state[last_tag] <= WEAKLY_TAKEN;
				end
			endcase
		end
	end

	assign tag = in_addr[5:2];
	assign branch_addr = in_addr + offset;
	assign prediction = (state[tag] == WEAKLY_TAKEN ||
			     state[tag] == STRONGLY_TAKEN) & request_prediction;
endmodule
