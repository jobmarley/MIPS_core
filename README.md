# MIPS_core

This is an implementation of a Mips processor. The features are quite limited right now, but thats enough for execution of kernel + debugging.

## Reference design
The reference design is as follow, but can be changed as needed.  
The only constraints for [pcie_mips_driver](https://github.com/jobmarley/pcie_mips_driver) to work correctly is:
 - XDMA is used with channel 1 (C2H & H2C) available
 - MSI interrupt used
 - Debug interface of the processor accessible through BAR1 at offset 0 (which means it needs to be accessible through DMA Bypass, not lite)
 
![image](https://user-images.githubusercontent.com/99695100/178165298-0fa1e8f4-bcb4-4cb5-aad4-4a3625170760.png)
### Build
The vivado project for the reference design is available as a tcl file in _vivado/MIPS_core_vivado.tcl_.  
To use it open a vivado tcl console, then write
```
cd MIPS_core/vivado
source MIPS_core_vivado.tcl
```
This will automatically generate the project files.  
Note that this reference project is configured for a KC705 board, so modifications might be necessary to make it run on other hardware. But that's a good starting point.

## Features
- Mips32 instruction set
- 250Mhz (XC7K325T)
- Breakpoint with instruction SDBBP<sup>**[1](#SDBBP)**</sup> (pause the processor and triggers interrupt to notify the driver)
- SC and LL instruction<sup>**[2](#SC&#32;&&#32;LL)**</sup>

### SDBBP
The SDBBP instruction is normally part of the Mips EJTAG specification, but using jtag with xilinx is only available
through vivado commandline, which is problematic. Instead of making a new instruction I reused that one.
When the processor run into it, gonna trigger a MSI interrupt and put itself in pause. This allows to debug pretty much anything,
even interrupt service routines.

### SC & LL
Mips doesn't have interlocked instructions. Instead it uses SC and LL. LL loads a value from memory, and marks it's address for the next SC instruction. The next SC instruction store a value and will only succeed if:
- the address matches the previous LL address
- no other memory address was accessed by the processor between LL and SC
- no other processor/peripheral accessed that memory location between LL and SC

The implementation of SC and LL makes use of AXI4 exclusive access which provides equivalent functionalities. That means it can be used for synchronization with other peripherals by using memory.

## Not supported
A lot of things are not supported currently.  
Here is a non exhaustive list:
- Exception/Interrupt vectors
- Kernel transition/syscalls
- Floating point
- MMU
- Cache

## Debug registers
Those registers are accessible through the AXI lite interface on the processor
| Address      | Description |
|--------------|:------------|
| 00000000 |  Processor state (0x1: Enable, 0x2: Break pending) |
| 00000004 |  LEDS (only 1st byte)  |
| 00000008 - 0000007C |  unused  |
| 00000080 - 000000FC |  Processor registers, only accessible if enable is 0. PC is mapped on register 0 |
| 00000100 - 0000017C |  COP0 registers  |

## Tests
Just run the following commands from the MIPS_core/core/test/ directory
```
python instruction_test_generate.py
vivado -mode batch -source core_test.tcl
```
## Performance
| Test      | Version | Cycle count | Performance count | Instruction per second | Clock frequency |
|--------------|:-----|:------------|:------------|:------------|:------------|
| mips_project_test over 10s, no cache | [751259be...](https://github.com/jobmarley/MIPS_core/commit/751259be9c90a9bd18cb2f2d89b1a88257c52010) [64b995f9...](https://github.com/jobmarley/mips_project_test/commit/64b995f915fc816a2f5840006b71d912ebccc6f7) | 1 000 000 704 | 42 512 991 | 4 251 296 | 100Mhz |
