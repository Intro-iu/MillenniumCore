/*
+-------------------------------------------------------------------------------------------+
|   ALUOp       	操作符	                    描述		                                |
+-------------------------------------------------------------------------------------------+
|   4'b0000	        ADD (加法)	                Result = A + B		                        |
|   4'b0001	        SUB (减法)	                Result = A - B		                        |
|   4'b0010	        AND (按位与)	            Result = A & B		                        |
|   4'b0011	        OR  (按位或)	            Result = A | B                              |
|   4'b0100	        XOR (按位异或)	            Result = A ^ B		                        |
|   4'b0101	        SLL (逻辑左移)	            Result = A << B[4:0]		                |
|   4'b0110	        SRL (逻辑右移)	            Result = A >> B[4:0]		                |
|   4'b0111	        SRA (算数右移)	            Result = $signed(A) >>> B[4:0]	            |
|   4'b1000	        SLT (有符号小于则置位)      Result = ($signed(A) < $signed(B))          |
|   4'b1001	        SLTU(无符号小于则置位)	    Result = (A < B)                            |
+-------------------------------------------------------------------------------------------+
*/

`timescale 1ns / 1ps
`include "defines.svh"

module ALU (
    input  logic [31:0] A,
    input  logic [31:0] B,
    input  logic [ 3:0] ALUOp,

    output logic [31:0] Result,       // 结果
    output logic        Zero,         // 为零
    output logic        Carry,        // 进位
    output logic        Overflow      // 溢出
);
    // ALU操作
    always_comb begin
        // 默认值
        Result   = 'x;
        Carry    = '0;
        Overflow = '0;
        Zero     = '0;

        case (ALUOp)
            `ALU_ADD: begin // A + B
                {Carry, Result} = A + B;
                Overflow = A[31] == B[31] && A[31] != Result[31] ? '1 : '0;
            end
            `ALU_SUB: begin // A - B
                {Carry, Result} = A - B;
                Overflow = A[31] != B[31] && A[31] != Result[31] ? '1 : '0;
            end
            `ALU_AND:   Result = A & B;
            `ALU_OR:    Result = A | B;
            `ALU_XOR:   Result = A ^ B;
            `ALU_SLL:   Result = A << B[4:0];
            `ALU_SRL:   Result = A >> B[4:0];
            `ALU_SRA:   Result = $signed(A) >>> B[4:0];
            `ALU_SLT:   Result = ($signed(A) < $signed(B)) ? '1 : '0;
            `ALU_SLTU:  Result = (A < B) ? '1 : '0;
        endcase
        Zero = Result == 32'b0 ? '1 : '0;
    end
endmodule

module dataExt #(
    parameter int INPUT_WIDTH = 12,
    parameter bit extType = 1,
)(
    input [INPUT_WIDTH-1:0] data,
    output logic [31:0] ext
);
    assign ext = extType ? signed'(data) : unsigned'(data);
endmodule