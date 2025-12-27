---
layout: post
title: Tamper Detection Box
description: A transistor-switched hardware security system that triggers an audible and visual alarm upon light exposure.
skills: 
  - Circuit Design
  - Analog Electronics
  - Transistor Switching
  - Hardware Security
  - Prototyping
    
main-image: /tamper.jpg
---

# Project Overview

The **Tamper Detection Box** is an active hardware security solution designed to monitor the physical integrity of a sealed enclosure. By utilizing a photoresistor-triggered transistor switch, the system detects unauthorized opening of a chassis and immediately activates a dual-alert system consisting of a piezo buzzer and a high-visibility LED.

**Key Features:**
* **Active Switching**: Utilizes a transistor (acting as a switch) to ensure the alarm receives full power instantly.
* **Dual-Sensory Alert**: Simultaneous audible (Piezo) and visual (LED) indicators.
* **Zero-Software Reliance**: A pure hardware logic design that is immune to software exploits or firmware hangs.
* **Low Standby Current**: Draws negligible power while the enclosure remains dark.

---

# Circuit Architecture

The design is built around a $5V$ power rail, using a transistor to drive the load based on the resistance of a photoresistor ($R_{LDR}$).

{% include image-gallery.html images="boxschematic.PNG" height="400" %}



[Image of an N-channel MOSFET switching circuit diagram]


### Core Components:
* **Photoresistor (LDR)**: Connected to $V_{cc}$ ($5V$); its resistance drops significantly when exposed to light, allowing current to reach the transistor gate.
* **Transistor**: Acts as the "logic gate" for the circuit, switching the $5V$ rail to the output components.
* **330Ω Resistor**: A current-limiting resistor placed in series to protect the LED and buzzer from overcurrent.
* **Piezo Buzzer & LED**: Wired in parallel at the end of the circuit to provide synchronized alerts.

---

# Theory of Operation

The circuit leverages the switching characteristics of a transistor to provide a deterministic trigger point.

1.  **Dark State (Enclosure Sealed)**: The photoresistor maintains high resistance (in the $M\Omega$ range). This prevents sufficient voltage from reaching the transistor's gate, keeping the switch in the "OFF" state.
2.  **Light State (Enclosure Opened)**: When light enters the box, the photoresistor's resistance drops to the $k\Omega$ range. This allows current to flow to the gate, saturating the transistor and "closing" the switch.
3.  **Alarm Activation**: $5V$ flows through the transistor and the $330\Omega$ resistor. The current is then split between the **Piezo Buzzer** (audible) and the **LED** (visual).

$$I_{total} = \frac{V_{cc} - V_{transistor}}{R_{330} + R_{load}}$$

---

# Implementation Details

The system was prototyped on a breadboard to calibrate the sensitivity of the photoresistor before final integration.

## Design Characteristics:
* **Parallel Load Configuration**: By placing the buzzer and LED in parallel, the system ensures redundancy; if the LED burns out, the buzzer will still function.
* **Threshold Tuning**: The sensitivity is determined by the specific transistor's gate-source threshold voltage ($V_{GS(th)}$), ensuring the alarm only triggers when a significant light breach occurs.
* **Compact Integration**: The small footprint of the components allows the circuit to be tucked into the corner of any standard electronic chassis.

---

# Verification and Testing

The circuit was tested under various environmental conditions to ensure reliability and minimize false positives.

{% include youtube-video.html id="trNMwuHIo6E" autoplay= "false"%}

## Testing Methodology:
1.  **Baseline Dark Test**: Confirmed $0V$ at the output when the enclosure was fully sealed.
2.  **Flashlight Breach**: Verified instantaneous trigger when a high-intensity light source was introduced.
3.  **Ambient Light Test**: Adjusted the photoresistor positioning to ensure it triggers under standard room lighting (approx. 300-500 lux).
4.  **Load Testing**: Measured voltage across the LED and Buzzer to ensure the $330\Omega$ resistor provided adequate protection.

| Condition | LDR Resistance | Transistor State | Alarm Output |
| :--- | :--- | :--- | :--- |
| **Sealed** | $> 1 M\Omega$ | Open (OFF) | Silent / Dark |
| **Partial Open** | $\approx 50 k\Omega$ | Partial | Dim LED / Low Buzz |
| **Fully Open** | $< 1 k\Omega$ | Closed (ON) | **Full Alert** |

---

# Skills Demonstrated

* **Analog Circuit Design**: Implementing semiconductor-based switching logic.
* **Component Characterization**: Selecting resistors to balance power across parallel loads.
* **Hardware Security**: Designing physical-layer tamper-evident mechanisms.
* **Prototyping**: Transitioning from a schematic to a functional hardware alert system.

---

# Future Improvements

* **Latching Mechanism**: Implementing a Thyristor (SCR) so the alarm remains active even if the box is quickly re-closed.
* **Battery Integration**: Adding a 9V-to-5V regulator for independent, battery-powered operation.
* **Remote Notification**: Integrating an ESP8264 to send a Wi-Fi alert to a central monitoring station upon trigger.
