@{
  Nome = 'Este trabalho - RiscOne (top_core)'
  Top = 'top_core'
  Fontes = @(
    '../../processador_riscV.srcs/sources_1/new/opcode_pkg.sv'
    '../../processador_riscV.srcs/sources_1/new/func3_pkg.sv'
    '../../processador_riscV.srcs/sources_1/new/func7_pkg.sv'
    '../../processador_riscV.srcs/sources_1/new/alu_pkg.sv'
    '../../processador_riscV.srcs/sources_1/new/branch_pkg.sv'
    '../../processador_riscV.srcs/sources_1/new/mem_pkg.sv'
    '../../processador_riscV.srcs/sources_1/new/alu.sv'
    '../../processador_riscV.srcs/sources_1/new/control_unit.sv'
    '../../processador_riscV.srcs/sources_1/new/imm_gen.sv'
    '../../processador_riscV.srcs/sources_1/new/register_file.sv'
    '../../processador_riscV.srcs/sources_1/new/decoder.sv'
    '../../processador_riscV.srcs/sources_1/new/execution.sv'
    '../../processador_riscV.srcs/sources_1/new/instruction_memory.sv'
    '../../processador_riscV.srcs/sources_1/new/search.sv'
    '../../processador_riscV.srcs/sources_1/new/data_memory.sv'
    '../../processador_riscV.srcs/sources_1/new/write_back.sv'
    '../../processador_riscV.srcs/sources_1/new/core.sv'
    '../../processador_riscV.srcs/sources_1/new/top_core.sv'
  )
  Xdc = @('../../processador_riscV.srcs/constrs_1/imports/constraints/Nexys-A7-100T-Master.xdc')
  Mem = @('../../processador_riscV.srcs/sources_1/imports/new/program_bytes.mem', '../../processador_riscV.srcs/sources_1/imports/new/data.mem')
}
