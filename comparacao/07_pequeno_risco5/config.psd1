@{
  Nome = 'Avelar (JN513) - Pequeno-Risco-5'
  Top = 'top_cmp'
  Fontes = @(
    'repo/src/mux.v'
    'repo/src/pc.v'
    'repo/src/alu.v'
    'repo/src/alu_control.v'
    'repo/src/control_unit.v'
    'repo/src/immediate_generator.v'
    'patch/instruction_memory.v'
    'repo/src/data_memory.v'
    'repo/src/registers.v'
    'repo/src/core.v'
    'wrapper/top_cmp.sv'
  )
  Xdc = @('constr.xdc')
  Mem = @('mem/prog_word_256.hex')
}
