@{
  Nome = 'Asghar - Single-Cycle RISC-V (top)'
  Top = 'top_cmp'
  Fontes = @(
    'src/Modules/alu_logic.sv'
    'src/Modules/branch_comp.sv'
    'src/Modules/control_unit.sv'
    'src/Modules/imm_gen.sv'
    'src/Modules/inst_mem.sv'
    'src/Modules/data_mem.sv'
    'src/Modules/reg_file.sv'
    'src/Modules/program_counter.sv'
    'src/Modules/top.sv'
    'wrapper/top_cmp.sv'
  )
  Xdc = @('constr.xdc')
  Mem = @('mem/instructions.mem', 'mem/data_mem.mem', 'src/Memory Files/reg_init.mem')
}
