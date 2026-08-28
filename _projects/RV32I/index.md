---
layout: post
title: RV32I Processor Core (RISC-V)
description: Designed and verified a single-cycle RV32I RISC-V processor in Verilog, implementing the base 32-bit integer instruction set, control unit, ALU, and memory interfaces.
order: 1
skills: 
  - RTL Design
  - SystemVerilog
  - RISC-V
  - Computer Architecture
  - Digital Design
  - Verilator
  - Waveform Analysis
main-image: /Summarized_Core.png
---

# Supported RISC-V RV32I Instructions

The core implements the standard **RV32I Base Integer Instruction Set**, supporting key instruction formats:

**Supported instruction categories:**
- **R-Type (Register-Register)**: `ADD`, `SUB`, `SLL`, `SLT`, `SLTU`, `XOR`, `SRL`, `SRA`, `OR`, `AND`
- **I-Type (Immediate / Loads)**: `ADDI`, `SLTI`, `SLTIU`, `XORI`, `ORI`, `ANDI`, `SLLI`, `SRLI`, `SRAI`, `LW`, `LH`, `LB`, `LHU`, `LBU`, `JALR`
- **S-Type (Stores)**: `SW`, `SH`, `SB`
- **B-Type (Branches)**: `BEQ`, `BNE`, `BLT`, `BGE`, `BLTU`, `BGEU`
- **U-Type (Upper Immediate)**: `LUI`, `AUIPC`
- **J-Type (Unconditional Jumps)**: `JAL`

---

# Processor Architecture Overview

The core is structured around a **single-cycle RV32I architecture**:

1. **Instruction Fetch (IF)** – PC register and Instruction Memory read
2. **Instruction Decode (ID)** – Opcode/funct parsing, Immediate Generation, and 32x32-bit Register File read
3. **Execution (EX)** – Arithmetic Logic Unit (ALU) calculation and branch target computation
4. **Memory Access (MEM)** – Data Memory read/write operations
5. **Write Back (WB)** – Writing ALU results or loaded memory data back to the register file

Key architectural characteristics:
- 32-bit datapath, PC, and register file
- Dedicated Immediate Generator for sign-extension across all instruction formats
- Hardwired `x0` register (always reads zero)
- Modular Verilog implementation with clear separation of control and datapath

---

# Datapath & Component Design

The datapath connects all key functional blocks to complete instruction execution within a single clock cycle.

## Major datapath components:
- **Program Counter (PC)**: Holds current instruction address with logic for sequential (+4) and branch/jump targets
- **Register File**: 32 x 32-bit registers with dual asynchronous read ports and single synchronous write port
- **Immediate Generator**: Extracting and sign-extending 12-bit and 20-bit immediates from instruction fields
- **Arithmetic Logic Unit (ALU)**: Executing arithmetic, bitwise, shift, and set-less-than comparisons
- **Data & Instruction Memory**: Byte-addressable memory interfaces supporting word, half-word, and byte access

{% include image-gallery.html images="Summarized_Core.png" height="400" %}
Figure 1: Block Diagram of the RV32I Core

{% include image-gallery.html images="Forwarding_Unit.png" height="400" %}
Figure 2: Forwarding Block Diagram of the RV32I Core

{% include image-gallery.html images="Branch_Prediction.png" height="400" %}
Figure 3: Branch Prediction Block Diagram of the RV32I Core

---

# Main Control & ALU Control Logic

The control logic converts the 32-bit instruction into execution signals across the core.

Key control responsibilities:
- **Main Control Unit**: Decodes `opcode` to output `RegWrite`, `ALUSrc`, `MemRead`, `MemWrite`, `MemtoReg`, `Branch`, and `Jump`
- **ALU Control Unit**: Decodes `funct3`, `funct7`, and `ALUOp` to drive the 4-bit ALU operational selection
- **Branch Logic**: Evaluates branch condition flags (Zero, Sign, Overflow) against instruction intent

---

# Verification and Testing

Verification was conducted using cycle-accurate behavioral simulation and waveform analysis.

## Verification methodology:
1. Assembly test programs targeting edge cases across R-Type, I-Type, Load/Store, and Branch instructions
2. Testbench setup delivering clock, reset, and memory initialization
3. Inspection of internal signals (PC, register values, ALU flags) using waveform viewing tools
4. Verification of state persistence and memory consistency across execution cycles

---

# Skills Demonstrated

- RISC-V RV32I ISA instruction decoding and execution
- Verilog HDL structural and behavioral modeling
- Digital logic design (ALU, Register File, Immediate Extender, Control Logic)
- Simulation, testbench creation, and waveform debugging
- Computer architecture fundamentals and datapath synthesis

---

# Key Takeaway

This project provided hands-on experience designing a 32-bit RISC-V processor core from scratch, mastering instruction encoding formats, control unit mapping, and Verilog RTL verification strategies.

---

# Files
All files are accessible here: [Github Repository](https://github.com/briancliau/RV32I)
