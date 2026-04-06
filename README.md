# Multicycle ALU Design in Verilog

## 📌 Overview
This project implements a **4-bit multicycle ALU** using a **controller–datapath architecture**.  
Operations are executed across multiple clock cycles using an **FSM-based controller**.
This design demonstrates multicycle execution, hardware reuse, and control–datapath separation.

The design supports:
- Arithmetic operations
- Logical operations
- Shift operations
- Comparison operations
- Iterative unsigned multiplication using the **shift-add algorithm**

---

## 🏗️ Architecture

The design is divided into two main components:

- **Datapath**: Registers, ALU, shifter, and multiplexers  
- **Controller**: Finite State Machine (FSM) generating control signals  

---

## 🖼️ Design Diagrams

### Datapath
![Datapath](docs/datapath.png)

### FSM
![FSM](docs/fsm.png)

---

## 🔄 Datapath Evolution

The datapath was developed incrementally:

1. Initial design with input/output registers and adder  
2. Addition of logical operations  
3. Integration of shift unit  
4. Extension to support iterative multiplication  

![Evolution](docs/datapath_evolution.png)

---

## ⚙️ Supported Operations

### Arithmetic
- ADD  
- SUB  

### Logical
- AND  
- OR  
- XOR  
- NOT  

### Comparison
- Signed comparison  
- Unsigned comparison  

### Shift Operations
- SRL (Shift Right Logical)  
- SLL (Shift Left Logical)  
- SRA (Shift Right Arithmetic)  

### Multiplication
- Iterative unsigned multiplication using shift-add  

---

## 🔁 FSM Behavior

The controller operates through the following states:

- **S0**: Reset  
- **S1–S3**: Load operands and opcode  
- **S_hold**: Stabilization of loaded data  
- **S4_1**: Execution of selected operation  
- **S5**: Write-back and completion  

---
