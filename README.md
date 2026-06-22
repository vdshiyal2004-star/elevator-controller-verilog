# 7-Floor Elevator Controller using Verilog HDL

## Overview
Designed a finite state machine (FSM) based elevator controller for a 7-floor building using Verilog HDL.

## Features
- Supports floors 0 to 7
- Up and Down movement control
- Door open/close control
- Floor request handling
- Emergency case handling
- FSM-based implementation with seven-segment display

## Tools Used
- Verilog HDL
- Xilinx Vivado
- Basys 3 FPGA 

## Files
- elevator.v : Main design
- elevator_tb.v : Testbench
- elevator.xdc
- screenshots/ : Simulation results

## RTL Schematic
<img width="1533" height="499" alt="image" src="https://github.com/user-attachments/assets/0b0a136a-7ef4-4266-9661-958f367b67d1" />


## Synthesized schematic
<img width="1775" height="472" alt="image" src="https://github.com/user-attachments/assets/aff021d7-5ef3-4cdc-b4a0-1a67cd64287a" />

## Simulation
<img width="1554" height="663" alt="image" src="https://github.com/user-attachments/assets/6c62a2e8-fc8a-430d-ab01-42f4604bfbe4" />

## Future Improvements
- Priority scheduling
- design with floor as veriable
- Multiple request queue
- FPGA implementation with seven-segment display shoving current floore and up/down motion 
