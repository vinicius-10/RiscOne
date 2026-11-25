@{
  Nome = 'Bandara et al. - BRISC-V single_cycle_base'
  Top = 'top_cmp'
  Fontes = @(
    'repo/BRISC-V_Processors/BRISC-V_single_cycle_base/src/ALU.v'
    'patch/zip_base_bsram.v'
    'repo/BRISC-V_Processors/BRISC-V_single_cycle_base/src/mem_interface.v'
    'repo/BRISC-V_Processors/BRISC-V_single_cycle_base/src/fetch.v'
    'repo/BRISC-V_Processors/BRISC-V_single_cycle_base/src/regFile.v'
    'repo/BRISC-V_Processors/BRISC-V_single_cycle_base/src/decode.v'
    'repo/BRISC-V_Processors/BRISC-V_single_cycle_base/src/control_unit.v'
    'repo/BRISC-V_Processors/BRISC-V_single_cycle_base/src/execute.v'
    'repo/BRISC-V_Processors/BRISC-V_single_cycle_base/src/memory.v'
    'repo/BRISC-V_Processors/BRISC-V_single_cycle_base/src/writeback.v'
    'repo/BRISC-V_Processors/BRISC-V_single_cycle_base/src/RISC_V_Core.v'
    'wrapper/top_cmp_zip_base.sv'
  )
  Xdc = @('constr.xdc')
  Mem = @('mem/zip_base_prog_word.hex')
}
