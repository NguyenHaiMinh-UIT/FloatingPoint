module demux1to4(
    input [31:0] in,
    input [1:0] sel,
    output reg [31:0] out0,
    output reg [31:0] out1,
    output reg [31:0] out2,
    output reg [31:0] out3

);
    always @(sel) begin
        case (sel) // @suppress "Default clause missing from case statement"
            2'b00: begin
                out0 = in;
                out1 <= 32'bz;
                out2 <=  32'bz;
                out3 <= 32'bz;
            end
            2'b01: begin
                out0 <= 32'bz;
                out1 = {(~in[31]),in[30:0]};
                out2 <= 32'bz;
                out3 <= 32'bz;
            end
            2'b10: begin
                out0 <= 32'bz;
                out1 <= 32'bz;
                out2 <= in;
                out3 <= 32'bz;
            end
            2'b11: begin
                out0 <= 32'bz;
                out1 <= 32'bz;
                out2 <= 32'bz;
                out3 <= in;
            end
        endcase
    end
endmodule : demux1to4
