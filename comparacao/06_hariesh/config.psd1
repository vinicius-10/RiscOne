@{
  Nome = 'HarieshAnbalagan - RV32I single_cycle_processor'
  Top = 'top_cmp'
  Fontes = @(
    'repo/src/single_cycle_processor/risc_v_32_i_pkg.sv'
    'repo/src/single_cycle_processor/ArithmeticLogicUnit.sv'
    'repo/src/single_cycle_processor/ComparatorUnit.sv'
    'repo/src/single_cycle_processor/CoreControlUnit.sv'
    'repo/src/single_cycle_processor/ImmediateSignExtend.sv'
    'repo/src/single_cycle_processor/LoadStoreUnit.sv'
    'patch/RegisterFile.sv'
    'patch/InstructionMemory.sv'
    'patch/DataMemory.sv'
    'patch/ProcessorCore.sv'
    'wrapper/top_cmp.sv'
  )
  Xdc = @('constr.xdc')
  Mem = @('mem/L_S_type.txt', 'mem/Data_Memory_Load.txt')
}
