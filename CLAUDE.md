# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Single-cycle RISC-V RV32I processor in SystemVerilog, built as a Vivado 2025.2 project (`processador_riscV.xpr`) for the Digilent Nexys A7-100T (`xc7a100tcsg324-1`). Synthesis top: `top_core`. Comments, headers and docs are in Portuguese (identifiers in English) — keep new comments in Portuguese and follow the existing header/Doxygen-style block (`@brief`, `@param`) used in every `.sv` file.

`README.md` (summary) and `docs/DOCUMENTACAO_PROJETO.md` (requirements, decisions, validation, open questions) describe the design. `docs/ESPEC_RV32I.md` is the RV32I spec aligned to the RTL (encodings, immediates, control signals, module interfaces, `core` wiring, MMIO) — keep it in sync when changing the RTL. `docs/intruçoes.xlsx` is the user's own working sheet (instruction fields, opcode map, funct3/funct7); everything relevant is already in ESPEC, so use ESPEC instead of parsing the xlsx. If asked to edit it: never save it with openpyxl (it drops the sheet's x14 data-validation dropdowns); edit `xl/worksheets/sheet1.xml` inside the zip directly, and only when Excel has it closed (a `~$` lock file means it is open). The RTL is the source of truth; those docs explicitly flag where comments and code disagree.

## Change discipline

- **Simplicity:** write the minimum that solves the request. No speculative logic, ports, parameters or "configurability" in the RTL (extra logic costs area and critical path), and no abstractions for single-use code.
- **Surgical changes:** touch only what the request needs and match the existing style. For things noticed along the way:
  - **Fix directly** (and mention it in the reply): cosmetic slips — typos and lost accents in comments/strings, misspelled or misleading identifier names (rename every use and rerun the affected testbenches).
  - **Report, don't fix:** anything that changes behavior — logic errors, wrong encodings, timing or reset issues, comments that disagree with the logic in a way that hides a real question, dead code. Explain the problem and suggest the fix; change it only if the user says so.

## Complex tasks: plan first

For complex work (new module, interface/port changes, new instructions/extensions, timing or memory-map changes, or anything touching 3+ RTL files) load the project skill `planejar-tarefa` before editing: resolve open questions with the user, write the plan to `docs/planos/`, get explicit approval, then execute testbench-first. Small, clear requests stay direct — no planning ceremony.

## Commits

Commit only when the user asks. When they do, load the project skill `fazer-commit`: Conventional Commits with the summary in Portuguese, one commit per logical change, `run_tb.ps1` must pass before committing RTL/testbench changes, and never stage the `.xpr`, Vivado outputs or installed `.mem` files without asking.

## Do not edit `processador_riscV.xpr`

Never modify the Vivado project file (`processador_riscV.xpr`) — not to add/remove sources, change the `sim_1` top, fix paths or anything else. The user manages it through the Vivado GUI. If a change needs the `.xpr` updated (new source file, new testbench, moved file), tell the user what to add/change in Vivado instead of doing it.

## Source layout that matters

- `processador_riscV.srcs/sources_1/new/` — all RTL and packages. Everything else under `processador_riscV.*/` (`.runs`, `.sim`, `.cache`, `.hw`, `.ip_user_files`) is Vivado-generated output; don't edit it.
- `processador_riscV.srcs/sim_1/new/` — all testbenches. When the user adds files in Vivado, remind them to uncheck "Copy sources into project" (otherwise Vivado makes stale copies under `*/imports/new/`) and to add testbenches as *simulation* sources.
- Memory images `program_bytes.mem` / `data.mem` (loaded via `$readmemh`) live only in `sources_1/imports/new/` (the copy the `.xpr` uses for synthesis and simulation). `data.mem` is one byte per hex token in address order (byte at address 0 first), so the word 10 is `0A 00 00 00`. `$readmemh` resolves paths relative to the simulator's run directory, so copy the `.mem` files there when simulating outside the Vivado GUI.

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

`tb_instruction_fetch.sv` defines its own `instruction_memory` model (synchronous like the real one, word = `~addr`, so the tb checks `instr_o == ~pc_o`), so don't compile the real `instruction_memory.sv` with it. The Vivado-generated scripts in `processador_riscV.sim/sim_1/behav/xsim/` (`compile.bat`, `elaborate.bat`, `simulate.bat`, `*_vlog.prj`) show the exact flags the GUI uses for the last-run testbench.

Synthesis/implementation for **measurement** (timing/area) use `scripts/synth.ps1` (non-project batch flow reading `sources_1/new` + the XDC; never touches the `.xpr`; output `build/synth/<tag>/resumo.txt`, history in `build/synth/historico.csv`; full run takes minutes, so run it in the background). **For timing closure, Fmax or area work, load the project skill `otimizar-timing`** and log results in `docs/TIMING.md`. The bitstream for the board is still generated by the user in the Vivado GUI.

## Software (riscv-gcc)

Toolchain: xPack `riscv-none-elf-gcc` 15.2.0 at `D:\ProgramFiles\xpack-riscv-none-elf-gcc-15.2.0-1\bin` (not on PATH; override with `-GccBin` or `$env:RISCV_GCC_BIN`). Programs live in `sw/apps/<name>/` (`selftest` = C self-check for simulation, `autoteste_placa` = selftest copy that uses all 37 RV32I instructions — installed as the board program since 2026-11-03, so `synth.ps1 -App placa` measures the full core, `asm_exemplo` = pure-assembly template, `leds` = board demo); shared startup/linker/MMIO in `sw/common/`. **When writing or reviewing programs for the core, load the project skill `rv32i-programas`** (`.claude/skills/rv32i-programas/SKILL.md`): what executes vs. silently NOPs, memory map, Harvard/.rodata rule, build/test flow. Run any app on the core with `run_tb.ps1 tb_program -App <name>` (default `selftest`).

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\build_sw.ps1 selftest           # -> build/sw/selftest/{program_bytes,data}.mem, .elf, .lst, .map
powershell -ExecutionPolicy Bypass -File .\scripts\build_sw.ps1 leds -Install      # also copies the .mem files to sources_1/imports/new (backs up the old ones)
```

- Harvard: IMEM and DMEM both start at 0. `.rodata` (constants, switch tables, function-pointer tables) must live in DMEM because loads can't read IMEM — `link.ld` does this and links with `--no-check-sections`. 4 KiB each (MEM_DEPTH = 1024); stack at the top of DMEM.
- Flags: `-march=rv32i -mabi=ilp32 -msmall-data-limit=0 -ffreestanding -nostdlib` + `-lgcc` (mul/div come from libgcc). `sw/common/libc_min.c` supplies memcpy/memset/memmove/memcmp.
- `crt0.S` sets sp, zeroes `.bss`, calls `main`, leaves its return in `a0` and spins in `_halt` (`j .` = `0x0000006F`). `.data` is only loaded with the FPGA bitstream — a CPU reset does not restore it.
- `data.mem` = bytes in address order (byte at address 0 first), assembled by `data_memory`'s `initial` into the little-endian word `mem[w] = {byte 4w+3, …, byte 4w}` (`mem` is a 1-D array of 32-bit words so Vivado infers LUTRAM).
- `tb_program` (in `run_tb.ps1`) rebuilds `selftest`, runs it on `core` until `_halt`, and passes if `main` returned 0 (else `a0` = failing test group, LEDs = `0xE000|group`). Add C checks to `sw/apps/selftest/main.c`; keep inputs `volatile` or GCC folds them at compile time.

## Architecture

```text
top_core          board pins -> core; inverts active-low CPU_RESETN into core.reset_i (active high)
└── core          wires the datapath; params XLEN, MEM_DEPTH, *_MEM_FILE
    ├── search ── instruction_memory   PC register + next-PC mux (reset / PC+4 / branch target); the next PC also
    │                                  addresses instruction_memory, a synchronous-read ROM in LUTs that registers
    │                                  the instruction on the same edge as the PC (still single-cycle, no stages)
    ├── decoder   register_file + imm_gen + control_unit
    ├── execution ── alu               operand muxes, branch decision + target, dedicated rs1+imm adder -> data_memory address,
    │                                  region flags (MMIO / first 4 KiB) computed without waiting for the adder carry
    ├── data_memory                    byte-addressable RAM + MMIO peripherals
    └── write_back                     ALU result vs memory data
```

- Only the PC, the registered instruction (inside `instruction_memory`), register-file writes, RAM writes and MMIO output registers are clocked (`posedge clk`); everything else is combinational. Reset is synchronous active-high and forces the next PC to 0, so the PC and the registered instruction restart at address 0 — registers and RAM are not reset. On FPGA configuration the PC starts at 0 and the registered instruction at word 0 (`initial` from the `.mem`), so the board runs without pressing reset.
- Control encodings are enums in the packages (`opcode_pkg`, `func3_pkg`, `func7_pkg`, `alu_pkg` → `alu_op_t`, `branch_pkg` → `branch_op_t`, `mem_pkg` → `mem_width_t`/`mem_signed_t`). `control_unit` maps opcode/funct3/funct7 to these; unsupported opcodes get safe defaults (no reg/mem write, PC keeps advancing) with no trap.
- MMIO lives inside `data_memory`: selected when `addr[31:28] == 4'h4`, register chosen by `addr[5:2]`. `core`/`data_memory` expose 4 generic 32-bit outputs `io_out0_o..io_out3_o` (write-only, reads return 0 so synthesis can trim unused bits) at `0x4000_0000 + 4k` and 4 generic 32-bit inputs `io_in0_i..io_in3_i` (R) at `0x4000_0010 + 4k`; `top_core` maps them to the board (out0 LEDs, out1 7-seg, out2 PMOD cols, in0 switches, in1 buttons, in2 PMOD rows; in3/out3 free). RAM occupies `0 .. MEM_DEPTH*4-1`.
- **Branch convention:** `alu.alu_lsb_o` is `alu_o[0]` (bit 0 of the result, not a zero flag). Branches use `OP_CMP` (equality) for BEQ/BNE and SLT/SLTU for relational branches, so the branch decision relies on the LSB of a 0/1 comparison result. Preserve this if you change ALU op encodings.

Naming: ports use `_i`/`_o` suffixes; signals are prefixed with the owning block (e.g. `execution_alu_control_o`).

## Out of scope by decision (see `docs/DOCUMENTACAO_PROJETO.md` §8)

The user decided (2026-10-31) **not to implement traps or misaligned-access handling for now** (maybe later). Treat the items below as intended behavior, not bugs — don't "fix" them or propose them unprompted:

- `execution` clears only bit 0 of jump/branch targets (as the ISA requires for JALR); misaligned targets don't trap.
- Misaligned halfword/word data accesses aren't supported and don't trap.
- `ECALL`/`EBREAK`/`FENCE` are NOPs; there are no CSRs or traps. Decoding is strict: invalid funct3/funct7 encodings become NOPs.
- `SLTU` = `~carry` of `a + ~b + 1` (correct; covered by `tb_alu`/`tb_core`). MMIO byte/halfword accesses use the same byte lanes and sign extension as RAM.

`tb_core` (system test) assembles its own program with `enc_*` functions and writes it into `dut.search_inst.instr_mem.mem` by hierarchy; add new instruction checks there.
