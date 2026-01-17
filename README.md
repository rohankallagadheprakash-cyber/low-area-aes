# Low-Area AES

## Getting started

This project implements a **low-area AES (Advanced Encryption Standard) design** on FPGA using VHDL.  
It is designed for **resource-constrained environments** (e.g., IoT devices) where minimizing area is more important than achieving the highest throughput.  

To make it easy for you to get started, you can either:  
- Open the **Vivado project file (`AES_Encryption_Project.xpr`)** directly, or  
- Manually add the **VHDL source files** to a new Vivado project.  

---

## Repository Contents

- `AES.vhd` – Top-level AES design  
- `AES_tb.vhd` – Testbench for AES verification  
- `AddRoundKey.vhd` – AddRoundKey transformation  
- `KeyExpansion.vhd` – AES key schedule  
- `MixColumns.vhd` – MixColumns transformation  
- `ShiftRows.vhd` – ShiftRows transformation  
- `SubBytes.vhd` – SubBytes S-box  
- `AES_Encryption_Project.xpr` – Vivado project file (ready to use)  
- `README.md` – Documentation and installation guide  

---

## Installation

### Requirements
- Xilinx **Vivado 2022.1** (tested version)  
- FPGA board: **Xilinx Artix-7 XC7A35T**  

### Option 1: Open the Vivado Project
1. Open **Xilinx Vivado**.  
2. Select **Open Project**.  
3. Navigate to this repository and open:  
4. Run **Synthesis → Implementation → Generate Bitstream**.  
5. To simulate, open `AES_tb.vhd` and run the testbench.  

### Option 2: Add Sources Manually
1. Create a **New RTL Project** in Vivado.  
2. Add all `.vhd` files from the repository.  
3. Set `AES.vhd` as the **Top Module**.  
4. Run **Simulation** using `AES_tb.vhd`.  
5. Run **Synthesis → Implementation → Generate Bitstream**.  
6. Connect your FPGA board and program it with the generated bitstream.  

---

## Usage

- **Simulation:**  
Run the testbench (`AES_tb.vhd`) in Vivado to verify AES encryption functionality.  

- **FPGA Deployment:**  
1. Connect the target FPGA board.  
2. Program the device with the generated bitstream.  
3. Verify output encryption results.  

---

## Roadmap

- Add AES-256 support.  
- Optimize further for performance-area trade-offs.  
- Explore lightweight side-channel countermeasures.  

---

## Authors and acknowledgment

- **Author:** Rohan Kallagadhe Prakash (4045611)  
- **Supervisor:** Dr. Chongyan Gu  

---

## License

This project is provided for **academic purposes only** under Queen’s University Belfast MSc Applied Cyber Security programme.  
Not licensed for commercial use.  

---

## Project status

✅ **Completed** — Core implementation finished; future improvements may be explored independently.

