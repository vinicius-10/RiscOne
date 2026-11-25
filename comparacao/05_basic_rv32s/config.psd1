@{
  Nome = 'Kang & Choi - basic_rv32s RV32I37F (monociclo)'
  Top = 'top_cmp'
  # RV32I37F_flat.v = RV32I37F.v (patch) com os `include "modules/..." expandidos por scripts/achatar.py
  # (o medir.ps1 passa -include_dirs ao read_verilog, que nao aceita a opcao)
  Fontes = @(
    'patch/RV32I37F_flat.v'
    'wrapper/top_cmp.sv'
  )
  Xdc = @('constr.xdc')
  Mem = @('mem/prog_word.hex', 'mem/data_word.hex')
}
