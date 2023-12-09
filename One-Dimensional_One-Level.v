module TOP(clk, reset, in_data, d1_out, d2_out, d3_out, d4_out, ld1_out, ld2_out, ld3_out, ld4_out, ld5_out,  L_out, H_out);
	input clk;
	input reset;
	input [7:0] in_data;
	output[7:0] d1_out, d2_out, d3_out, d4_out;
	output [7:0] ld1_out, ld2_out, ld3_out, ld4_out, ld5_out;
	output [7:0] L_out;
	output [7:0] H_out;

	parameter ODD = 1'd0;
	parameter EVEN = 1'd1;
	reg[7:0] d_out[3:0];
	reg[7:0] ld_out[4:0];

	wire[7:0] sub1;
	wire[7:0] sub2;

	assign sub1 = in_data - d_out[0];
	assign sub2 = d_out[2] - d_out[0];
	assign H_out = d_out[3];
	assign L_out = ld_out[4];
	assign d1_out = d_out[0];
	assign d2_out = d_out[1];
	assign d3_out = d_out[2];
	assign d4_out = d_out[3];
	assign ld1_out = ld_out[0];
	assign ld2_out = ld_out[1];
	assign ld3_out = ld_out[2];
	assign ld4_out = ld_out[3];
	assign ld5_out = ld_out[4];
	reg state, nstate;


	always@(posedge clk, posedge reset)begin
		if(reset)begin
			state <= ODD;
		end
		else begin
			state <= nstate;
		end
	end

	always@(*)begin
		case(state)
			ODD  : nstate = EVEN;
			EVEN : nstate = ODD;
			default: nstate = ODD;
		endcase
	end



	always@(posedge clk, posedge reset)begin
		if(reset)begin
			d_out[0] <= 8'd0;
			d_out[1] <= 8'd0;
		end
		else begin
			case(state)
				ODD : d_out[0] <= in_data >> 1;
				EVEN: d_out[1] <= sub1;
			endcase
		end
	end


	always@(posedge clk, posedge reset)begin
		if(reset)begin
			d_out[2] <= 8'd0;
			d_out[3] <= 8'd0;
		end
		else begin
			d_out[2] <= d_out[1];
			d_out[3] <= sub2;
		end
	end

	integer x;
	always@(posedge clk, posedge reset)begin
		if(reset)begin
			for (x = 0; x < 5; x = x + 1) begin
				ld_out[x] <= 8'd0;
			end
		end
		else begin
			ld_out[0] <= in_data;
			ld_out[1] <= ld_out[0];
			ld_out[2] <= (d_out[3] >> 2) + ld_out[1];
			ld_out[3] <= ld_out[2];
			ld_out[4] <= (d_out[3] >> 2) + ld_out[3];
		end
	end

endmodule