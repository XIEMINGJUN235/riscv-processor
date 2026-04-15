
`timescale 1ns / 1ps



module open_risc_v_soc(
    input  wire clk,                             
    input  wire rst

);
//open_riscv to rom
wire [31:0]rom_inst_o	;
wire[31:0]open_risc_c_inst_addr_o;

open_risc_v open_risc_v_inst(
   .clk          (clk)   ,               
   .rst        (rst),
   .inst_i        (rom_inst_o),
   .inst_addr_o    (open_risc_c_inst_addr_o)

);
rom rom_inst(
   .inst_addr_i(open_risc_c_inst_addr_o),
   .inst_o(rom_inst_o)
);











endmodule