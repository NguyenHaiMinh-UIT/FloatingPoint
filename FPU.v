module FPU (
    input clk,
    input [31:0] A,
    input [31:0] B,
    input [1:0] opcode,
    output reg [31:0] result
);
    reg [31:0] add_result, mul_result, div_result,sub_result;
    wire [31:0] B_add, B_sub, B_mul, B_div;
    wire [31:0] A_add, A_sub, A_mul, A_div;
    FloatingAddition FloatingAddition_instance(
        .A(A_add),
        .B(B_add),
        .clk(clk),
        .overflow(),
        .underflow(),
        .exception(),
        .result(add_result)
    );
    FloatingAddition FloatingSubition_instance(
        .A(A_sub),
        .B(B_sub),
        .clk(clk),
        .overflow(),
        .underflow(),
        .exception(),
        .result(sub_result)
    );
    FloatingMultiplication FloatingMultiplication_instance(
        .A(A_mul),
        .B(B_mul),
        .clk(clk),
        .overflow(),
        .underflow(),
        .exception(),
        .result(mul_result)
    );
    FloatingDivision FloatingDivision_instance(
        .A(A_div),
        .B(B_div),
        .clk(clk),
        .overflow(),
        .underflow(),
        .exception(),
        .result(div_result)
    );

    demux1to4 demux1to4_A(
        .in(A),
        .sel(opcode),
        .out0(A_add),
        .out1(A_sub),
        .out2(A_mul),
        .out3(A_div)
    );
    demux1to4 demux1to4_B(
        .in(B),
        .sel(opcode),
        .out0(B_add),
        .out1(B_sub),
        .out2(B_mul),
        .out3(B_div)
    );
    always @(opcode) begin
        case (opcode) // @suppress "Default clause missing from case statement"
            2'b00 : result = add_result;
            2'b01 : result = sub_result;
            2'b10 : result = mul_result;
            2'b11 : result = div_result;
        endcase
    end
endmodule : FPU