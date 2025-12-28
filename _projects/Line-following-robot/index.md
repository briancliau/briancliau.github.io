---
layout: post
title: Line-Following Robot
description: Designed and built an autonomous line-following robot featuring real-time battery monitoring, color sensing for lane calibration, and collision detection using an Arduino UNO WiFi R2 and custom integrated circuits.
skills: 
  - Arduino (C++)
  - Circuit Design
  - Battery Management Systems
  - Sensor Calibration
  - Hardware Integration
  - WebSockets
main-image: /line-following-bot.png

---

# Robot Specifications

The line-following bot is a compact, autonomous vehicle designed for precision lane following and environmental interaction.

{% include image-gallery.html images="3d_spec.png" height="250" %}
{% include image-gallery.html images="full_3d_model.png" height="300" %}

**Physical Dimensions:**
* **Length**: 241 mm
* **Width**: 136 mm
* **Height**: 75 mm
* **Weight**: 1.5 kg

The chassis and sensor housings were custom-designed using CAD to minimize weight while maintaining an aesthetically pleasing profile.

---

# Hardware Architecture

The robot's intelligence is powered by an **Arduino UNO WiFi R2**, interfacing with several custom-built sensor modules.

## Circuit Design & Schematics

The reliability of the bot relies on the precise design of its custom sensor circuits.

## H-Bridge Motor Control
The L293D H-Bridge allows for bi-directional control of the DC motors, separating the high-current motor power from the Arduino logic.


{% include image-gallery.html images="h_bridge_circuit.png" height="400" %}

## Color Sensor Array
The color sensor uses a combination of Red and Blue LEDs with photoresistors. By measuring the reflected light intensities (analog values), the bot identifies lane colors.


{% include image-gallery.html images="color_sensor_circuit.png" height="300" %}

## IR Collision Detector
The collision detector uses a TEPT4400 phototransistor and an LVIR3333 IR emitter to sense objects in front of the robot based on IR reflection.


{% include image-gallery.html images="ir_sensor_circuit.png" height="300" %}

---

# Custom Features & Design

### Real-Time Battery Monitoring
To ensure operational reliability, we implemented a dedicated monitoring system:
* **Voltage Dividers**: Scale battery voltage for sampling by analog pins A1 and A2.
* **Visual Indicators**: If voltage drops below 7.4V, specific red LEDs trigger to signal low health.
* **Status Mapping**: The left red LED is for the motor, while the right LED is for the Arduino.

{% include image-gallery.html images="battery_divider_1.png" height="400" %}
{% include image-gallery.html images="battery_divider_2.png" height="400" %}
 

### Optimized Aesthetics & Weight
* **Protoboard Integration**: Sensors were moved from breadboards to protoboards to optimize the size and weight of the bot.
* **Wiring Standards**: We used the shortest possible wires and followed a strict color code.
* **Color Coding**: Red for power, black for ground, blue/yellow for LEDs, and purple for analog read values.

---

# Security & Communication

The bot communicates via **WebSockets** and includes a custom security layer to prevent unauthorized commands:
* **Message Filtering**: The system only reads messages that include unique client IDs.
* **ID Protocol**: Messages must follow the structure: `[their client ID]. [our client ID]. [message]`.
* **Validation**: This ensures the bot only responds to recognized instructions sent directly to it.

---

# Inventory & Components

| Item | Quantity | Type | Status | Cost |
| :--- | :--- | :--- | :--- | :--- |
| Arduino UNO WiFi R2 | 2 | Electrical | On bot / Testing | Provided |
| 9-Volt Battery | 4 | Electrical | On bot | Provided |
| L293D H-Bridge | 1 | Mechanical | On bot | Provided |
| DC Motors | 2 | Mechanical | On bot | Provided |
| IR Phototransistor | 1 | Electrical | On bot | Provided |
| Photoresistors | 2 | Electrical | On bot | Provided |
| Chassis Body | 2 | CAD | On bot | $25 |

---

# User Instructions

### Setup and Calibration
1. **Code Deployment**: Flash the Arduino, ensuring batteries are disconnected during the process.
2. **Lane Calibration**:
    * Place bot on **Red**, **Yellow**, and **Blue** lanes sequentially, pressing the button at each stage.
    * Calibrate for the **Black** background and finally the **Collision Detector**.
3. **Operation**: Ensure back red LEDs are NOT lit (indicating healthy batteries) and press the button to start.

---

# Skills Demonstrated
* **Embedded Systems**: Programming Arduino for multi-sensor integration and motor control.
* **Circuit Design**: Creating voltage dividers and sensor schematics.
* **Hardware Prototyping**: Soldering protoboards and wire management for compact design.
* **Network Security**: Implementing filtering protocols for WebSocket communication.

---

# Future Improvements
* Create custom PCBs for the color sensor, collision detection sensor, and motor driver circuit.
* Create a more comprehensive LED circuit for battery monitoring.
* Create custom websocket for greater security. 

---

# Project Team
* **Brian Liau** – Lead Hardware Engineer: Responsible for circuit schematic design, protoboard soldering, full-scale hardware integration with the Arduino, and final system verification/testing.
* **Patrick Johnson** – Mechanical Fabrication: Responsible for 3D printing and assembly of the chassis and sensor mounts.

---
# Files
The complete source code and design files are available here: [GitHub Repository](https://github.com/aobu/line-follower/tree/main)

---
# Solo Bot Run

# Joint Bot Run 


