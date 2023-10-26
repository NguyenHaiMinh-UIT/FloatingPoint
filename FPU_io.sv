interface FPU_io(input bit clk);
    logic [31:0] A;
    logic [31:0] B;
    logic [31:0] result;
    logic [1:0] opcode;
    clocking cb @(posedge clk); 
        output A;
        output B;
        output opcode;
        input  result;
    endclocking 
    modport tb (clocking cb);
endinterface //FPU_io