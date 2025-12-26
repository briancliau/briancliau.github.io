---
layout: post
title: Pipelined LEGv8 Processor with Hazard Detection & Forwarding
description: Designed and verified a **5-stage pipelined LEGv8 processor** implementing an ARM instruction subset and correctly handling **data hazards**, **load-use hazards**, and **control hazards**, using forwarding and stalling mechanisms
skills: 
  - VHDL
  - GHDL
  - GTKWave
  - Waveform Analysis
  - LEGv8
  - Computer Architecture
  - Pipeline Design
  - Hazard Detection
  - Forwarding
    
main-image: /hazard.PNG
---

# Subset of LEGv8 Instructions

The processor implements a functional subset of the ARM LEGv8 instruction set chosen to exercise pipeline behavior and hazards.

**Supported instruction categories:**
- **Arithmetic / Logic**: `ADD`, `SUB`, `AND`, `ORR`, `LSL`, `LSR`
- **Immediate operations**: `ADDI`, `SUBI`
- **Memory access**: `LDUR`, `STUR`
- **Control flow**: `B`, `CBZ`

Instructions execute across multiple pipeline stages, allowing multiple instructions to be in-flight simultaneously.

---

# Processor Architecture Overview

The processor follows a **five-stage pipelined LEGv8 architecture**:

1. **IF** – Instruction Fetch  
2. **ID** – Instruction Decode & Register Read  
3. **EX** – Execute / Address Calculation  
4. **MEM** – Data Memory Access  
5. **WB** – Write Back  

Pipeline registers (**IF/ID**, **ID/EX**, **EX/MEM**, **MEM/WB**) separate each stage and preserve data and control signals across cycles.

Key architectural characteristics:
- 64-bit datapath and register file
- Separate instruction and data memory
- Pipeline register isolation between stages
- Increased instruction throughput compared to single-cycle execution

---

# Datapath Design

The datapath was derived from the single-cycle design and refactored into a pipelined structure.

## Major datapath components:
- Program Counter (PC) and instruction fetch logic
- Register File accessed during the ID stage
- Arithmetic Logic Unit (ALU) operating in the EX stage
- Sign-extension and immediate generation logic
- Data memory accessed during the MEM stage
- Write-back multiplexing in the WB stage
- Inter-stage pipeline registers carrying both data and control signals

Pipeline registers ensure that each instruction progresses independently through the stages.

{% include image-gallery.html images="hazard.PNG" height="400" %}

---

# Control Logic and Pipeline Control

Control signals are generated during the **ID stage** and propagated through the pipeline registers to align with their corresponding data.

Key control responsibilities:
- Coordinating register writes in WB stage
- Selecting ALU operations in EX stage
- Enabling memory access in MEM stage
- Managing branch-related control flow

Careful timing of control signals is required to maintain correctness in the presence of overlapping instruction execution.

---

# Forwarding Unit

To resolve **data hazards** without unnecessary stalls, a **forwarding unit** was implemented.

## Forwarding behavior:
- Forwards ALU results from **EX/MEM** and **MEM/WB** stages
- Controls ALU operand selection via `ForwardA` and `ForwardB` signals
- Prevents read-after-write (RAW) hazards for dependent instructions

This significantly reduces pipeline stalls and improves throughput.

---

# Hazard Detection Unit

A **hazard detection unit (HDU)** handles load-use hazards that cannot be resolved through forwarding alone.

## Hazard handling mechanisms:
- Detects load-use dependencies in the ID stage
- Stalls the PC and IF/ID pipeline register
- Inserts a NOP into the pipeline by zeroing control signals

This ensures correctness when an instruction depends on data still being loaded from memory.

---

# Control Hazards and Limitations

Branch instructions introduce **control hazards** in the pipelined architecture.

- Branch outcomes are resolved after the EX stage
- Instructions fetched after a branch may be incorrect
- Basic pipeline flushing is used for unconditional branches

**Limitation:**  
Conditional branches such as `CBZ` introduce additional hazards that are not fully resolved in this implementation. A complete solution would require:
- Earlier branch resolution
- Pipeline flushing logic
- Branch prediction mechanisms

---

# Implementation Details

The processor was implemented in **VHDL** with modular separation between pipeline stages and control logic.

## Design characteristics:
- Structural VHDL for datapath and pipeline registers
- Behavioral VHDL for ALU, forwarding unit, and hazard detection unit
- Explicit debug signals used to validate forwarding and stalls
- Clear separation of stage logic for maintainability

---

# Verification and Testing

Verification was performed using **cycle-accurate simulation** and waveform analysis.

## Verification methodology:
1. Custom LEGv8 assembly programs loaded into instruction memory
2. Multiple instructions observed simultaneously across pipeline stages
3. Pipeline registers, forwarding paths, and stall signals inspected in GTKWave
4. Final register and memory states validated against expected behavior

---

## Instruction Memory 1

1. `LDUR  X9, [XZR, 0]` 
2. `ADD X9, X9, X9`  
3. `ADD X10, X9, X9`  
4. `SUB X11, X10, X9` 
5. `STUR  X11, [XZR, 8]`  
6. `STUR  X11, [XZR, 16]`
7. `NOP`  
8. `NOP`  
9. `NOP`  
10. `NOP`  

{% include image-gallery.html images="p1_overall.PNG" height="400" %}

---

## Instruction Memory 2

1. `CBNZ X9 2`  
2. `LSR X10, X10, 2`  
3. `ANDI X11, X10, 15`  
4. `LSL X12, X12, 2`  
5. `ORR X21, X19, X20`
6. `SUBI X22, X21, 15`  

{% include image-gallery.html images="p2_overall.PNG" height="400" %}

---

# Results and Observations

- Multiple instructions executed concurrently across pipeline stages
- Forwarding eliminated most data hazards without stalling
- Load-use hazards correctly triggered pipeline stalls
- Control hazards highlighted the need for branch handling enhancements
- Throughput improved relative to the single-cycle implementation

---

# Skills Demonstrated

- Pipelined CPU datapath design
- Forwarding and hazard detection logic
- ARM LEGv8 instruction execution
- VHDL-based processor implementation
- Cycle-accurate simulation and waveform analysis
- Debugging complex hardware interactions

---

# Future Improvements

- Implement full control hazard handling for conditional branches
- Add branch prediction
- Quantitatively measure CPI and performance gains
- Compare against single-cycle and multi-cycle designs

---

# Key Takeaway

This project demonstrated how instruction-level parallelism improves processor performance while introducing new complexity, emphasizing the importance of precise timing, hazard management, and control in modern CPU design.

---

# Files
All files are accessible here: [Github Files](<https://github.com/briancliau/briancliau.github.io/tree/main/_projects/Pipelined-Processor-(LEGv8)/VHDL-files>)
