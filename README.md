# riscv-processor
A three stage pipelined RISC-V processor core with data fowarding
## Project Status

This project is a completed and functional three-stage pipelined RISC‑V processor core, verified with the official `riscv-tests` suite. 

As a sophomore student, this is my first complete processor design project. I will continue to improve and extend this core in my spare time, including:

- Adding load/store instructions (LW/SW)
- Adding M extension (mul/div)
- Optimizing the pipeline and adding forwarding for all hazards
- FPGA synthesis and timing analysis

Suggestions and feedback are always welcome!

## Repository Structure

### RTL Source Files (`/rtl`)

| File | Description |
|------|-------------|
| `pc_reg.v` | Program counter with branch/jump support |
| `ifetch.v` | Instruction fetch interface (PC → ROM → IF/ID) |
| `if_id.v` | Pipeline register between IF and ID stages |
| `id.v` | Instruction decoder and operand preparation |
| `regs.v` | Register file (32×32, 2 read ports / 1 write port) |
| `id_ex.v` | Pipeline register between ID and EX stages |
| `ex.v` | ALU and execution logic (supports RV32I subset) |
| `ctrl.v` | Control logic for pipeline stall and jump forwarding |
| `dff_set.v` | D flip-flop with synchronous set (used for pipeline registers) |
| `defines.v` | Macro definitions for instruction opcodes and funct fields |

### Testbench (`/tb`)

| File | Description |
|------|-------------|
| `tb.v` | Top-level testbench. Generates clock and reset, loads test program into ROM, and prints register values for verification. |
| `open_risc_v_soc.v` | Top-level SoC wrapper that connects the CPU core with the instruction ROM. |
| `rom.v` | Instruction ROM (4096×32). Test programs are loaded via `$readmemh`. |

### Test Programs (`/tb/inst_txt`)

- for example`rv32ui-p-addi.txt` – Official RISC-V test for `addi` instruction
- 
- Additional test files for other instructions like `rv32ui-p-auipc.txt` – Official RISC-V test for `auipc` instruction

## How to Run Simulation

### Prerequisites
- ModelSim (or any Verilog simulator supporting Verilog-2001)

### Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/riscv-processor.git
   cd riscv-processor

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

Copyright (c) 2026 [XIE MINGJUN]
