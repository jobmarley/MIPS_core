# MIPS_core

This is an implementation of a Mips processor. The features are quite limited right now, but thats enough for execution of kernel + debugging.

## Reference design
The reference design is as follow, but can be changed as needed.  
The only constraints for [pcie_mips_driver](https://github.com/jobmarley/pcie_mips_driver) to work correctly is:
 - XDMA is used with channel 1 (C2H & H2C) available
 - MSI interrupt used
 - Debug interface of the processor accessible through BAR1 at offset 0 (which means it needs to be accessible through DMA Bypass, not lite)
 
![image](https://user-images.githubusercontent.com/99695100/178165298-0fa1e8f4-bcb4-4cb5-aad4-4a3625170760.png)

## Features
- Mips I instructions
- 50Mhz processor clock
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
