@{
  Nome = 'Casacuberta - RV32i-Verilog (core + progMem + dataMem)'
  Top = 'top_cmp'
  Fontes = @(
    'patch/core/core.v'
    'repo/src/mem/mem_data.v'
    'patch/mem_prog.v'
    'wrapper/top_cmp.v'
  )
  Xdc = @('constr.xdc')
  Mem = @('mem/prog_256.hex')
  Include = @()
  Define = @()
  Vhdl2008 = $false
  Generics = @()
}
