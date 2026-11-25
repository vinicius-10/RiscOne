@{
  Nome = 'Bandara et al. - BRISC-V monociclo (Explorer, cfg do usuario)'
  Top = 'top_cmp'
  Fontes = @(
    'usuario_256/ALU.v'
    'usuario_256/regFile.v'
    'usuario_256/decode_unit.v'
    'usuario_256/control_unit.v'
    'usuario_256/hazard_detection_unit.v'
    'usuario_256/single_cycle_control_unit.v'
    'usuario_256/execution_unit.v'
    'usuario_256/fetch_issue.v'
    'usuario_256/fetch_receive.v'
    'usuario_256/memory_issue.v'
    'usuario_256/memory_receive.v'
    'usuario_256/writeback_unit.v'
    'usuario_256/single_cycle_core.v'
    'usuario_256/memory_interface.v'
    'patch/dual_port_BRAM.v'
    'patch/dual_port_BRAM_byte_en.v'
    'usuario_256/dual_port_BRAM_memory_subsystem.v'
    'wrapper/top_cmp.sv'
  )
  Xdc = @('constr.xdc')
  Mem = @('mem/prog_b0.hex', 'mem/prog_b1.hex', 'mem/prog_b2.hex', 'mem/prog_b3.hex')
}
