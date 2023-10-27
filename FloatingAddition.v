module FloatingAddition(
  input  [31:0] A, B,
  output [31:0] result
);
//  wire [31:0] result;
	reg a_sign;
	reg [7:0] a_exponent;
	reg [23:0] a_mantissa;
	reg b_sign;
	reg [7:0] b_exponent;
	reg [23:0] b_mantissa;

  reg o_sign;
  reg [7:0] o_exponent;
  reg [24:0] o_mantissa;

  reg [7:0] diff;
  reg [23:0] tmp_mantissa;
  reg [7:0] tmp_exponent;


  reg  [7:0] i_e;
  reg  [24:0] i_m;
  wire [7:0] o_e;
  wire [24:0] o_m;

  addition_normaliser norm1
  (
    .in_e(i_e),
    .in_m(i_m),
    .out_e(o_e),
    .out_m(o_m)
  );

  assign result[31] = o_sign;
  assign result[30:23] = o_exponent;
  assign result[22:0] = o_mantissa[22:0];

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
    if (a_exponent == b_exponent) begin // Equal exponents
      o_exponent = a_exponent;
      if (a_sign == b_sign) begin // Equal signs = add
        o_mantissa = a_mantissa + b_mantissa;
        //Signify to shift
        o_mantissa[24] = 1;
        o_sign = a_sign;
      end else begin // Opposite signs = subtract
        if(a_mantissa > b_mantissa) begin
          o_mantissa = a_mantissa - b_mantissa;
          o_sign = a_sign;
        end else begin
          o_mantissa = b_mantissa - a_mantissa;
          o_sign = b_sign;
        end
      end
    end else begin //Unequal exponents
      if (a_exponent > b_exponent) begin // A is bigger
        o_exponent = a_exponent;
        o_sign = a_sign;
				diff = a_exponent - b_exponent;
        tmp_mantissa = b_mantissa >> diff;
        if (a_sign == b_sign)
          o_mantissa = a_mantissa + tmp_mantissa;
        else
          	o_mantissa = a_mantissa - tmp_mantissa;
      end else if (a_exponent < b_exponent) begin // B is bigger
        o_exponent = b_exponent;
        o_sign = b_sign;
        diff = b_exponent - a_exponent;
        tmp_mantissa = a_mantissa >> diff;
        if (a_sign == b_sign) begin
          o_mantissa = b_mantissa + tmp_mantissa;
        end else begin
					o_mantissa = b_mantissa - tmp_mantissa;
        end
      end
    end
    if(o_mantissa[24] == 1) begin
      o_exponent = o_exponent + 1;
      o_mantissa = o_mantissa >> 1;
    end else if((o_mantissa[23] != 1) && (o_exponent != 0)) begin
      i_e = o_exponent;
      i_m = o_mantissa;
      o_exponent = o_e;
      o_mantissa = o_m;
    end
  end
endmodule
module addition_normaliser(in_e, in_m, out_e, out_m);
  input [7:0] in_e;
  input [24:0] in_m;
  output [7:0] out_e;
  output [24:0] out_m;

  wire [7:0] in_e;
  wire [24:0] in_m;
  reg [7:0] out_e;
  reg [24:0] out_m;

  always @ ( * ) begin
		if (in_m[23:3] == 21'b000000000000000000001) begin
			out_e = in_e - 20;
			out_m = in_m << 20;
		end else if (in_m[23:4] == 20'b00000000000000000001) begin
			out_e = in_e - 19;
			out_m = in_m << 19;
		end else if (in_m[23:5] == 19'b0000000000000000001) begin
			out_e = in_e - 18;
			out_m = in_m << 18;
		end else if (in_m[23:6] == 18'b000000000000000001) begin
			out_e = in_e - 17;
			out_m = in_m << 17;
		end else if (in_m[23:7] == 17'b00000000000000001) begin
			out_e = in_e - 16;
			out_m = in_m << 16;
		end else if (in_m[23:8] == 16'b0000000000000001) begin
			out_e = in_e - 15;
			out_m = in_m << 15;
		end else if (in_m[23:9] == 15'b000000000000001) begin
			out_e = in_e - 14;
			out_m = in_m << 14;
		end else if (in_m[23:10] == 14'b00000000000001) begin
			out_e = in_e - 13;
			out_m = in_m << 13;
		end else if (in_m[23:11] == 13'b0000000000001) begin
			out_e = in_e - 12;
			out_m = in_m << 12;
		end else if (in_m[23:12] == 12'b000000000001) begin
			out_e = in_e - 11;
			out_m = in_m << 11;
		end else if (in_m[23:13] == 11'b00000000001) begin
			out_e = in_e - 10;
			out_m = in_m << 10;
		end else if (in_m[23:14] == 10'b0000000001) begin
			out_e = in_e - 9;
			out_m = in_m << 9;
		end else if (in_m[23:15] == 9'b000000001) begin
			out_e = in_e - 8;
			out_m = in_m << 8;
		end else if (in_m[23:16] == 8'b00000001) begin
			out_e = in_e - 7;
			out_m = in_m << 7;
		end else if (in_m[23:17] == 7'b0000001) begin
			out_e = in_e - 6;
			out_m = in_m << 6;
		end else if (in_m[23:18] == 6'b000001) begin
			out_e = in_e - 5;
			out_m = in_m << 5;
		end else if (in_m[23:19] == 5'b00001) begin
			out_e = in_e - 4;
			out_m = in_m << 4;
		end else if (in_m[23:20] == 4'b0001) begin
			out_e = in_e - 3;
			out_m = in_m << 3;
		end else if (in_m[23:21] == 3'b001) begin
			out_e = in_e - 2;
			out_m = in_m << 2;
		end else if (in_m[23:22] == 2'b01) begin
			out_e = in_e - 1;
			out_m = in_m << 1;
		end
  end
endmodule


// module FloatingAddition 
// (
//     input [31:0]A,
//     input [31:0]B,
//     // input clk,
//     // output overflow,
//     // output underflow,
//     // output exception,
//     output reg  [31:0] result
// );

//     reg [23:0] A_Mantissa,B_Mantissa;
//     reg [23:0] Temp_Mantissa;
//     reg [22:0] Mantissa;
//     reg [7:0] Exponent;
//     reg Sign;
//     // wire MSB;
//     reg [7:0] A_Exponent,B_Exponent,Temp_Exponent,diff_Exponent; // @suppress "Variable 'Temp_Exponent' is never used"
//     reg A_sign,B_sign;
//     // reg [32:0] Temp;
//     reg carry;
//     // reg [2:0] one_hot;
//     reg comp;
//     reg [7:0] exp_adjust;
//     always @(*)
//     begin

//         comp =  (A[30:23] >= B[30:23])? 1'b1 : 1'b0;

//         A_Mantissa = comp ? {1'b1,A[22:0]} : {1'b1,B[22:0]};
//         A_Exponent = comp ? A[30:23] : B[30:23];
//         A_sign = comp ? A[31] : B[31];

//         B_Mantissa = comp ? {1'b1,B[22:0]} : {1'b1,A[22:0]};
//         B_Exponent = comp ? B[30:23] : A[30:23];
//         B_sign = comp ? B[31] : A[31];

//         diff_Exponent = A_Exponent-B_Exponent;
//         B_Mantissa = (B_Mantissa >> diff_Exponent);
//         {carry,Temp_Mantissa} =  (A_sign ~^ B_sign)? A_Mantissa + B_Mantissa : A_Mantissa-B_Mantissa ;
//         exp_adjust = A_Exponent;
//         if(carry)
//             begin
//                 Temp_Mantissa = Temp_Mantissa>>1;
//                 exp_adjust = exp_adjust+1'b1;
//             end
//         else
//             begin
//                 while(!Temp_Mantissa[23])
//                     begin
//                         Temp_Mantissa = Temp_Mantissa<<1;
//                         exp_adjust =  exp_adjust-1'b1;
//                     end
//             end
//         Sign = A_sign;
//         Mantissa = Temp_Mantissa[22:0];
//         Exponent = exp_adjust;
//         result = {Sign,Exponent,Mantissa};
//         //Temp_Mantissa = (A_sign ~^ B_sign) ? (carry ? Temp_Mantissa>>1 : Temp_Mantissa) : (0); 
//         //Temp_Exponent = carry ? A_Exponent + 1'b1 : A_Exponent; 
//         //Temp_sign = A_sign;
//         //result = {Temp_sign,Temp_Exponent,Temp_Mantissa[22:0]};
//     end
// endmodule