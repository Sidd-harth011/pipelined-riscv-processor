# 🚀 32-Bit RV32I Pipelined RISC-V Processor

**Author:** Siddharth Gautam  
**Domain:** Computer Architecture / FPGA / SoC Design

---

## 📌 Overview
This project presents a high-performance, 32-bit RISC-V processor core designed from the ground up at the Register-Transfer Level (RTL) using Verilog. Built around a **5-stage pipelined architecture** (IF, ID, EX, MEM, WB), this core implements the RV32I base integer instruction set.

The design addresses the inherent complexities of pipelining by implementing a sophisticated **Hazard Detection Unit**, enabling high instruction throughput through dynamic data forwarding and pipeline control. The processor is fully synthesizable and achieves physical timing closure at a **100 MHz system clock** on Artix-7 FPGA silicon.

---

## ✨ Key Features

* 🔹 **5-Stage Pipelined Datapath:** Implements overlapped instruction execution, maximizing throughput by completing one instruction per clock cycle once the pipeline is primed.
* 🔹 **Hazard Detection & Resolution:** Advanced control logic that actively identifies structural, data, and control hazards, maintaining architectural integrity in a high-speed execution environment.
* 🔹 **Data Forwarding Unit:** A bypass mechanism that routes freshly computed ALU or memory results directly into the Execute stage, effectively eliminating Read-After-Write (RAW) data hazards and reducing pipeline stalls.
* 🔹 **Dynamic Branch Flushing:** Intelligent control logic that flushes speculatively fetched instructions from the pipeline upon branch resolution, ensuring the CPU state remains pristine during control-flow changes.

---

## 📐 Architecture
The processor core is built on a modular, robust datapath designed for speed and reliability:

### 🔸 Core Pipeline Stages
* **Instruction Fetch (IF):** Sequential instruction retrieval utilizing the Program Counter (PC).
* **Instruction Decode (ID):** Opcode translation, register file access, and immediate operand extraction.
* **Execute (EX):** Arithmetic Logic Unit (ALU) operations and branch target calculation.
* **Memory Access (MEM):** Synchronous interaction with BRAM for Load/Store operations.
* **Writeback (WB):** Final commit phase where computed data is written back to the Register File.

### 🔸 Control & Synchronization
* **Hazard Detection Unit:** Monitors register dependencies across pipeline stages to trigger `stall` and `flush` control signals.
* **Pipeline Barriers:** Synchronous flip-flop registers placed between each stage to ensure stable data handoff on the clock edge.

---

## 🔬 Verification & Simulation
Rigorous verification was performed using **Xilinx Vivado** simulation environments. The design was validated using a custom testbench (`riscv_tb.v`) with the following focus areas:

* **Hazard Scenario Testing:** Stress-testing the core with RAW dependencies and conditional branch jumps.
* **Waveform Analysis:** Proving the effectiveness of the forwarding muxes and the injection of NOP bubbles.
* **Instruction Integrity:** Validating the execution of the full RV32I base integer set through a diagnostic assembly suite.

---


## 🚀 Future Enhancements
* **Cache Hierarchies:** Moving from simple BRAM to multi-level cache structures to mitigate memory bottlenecks.
* **AXI4-Lite Integration:** Wrapping the core in an industry-standard AXI4-Lite interface for SoC-level connectivity and peripheral expansion.
* **M-Extension:** Expanding the ISA to include hardware-accelerated integer multiplication and division.
* **Debug Interface:** Integrating a JTAG-based debug interface for real-time in-circuit CPU monitoring.

---

## 🛠️ Tech Stack
* **Language:** Verilog (RTL)
* **Architecture:** RISC-V RV32I
* **Tools:** Xilinx Vivado (Synthesis/Implementation)
* **Domain:** Digital Logic Design / Computer Architecture

---

⭐ **If you find this processor architecture useful for your own RISC-V studies, please give this repository a star!**