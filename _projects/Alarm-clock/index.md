---
layout: post
title: Discrete IC Alarm Clock (In Progress)
description: Ongoing design of a fully discrete digital alarm clock built from fundamental logic ICs, counters, comparators, a crystal oscillator, and a custom PCB—without the use of microcontrollers or programmable logic.
skills: 
  - Digital Logic Design
  - CMOS / TTL ICs
  - Clock & Timing Circuits
  - Finite State Machines
  - Schematic Capture
  - PCB Design
  - Hardware Debugging
main-image: /alarm-clock.png
---

# Project Overview

This project is an **alarm clock designed entirely from discrete integrated circuits**, intentionally avoiding microcontrollers, FPGAs, or programmable logic. All timing, counting, comparison, display driving, and alarm triggering are implemented using **standard CMOS and TTL ICs**, a **32.768 kHz crystal oscillator**, and custom-designed PCBs.

The primary objective is to build a **fully functional, reliable digital alarm clock** while gaining a deep understanding of **timekeeping, synchronous logic, and hardware-only system design**.

🚧 **Status**: In Active Development

---

# Design Constraints & Philosophy

This project is governed by strict constraints to emphasize fundamental hardware design:

* ❌ No microcontrollers
* ❌ No firmware or software timing
* ❌ No programmable logic
* ✅ Only off-the-shelf logic ICs
* ✅ Crystal-based time reference
* ✅ Fully schematic-driven design
* ✅ Custom PCB implementation

All system behavior must emerge from hardware logic alone.

---

# System Architecture (Planned)

The alarm clock is composed of several interconnected subsystems:

### Major Subsystems
* **Time Base Generator** – Crystal oscillator and frequency divider
* **Seconds / Minutes / Hours Counters** – Cascaded binary and decade counters
* **Display Driver** – BCD to 7-segment decoding
* **Time Set Logic** – Manual adjustment using pushbuttons
* **Alarm Time Storage** – Latches / flip-flops
* **Alarm Comparator** – Magnitude comparison between current time and alarm time
* **Alarm Output Logic** – Buzzer or speaker driver
* **Power Regulation** – Linear 5V regulation

---

# Time Base & Frequency Division

A **32.768 kHz watch crystal** provides the fundamental time reference. This signal is divided down using a **binary ripple counter** to generate a precise **1 Hz clock**.

### Implemented Components
* **CD74HC4060** – Crystal oscillator and 14-stage binary divider
* Output taps selected to derive stable timing signals

This approach mirrors the timing architecture used in commercial digital clocks.

---

# Timekeeping Logic

Timekeeping is implemented using cascaded counter stages:

### Planned Counter Chain
* **Seconds**: Mod-60 counter
* **Minutes**: Mod-60 counter
* **Hours**: Mod-24 counter

Counters are constructed using **SN74HC161** synchronous binary counters with combinational reset logic to enforce modulus limits.

Carry propagation is carefully managed to maintain synchronous operation and avoid timing glitches.

---

# Display System

The time is displayed using **7-segment LED displays** driven entirely by hardware decoding logic.

### Display Components
* **SN74LS47** – BCD to 7-segment decoder/drivers
* Multiplexing logic (if required) implemented using logic gates and multiplexers
* Digit enable logic synchronized with display refresh

The design prioritizes readability while minimizing component count.

---

# Alarm Functionality

The alarm system compares the current time to a user-set alarm time:

### Alarm Logic
* **CD4585** magnitude comparators check equality between:
  * Current hours/minutes
  * Stored alarm hours/minutes
* When all comparator outputs match, an **alarm enable signal** is asserted
* Alarm output is latched until manually cleared

Alarm time storage uses **D-type flip-flops (CD4013)** to retain user-defined values.

---

# User Input & Control

User interaction is handled through **mechanical pushbuttons**, debounced in hardware.

### Controls (Planned)
* Time set increment
* Alarm set increment
* Mode select (clock vs alarm)
* Alarm enable / disable

All button interactions are translated into clean logic-level pulses without software assistance.

---

# Power System

* **L7805 linear regulator** provides stable 5V logic supply
* Designed to support LED displays and alarm output load
* Decoupling and filtering included at every IC

---

# Current Progress

✔️ Component selection finalized  
✔️ Time base architecture validated  
✔️ Initial counter and comparator schematics drafted  
✔️ Display driver logic verified  
⏳ PCB layout in progress  
⏳ Alarm logic integration  
⏳ Full system bring-up and testing  

---

# Technical Challenges

This project focuses on several non-trivial hardware challenges:

* **Glitch-free counter resets**
* **Synchronous carry propagation**
* **Button debouncing without firmware**
* **Comparator timing alignment**
* **Minimizing IC count while preserving clarity**
* **PCB signal integrity for clock lines**

---

# Skills Demonstrated (Ongoing)

* **Digital Logic Design** – Counters, comparators, FSMs
* **Timing Analysis** – Clock division and synchronization
* **Hardware-Only System Design** – No firmware safety net
* **Schematic & PCB Design** – End-to-end hardware workflow
* **Debugging** – Logic probing and incremental validation

---

# Planned Improvements & Roadmap

* Complete PCB routing and fabrication
* Integrate alarm output stage
* Add visual alarm indicator (LED)
* Improve user interface ergonomics
* Validate long-term timing accuracy
* Optional enclosure design

---

# Project Status

🚧 **Status**: In Active Development  
📅 **Start Date**: Fall 2025  
🎯 **Target Completion**: TBD  

---

# Files

Schematics, PCB layouts, and documentation will be published here upon completion:  
[GitHub Repository – Coming Soon](#)

---
