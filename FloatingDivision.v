`timescale 1ns / 1ps
// `include "FloatingMultiplication.v"
// `include "FloatingAddition.v"
// module FloatingDivision#(parameter XLEN=32)
//                         (input [XLEN-1:0]A,
//     input [XLEN-1:0]B,
//     input clk,
//     // output overflow,
//     // output underflow,
//     // output exception,
//     output [XLEN-1:0] result);

//     // reg [23:0] A_Mantissa,B_Mantissa;
//     // reg [22:0] Mantissa;
//     // wire [7:0] exp;
//     // reg [23:0] Temp_Mantissa;
//     // reg [7:0] A_Exponent,B_Exponent,Temp_Exponent,diff_Exponent;
//     wire [7:0] Exponent;
//     // reg [7:0] A_adjust,B_adjust;
//     // reg A_sign,B_sign,Sign; 
//     // reg [32:0] Temp;
//     wire [31:0] temp1,temp2,temp3,temp4,temp5,temp6,temp7,debug;
//     wire [31:0] reciprocal;
//     wire [31:0] x0,x1,x2,x3;
//     // reg [6:0] exp_adjust;
//     // reg [XLEN-1:0] B_scaled;
//     // reg en1,en2,en3,en4,en5;
//     // reg dummy;
//     /*----Initial value----*/
//     FloatingMultiplication M1(.A({{1'b0,8'd126,B[22:0]}}),.B(32'h3ff0f0f1),.result(temp1)); //verified
//     assign debug = {1'b1,temp1[30:0]};
//     FloatingAddition A1(.A(32'h4034b4b5),.B({1'b1,temp1[30:0]}),.result(x0));

//     /*----First Iteration----*/
//     FloatingMultiplication M2(.A({{1'b0,8'd126,B[22:0]}}),.B(x0),.result(temp2));
//     FloatingAddition A2(.A(32'h40000000),.B({!temp2[31],temp2[30:0]}),.result(temp3));
//     FloatingMultiplication M3(.A(x0),.B(temp3),.result(x1));

//     /*----Second Iteration----*/
//     FloatingMultiplication M4(.A({1'b0,8'd126,B[22:0]}),.B(x1),.result(temp4));
//     FloatingAddition A3(.A(32'h40000000),.B({!temp4[31],temp4[30:0]}),.result(temp5));
//     FloatingMultiplication M5(.A(x1),.B(temp5),.result(x2));

//     /*----Third Iteration----*/
//     FloatingMultiplication M6(.A({1'b0,8'd126,B[22:0]}),.B(x2),.result(temp6));
//     FloatingAddition A4(.A(32'h40000000),.B({!temp6[31],temp6[30:0]}),.result(temp7));
//     FloatingMultiplication M7(.A(x2),.B(temp7),.result(x3));

//     /*----Reciprocal : 1/B----*/
//     assign Exponent = x3[30:23]+8'd126-B[30:23];
//     assign reciprocal = {B[31],Exponent,x3[22:0]};

//     /*----Multiplication A*1/B----*/
//     FloatingMultiplication M8(.A(A),.B(reciprocal),.result(result));
// endmodule
module FloatingDivision (A, B, result);
	input [31:0] A;
	input [31:0] B;
	output [31:0] result;

	wire [31:0] b_reciprocal;

	reciprocal recip
	(
		.in(B),
		.out(b_reciprocal)
	);

	FloatingMultiplication mult
	(
		.A(A),
		.B(b_reciprocal),
		.result(result)
	);

endmodule

module reciprocal (in, out);
	input [31:0] in;

	output [31:0] out;

	assign out[31] = in[31];
	assign out[22:0] = N2[22:0];
	assign out[30:23] = (D==9'b100000000)? 9'h102 - in[30:23] : 9'h101 - in[30:23];

	wire [31:0] D;
	assign D = {1'b0, 8'h80, in[22:0]};

	wire [31:0] C1; //C1 = 48/17
	assign C1 = 32'h4034B4B5;
	wire [31:0] C2; //C2 = 32/17
	assign C2 = 32'h3FF0F0F1;
	wire [31:0] C3; //C3 = 2.0
	assign C3 = 32'h40000000;

	wire [31:0] N0;
	wire [31:0] N1;
	wire [31:0] N2;

	//Temporary connection wires
	wire [31:0] S0_2D_out;
	wire [31:0] S1_DN0_out;
	wire [31:0] S1_2min_DN0_out;
	wire [31:0] S2_DN1_out;
	wire [31:0] S2_2minDN1_out;

	wire [31:0] S0_N0_in;

	assign S0_N0_in = {~S0_2D_out[31], S0_2D_out[30:0]};

	//S0
	FloatingMultiplication S0_2D
	(
		.A(C2),
		.B(D),
		.result(S0_2D_out)
	);

	FloatingAddition S0_N0
	(
		.A(C1),
		.B(S0_N0_in),
		.result(N0)
	);

	//S1
	FloatingMultiplication S1_DN0
	(
		.A(D),
		.B(N0),
		.result(S1_DN0_out)
	);

	FloatingAddition S1_2minDN0
	(
		.A(C3),
		.B({~S1_DN0_out[31], S1_DN0_out[30:0]}),
		.result(S1_2min_DN0_out)
	);

	FloatingMultiplication S1_N1
	(
		.A(N0),
		.B(S1_2min_DN0_out),
		.result(N1)
	);

	//S2
	FloatingMultiplication S2_DN1
	(
		.A(D),
		.B(N1),
		.result(S2_DN1_out)
	);

	FloatingAddition S2_2minDN1
	(
		.A(C3),
		.B({~S2_DN1_out[31], S2_DN1_out[30:0]}),
		.result(S2_2minDN1_out)
	);

	FloatingMultiplication S2_N2
	(
		.A(N1),
		.B(S2_2minDN1_out),
		.result(N2)
	);

endmodule