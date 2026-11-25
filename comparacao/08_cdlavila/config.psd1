@{
  Nome    = 'cdlavila - unicycle-processor-risc-v-rv32i'
  Top     = 'top_cmp'
  Fontes  = @(
    'repo/ProgramCounter.sv'
    'repo/Sum4.sv'
    'repo/InstructionMemory.sv'
    'repo/ControlUnit.sv'
    'repo/RegistersUnit.sv'
    'repo/ImmGen.sv'
    'repo/BranchUnit.sv'
    'repo/MuxALUASrc.sv'
    'repo/MuxALUBSrc.sv'
    'repo/ALU.sv'
    'repo/MuxNextPCSrc.sv'
    'repo/DataMemory.sv'
    'repo/MuxRUDataWrSrc.sv'
    'patch/design.sv'
    'wrapper/top_cmp.sv'
  )
  Xdc     = @('constr.xdc')
  Mem     = @('mem/Instructions.txt', 'mem/Memory.txt', 'repo/Registers.txt')
  Include = @()
  Define  = @()
  Vhdl2008 = $false
  Generics = @()
}
