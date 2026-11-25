@{
  Nome = 'El-Helwani & Khalid - Semi-Edge RISC-V (RISCV_Single_Cycle)'
  Top = 'top_cmp'
  Fontes = @(
    'patch/RISCV_Single_Cycle_Core.v'
    'wrapper/top_cmp.sv'
  )
  Xdc = @('constr.xdc')
  Mem = @('mem/program.hex')
}
