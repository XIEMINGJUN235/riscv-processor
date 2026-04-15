`timescale 1ns / 1ps

`include "defines.v"


module ex(
//from id_ex
input wire[31:0]inst_i,
input wire[31:0]inst_addr_i,
input wire[31:0]op1_i,
input wire[31:0]op2_i,
input wire[4:0]rd_addr_i,
input wire rd_wen_i,
input wire [31:0]base_addr_i,
input wire [31:0]addr_offset_i,
//to regs
output reg[4:0]rd_addr_o,
output reg[31:0]rd_data_o,
output reg rd_wen_o,
    output reg           [  31: 0]      jump_addr_o                ,
    output reg                          jump_wen_o                 ,
    output reg                          hold_flag_o                      
);
 wire                 [   6: 0]      opcode                      ;
    wire                 [   4: 0]      rd                          ;
    wire                 [   2: 0]      func3                       ;
    wire                 [   4: 0]      rs1                         ;
    wire                 [   4: 0]      rs2                         ;
    wire                 [  11: 0]      imm                         ;
    wire                  [6:0]         func7                         ;
    wire                  [4:0]         shamt                        ;
    assign                              opcode                      = inst_i[6:0]          ;
    assign                              rd                          = inst_i[11:7]         ;
    assign                              func3                       = inst_i[14:12]        ;
    assign                              func7                       = inst_i[31:25]        ;
    assign                              rs1                         = inst_i[19:15]        ;
    assign                              rs2                         = inst_i[24:20]        ;
    assign                              imm                         = inst_i[31:20]        ;
    assign                              shamt                       = inst_i[24:20]        ;

    wire [31:0]jump_imm = {{19{inst_i[31]}}, inst_i[31], inst_i[7], inst_i[30:25], inst_i[11:8],1'b0};
    wire op1_i_equal_op2_i;
    wire op1_i_less_op2_i_signed;
    wire op1_i_less_op2_i_unsigned;
    wire [31:0] SRA_mask;

    assign op1_i_equal_op2_i = (op1_i == op2_i) ? 1'b1 : 1'b0;
    assign op1_i_less_op2_i_signed = ($signed(op1_i) < $signed(op2_i)) ? 1'b1 : 1'b0;
    assign op1_i_less_op2_i_unsigned = (op1_i < op2_i) ? 1'b1 : 1'b0;
    assign SRA_mask =  (32'hffff_ffff) >> op2_i[4:0]; // SRAI时需要的掩码


    wire [31:0] op1_i_add_op2_i; 
    wire [31:0] op1_i_and_op2_i ;
    wire [31:0] op1_i_xor_op2_i ;
    wire [31:0] op1_i_or_op2_i ;
    wire [31:0] op1_i_sll_op2_i ;
    wire [31:0] op1_i_srl_op2_i ;
    wire [31:0] base_addr_add_addr_offset;
     //计算内存访问的有效地址
assign op1_i_add_op2_i = op1_i + op2_i;
assign op1_i_and_op2_i = op1_i & op2_i;
assign op1_i_xor_op2_i = op1_i ^ op2_i;
assign op1_i_or_op2_i = op1_i | op2_i;
assign op1_i_sll_op2_i = op1_i << op2_i;
assign op1_i_srl_op2_i = op1_i >> op2_i;
assign base_addr_add_addr_offset = base_addr_i + addr_offset_i; //符号扩展后的立即数加上基地址，得到内存访问的有效地址

//type I
always @(*)begin
    rd_data_o   = 32'b0;
    rd_addr_o   = 5'b0;
    rd_wen_o    = 1'b0;
    jump_addr_o = 32'b0;
    jump_wen_o  = 1'b0;
    hold_flag_o = 1'b0;
  case(opcode)
      `INST_TYPE_I:begin
       jump_addr_o = 32'b0;
       jump_wen_o  = 1'b0;
       hold_flag_o =1'b0;
         case(func3)
                `INST_ADDI:begin//`INST_ADDI,`INST_SLTI,`INST_SLTIU,`INST_XORI,`INST_ORI,`INST_ANDI
                rd_data_o = op1_i_add_op2_i ;
                rd_addr_o = rd_addr_i;
                rd_wen_o = 1'b1;
    end
                `INST_SLTI:begin
                rd_data_o = {30'b0,op1_i_less_op2_i_signed};
                rd_addr_o = rd_addr_i;
                rd_wen_o = 1'b1;
    end
                `INST_SLTIU:begin
                rd_data_o = {30'b0,op1_i_less_op2_i_unsigned};
                rd_addr_o = rd_addr_i;
                rd_wen_o = 1'b1;
    end
            `INST_XORI:begin
                rd_data_o = op1_i_xor_op2_i;
                rd_addr_o = rd_addr_i;
                rd_wen_o = 1'b1;
    end
            `INST_ORI:begin
                rd_data_o = op1_i_or_op2_i;
                rd_addr_o = rd_addr_i;
                rd_wen_o = 1'b1;
    end
           `INST_ANDI:begin
                rd_data_o = op1_i_and_op2_i;
                rd_addr_o = rd_addr_i;
                rd_wen_o = 1'b1;
    end
               `INST_SLLI:begin
                rd_data_o = op1_i_sll_op2_i;
                rd_addr_o = rd_addr_i;
                rd_wen_o = 1'b1;
                
    end
            `INST_SRI:begin
            if (func7[5] == 1'b1) begin//SRAI
                rd_data_o = ((op1_i_srl_op2_i) & SRA_mask) | ((~SRA_mask) & ({32{op1_i[31]}}));
                rd_addr_o = rd_addr_i;
                rd_wen_o = 1'b1;
            
            end
            else begin//SRLI
                rd_data_o = op1_i_srl_op2_i;
                rd_addr_o = rd_addr_i;
                rd_wen_o = 1'b1;
                
            end
    
    end
                default:begin                   
                rd_data_o = 32'b0;
                rd_addr_o = 5'b0;
                rd_wen_o = 1'b0;
                end
    endcase
                end
                
        `INST_TYPE_R_M:begin
        jump_addr_o = 32'b0;
        jump_wen_o  = 1'b0;
        hold_flag_o =1'b0;
                  case(func3)
                     `INST_ADD_SUB:begin           //`INST_ADD_SUB,`INST_SLL,`INST_SLT,`INST_SLTU,`INST_XOR,`INST_SR,`INST_AND,`INST_OR                  
                     if (func7[5] == 1'b0)begin
                     rd_data_o = op1_i_add_op2_i;
                     rd_addr_o = rd_addr_i;
                     rd_wen_o = 1'b1;
    end

                     else begin
                     rd_data_o = op1_i - op2_i;
                     rd_addr_o = rd_addr_i;
                     rd_wen_o = 1'b1;
    end  
                     end
                    `INST_SLT:begin                                                    
                     rd_data_o = {30'b0, op1_i_less_op2_i_signed};
                     rd_addr_o = rd_addr_i;
                     rd_wen_o = 1'b1;
    end
                     `INST_SLL:begin                                                    
                     rd_data_o = op1_i_sll_op2_i;
                     rd_addr_o = rd_addr_i;
                     rd_wen_o = 1'b1;
    end
    
                    `INST_SLTU:begin                                                    
                     rd_data_o = {30'b0, op1_i_less_op2_i_unsigned};
                     rd_addr_o = rd_addr_i;
                     rd_wen_o = 1'b1;
    end
                    `INST_XOR:begin                                                    
                     rd_data_o = op1_i_xor_op2_i;
                     rd_addr_o = rd_addr_i;
                     rd_wen_o = 1'b1;
    end
                    `INST_OR:begin                                                    
                     rd_data_o = op1_i_or_op2_i;
                     rd_addr_o = rd_addr_i;
                     rd_wen_o = 1'b1;
    end
                   `INST_AND:begin                                                    
                     rd_data_o = op1_i_and_op2_i;
                     rd_addr_o = rd_addr_i;
                     rd_wen_o = 1'b1;
    end
                   `INST_SR:begin                                                    
                    if (func7[5] == 1'b1) begin//SRAI
                    rd_data_o = ((op1_i_srl_op2_i) & SRA_mask) | ((~SRA_mask) & ({32{op1_i[31]}}));
                    rd_addr_o = rd_addr_i;
                    rd_wen_o = 1'b1;
            
                     end
            else begin//SRLI
                   rd_data_o = op1_i_srl_op2_i;
                   rd_addr_o = rd_addr_i;
                   rd_wen_o = 1'b1;                
            end
    end
default:begin
rd_data_o = 32'b0;
rd_addr_o = 5'b0;
rd_wen_o = 1'b0;
end
    endcase
end

`INST_TYPE_B:begin  
rd_addr_o = 5'b0;
rd_data_o  = 32'b0;
rd_wen_o   =1'b0;
    case (func3)
    `INST_BEQ: begin//`INST_BEQ,`INST_BNE,`INST_BLT,`INST_BGE,`INST_BLTU,`INST_BGEU
        jump_addr_o = base_addr_add_addr_offset;
        jump_wen_o  = op1_i_equal_op2_i;
        hold_flag_o =1'b0;
   end
   `INST_BNE: begin
        jump_addr_o = base_addr_add_addr_offset;
        jump_wen_o  = ~op1_i_equal_op2_i;
        hold_flag_o =1'b0;
   end
     `INST_BLT: begin
        jump_addr_o = base_addr_add_addr_offset;
        jump_wen_o  = op1_i_less_op2_i_signed;
        hold_flag_o =1'b0;
   end
      `INST_BGE: begin
        jump_addr_o = base_addr_add_addr_offset;
        jump_wen_o  = ~op1_i_less_op2_i_signed;
        hold_flag_o =1'b0;
   end
      `INST_BLTU: begin
        jump_addr_o = base_addr_add_addr_offset;
        jump_wen_o  = op1_i_less_op2_i_unsigned;
        hold_flag_o =1'b0;
   end
      `INST_BGEU: begin
        jump_addr_o = base_addr_add_addr_offset;
        jump_wen_o  = ~op1_i_less_op2_i_unsigned;
        hold_flag_o =1'b0;
   end
        default: begin
        jump_addr_o = 32'b0;
        jump_wen_o  = 1'b0;
        hold_flag_o = 1'b0;
        end
    endcase
end
`INST_JAL:begin
    rd_data_o = op1_i_add_op2_i;
    rd_addr_o = rd_addr_i;
    rd_wen_o = 1'b1;
    jump_addr_o = base_addr_add_addr_offset;
    jump_wen_o  = 1'b1;
    hold_flag_o =1'b0;
end
`INST_JALR:begin
    rd_data_o = op1_i_add_op2_i;
    rd_addr_o = rd_addr_i;
    rd_wen_o = 1'b1;
    jump_addr_o = base_addr_add_addr_offset;
    jump_wen_o  = 1'b1;
    hold_flag_o =1'b0;
end
`INST_LUI:begin
 rd_data_o = op1_i;
    rd_addr_o = rd_addr_i;
    rd_wen_o = 1'b1;
    jump_addr_o = 32'b0;
    jump_wen_o  = 1'b0;
    hold_flag_o =1'b0;
end
`INST_AUIPC:begin
    rd_data_o = op1_i_add_op2_i;
    rd_addr_o = rd_addr_i;
    rd_wen_o = 1'b1;
    jump_addr_o = 32'b0;
    jump_wen_o  = 1'b0;
    hold_flag_o =1'b0;
end
default:begin
rd_data_o = 32'b0;
rd_addr_o = 5'b0;
rd_wen_o = 1'b0;
jump_addr_o = 32'b0;
jump_wen_o  = 1'b0;
hold_flag_o  =1'b0;

end

    endcase

end
endmodule