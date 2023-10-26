module top_test();
    bit clk = 0;
    always #1 clk = ~clk;
    FPU_io fpu_interface(.clk(clk));
    test test_bench(fpu_interface);
    FPU DUT
    (
        .clk(clk),
        .A(fpu_interface.A),
        .B(fpu_interface.B),
        .opcode(fpu_interface.opcode),
        .result(fpu_interface.result)
    );
endmodule
