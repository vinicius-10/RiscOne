@{
  Nome = 'Rudi-RV32I (hamsternz) - sem ponte registrada'
  Top = 'top_cmp'
  Fontes = @(
    'repo/src/cpu/alu.vhd'
    'repo/src/cpu/branch_test.vhd'
    'repo/src/cpu/data_bus_mux_a.vhd'
    'repo/src/cpu/data_bus_mux_b.vhd'
    'repo/src/cpu/decode.vhd'
    'repo/src/cpu/program_counter.vhd'
    'repo/src/cpu/register_file.vhd'
    'repo/src/cpu/result_bus_mux.vhd'
    'repo/src/cpu/shifter.vhd'
    'repo/src/cpu/sign_extender.vhd'
    'repo/src/cpu/riscv_cpu.vhd'
    'repo/src/bus/bus_bridge.vhd'
    'patch/program_memory_tcc.vhd'
    'patch/ram_memory_tcc.vhd'
    'wrapper/top_cmp.vhd'
  )
  Xdc = @('constr.xdc')
  Mem = @()
  Include = @()
  Define = @()
  Vhdl2008 = $false
  Generics = @()
}
