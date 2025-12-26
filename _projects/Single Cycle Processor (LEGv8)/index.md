---
layout: post
title: Single-Cycle LEGv8 Processor Design & Verification
description: Designed and verified a single-cycle LEGv8 processor implementing an ARM instruction subset, including datapath design, control logic, and functional validation using assembly test programs.
skills: 
  - VHDL
  - GHDL
  - GTKWave
  - Waveform Analysis
  - LEGv8
  - Computer Architecture
    
main-image: /images/Single Cycle Processor.PNG
---

# Subset of LEGv8 Instructions

This processor implements a functional subset of the ARM LEGv8 instruction set, sufficient to demonstrate arithmetic operations, memory access, and control flow.

**Supported instruction categories:**
- **Arithmetic / Logic**: `ADD`, `SUB`, `AND`, `ORR`
- **Immediate operations**: `ADDI`, `SUBI`
- **Memory access**: `LDUR`, `STUR`
- **Control flow**: `B`, `CBZ`

All supported instructions execute in a single clock cycle in accordance with the LEGv8 instruction format and semantics.

---

# Processor Architecture Overview

The design follows a **single-cycle processor architecture**, where each instruction completes instruction fetch, decode, execute, memory access, and write-back within one clock period.

Key architectural characteristics:
- 64-bit datapath and register file
- Separate instruction and data memory
- Hardwired control logic
- Deterministic CPI of 1

This architecture prioritizes simplicity and correctness, making it well-suited for instruction-level verification and architectural exploration.

---

# Datapath Design

The datapath was designed to support all required LEGv8 instruction formats and execution paths.

## Major datapath components:
- **Program Counter (PC)** with sequential and branch target update logic
- **Instruction Memory** for instruction fetch
- **Register File** with two read ports and one write port
- **Arithmetic Logic Unit (ALU)** for arithmetic, logical, and comparison operations
- **Sign Extension Unit** for immediate operands
- **Data Memory** for load and store instructions
- **Branch Decision Logic** for conditional and unconditional branches

Multiplexers controlled by the control unit ensure correct operand selection and data routing for each instruction type.

{% include image-gallery.html images="images/Single Cycle Processor.PNG" height="400" %}

---

# Control Unit Design

A **hardwired control unit** decodes LEGv8 opcodes and generates all necessary control signals in a single cycle.

## Control signals generated include:
- Register write enable
- ALU operation control
- Memory read and write enable
- ALU operand source selection
- Branch enable and PC source selection

The control unit ensures that only the required datapath components are activated for each instruction, maintaining correctness across all supported operations.

---

# Implementation Details

The processor was implemented in **VHDL**, with each major functional block separated into modular components.

## Design characteristics:
- Structural VHDL used for datapath interconnections
- Behavioral VHDL used for ALU and control logic
- Signal naming and module organization aligned with LEGv8 architectural conventions

This modular structure simplifies debugging and enables future extensions such as pipelining or multi-cycle execution.

---

# Verification and Testing

Processor correctness was verified using **custom LEGv8 assembly test programs**.

## Verification methodology:
1. Assembly programs loaded into instruction memory
2. Processor execution simulated cycle-by-cycle
3. Signal behavior inspected using GTKWave
4. Register and memory states compared against expected results

Verification confirmed:
- Correct arithmetic and logical results
- Proper memory load/store behavior
- Accurate branch target computation
- Correct program counter updates

## Instruction Memory 1
1. `ADDI X9, X9, 1`
2. `ADD  X10, X9, X11`
3. `STUR X10, [X11, 0]` 
4. `LDUR X12, [X11, 0]`
5. `CBZ X9, 2`
6. `B 3`
7. `ADD X9, X10, X11`
8. `ADD X9, X10, X11`
9. `ADDI  X9, X9, 1` 
10. `ADD   X21, X10, X9`
{% include image-gallery.html images="images/p1.PNG" height="400" %}

## Instruction Memory 2
1. `ADDI X10, X11, 1`
2. `ADDI X10, X11, 2`
3. `ADDI X9, X9, 1`
4. `SUBI X9, X9, 1`
5. `ADD  X10, X9, X11`
{% include image-gallery.html images="images/comp.PNG" height="400" %}

## Instruction Memory 3
1. `STUR X10, [X11, 0]`
2. `LDUR X10, [X9, 0]`
{% include image-gallery.html images="images/ldstr.PNG" height="400" %}

---

# Results and Observations

- All implemented instructions executed correctly within a single clock cycle
- Branch instructions correctly altered control flow
- Load and store instructions accessed memory as expected
- Critical path length highlighted timing limitations of single-cycle designs

This reinforced the trade-offs between simplicity and clock frequency in processor architecture.

---

# Skills Demonstrated

- CPU datapath and control unit design
- ARM LEGv8 instruction decoding
- VHDL-based hardware development
- Simulation and waveform analysis
- Assembly-level processor verification
- Computer architecture fundamentals

---

# Future Improvements

Potential extensions to this project include:
- Adding hazard detection and forwarding logic
- Expanding the supported LEGv8 instruction subset
- Performing performance comparisons across architectures

---

# Key Takeaway

This project provided hands-on experience translating an ISA specification into a functioning hardware implementation, emphasizing the relationship between instruction semantics, datapath design, and control logic.




