// module FPU (
//     input clk,
//     input [31:0] A,
//     input [31:0] B,
//     input [1:0] opcode,
//     output reg [31:0] result
// );
//     wire [31:0] add_result, mul_result, div_result,sub_result;
//     wire [31:0] B_add, B_sub, B_mul, B_div;
//     wire [31:0] A_add, A_sub, A_mul, A_div;
//     FloatingAddition FloatingAddition_instance(
//         .A(A_add),
//         .B(B_add),
//         // .clk(clk),
//         .result(add_result)
//     );
//     FloatingAddition FloatingSubition_instance(
//         .A(A_sub),
//         .B(B_sub),
//         // .clk(clk),
//         .result(sub_result)
//     );
//     FloatingMultiplication FloatingMultiplication_instance(
//         .A(A_mul),
//         .B(B_mul),
//         .clk(clk),
//         .result(mul_result)
//     );
//     FloatingDivision FloatingDivision_instance(
//         .A(A_div),
//         .B(B_div),
//         .clk(clk),
//         .result(div_result)
//     );

//     demux1to4 demux1to4_A(
//         .in(A),
//         .sel(opcode),
//         .out0(A_add),
//         .out1(A_sub),
//         .out2(A_mul),
//         .out3(A_div)
//     );
//     demux1to4 demux1to4_B(
//         .in(B),
//         .sel(opcode),
//         .out0(B_add),
//         .out1(B_sub),
//         .out2(B_mul),
//         .out3(B_div)
//     );
//     always @(*) begin
//         if (opcode == 0) begin
//             A_add = A;
//             B_add = B;
//             result = add_result;
//         end
//         else if (opcode == 1) begin
//             A_sub = A;
//             B_sub = B;
//             result = sub_result;
//         end
//         else if (opcode == 2) begin
//             A_mul = A;
//             B_mul = B;
//             result = mul_result;
//         end
//         else begin
//             A_div = A;
//             B_div = B;
//             result = div_result;
//         end 
//     end

// endmodule

//IEEE 754 Single Precision ALU
`timescale 1ns/1ps
module FPU(clk, A, B, opcode, result);
	input clk;
	input [31:0] A, B;
	input [1:0] opcode;
	output [31:0] result;

	wire [31:0] result;
	wire [7:0] a_exponent;
	wire [23:0] a_mantissa;
	wire [7:0] b_exponent;
	wire [23:0] b_mantissa;

	reg        o_sign;
	reg [7:0]  o_exponent;
	reg [24:0] o_mantissa;


	reg [31:0] adder_a_in;
	reg [31:0] adder_b_in;
	wire [31:0] adder_out;

	reg [31:0] multiplier_a_in;
	reg [31:0] multiplier_b_in;
	wire [31:0] multiplier_out;

	reg [31:0] divider_a_in;
	reg [31:0] divider_b_in;
	wire [31:0] divider_out;

	assign result[31] = o_sign;
	assign result[30:23] = o_exponent;
	assign result[22:0] = o_mantissa[22:0];

	assign a_sign = A[31];
	assign a_exponent[7:0] = A[30:23];
	assign a_mantissa[23:0] = {1'b1, A[22:0]};

	assign b_sign = B[31];
	assign b_exponent[7:0] = B[30:23];
	assign b_mantissa[23:0] = {1'b1, B[22:0]};

	assign ADD = !opcode[1] & !opcode[0];
	assign SUB = !opcode[1] & opcode[0];
	assign DIV = opcode[1] & !opcode[0];
	assign MUL = opcode[1] & opcode[0];

	FloatingAddition A1
	(
		.A(adder_a_in),
		.B(adder_b_in),
		.result(adder_out)
	);

	FloatingMultiplication M1
	(
		.A(multiplier_a_in),
		.B(multiplier_b_in),
		.result(multiplier_out)
	);

	FloatingDivision D1
	(
		.A(divider_a_in),
		.B(divider_b_in),
		.result(divider_out)
	);

	always @ (posedge clk) begin
		if (ADD) begin
			//If a is NaN or b is zero return a
			if ((a_exponent == 255 && a_mantissa != 0) || (b_exponent == 0) && (b_mantissa == 0)) begin
				o_sign = a_sign;
				o_exponent = a_exponent;
				o_mantissa = a_mantissa;
			//If b is NaN or a is zero return b
			end else if ((b_exponent == 255 && b_mantissa != 0) || (a_exponent == 0) && (a_mantissa == 0)) begin
				o_sign = b_sign;
				o_exponent = b_exponent;
				o_mantissa = b_mantissa;
			//if a or b is inf return inf
			end else if ((a_exponent == 255) || (b_exponent == 255)) begin
				o_sign = a_sign ^ b_sign;
				o_exponent = 255;
				o_mantissa = 0;
			end else begin // Passed all corner cases
				adder_a_in = A;
				adder_b_in = B;
				o_sign = adder_out[31];
				o_exponent = adder_out[30:23];
				o_mantissa = adder_out[22:0];
			end
		end else if (SUB) begin
			//If a is NaN or b is zero return a
			if ((a_exponent == 255 && a_mantissa != 0) || (b_exponent == 0) && (b_mantissa == 0)) begin
				o_sign = a_sign;
				o_exponent = a_exponent;
				o_mantissa = a_mantissa;
			//If b is NaN or a is zero return b
			end else if ((b_exponent == 255 && b_mantissa != 0) || (a_exponent == 0) && (a_mantissa == 0)) begin
				o_sign = b_sign;
				o_exponent = b_exponent;
				o_mantissa = b_mantissa;
			//if a or b is inf return inf
			end else if ((a_exponent == 255) || (b_exponent == 255)) begin
				o_sign = a_sign ^ b_sign;
				o_exponent = 255;
				o_mantissa = 0;
			end else begin // Passed all corner cases
				adder_a_in = A;
				adder_b_in = {~B[31], B[30:0]};
				o_sign = adder_out[31];
				o_exponent = adder_out[30:23];
				o_mantissa = adder_out[22:0];
			end
		end else if (DIV) begin
			divider_a_in = A;
			divider_b_in = B;
			o_sign = divider_out[31];
			o_exponent = divider_out[30:23];
			o_mantissa = divider_out[22:0];
		end else begin //Multiplication
			//If a is NaN return NaN
			if (a_exponent == 255 && a_mantissa != 0) begin
				o_sign = a_sign;
				o_exponent = 255;
				o_mantissa = a_mantissa;
			//If b is NaN return NaN
			end else if (b_exponent == 255 && b_mantissa != 0) begin
				o_sign = b_sign;
				o_exponent = 255;
				o_mantissa = b_mantissa;
			//If a or b is 0 return 0
			end else if ((a_exponent == 0) && (a_mantissa == 0) || (b_exponent == 0) && (b_mantissa == 0)) begin
				o_sign = a_sign ^ b_sign;
				o_exponent = 0;
				o_mantissa = 0;
			//if a or b is inf return inf
			end else if ((a_exponent == 255) || (b_exponent == 255)) begin
				o_sign = a_sign;
				o_exponent = 255;
				o_mantissa = 0;
			end else begin // Passed all corner cases
				multiplier_a_in = A;
				multiplier_b_in = B;
				o_sign = multiplier_out[31];
				o_exponent = multiplier_out[30:23];
				o_mantissa = multiplier_out[22:0];
			end
		end
	end
endmodule