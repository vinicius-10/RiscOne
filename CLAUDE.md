# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Single-cycle RISC-V RV32I processor in SystemVerilog, built as a Vivado 2025.2 project (`processador_riscV.xpr`) for the Digilent Nexys A7-100T (`xc7a100tcsg324-1`). Synthesis top: `top_core`. Comments, headers and docs are in Portuguese (identifiers in English) — keep new comments in Portuguese and follow the existing header/Doxygen-style block (`@brief`, `@param`) used in every `.sv` file.

`README.md` (summary) and `DOCUMENTACAO_PROJETO.md` (spec + open questions) describe the design in detail. The RTL is the source of truth; those docs explicitly flag where comments and code disagree.

## Source layout that matters

- `processador_riscV.srcs/sources_1/new/` — all RTL and packages. Everything else under `processador_riscV.*/` (`.runs`, `.sim`, `.cache`, `.hw`, `.ip_user_files`) is Vivado-generated output; don't edit it.
- `processador_riscV.srcs/sim_1/` — testbenches. Most live in `sim_1/new/`, but `tb_control_unit.sv` and `tb_write_back.sv` live in `sim_1/imports/new/` (that is the path the `.xpr` `sim_1` fileset references).
- Memory images `program_bytes.mem` / `data.mem` (loaded via `$readmemh`) also exist in two places: `sources_1/imports/new/` and `sim_1/new/`. `$readmemh` resolves paths relative to the simulator's run directory, so copy the `.mem` files there when simulating outside the Vivado GUI.

## Simulation (xsim)

Vivado is installed at `D:\ProgramFiles\AMDVitis\2025.2\Vivado\bin` (not on PATH). Testbenches are self-checking: they print `[PASS]`/`[FAIL]` lines and a final summary with an error count, then `$finish`.

In the GUI, set the `sim_1` top module (currently `tb_register_file`) and Run Behavioral Simulation. To run one testbench from a shell, use **PowerShell** in a scratch directory (under Git Bash, `xsim -R` hangs and never prints output). Compile packages before the modules that import them:

```powershell
$V = "D:\ProgramFiles\AMDVitis\2025.2\Vivado\bin"
$S = "D:\valuc\vivado\projects\processador_riscV\processador_riscV.srcs"
& "$V\xvlog.bat" --sv --relax "$S\sources_1\new\register_file.sv" "$S\sim_1\new\tb_register_file.sv"
& "$V\xelab.bat" --relax tb_register_file -s rf_sim
& "$V\xsim.bat" rf_sim -R
```

For DUTs that use packages, list `"$S\sources_1\new\*_pkg.sv"` first, then the DUT files and testbench (see each testbench header's `Dependencies:` line). `tb_alu.sv` uses `alu_op_t` before its `import alu_pkg::*;` (line 62), so it fails to elaborate standalone (it likely only builds in the project because other testbenches import packages at compilation-unit scope). The Vivado-generated scripts in `processador_riscV.sim/sim_1/behav/xsim/` (`compile.bat`, `elaborate.bat`, `simulate.bat`, `*_vlog.prj`) show the exact flags the GUI uses for the last-run testbench.

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

- `search.sv` defaults `MEM_FILE` to `program_bytes.hex`, while `core`/`instruction_memory` use `.mem` (core overrides it, so synthesis uses `.mem`).
- `SLTU` derives from the subtraction carry — verify against the intended semantics.
- `execution` clears only bit 0 of jump/branch targets.
- Byte/halfword loads/stores are handled for RAM only, not for MMIO.
