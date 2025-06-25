# MIPS-SingleCycle-Design-Verification

![MIPS Architecture](https://i.sstatic.net/5d5XB.png)
> Based on *Computer Organization and Design*, 5th Edition – Patterson & Hennessy - But this pic does not support all insturctions of MIPS....Will add Custom Made one that support all soon ISA.

---

## 📘 Overview

This project implements a **single-cycle MIPS processor** following the textbook model from *Computer Organization and Design, 5th Ed* by David A. Patterson and John L. Hennessy. It includes:

- Complete RTL hardware design
- A structured testbench
- Full coverage for **all 97 MIPS instructions tested randomly that cover all MIPS instructions**
- Simulation and verification using **QuestaSim**

The goal is to provide a robust reference design and verification environment for educational and professional use.

---

## 📂 Repository Structure

```bash
MIPS-SingleCycle-Design-Verification/
├── Design/               # RTL files (MIPS processor datapath and control)
│   └── *.v              # Main SystemVerilog modules
├── Verification/         # Testbench and instruction memory setup
│   └──*.v                # Main SystemVerilog modules
│   ├── MIPS_TB.sv        # Top-level testbench
│   ├── run.do            # Simulation script for QuestaSim
│   ├── instructions.mem  # Instruction memory in machine code
│   └── README.md         # Instruction decoding info
└── README.md             # You're here!
