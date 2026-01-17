# Layered-testbench-for-synchronous-fifo
# Layered Testbench for Synchronous FIFO

This repository contains the **layered testbench verification environment** for a **Synchronous FIFO (First-In-First-Out) hardware design** written in SystemVerilog.

A **synchronous FIFO** is a hardware buffer where **data is written and read in the same clock domain** and **data order is preserved** (first in, first out). It is widely used to manage data flow between modules operating at the same clock frequency. :contentReference[oaicite:0]{index=0}

#Project Overview

- **Design Under Test (DUT):** A synchronous FIFO RTL module  
- **Verification:** Layered testbench architecture to validate functionality  
- **Language:** SystemVerilog  
- **Focus:** Modular verification, clear separation between stimulus, checks, and scoreboard

#Repository Structure

- **rtl/** – RTL design files of the synchronous FIFO  
- **tb/** – Layered verification testbench sources  
- **result/** – Simulation outputs (log, waveform dumps)

#What is a Synchronous FIFO?

A *Synchronous FIFO* is a type of hardware buffer where both *write* and *read* operations occur under the **same clock signal**. It maintains **data order** while managing control flags like **full** and **empty**. :contentReference[oaicite:1]{index=1}

#Typical FIFO Signals
| Signal | Direction | Description |
|--------|-----------|-------------|
| `clk` | Input | Shared system clock |
| `rst` | Input | Reset signal |
| `wr_en` | Input | Enable write |
| `rd_en` | Input | Enable read |
| `data_in` | Input | FIFO write data |
| `data_out` | Output | FIFO read data |
| `full` | Output | Indicates FIFO is full |
| `empty` | Output | Indicates FIFO is empty |


#Layered Testbench Architecture

The layered testbench separates verification into logical layers:

1. **Driver** – Generates transactions to DUT  
2. **Monitor** – Observes DUT signals  
3. **Scoreboard** – Compares expected vs. actual results  
4. **Test sequences** – Defines specific test scenarios  
5. **Environment** – Top-level integration of testbench layers

This modular approach improves clarity, reusability, and scalability of the testbench.
