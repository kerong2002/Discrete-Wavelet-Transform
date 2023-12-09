module TOP(clk, reset, in_data, d1_out, d2_out, d3_out, d4_out, ld1_out, ld2_out, ld3_out, ld4_out, ld5_out,  L_out, H_out);
	input clk;
	input reset;
	input [7:0] in_data;
	output[7:0] d1_out, d2_out, d3_out, d4_out;
	output [7:0] ld1_out, ld2_out, ld3_out, ld4_out, ld5_out;
	output [7:0] L_out;
	output [7:0] H_out;

	parameter S1 = 2'd0;
	parameter S2 = 2'd1;
	parameter S3 = 2'd2;
	parameter S4 = 2'd3;

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
	reg [1:0] state, nstate;
	reg [15:0] reg_b;
	reg [15:0] reg_c;
	reg [31:0] reg_d;

	assign mux_a = (state == S1) ? in_data :
				   (state == S3) ? in_data : 
				   	               reg_d[15:8];
	assign mux_b = (state == S2) ? in_data :
				   (state == S4) ? in_data :		
				                   reg_d[7:0];
	assign mux_c = (state == S4) ? d_out[2]	: 	
				   (state == S2) ? d_out[2]	: 
				                   reg_b[7:0];
	assign mux_d = (state == S3) ? ld_out[1] :
	 			   (state == S1) ? ld_out[1] :
	 			    			   reg_d[31:24];

	assign mux_e = (state == S4) ? reg_c[7:0] :
	 			   (state == S2) ? reg_c[7:0] : 
	 			   				   ld_out[3];

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
			S4 : 	 nstate = S1;
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
			reg_b <= 16'd0;
		end
		else begin
			reg_b <= {d_out[2], reg_b[15:8]};
		end
	end

	always@(posedge clk, posedge reset)begin
		if(reset)begin
			reg_c <= 16'd0;
		end
		else begin
			reg_c <= {ld_out[3], reg_c[15:8]};
		end
	end

	always@(posedge clk, posedge reset)begin
		if(reset)begin
			reg_d <= 31'd0;
		end
		else begin
			reg_d <= {reg_d[23:0], ld_out[4]};
		end
	end

endmodule