`timescale 1ns/1ps
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
        virtual function void referenc_calc();
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
            $display ("A: %0.20f",$bitstoshortreal(in_A));
            $display ("B: %0.20f",$bitstoshortreal(in_B));
            $display ("Expected Result: %0.20f", out);
        endfunction
        //============================================//
    endclass: FPU //FPU

    class special extends FPU;
        local bit [31:0] A [0:4];
        local bit [31:0] B [0:4];
        local bit [2:0] index_A;
        local bit [2:0] index_B;
        bit [2:0] opcode;
        shortreal result;
        function  new(input bit [2:0] index_A, input bit [2:0] index_B);
            A[0] = 32'h00000000;
            B[0] = 32'h00000000;
            A[1] = 32'h80000000;
            B[1] = 32'h80000000;
            A[2] = 32'h7f800000;
            B[2] = 32'h7f800000;
            A[3] = 32'hff800000;
            B[3] = 32'hff800000;
            A[4] = 32'hff8f0000;
            B[4] = 32'hff8f0000;
            this.index_A = index_A;
            this.index_B = index_B;
        endfunction
        function void referenc_calc();
            if (opcode == 0)
                result = $bitstoshortreal(A[index_A]) + $bitstoshortreal(B[index_B]);
            else if (opcode == 1)
                result = $bitstoshortreal(A[index_A]) - $bitstoshortreal(B[index_B]);
            else if (opcode == 2)
                result = $bitstoshortreal(A[index_A]) * $bitstoshortreal(B[index_B]);
            else
                result =  $bitstoshortreal(A[index_A]) / $bitstoshortreal(B[index_B]);
        endfunction
        function void display();
            $display("Spectial case");
            $display ("A: %0.20f",$bitstoshortreal(A[index_A]));
            $display ("B: %0.20f",$bitstoshortreal(B[index_B]));
            $display ("Out: %0.20f", result);
        endfunction
        function real get_A;
            return this.A[index_A];
        endfunction
        function real get_B;
            return this.B[index_B];
        endfunction
    endclass //className extends superClass
    //================= ENUM =====================//
    typedef enum  {ADD , SUB, MUL , DIV } OPCODE;
    OPCODE add = ADD; // @suppress "Variable 'add' is never used"
    OPCODE sub = SUB; // @suppress "Variable 'sub' is never used"
    OPCODE mul = MUL; // @suppress "Variable 'mul' is never used"
    OPCODE div = DIV; // @suppress "Variable 'div' is never used"
    //============================ MAIN ===================================// 
    initial begin
        bit [31:0] A,B;
        bit [1:0] opcode;
        bit [31:0] result;
        FPU fpu_unit;
        random random_task;
        special special_case;
        random_task = new();
        fpu_unit = new();
        // special_case = new();


        fpu_unit.opcode = add;
        test_add(fpu_unit, random_task);
        fpu_unit.opcode = sub;
        test_sub(fpu_unit,random_task);
        fpu_unit.opcode = mul;
        test_mul(fpu_unit, random_task);
        fpu_unit.opcode = div;
        test_div(fpu_unit,random_task);

        special_case = new(2,2);
        special_case.opcode = add;
        test_special_case(special_case);
        special_case = new(4,2);
        special_case.opcode = sub;
        test_special_case(special_case);
        special_case = new(1,4);
        special_case.opcode = mul;
        test_special_case(special_case);
        special_case = new(4,4);
        special_case.opcode = div;
        test_special_case(special_case);
    end
    //=========================== END MAIN ===================================// 
    task test_add (FPU fpu_add, random random_task);
        shortreal out;
        fpu_io.cb.opcode <= fpu_add.opcode;
        $display("--------------------------");
        for (integer i=0;i<20;i++) begin
            random_task.randomize();
            $display("a random: %0.20f",$bitstoshortreal(random_task.A));
            fpu_add.set_A(random_task.A);
            fpu_add.set_B(random_task.B);
            fpu_io.cb.A <= fpu_add.get_A;
            fpu_io.cb.B <= fpu_add.get_B;
            fpu_add.referenc_calc;
            #8;
            $display("--------------------------");
            fpu_add.display;
            out = $bitstoshortreal(fpu_io.cb.result);
            $display("Real ADD Result : %0.20f", out);
            $display("--------------------------");
        end
        $display("--------------------------");
    endtask

    task test_sub(FPU fpu_sub, random random_task);
        shortreal out;
        fpu_io.cb.opcode <= fpu_sub.opcode;
        $display("--------------------------");
        for (integer i=0;i<10;i++) begin
            random_task.randomize();
            fpu_sub.set_A(random_task.A);
            fpu_sub.set_B(random_task.B);
            fpu_io.cb.A <= fpu_sub.get_A;
            fpu_io.cb.B <= fpu_sub.get_B;
            fpu_sub.referenc_calc;
            #8;
            $display("--------------------------");
            fpu_sub.display;
            out = $bitstoshortreal(fpu_io.cb.result);
            $display("Real SUB Result : %0.20f", out);
            $display("--------------------------");
        end
        $display("--------------------------");
    endtask : test_sub

    task test_mul(FPU fpu_mul, random random_task);
        shortreal out;
        fpu_io.cb.opcode <= fpu_mul.opcode;
        $display("--------------------------");
        for (integer i=0;i<10;i++) begin
            random_task.randomize();
            fpu_mul.set_A(random_task.A);
            fpu_mul.set_B(random_task.B);
            fpu_io.cb.A <= fpu_mul.get_A;
            fpu_io.cb.B <= fpu_mul.get_B;
            fpu_mul.referenc_calc;
            #8;
            $display("--------------------------");
            fpu_mul.display;
            out = $bitstoshortreal(fpu_io.cb.result);
            $display("--------------------------");
            $display("Real MUL Result : %0.20f", out);
        end
        $display("--------------------------");
    endtask : test_mul

    task test_div(FPU fpu_div, random random_task);
        shortreal out;
        fpu_io.cb.opcode <= fpu_div.opcode;
        $display("--------------------------");
        for (integer i=0;i<10;i++) begin
            random_task.randomize();
            fpu_div.set_A(random_task.A);
            fpu_div.set_B(random_task.B);
            fpu_io.cb.A <= fpu_div.get_A;
            fpu_io.cb.B <= fpu_div.get_B;
            fpu_div.referenc_calc;
            #8;
            $display("--------------------------");
            fpu_div.display;
            out = $bitstoshortreal(fpu_io.cb.result);
            $display("Real DIV Result : %0.20f", out);
            $display("--------------------------");
        end
        $display("--------------------------");
    endtask : test_div
    task test_special_case(special fpu_special);
        shortreal out;
        fpu_io.cb.opcode <= fpu_special.opcode;
        fpu_io.cb.A <= fpu_special.get_A;
        fpu_io.cb.B <= fpu_special.get_B;
        #8
        $display("|--------------------------------|");
        $display("|Testcase: SPEICAL |");
        if (fpu_special.opcode == 0) begin
            $display("|ADD");
        end
        else if (fpu_special.opcode == 1) begin
            $display("|SUB");
        end
        else if (fpu_special.opcode == 2) begin
            $display("|MUL");
        end
        else begin
            $display("|DIV");
        end
        fpu_special.display;
        out = $bitstoshortreal(fpu_io.cb.result);
        $display("DUT out: %0.44f", out);
        $display("--------------------------------");
    endtask
endprogram : test
