---
layout: post
title: 63-Tap FIR Filter Hardware Accelerator & AHB-Lite Wrapper
description: Designed and integrated a pipelined 63-tap symmetric FIR filter hardware accelerator into an AMBA AHB-Lite SoC peripheral wrapper, featuring custom CSRs, pipelined multiplier-accumulator trees, and interrupt-driven status signaling.
order: 5
skills: 
  - SystemVerilog
  - Verilog
  - AMBA AHB-Lite
  - Digital Signal Processing (DSP)
  - Hardware Acceleration
  - SoC Integration
  - Verilator & Simulation
main-image: /FIR_Filter.png
---

# Overview of FIR Filter Accelerator

This project implements a hardware-accelerated **63-tap finite impulse response (FIR) filter** integrated into an AMBA AHB-Lite peripheral wrapper (`ACCEL.sv`) for a microcontroller-based System-on-Chip (SoC). The accelerator offloads compute-intensive digital signal processing tasks from the main processor core, leveraging symmetric filter folding, pipelined multipliers, and an optimized adder reduction tree.

**Key Architectural Features:**
- **Symmetric FIR Optimization**: Exploits coefficient symmetry across 63 taps to reduce multiplier resource requirements using pre-addition.
- **AMBA AHB-Lite Integration**: Implements a complete programmer's model with Control and Status Registers (CSRs) accessible via standard AHB-Lite bus transactions.
- **Buffered Output Management**: Features a 256-entry output data buffer with automatic pointer tracking and interrupt request (`IRQ`) generation upon completion
- **Configurable Operational States**: Supports distinct operating states including `IDLE`, `LOAD_COEFF`, `COMPUTE`, and `READOUT`.

---

# Subsystem Architecture

The accelerator consists of the top-level AHB subordinate wrapper (`ACCEL.sv`), the automatically generated register interface (`pregs.sv`), and the core FIR filter computation engine (`FIR_63TAP.sv`).

1. **AHB-Lite Subordinate Wrapper (`ACCEL.sv`)**: Translates AHB-Lite bus commands into internal register configurations and coordinates state transitions between coefficient loading, computation, and readout.
2. **Control & Status Register File (`pregs.sv`)**: Manages operational configuration (`CTRL`), status flags (`STATUS`), input samples (`IN_SAMPLE`), coefficient ports (`IN_COEFF`), and output buffer read addresses.
3. **63-Tap FIR Core (`FIR_63TAP.sv`)**: Implements pipelined data shifting, coefficient storage, parallel multiplications, and a multi-stage adder tree reduction culminating in rounded fixed-point output samples.

---

# Operational States & Programmer's Model

The accelerator operates through four primary states controlled via the `CTRL` register:
- **`IDLE` (4'h1)**: Reset and standby state.
- **`LOAD_COEFF` (4'h2)**: Sequential loading of filter coefficients through the `IN_COEFF` port.
- **`COMPUTE` (4'h4)**: Active sample processing state where incoming data streams are filtered and written to the internal 256-entry buffer.
- **`READOUT` (4'h8)**: State enabling software to index and read back processed output samples from the buffer.

| Address Offset | Signal Name | Access | Bit Width | Description |
| --- | --- | --- | --- | --- |
| 0x10 | **CTRL** | RW | 4 | Configuration and operational state register |
| 0x14 | **STATUS** | R | 2 | Status flags (Buffer full / completion status) |
| 0x18 | **IN_SAMPLE** | RW | 10 | Input sample streaming port |
| 0x1c | **IN_COEFF** | RW | 10 | Coefficient loading port |
| 0x20 | **OUT_SAMPLE_ADDR** | RW | 8 | Output buffer read address index |
| 0x24 | **OUT_SAMPLE** | R | 20 | Filtered output sample data read port |

---

# Verification and Simulation

The design was verified using an isolated SystemVerilog testbench (`tb.sv`) emulating full AHB-Lite bus transaction sequences.

## Verification Methodology:
1. **Coefficient Initialization**: Bulk loading of filter coefficients via sequential AHB writes.
2. **Stream Processing**: Streaming input samples from test vector files into the accelerator during the `COMPUTE` state.
3. **Interrupt & Buffer Validation**: Monitoring hardware `IRQ` assertion and `STATUS[0]` buffer-full flags upon completion.
4. **Result Readout**: Indexing through the 256-entry output buffer via `OUT_SAMPLE_ADDR` to verify filtered outputs.

---

# Skills Demonstrated

- RTL design and microarchitecture of high-throughput DSP hardware blocks (FIR filters)
- AMBA AHB-Lite peripheral wrapper integration and register-transfer level interfacing
- Fixed-point arithmetic optimization using symmetric folding and pipelined adder trees
- Automated register interface generation and verification using custom SystemVerilog testbenches
- Cycle-accurate waveform simulation, debugging, and interrupt-driven control design

---

# Key Takeaway

This project demonstrated how to bridge high-performance digital signal processing algorithms with standard SoC interconnect protocols like AMBA AHB-Lite, delivering an efficient, interrupt-driven hardware accelerator capable of real-time filtering with minimal CPU overhead.

---

# Files
All source files and testbenches are accessible here: [GitHub Repository](https://github.com/briancliau/briancliau.github.io)
FIR Filter image taken from: https://www.dsprelated.com/showarticle/1585.php