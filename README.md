# MH-Titans

## FPGA-Based Railway Interlocking and Dynamic Route Control System

Developed by **Team MH Titans** for **VELTRAXX'26 National Design Challenge**.

---

## Project Overview

The FPGA-Based Railway Interlocking System is a safety-oriented digital controller implemented on an **Artix-7 FPGA**.

The system uses a **Finite State Machine (FSM)** to control railway routes, prevent conflicting route activation, handle emergency requests, enforce clearance delays, and detect stalled trains using a watchdog timer.

The project models important railway interlocking behavior on compact and affordable FPGA hardware.

---

## Key Features

- FSM-based sequential route control
- Route locking after a request is granted
- Route remains locked even after the request button is released
- Track Clear input for route release
- Prevention of conflicting route requests
- Emergency route preemption
- Hardware-timed all-red clearance delay
- Watchdog timeout for stalled trains
- Global SYSTEM FAULT state
- Blinking RED indication during system fault
- Manual reset required to recover from fault
- Fail-safe default outputs

---

## Hardware Platform

- **FPGA Board:** Digilent Nexys 4 DDR
- **FPGA Device:** Artix-7
- **HDL:** Verilog HDL
- **Clock:** 100 MHz FPGA clock
- **Development Tool:** Xilinx Vivado

---

## System Operation

### 1. Normal Route Request

A train requests Route A or Route B.

The FSM checks the current system state and grants the requested route if it is safe.

Once granted, the route becomes locked.

### 2. Route Locking

A granted route remains active even after the request button is released.

The route can only return to the idle state after receiving the **Track Clear** signal.

This models physical train movement and track occupancy.

### 3. Emergency Preemption

When an emergency request is received:

1. Active normal routes are forced to RED.
2. The system enters the emergency clearance state.
3. A hardware timer enforces the required all-red clearance delay.
4. After the delay, the emergency route is activated.

### 4. Watchdog Fail-Safe

If an active route does not receive the Track Clear signal within the configured watchdog period:

1. The watchdog timer expires.
2. The FSM enters SYSTEM FAULT.
3. Route signals are forced to a safe RED condition.
4. Fault indication blinks.
5. The system remains in the fault state until manual reset.

---

## Repository Structure

```text
MH-Titans/
│
├── README.md
│
├── constraints/
│   └── nexys4_ddr.xdc
│
├── docs/
│   └── README.md
│
├── src/
│   └── railway_interlocking.v
│
├── tb/
│   └── tb_railway_interlocking.v
│
├── scripts/
│   └── README.md
│
├── logs/
│   └── README.md
│
├── outputs/
│   └── README.md
│
└── presentation/
    ├── MH Titans final (1).pdf
    └── README.md
