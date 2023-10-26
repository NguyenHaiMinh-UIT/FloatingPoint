program automatic test (FPU_io.tb fpu_io);
    class random;
        rand bit [31:0] A;
        rand bit [31:0] B;
    endclass

    class FPU;
        bit [1:0] opcode;
        local bit [31:0] A;
        local bit [31:0] B;
        local shortreal in_A;
        local shortreal in_B;
        shortreal out ;
        //=================================//
        virtual function referenc_calc();
            if (opcode == 0) out  = in_A + in_B;
            else if (opcode == 1) out = in_A - in_B;
            else if (opcode == 2) out = in_A * in_B;
            else out = in_A / in_B;
        endfunction : referenc_calc
        //=================================//
        virtual function void set_A(input bit [31:0] in);
            this.A = in;
            this.in_A = $bitstoshortreal(this.A);
        endfunction : set_A
        //=================================//
        virtual function void set_B(input bit [31:0] in);
            this.B = in;
            this.in_B = $bitstoshortreal(this.B);
        endfunction :set_B
        //=================================//
        virtual function real get_A;
            return this.A;
        endfunction
        virtual function real get_B;
            return this.B;
        endfunction
    //=============================================//
        virtual function void display();
            $display ("A: %0.44f",$bitstoshortreal(in_A));
            $display ("B: %0.44f",$bitstoshortreal(in_B));
            $display ("Expected Result: %0.44f", out);
        endfunction
    //============================================//
    endclass: FPU //FPU
    //================= ENUM =====================//
    typedef enum bit [1:0] {ADD = 0, SUB = 1, MUL = 2, DIV = 3} OPCODE;
    OPCODE add = ADD;
    OPCODE sub = SUB;
    OPCODE mul = MUL;
    OPCODE div = DIV;
    //================== MAIN ====================// 
    initial begin
        random random;
        FPU fpu_unit;
        random = new();
        fpu_unit = new();
    end

    task test_add (FPU fpu_add, random random_task);
        shortreal out;
        fpu_io.cb.opcode <= fpu_add.opcode;
        $display("--------------------------");
        for (integer i=0;i<20;i++) begin
            random_task.randomize();
            fpu_add.set_A(random_task.A);
            fpu_add.set_B(random_task.B);
            fpu_io.cb.A <= fpu_add.get_A;
            fpu_io.cb.B <= fpu_add.get_B;
            fpu_add.referenc_calc;
            fpu_add.display;
            out = $bitstoshortreal(fpu_io.cb.result);
            $display("Real Result : %0.44f", out);
        end
    endtask
endprogram : test
