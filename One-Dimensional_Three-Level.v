module TOP(clk, reset, in_data, d1_out, d2_out, d3_out, d4_out, ld1_out, ld2_out, ld3_out, ld4_out, ld5_out,  L_out, H_out
		, state, mux_a, mux_b, mux_c, mux_d, mux_e);
	output [2:0] state;
	output [7:0] mux_a, mux_b, mux_c, mux_d, mux_e;

	input clk;
	input reset;
	input [7:0] in_data;
	output[7:0] d1_out, d2_out, d3_out, d4_out;
	output [7:0] ld1_out, ld2_out, ld3_out, ld4_out, ld5_out;
	output [7:0] L_out;
	output [7:0] H_out;

	parameter S1 = 3'd0;
	parameter S2 = 3'd1;
	parameter S3 = 3'd2;
	parameter S4 = 3'd3;
	parameter S5 = 3'd4;
	parameter S6 = 3'd5;
	parameter S7 = 3'd6;
	parameter S8 = 3'd7;



	reg[7:0] d_out[3:0];
	reg[7:0] ld_out[4:0];


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
	wire [7:0] mux_a;
	wire [7:0] mux_b;
	wire [7:0] mux_c;
	wire [7:0] mux_d;
	wire [7:0] mux_e;
	reg [2:0] state, nstate;
	reg [47:0] reg_b;
	reg [47:0] reg_c;
	reg [39:0] reg_d;

	assign mux_a = (state == S1 | state == S3 | state == S5 | state == S7) ? in_data :
				   (state == S4 | state == S8) ? reg_d[15:8] :
				   (state == S6) ? 	reg_d[23:16] :
				   8'd0;


	assign mux_b = (state == S2 | state == S4 | state == S6 | state == S8) ? in_data :
				   (state == S1 | state == S5) ? reg_d[7:0] :
				   (state == S7) ? ld_out[4] :
				   8'd0;


	assign mux_c = (state == S2 | state == S4 | state == S6 | state == S8) ? d_out[2]	: 	
				   (state == S1 | state == S5) ? reg_b[39:32] :
				   (state == S7) ? reg_b[7:0] :
				   8'd0;


	assign mux_d = (state == S1 | state == S3 | state == S5 | state == S7 ) ? ld_out[1] :
	 			   (state == S2 | state == S6) ? reg_d[31:24] :
	 			   (state == S8) ? reg_d[39:32] : 
	 			   8'd0;

	assign mux_e = (state == S1 | state == S3 | state == S5 | state == S7 ) ? ld_out[3] :
				   (state == S2 | state == S6) ? reg_c[39:32] :
	 			   (state == S8) ? reg_c[7:0]: 
	 			   8'd0;

	always@(posedge clk, posedge reset)begin
		if(reset)begin
			state <= S1;
		end
		else begin
			state <= nstate;
		end
	end

	always@(*)begin
		case(state)
			S1 :	 nstate = S2;
			S2 : 	 nstate = S3;
			S3 : 	 nstate = S4;
			S4 : 	 nstate = S5;
			S5 : 	 nstate = S6;
			S6 : 	 nstate = S7;
			S7 : 	 nstate = S8;
			S8 : 	 nstate = S1;
			default: nstate = S1;
		endcase
	end

	integer x;
	always@(posedge clk, posedge reset)begin
		if(reset)begin
			for (x = 0; x < 4; x = x + 1)begin
				d_out[x] <= 8'd0;
			end
		end
		else begin
			d_out[0] <= mux_a >> 1;
			d_out[1] <= mux_b - d_out[0];
			d_out[2] <= d_out[1];
			d_out[3] <= mux_c - d_out[0];
		end
	end

	always@(posedge clk, posedge reset)begin
		if(reset)begin
			for (x = 0; x < 5; x = x + 1)begin
				ld_out[x] <= 8'd0;
			end
		end
		else begin
			ld_out[0] <= in_data;
			ld_out[1] <= ld_out[0];
			ld_out[2] <= (d_out[3] >> 2) + mux_d;
			ld_out[3] <= ld_out[2];
			ld_out[4] <= (d_out[3] >> 2) + mux_e;
		end
	end

	always@(posedge clk, posedge reset)begin
		if(reset)begin
			reg_b <= 48'd0;
		end
		else begin
			reg_b <= {d_out[2], reg_b[47:8]};
		end
	end

	always@(posedge clk, posedge reset)begin
		if(reset)begin
			reg_c <= 48'd0;
		end
		else begin
			reg_c <= {ld_out[3], reg_c[47:8]};
		end
	end

	always@(posedge clk, posedge reset)begin
		if(reset)begin
			reg_d <= 40'd0;
		end
		else begin
			reg_d <= {reg_d[31:0], ld_out[4]};
		end
	end

endmodule