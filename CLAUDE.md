# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Single-cycle RISC-V RV32I processor in SystemVerilog, built as a Vivado 2025.2 project (`processador_riscV.xpr`) for the Digilent Nexys A7-100T (`xc7a100tcsg324-1`). Synthesis top: `top_core`. Comments, headers and docs are in Portuguese (identifiers in English) — keep new comments in Portuguese and follow the existing header/Doxygen-style block (`@brief`, `@param`) used in every `.sv` file.

`README.md` (summary) and `DOCUMENTACAO_PROJETO.md` (spec + open questions) describe the design in detail. The RTL is the source of truth; those docs explicitly flag where comments and code disagree.

## Do not edit `processador_riscV.xpr`

Never modify the Vivado project file (`processador_riscV.xpr`) — not to add/remove sources, change the `sim_1` top, fix paths or anything else. The user manages it through the Vivado GUI. If a change needs the `.xpr` updated (new source file, new testbench, moved file), tell the user what to add/change in Vivado instead of doing it.

## Source layout that matters

- `processador_riscV.srcs/sources_1/new/` — all RTL and packages. Everything else under `processador_riscV.*/` (`.runs`, `.sim`, `.cache`, `.hw`, `.ip_user_files`) is Vivado-generated output; don't edit it.
- `processador_riscV.srcs/sim_1/` — testbenches. Most live in `sim_1/new/`, but `tb_control_unit.sv` and `tb_write_back.sv` live in `sim_1/imports/new/` (that is the path the `.xpr` `sim_1` fileset references).
- Memory images `program_bytes.mem` / `data.mem` (loaded via `$readmemh`) live only in `sources_1/imports/new/` (the copy the `.xpr` uses for synthesis and simulation). `data.mem` is written one byte per hex token (`00 00 00 0A`). `$readmemh` resolves paths relative to the simulator's run directory, so copy the `.mem` files there when simulating outside the Vivado GUI.

## Simulation (xsim)

Vivado is installed at `D:\ProgramFiles\AMDVitis\2025.2\Vivado\bin` (not on PATH). Testbenches are self-checking: they print `[PASS]`/`[FAIL]` lines and a final summary with an error count, then `$finish`.

Run testbenches with the script (from PowerShell; under Git Bash `xsim -R` hangs and never prints output):

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\run_tb.ps1            # all testbenches
powershell -ExecutionPolicy Bypass -File .\scripts\run_tb.ps1 tb_alu     # one (or several)
powershell -ExecutionPolicy Bypass -File .\scripts\run_tb.ps1 -List      # names; -ShowLog prints full sim output
```

It compiles all packages + the DUT files for each testbench, copies the `.mem` images into `build/sim/<tb>/` (git-ignored; logs `compile.txt`, `elaborate.txt`, `simulate.txt` stay there), and reports PASS/FAIL by parsing the testbench summary line. Exit code is 0 only if all pass. **When adding a testbench or changing a module's submodules, update the `$Tests` table in `scripts/run_tb.ps1`.** Override the Vivado path with `-VivadoBin` or `$env:VIVADO_BIN`.

In the GUI, set the `sim_1` top module (currently `tb_register_file`) and Run Behavioral Simulation. Manual equivalent of what the script does (packages must be compiled before modules that import them):

```powershell
$V = "D:\ProgramFiles\AMDVitis\2025.2\Vivado\bin"
$S = "D:\valuc\vivado\projects\processador_riscV\processador_riscV.srcs"
& "$V\xvlog.bat" --sv --relax "$S\sources_1\new\register_file.sv" "$S\sim_1\new\tb_register_file.sv"
& "$V\xelab.bat" --relax tb_register_file -s rf_sim
& "$V\xsim.bat" rf_sim -R
```

`tb_instruction_fetch.sv` defines its own `instruction_memory` model, so don't compile the real `instruction_memory.sv` with it. The Vivado-generated scripts in `processador_riscV.sim/sim_1/behav/xsim/` (`compile.bat`, `elaborate.bat`, `simulate.bat`, `*_vlog.prj`) show the exact flags the GUI uses for the last-run testbench.

Synthesis/implementation/bitstream are done through Vivado (GUI or `vivado -mode batch` with a Tcl script opening `processador_riscV.xpr`); there is no checked-in build script.

## Architecture

```text
top_core          board pins -> core (inverts active-low CPU_RESETN)
└── core          wires the single-cycle datapath; params XLEN, MEM_DEPTH, *_MEM_FILE
    ├── search ── instruction_memory   PC register, PC+4 vs branch target mux
    ├── decoder   register_file + imm_gen + control_unit
    ├── execution ── alu               operand muxes, branch decision + target
    ├── data_memory                    byte-addressable RAM + MMIO peripherals
    └── write_back                     ALU result vs memory data
```

- Only the PC, register-file writes, RAM writes and MMIO output registers are clocked (`posedge clk`); everything else is combinational. Reset is synchronous active-high and clears **only the PC** — registers and RAM are not reset.
- Control encodings are enums in the packages (`opcode_pkg`, `func3_pkg`, `func7_pkg`, `alu_pkg` → `alu_op_t`, `branch_pkg` → `branch_op_t`, `mem_pkg` → `mem_width_t`/`mem_signed_t`). `control_unit` maps opcode/funct3/funct7 to these; unsupported opcodes get safe defaults (no reg/mem write, PC keeps advancing) with no trap.
- MMIO lives inside `data_memory`: selected when `addr[31:28] == 4'h4`, register chosen by `addr[5:2]` — LEDs `0x4000_0000`, switches `0x4000_0004`, buttons `0x4000_0008`, 7-seg display `0x4000_000C`, PMOD rows/cols `0x4000_0010`. RAM occupies `0 .. MEM_DEPTH*4-1`.
- **Branch convention:** `alu.zero_o` is `alu_o[0]`, not a NOR of the result. Branches use `OP_CMP` (equality) for BEQ/BNE and SLT/SLTU for relational branches, so the branch decision relies on the LSB of a 0/1 comparison result. Preserve this if you change ALU op encodings.

Naming: ports use `_i`/`_o` suffixes; signals are prefixed with the owning block (e.g. `execution_alu_control_o`).

## Known inconsistencies (see `DOCUMENTACAO_PROJETO.md` §8)

- `execution` clears only bit 0 of jump/branch targets (as the ISA requires for JALR); misaligned targets don't trap.
- Misaligned halfword/word data accesses aren't supported and don't trap.
- `ECALL`/`EBREAK`/`FENCE` are NOPs; there are no CSRs or traps. Decoding is strict: invalid funct3/funct7 encodings become NOPs.
- `SLTU` = `~carry` of `a + ~b + 1` (correct; covered by `tb_alu`/`tb_core`). MMIO byte/halfword accesses use the same byte lanes and sign extension as RAM.

`tb_core` (system test) assembles its own program with `enc_*` functions and writes it into `dut.search_inst.instr_mem.mem` by hierarchy; add new instruction checks there.
