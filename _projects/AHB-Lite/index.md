---
layout: post
title: AHB-Lite Bus Interconnect & Peripheral Subsystem
description: Implemented and verified an AMBA AHB-Lite bus protocol interconnect in Verilog/SystemVerilog, featuring single-master multi-slave pipelined transfer handling, memory decoding, and peripheral interfaces.
skills: 
  - SystemVerilog
  - Verilog
  - AMBA AHB-Lite
  - SoC Architecture
  - Bus Interconnect Design
  - SystemVerilog Assertions
  - Verilator
  - Waveform Debugging
main-image: /AHB_Block_Diagram.png
---

# Overview of AMBA AHB-Lite Protocol

**AMBA AHB-Lite** (Advanced High-performance Bus Lite) is a subset of the full AMBA AHB specification designed for high-performance, single-master embedded System-on-Chip (SoC) architectures.

**Key Protocol Features:**
- **Pipelined Operations**: Overlapped Address and Data phases for maximum bus throughput
- **Single Master Architecture**: Eliminates complex bus arbitration overhead while maintaining high performance
- **Burst Transfers**: Supports single and burst transfer modes
- **Control Signals**: `HTRANS`, `HSIZE`, `HWRITE`, `HWDATA`, `HRDATA`, `HREADY`, and `HRESP`

---

# Subsystem Architecture

The implemented subsystem integrates an **AHB-Lite Master**, a **Central Decoder / Multiplexer Interconnect**, and **Slave Peripherals** (Memory & IO devices).

1. **AHB-Lite Master**: Generates transfer requests, control signals (`HTRANS`, `HADDR`, `HWRITE`), and write data (`HWDATA`)
2. **Address Decoder**: Maps input addresses (`HADDR`) to target slave select signals (`HSELx`)
3. **Slave Multiplexer**: Routes read data (`HRDATA`) and readiness status (`HREADY`) back to the master based on the active slave
4. **AHB Slaves**: Memory modules (SRAM/ROM) and peripheral controllers responding to bus transactions

Key architectural characteristics:
- Full 32-bit address and 32-bit data bus implementation
- Address decoding logic supporting memory-mapped I/O spaces
- Pipelined two-stage transfers (Address Phase followed by Data Phase)
- Wait-state injection support via `HREADY` feedback for slow peripherals

---

# Bus Transfer Phases & Timing

The bus interconnect operates across distinct phases to ensure zero-wait-state back-to-back operations when peripherals are ready.

## Bus Transfer Flow:
- **Address Phase (T1)**: The Master drives `HADDR`, `HTRANS`, `HWRITE`, and `HSIZE`. The decoder selects the appropriate slave (`HSELx`).
- **Data Phase (T2)**: The selected slave responds to `HWDATA` for write requests or drives `HRDATA` for read requests.
- **Handshaking**: Slaves hold `HREADY` low to extend the data phase when internal processing requires additional clock cycles.

{% include image-gallery.html images="AHB_Block_Diagram.png" height="400" %}

---

# Decoder and Multiplexer Logic

The central interconnect coordinates signal routing without active bus contention:

Key interconnect responsibilities:
- **Address Decoding**: Combinational lookup mapping high-order address bits to discrete `HSEL` signals
- **Response Multiplexing**: Registered tracking of the active slave from the Address Phase to accurately route `HRDATA` and `HREADYout` during the Data Phase
- **Default Slave Support**: Returns `HRESP` error or zero response when accessing unmapped address regions

---

# Verification and Simulation

Verification was performed using HDL testbenches and cycle-accurate waveform analysis.

## Verification methodology:
1. **Single Read/Write Cycles**: Validated word, half-word, and byte access across mapped memory locations
2. **Back-to-Back Pipeline Transfers**: Verified seamless transition between consecutive read and write operations
3. **Wait-State Insertion**: Injected artificial delay cycles via `HREADY` to verify master holding logic
4. **Boundary Address Testing**: Confirmed accurate decoder selection across memory map bounds

---

# Skills Demonstrated

- AMBA AHB-Lite protocol implementation and bus timing compliance
- Verilog / SystemVerilog RTL design for SoC bus fabrics
- Address decoder and slave multiplexer interconnect design
- Pipelined hardware transaction design and wait-state handling
- Simulation, testbench development, and cycle-by-cycle waveform verification

---

# Key Takeaway

This project demonstrated the design principles behind modern SoC interconnects, highlighting how pipelined bus protocols like AHB-Lite maximize data throughput while minimizing logic complexity in single-master processor systems.

---

# Files
All files are accessible here: [Github Repository](https://github.com/briancliau/AHB_Lite)
