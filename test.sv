class Data;
    rand bit [31:0] A;
    rand bit [31:0] B;
    bit [1:0] opcode;
    constraint limit {
        A inside {[0:8]};
        B inside {[0:4]};
        B < 2;
    }
    virtual function referance_calc(A, B, opcode);
        
    endfunction //new()
endclass //Data:



program test;
    
endprogram : test
