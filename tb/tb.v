`timescale 1ns / 1ps
module tb;
                                                                   
                                                    
reg clk;
reg rst;
integer r;
wire x3 = tb.open_risc_v_soc_inst.open_risc_v_inst.regs_inst.regs[3];
wire x26 = tb.open_risc_v_soc_inst.open_risc_v_inst.regs_inst.regs[26];
wire x27 = tb.open_risc_v_soc_inst.open_risc_v_inst.regs_inst.regs[27];
    
always#10 clk = ~clk;
initial begin
    clk <=1'b0;
    rst <= 1'b0;
    #30;
    rst <=1'b1;
    end 
//rom initial
initial begin
    $readmemh("./inst_txt/rv32ui-p-auipc.txt",tb.open_risc_v_soc_inst.rom_inst.rom_mem);//verify with the official RISC-V ISA test,all test passed,so the rom is correct.
    end
initial begin
  
  wait(x26 == 32'b1);
  #200;
  if (x27 == 32'b1) begin
    $display("###############    pass    !!!#########3############");
    
  end 
  else begin
    $display("###############    fail    !!!#########3############"); 
    $display("fail testnum = %2d", x3);
    for (r = 0; r < 32; r = r + 1) begin
     $display("x%2d register value is %d",r,tb.open_risc_v_soc_inst.open_risc_v_inst.regs_inst.regs[r]);   
    end
end
end
open_risc_v_soc open_risc_v_soc_inst(
    .clk(clk),                             
    .rst(rst)
    );
endmodule
 /* while (1) begin
        @(posedge clk)
        $display("x16 register value is %d",tb.open_risc_v_soc_inst.open_risc_v_inst.regs_inst.regs[16]);
        $display("x28 register value is %d",tb.open_risc_v_soc_inst.open_risc_v_inst.regs_inst.regs[28]);
        $display("x23 register value is %d",tb.open_risc_v_soc_inst.open_risc_v_inst.regs_inst.regs[23]);
        $display("=========================");
        $display("=========================");

    end*/