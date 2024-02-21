`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/04 23:00:18
// Design Name: 
// Module Name: control_unit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module control_unit(
    input  [31:0] ir,
    output [2:0] br_flags,
    output is_jal, is_jalr,
    output is_lui, is_auipc, ra_to_reg,
    output reg [2:0] alu_op,
    output reg alu_src,
    output reg mem_to_reg,
    output reg mem_write, reg_write
    );
    parameter OPCODE_ALU = 7'b011_0011, OPCODE_ALU_IMM = 7'b001_0011, OPCODE_LUI = 7'b011_0111, OPCODE_AUIPC = 7'b001_0111,
              OPCODE_LOAD = 7'b000_0011, OPCODE_STORE = 7'b010_0011, OPCODE_BRANCH = 7'b110_0011,
              OPCODE_JAL = 7'b110_1111, OPCODE_JALR = 7'b110_0111;

    parameter FUNCT3_ADDI = 3'b000, FUNCT3_SLLI = 3'b001, FUNCT3_SRLI_SRAI = 3'b101;

    parameter FUNCT3_BEQ = 3'b000, FUNCT3_BLT = 3'b100, FUNCT3_BLTU = 3'b110;

    parameter FUNCT3_ADD_SUB = 3'b000, FUNCT3_AND = 3'b111, FUNCT3_OR = 3'b110, FUNCT3_XOR = 3'b100;

    parameter FUNCT7_ADD = 7'b0, FUNCT7_SUB = 7'b0100000;

    parameter FUNCT7_SRLI = 7'b0, FUNCT7_SRAI = 7'b0100000;

    parameter ALU_OP_SUB = 3'd0, ALU_OP_ADD = 3'd1, ALU_OP_AND = 3'd2, ALU_OP_OR = 3'd3,
              ALU_OP_XOR = 3'd4, ALU_OP_SRLI = 3'd5, ALU_OP_SLLI = 3'd6, ALU_OP_SRAI = 3'd7;

    wire [6:0] opcode;
    wire [2:0] funct3;
    wire [6:0] funct7;
    assign opcode = ir[6:0];
    assign funct3 = ir[14:12];
    assign funct7 = ir[31:25];

    wire br_eq, br_lt, br_ltu;
    assign br_eq = (opcode == OPCODE_BRANCH) && (funct3 == FUNCT3_BEQ);
    assign br_lt = (opcode == OPCODE_BRANCH) && (funct3 == FUNCT3_BLT);
    assign br_ltu = (opcode == OPCODE_BRANCH) && (funct3 == FUNCT3_BLTU);
    assign br_flags = {br_ltu, br_lt, br_eq};

    assign is_jal = (opcode == OPCODE_JAL);
    assign is_jalr = (opcode == OPCODE_JALR);
    assign ra_to_reg = is_jal || is_jalr;

    assign is_lui = (opcode == OPCODE_LUI);
    assign is_auipc = (opcode == OPCODE_AUIPC);

    always @(*) begin
        // default values
        alu_op = 0; alu_src = 0;
        mem_to_reg = 0; mem_write = 0;
        reg_write = 0;
        case (opcode)
            OPCODE_JAL: reg_write = 1;

            OPCODE_JALR: begin
                alu_op = ALU_OP_ADD;
                alu_src = 1;
                reg_write = 1;
            end

            OPCODE_LUI: begin
                alu_op = ALU_OP_ADD;
                alu_src = 1;
                reg_write = 1;
            end
            OPCODE_AUIPC: begin
                alu_op = ALU_OP_ADD;
                alu_src = 1;
                reg_write = 1;
            end

            OPCODE_STORE: begin
                alu_op = ALU_OP_ADD;
                alu_src = 1;
                mem_write = 1;
            end
            OPCODE_LOAD: begin
                alu_op = ALU_OP_ADD;
                alu_src = 1;
                mem_to_reg = 1;
                reg_write = 1;
            end

            OPCODE_BRANCH: begin
                alu_op = ALU_OP_SUB;
            end

            OPCODE_ALU: begin
                reg_write = 1;
                case (funct3)
                    FUNCT3_ADD_SUB: begin
                        case (funct7)
                            FUNCT7_ADD: alu_op = ALU_OP_ADD;
                            FUNCT7_SUB: alu_op = ALU_OP_SUB;
                            default: alu_op = 0;
                        endcase
                    end

                    FUNCT3_AND: alu_op = ALU_OP_AND;
                    FUNCT3_OR:  alu_op = ALU_OP_OR;
                    FUNCT3_XOR: alu_op = ALU_OP_XOR;

                    default: alu_op = 0;
                endcase
            end

            OPCODE_ALU_IMM: begin
                reg_write = 1;
                alu_src = 1;
                case (funct3)
                    FUNCT3_ADDI: alu_op = ALU_OP_ADD;
                    FUNCT3_SLLI: alu_op = ALU_OP_SLLI;
                    FUNCT3_SRLI_SRAI: begin
                        case (funct7)
                            FUNCT7_SRLI: alu_op = ALU_OP_SRLI;
                            FUNCT7_SRAI: alu_op = ALU_OP_SRAI;
                            default: alu_op = 0;
                        endcase
                    end
                    default: alu_op = 0;
                endcase
            end

            default: alu_op = 0;
        endcase
    end
endmodule
