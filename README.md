# VGA Sine Wave + Toy Train Speed Measurement (VHDL)

This repository contains our group project for the VHDL 

## Project goals
- Display a sine wave on a VGA (Video Graphics Array) monitor
- Measure the speed of a toy train using sensor events (time measurement between events and conversion to speed, per project specification)
- Optional UART (Universal Asynchronous Receiver-Transmitter) output for debugging/telemetry

## Team and responsibilities
| Member | Main responsibility | Module / Block |
|---|---|---|
| Muhammad Irtiza Ahsan Siddiqui | Top-level integration / datapath wiring | `DataPathTop` |
| Joseph Kwabena Owusu | Display composition / image pipeline integration | `ImageTop` |
| Harsha Kanakaraj | Register block / configuration / state | `Register` |
| Noureldin Mohamed Abdalla Sheir | Sine wave generation | `Sine` |
| Ahmed Yusuf Azhar | Debug communication / serial output | `UART` |
| Sishir Gautam | VGA timing + pixel coordinate generation | `VGA` |

## Repository structure (root folders)
- `src/` – Synthesizable VHDL source code (entities/architectures, packages)
- `tb/` – Testbenches (simulation-only VHDL)
- `sim/` – Simulation scripts and outputs (Vivado/XSim scripts, wave configs, logs)
- `syn/` – Synthesis/implementation-related files (constraints, build scripts, exported products if needed)



## Build / run (Vivado)
1. Open Xilinx Vivado
2. Create/open the project
3. Add sources:
   - `src/` as Design Sources
   - `tb/` as Simulation Sources
4. Add constraints (if used) from `syn/` (or your chosen constraints location)
5. Run:
   - Run Simulation (XSim)
   - Run Synthesis / Implementation 

## Collaboration workflow
- Create a feature branch: 
- Commit small logical changes
- Push your branch to GitHub
- Open a Pull Request into `main`
- At least one teammate reviews before merge




