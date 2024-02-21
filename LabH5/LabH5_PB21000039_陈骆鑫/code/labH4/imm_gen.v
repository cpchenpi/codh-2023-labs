`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/03 22:05:30
// Design Name: 
// Module Name: imm_gen
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


module imm_gen(
    input     [31:0] ir,
    output reg [31:0] imm
    );
    parameter OPCODE_ALU = 7'b011_0011, OPCODE_ALU_IMM = 7'b001_0011, OPCODE_LUI = 7'b011_0111, OPCODE_AUIPC = 7'b001_0111,
              OPCODE_LOAD = 7'b000_0011, OPCODE_STORE = 7'b010_0011, OPCODE_BRANCH = 7'b110_0011,
              OPCODE_JAL = 7'b110_1111, OPCODE_JALR = 7'b110_0111;
    
    parameter FUNCT3_ADDI = 3'b000, FUNCT3_SLLI = 3'b001, FUNCT3_SRLI_SRAI = 3'b101;

    always @(*) begin
        case (ir[6:0])
            OPCODE_ALU:
                imm = 0;

            OPCODE_ALU_IMM: begin
                case (ir[14:12])
                    FUNCT3_ADDI:        imm = {{20{ir[31]}}, ir[31:20]};
                    FUNCT3_SLLI:        imm = {27'b0, ir[24:20]};
                    FUNCT3_SRLI_SRAI:   imm = {27'b0, ir[24:20]};
                    default: imm = 0;
                endcase
            end

            OPCODE_LUI:
                imm = {{ir[31:12]}, 12'b0};
            OPCODE_AUIPC:
                imm = {{ir[31:12]}, 12'b0};

            OPCODE_LOAD:
                imm = {{20{ir[31]}}, ir[31:20]};
            
            OPCODE_STORE:
                imm = {{20{ir[31]}}, ir[31:25], ir[11:7]};

            OPCODE_BRANCH:
                imm = {{20{ir[31]}}, ir[31], ir[7], ir[30:25], ir[11:8]};   // without left shift!

            OPCODE_JAL:
                imm = {{12{ir[31]}}, ir[31], ir[19:12], ir[20], ir[30:21]};        // without left shift!

            OPCODE_JALR:
                imm = {{20{ir[31]}}, ir[31:20]};

            default:
                imm = 0;
        endcase
    end
endmodule
