`timescale 1ns / 1ps
`include "defines.svh"

module control (
    input [6:0] opcode,
    input [2:0] funct3,
    input [6:0] funct7,

    output logic br,
    output logic ret,
    output logic memRead,
    output logic memWrite,
    output logic memToReg,
    output logic extIn,
    output logic extOs,
    output logic ALUSrc,
    output logic regWrite,
    output logic opComp,
    output logic immShift,
    output logic asOffset,
    output logic [1:0] memCut,
    output logic [1:0] regCut,
    output logic [3:0] ALUOp
);

    always_comb begin
        ALUOp = 'x;
        {extIn, extOs} = '1;
        {br, ret, memRead, memWrite, memToReg, ALUSrc, regWrite, opComp, immShift, asOffset, memCut, regCut} = '0;
        case (opcode)
            7'b0110011: begin
                {regWrite} = '1;
                ALUOp = funct3 == 3'b000 && funct7 == 7'b0000000 ? `ALU_ADD  :  // add
                        funct3 == 3'b000 && funct7 == 7'b0100000 ? `ALU_SUB  :  // sub
                        funct3 == 3'b111 && funct7 == 7'b0000000 ? `ALU_AND  :  // and
                        funct3 == 3'b110 && funct7 == 7'b0000000 ? `ALU_OR   :  // or
                        funct3 == 3'b100 && funct7 == 7'b0000000 ? `ALU_XOR  :  // xor
                        funct3 == 3'b001 && funct7 == 7'b0000000 ? `ALU_SLL  :  // sll
                        funct3 == 3'b101 && funct7 == 7'b0000000 ? `ALU_SRL  :  // srl
                        funct3 == 3'b101 && funct7 == 7'b0100000 ? `ALU_SRA  :  // sra
                        funct3 == 3'b010 && funct7 == 7'b0000000 ? `ALU_SLT  :  // slt
                        funct3 == 3'b011 && funct7 == 7'b0000000 ? `ALU_SLTU :  // sltu
                        4'b1111;                                                // invalid
            end
            7'b0010011: begin
                {ALUSrc, regWrite} = '1;
                extIn = funct3 == 3'b001 || funct3 == 3'b101 ? '0 : extIn;
                ALUOp = funct3 == 3'b000 ? `ALU_ADD :                           // addi
                        funct3 == 3'b111 ? `ALU_AND :                           // andi
                        funct3 == 3'b110 ? `ALU_OR  :                           // ori
                        funct3 == 3'b100 ? `ALU_XOR :                           // xori
                        funct3 == 3'b001 && funct7 == 7'b0000000 ? `ALU_SLL :   // slli
                        funct3 == 3'b101 && funct7 == 7'b0000000 ? `ALU_SRL :   // srli
                        funct3 == 3'b101 && funct7 == 7'b0100000 ? `ALU_SRA :   // srai
                        funct3 == 3'b010 ? `ALU_SLT :                           // slti
                        funct3 == 3'b011 ? `ALU_SLTU:                           // sltiu
                        4'b1111;                                                // invalid
            end
            7'b0000011: begin
                {ALUSrc, memRead, memToReg, regWrite} = '1;
                memCut = funct3 == 3'b010 ? memCut :
                         funct3 == 3'b101 || funct3 == 3'b001 ? 2'b01 :
                         funct3 == 3'b100 || funct3 == 3'b000 ? 2'b10 :
                         2'b11;                                                 // invalid
                extOs = funct3 == 3'b100 || funct3 == 3'b101 ? '0 : extOs;
                ALUOp = funct3 == 3'b000 ? `ALU_ADD :                           // lb
                        funct3 == 3'b100 ? `ALU_ADD :                           // lbu
                        funct3 == 3'b001 ? `ALU_ADD :                           // lh
                        funct3 == 3'b101 ? `ALU_ADD :                           // lhu
                        funct3 == 3'b010 ? `ALU_ADD :                           // lw
                        4'b1111;                                                // invalid
            end
            7'b1100111: begin
                {ret, regWrite, ALUSrc} = '1;
                ALUOp = funct3 == 3'b000 ? `ALU_ADD :                           // jalr
                        4'b1111;                                                // invalid
            end
            7'b0100011: begin
                {ALUSrc, memWrite} = '1;
                regCut = funct3 == 3'b010 ? regCut :
                         funct3 == 3'b001 ? 2'b01  :
                         funct3 == 3'b000 ? 2'b10  :
                         2'b11;                                                 // invalid
                ALUOp = funct3 == 3'b000 ? `ALU_ADD :                           // sb
                        funct3 == 3'b001 ? `ALU_ADD :                           // sh
                        funct3 == 3'b010 ? `ALU_ADD :                           // sw
                        4'b1111;                                                // invalid
            end
            7'b1100011: begin
                {ALUSrc, br} = '1;
                opComp = funct3 == 3'b000 || funct3 == 3'b100 ? opComp : '1;
                ALUOp = funct3 == 3'b000 ? `ALU_SUB :                           // beq
                        funct3 == 3'b001 ? `ALU_SUB :                           // bne
                        funct3 == 3'b100 ? `ALU_SLT :                           // blt
                        funct3 == 3'b110 ? `ALU_SLTU:                           // bltu
                        funct3 == 3'b101 ? `ALU_SLT :                           // bge
                        funct3 == 3'b111 ? `ALU_SLTU:                           // bgeu
                        4'b1111;                                                // invalid
            end
            7'b0110111: begin
                {immShift, regWrite} = '1;
                ALUOp = `ALU_SLL;                                               // lui
            end
            7'b0010111:
                {immShift, asOffset, regWrite} = '1;
                ALUOp = `ALU_SLL;                                               // auipc
            7'b1101111: begin
                {ret} = '1;
                ALUOp = `ALU_ADD;                                               // jal   
            end         
        endcase
    end

endmodule
