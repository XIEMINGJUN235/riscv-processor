`timescale 1ns / 1ps

module dff_set #(                                                   //这段代码试图描述一个带同步置位功能的D触发器（D Flip-Flop with Set）CPU里有很多需要存数据的地方

    parameter                           DW                          = 32                   
)
(
    input  wire                         clk                        ,
    input  wire                         rst                        ,
    input wire                          hold_flag_i                ,
    input  wire          [DW-1: 0]      set_data                   ,
    input  wire           [DW-1: 0]      data_i                     ,
    output reg           [DW-1: 0]      data_o                      
);
 always @(posedge clk)
            begin
                if(rst == 1'b0 || hold_flag_i == 1'b1)
                data_o <= set_data;
                                                         
                else
                    data_o <= data_i;
            end
endmodule
//// IF/ID 流水线寄存器要做什么？
//任务	说明
//锁存数据	每个时钟上升沿，把取指阶段输出的 inst（指令）和 pc 存下来。
//保持稳定	在下一个时钟周期内，这些值不能变化，让译码阶段可以安全地使用它们。
//支持复位	刚开机或系统复位时，需要把指令强制设成一个空操作（NOP），防止误译码。
//这正好对应了 dff_set 的功能：

//正常工作时（rst=1）：data_o <= data_i，把输入的数据存下来输出。

//复位时（rst=0）：data_o <= set_data，把预设值（如 NOP 的机器码）输出。
//为什么需要同步置位：保证 CPU 复位后，译码阶段不会看到随机指令，而是安全地执行 NOP，避免执行非法指令导致错误。

//你现在可以把这个模块理解为 “听话的存储盒子”，它在 IF/ID 里的任务就是 “听时钟的话存数据，听复位的话变初始值”。