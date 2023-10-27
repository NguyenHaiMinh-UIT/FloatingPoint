// module FloatingMultiplication #(parameter XLEN=32)
//    (input [31:0]A,
//     input [31:0]B,
//     input clk,
//     // output overflow,
//     // output underflow,
//     // output exception,
//     output reg  [31:0] result);

//     reg [23:0] A_Mantissa,B_Mantissa;
//     reg [22:0] Mantissa;
//     reg [47:0] Temp_Mantissa;
//     reg [7:0] A_Exponent,B_Exponent,Temp_Exponent,diff_Exponent,Exponent; // @suppress "Variable 'diff_Exponent' is never used"
//     reg A_sign,B_sign,Sign;
//     reg [32:0] Temp; // @suppress "Variable 'Temp' is never used"
//     reg [6:0] exp_adjust; // @suppress "Variable 'exp_adjust' is never used"
//     always@(*)
//     begin
//         A_Mantissa = {1'b1,A[22:0]};
//         A_Exponent = A[30:23];
//         A_sign = A[31];

//         B_Mantissa = {1'b1,B[22:0]};
//         B_Exponent = B[30:23];
//         B_sign = B[31];

//         Temp_Exponent = A_Exponent+B_Exponent-127;
//         Temp_Mantissa = A_Mantissa*B_Mantissa;
//         Mantissa = Temp_Mantissa[47] ? Temp_Mantissa[46:24] : Temp_Mantissa[45:23];
//         Exponent = Temp_Mantissa[47] ? Temp_Exponent+1'b1 : Temp_Exponent;
//         Sign = A_sign^B_sign;
//         result = {Sign,Exponent,Mantissa};
//     end
// endmodule

module FloatingMultiplication(A, B, result);
  input  [31:0] A, B;
  output [31:0] result;

  wire [31:0] result;
	reg a_sign;
  reg [7:0] a_exponent;
  reg [23:0] a_mantissa;
	reg b_sign;
  reg [7:0] b_exponent;
  reg [23:0] b_mantissa;

  reg o_sign;
  reg [7:0] o_exponent;
  reg [24:0] o_mantissa;

	reg [47:0] product;

  assign result[31] = o_sign;
  assign result[30:23] = o_exponent;
  assign result[22:0] = o_mantissa[22:0];

	reg  [7:0] i_e;
	reg  [47:0] i_m;
	wire [7:0] o_e;
	wire [47:0] o_m;

	multiplication_normaliser norm1
	(
		.in_e(i_e),
		.in_m(i_m),
		.out_e(o_e),
		.out_m(o_m)
	);


  always @ ( * ) begin
		a_sign = A[31];
		if(A[30:23] == 0) begin
			a_exponent = 8'b00000001;
			a_mantissa = {1'b0, A[22:0]};
		end else begin
			a_exponent = A[30:23];
			a_mantissa = {1'b1, A[22:0]};
		end
		b_sign = B[31];
		if(B[30:23] == 0) begin
			b_exponent = 8'b00000001;
			b_mantissa = {1'b0, B[22:0]};
		end else begin
			b_exponent = B[30:23];
			b_mantissa = {1'b1, B[22:0]};
		end
    o_sign = a_sign ^ b_sign;
    o_exponent = a_exponent + b_exponent - 127;
    product = a_mantissa * b_mantissa;
		// Normalization
    if(product[47] == 1) begin
      o_exponent = o_exponent + 1;
      product = product >> 1;
    end else if((product[46] != 1) && (o_exponent != 0)) begin
      i_e = o_exponent;
      i_m = product;
      o_exponent = o_e;
      product = o_m;
    end
		o_mantissa = product[46:23];
	end
endmodule



module multiplication_normaliser(in_e, in_m, out_e, out_m);
  input [7:0] in_e;
  input [47:0] in_m;
  output [7:0] out_e;
  output [47:0] out_m;

  wire [7:0] in_e;
  wire [47:0] in_m;
  reg [7:0] out_e;
  reg [47:0] out_m;

  always @ ( * ) begin
	  if (in_m[46:41] == 6'b000001) begin
			out_e = in_e - 5;
			out_m = in_m << 5;
		end else if (in_m[46:42] == 5'b00001) begin
			out_e = in_e - 4;
			out_m = in_m << 4;
		end else if (in_m[46:43] == 4'b0001) begin
			out_e = in_e - 3;
			out_m = in_m << 3;
		end else if (in_m[46:44] == 3'b001) begin
			out_e = in_e - 2;
			out_m = in_m << 2;
		end else if (in_m[46:45] == 2'b01) begin
			out_e = in_e - 1;
			out_m = in_m << 1;
		end
  end
endmodule
