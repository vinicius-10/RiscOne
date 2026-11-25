@{
  Nome = 'Poli et al. - minimal-risc-v-cpu (RV64I 7 instr.)'
  Top = 'top_cmp'
  Fontes = @(
    'repo/source/components/common_pkg.sv'
    'repo/source/components/ALU/ALU.sv'
    'repo/source/components/ALU/ALU_control.sv'
    'repo/source/components/control_unit/control_unit.sv'
    'repo/source/components/imm_generator/imm_generator.sv'
    'repo/source/components/program_counter/program_counter.sv'
    'repo/source/components/register_file/register_file.sv'
    'repo/source/components/instruction_memory/instruction_memory.sv'
    'repo/source/components/data_memory/data_memory.sv'
    'patch/top.sv'
    'wrapper/top_cmp.sv'
  )
  Xdc = @('constr.xdc')
  Mem = @('repo/source/components/instruction_memory/instruction_memory.mem', 'repo/source/components/data_memory/data_memory.mem')
}
