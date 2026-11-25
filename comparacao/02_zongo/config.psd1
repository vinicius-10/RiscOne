@{
  Nome = 'Zongo - rv32i-core'
  Top = 'top_cmp'
  Fontes = @(
    'repo/rtl/aLU.v'
    'repo/rtl/aluControl.v'
    'repo/rtl/branch_unit.v'
    'repo/rtl/control.v'
    'repo/rtl/imGen.v'
    'repo/rtl/regFile.v'
    'repo/rtl/pc.v'
    'patch/imem.v'
    'repo/rtl/dmem.v'
    'repo/rtl/core.v'
    'wrapper/top_cmp.sv'
  )
  Xdc = @('constr.xdc')
  Mem = @('mem/prog_256.hex')
  Include = @()
  Define = @()
  Vhdl2008 = $false
  Generics = @()
}
