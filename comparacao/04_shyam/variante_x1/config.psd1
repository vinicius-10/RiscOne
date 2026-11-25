@{
  Nome = 'Shyam (variante x1 sem ref. hierarquica)'
  Top = 'top_cmp'
  Fontes = @(
    '../repo/Design_Sources/pc_flop.v'
    '../repo/Design_Sources/pc_mux.v'
    '../repo/Design_Sources/pc_plus4.v'
    '../repo/Design_Sources/pc_target.v'
    '../repo/Design_Sources/instruction_memory.v'
    '../repo/Design_Sources/instruction_decoder.v'
    '../repo/Design_Sources/reg_file.v'
    '../repo/Design_Sources/extend.v'
    '../repo/Design_Sources/main_decoder.v'
    '../repo/Design_Sources/alu_decoder.v'
    '../repo/Design_Sources/controlunit.v'
    '../repo/Design_Sources/alu_mux.v'
    '../repo/Design_Sources/alu.v'
    '../repo/Design_Sources/data_memory.v'
    '../repo/Design_Sources/result_mux.v'
    'patch/processor.v'
    '../wrapper/top_cmp.sv'
  )
  Xdc = @('../constr.xdc')
  Mem = @('../mem/program.mem')
}
