`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UTFPR-CP
// Engineer: Vinicius Souza Dias
//
// Create Date: 30.10.2026 10:00:00
// Design Name: Processador RV32I
// Module Name: tb_core
// Project Name: processador_riscV
// Target Devices: Artix-7 Nexys A7-100T
// Tool Versions: Vivado 2025.2
// Description: Testbench de sistema do core monociclo. Executa um programa que
//              cobre as 37 instrucoes RV32I do escopo (R, I, loads, stores,
//              branches, LUI/AUIPC, JAL/JALR), acessos MMIO e instrucoes
//              invalidas/nao suportadas, verificando cada instrucao executada.
//
// Dependencies: core e todos os seus submodulos e pacotes
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//   O programa e montado pelo proprio testbench (funcoes enc_*) e escrito por
//   hierarquia na instruction_memory, sobrescrevendo o program_bytes.mem.
//////////////////////////////////////////////////////////////////////////////////

/**
 * @file tb_core.sv
 * @brief Verificacao instrucao a instrucao do processador completo.
 *
 * Cada entrada da tabela `prog` corresponde a uma palavra da memoria de
 * instrucoes (indice = PC/4) e descreve o efeito esperado da instrucao:
 * valor do registrador destino, palavra da RAM, saida MMIO e o proximo PC.
 * A cada ciclo o testbench le o PC, executa uma borda de clock e compara o
 * estado do core com a entrada correspondente. Entradas do tipo K_TRAP ficam
 * logo apos desvios tomados e geram falha se forem executadas. Ao final,
 * confere que todas as entradas (exceto traps) foram executadas.
 */
module tb_core;

    // ------------------------------------------------------------------
    // Opcodes (definidos aqui, independentes do opcode_pkg do DUT)
    // ------------------------------------------------------------------
    localparam logic [6:0] OP    = 7'b0110011;
    localparam logic [6:0] OPI   = 7'b0010011;
    localparam logic [6:0] LD    = 7'b0000011;
    localparam logic [6:0] ST    = 7'b0100011;
    localparam logic [6:0] BR    = 7'b1100011;
    localparam logic [6:0] LUI   = 7'b0110111;
    localparam logic [6:0] AUIPC = 7'b0010111;
    localparam logic [6:0] JAL   = 7'b1101111;
    localparam logic [6:0] JALR  = 7'b1100111;

    localparam logic [31:0] NOP    = 32'h0000_0013; // addi x0, x0, 0
    localparam logic [31:0] ECALL  = 32'h0000_0073;
    localparam logic [31:0] FENCE  = 32'h0000_000F;
    localparam logic [31:0] IO     = 32'h4000_0000;
    localparam logic [31:0] IN0    = 32'h0000_A5F0; // entrada 0 (chaves na placa)
    localparam logic [31:0] IN3    = 32'h8000_00F0; // entrada 3: bit 31 = 1 para testar sinal

    // ------------------------------------------------------------------
    // DUT
    // ------------------------------------------------------------------
    logic        clk = 1'b0;
    logic        reset = 1'b1;
    logic [31:0] io_out0, io_out1, io_out2, io_out3;

    core #(
        .XLEN(32),
        .MEM_DEPTH(1024)
    ) dut (
        .clk        (clk),
        .reset_i    (reset),
        .io_in0_i   (IN0),
        .io_in1_i   (32'h0),
        .io_in2_i   (32'h0),
        .io_in3_i   (IN3),
        .io_out0_o  (io_out0),
        .io_out1_o  (io_out1),
        .io_out2_o  (io_out2),
        .io_out3_o  (io_out3)
    );

    always #5 clk = ~clk;

    // ------------------------------------------------------------------
    // Codificadores de instrucao (formatos R, I, S, B, U, J da ISA)
    // ------------------------------------------------------------------
    function automatic logic [31:0] enc_r(logic [6:0] f7, logic [4:0] rs2, logic [4:0] rs1,
                                          logic [2:0] f3, logic [4:0] rd);
        return {f7, rs2, rs1, f3, rd, OP};
    endfunction

    function automatic logic [31:0] enc_i(logic [6:0] op, int imm, logic [4:0] rs1,
                                          logic [2:0] f3, logic [4:0] rd);
        logic [11:0] i;
        i = imm[11:0];
        return {i, rs1, f3, rd, op};
    endfunction

    function automatic logic [31:0] enc_sh(logic [6:0] f7, int shamt, logic [4:0] rs1,
                                           logic [2:0] f3, logic [4:0] rd);
        logic [4:0] s;
        s = shamt[4:0];
        return {f7, s, rs1, f3, rd, OPI};
    endfunction

    function automatic logic [31:0] enc_s(int imm, logic [4:0] rs2, logic [4:0] rs1, logic [2:0] f3);
        logic [11:0] i;
        i = imm[11:0];
        return {i[11:5], rs2, rs1, f3, i[4:0], ST};
    endfunction

    function automatic logic [31:0] enc_b(int off, logic [4:0] rs2, logic [4:0] rs1, logic [2:0] f3);
        logic [12:0] i;
        i = off[12:0];
        return {i[12], i[10:5], rs2, rs1, f3, i[4:1], i[11], BR};
    endfunction

    function automatic logic [31:0] enc_u(logic [6:0] op, logic [19:0] imm20, logic [4:0] rd);
        return {imm20, rd, op};
    endfunction

    function automatic logic [31:0] enc_j(int off, logic [4:0] rd);
        logic [20:0] i;
        i = off[20:0];
        return {i[20], i[10:1], i[11], i[19:12], rd, JAL};
    endfunction

    // ------------------------------------------------------------------
    // Tabela do programa e efeitos esperados
    // ------------------------------------------------------------------
    typedef enum {K_REG, K_MEM, K_OUT0, K_OUT1, K_OUT2, K_OUT3, K_NONE, K_TRAP, K_HALT} kind_e;

    typedef struct {
        string       name;
        logic [31:0] instr;
        kind_e       kind;
        logic [4:0]  rd;      // K_REG: registrador verificado
        logic [31:0] val;     // valor esperado (registrador, RAM ou MMIO)
        logic [31:0] addr;    // K_MEM: endereco da palavra verificada
        bit          chk_npc; // verifica o proximo PC
        logic [31:0] npc;     // proximo PC esperado
    } step_t;

    step_t prog[$];
    int    error_count = 0;

    function automatic logic [31:0] here();
        return prog.size() * 4;
    endfunction

    // Adiciona uma instrucao; npc_off e relativo ao PC desta instrucao.
    function automatic void add(string name, logic [31:0] instr, kind_e kind,
                                logic [4:0] rd = 0, logic [31:0] val = 0,
                                logic [31:0] addr = 0, bit chk_npc = 1, int npc_off = 4);
        step_t s;
        s.name    = name;
        s.instr   = instr;
        s.kind    = kind;
        s.rd      = rd;
        s.val     = val;
        s.addr    = addr;
        s.chk_npc = chk_npc;
        s.npc     = here() + npc_off;
        prog.push_back(s);
    endfunction

    // Instrucao que escreve rd.
    function automatic void reg_op(string name, logic [31:0] instr, logic [4:0] rd, logic [31:0] val);
        add(name, instr, K_REG, rd, val);
    endfunction

    // Branch: tomado salta +8 (sobre um trap), nao tomado segue para PC+4.
    function automatic void branch(string name, logic [31:0] instr, bit taken);
        add(name, instr, K_NONE, 0, 0, 0, 1, taken ? 8 : 4);
        if (taken) add("trap apos branch tomado", NOP, K_TRAP, 0, 0, 0, 0);
    endfunction

    function automatic void trap(string name);
        add(name, NOP, K_TRAP, 0, 0, 0, 0);
    endfunction

    // ------------------------------------------------------------------
    // Acesso hierarquico ao estado do DUT
    // ------------------------------------------------------------------
    function automatic logic [31:0] reg_val(logic [4:0] r);
        if (r == 0) return '0;
        return dut.decoder_inst.register_file_inst.register_file[r];
    endfunction

    function automatic logic [31:0] ram_word(logic [31:0] a);
        int w;
        w = a >> 2;
        return dut.data_memory_inst.mem[w];
    endfunction

    task automatic fail(string msg);
        error_count++;
        $display("[FAIL] %s", msg);
    endtask

    // ------------------------------------------------------------------
    // Montagem do programa
    // ------------------------------------------------------------------
    logic [31:0] x1_jal;   // valor de x1 apos o JAL (usado nos testes MMIO)

    task automatic build_program();
        int a;

        // ---------------- Tipo I: valores base ----------------
        reg_op("addi x1, x0, 5",    enc_i(OPI, 5,  0, 3'b000, 1), 1, 32'd5);
        reg_op("addi x2, x0, -3",   enc_i(OPI, -3, 0, 3'b000, 2), 2, 32'hFFFF_FFFD);

        // ---------------- Tipo R ----------------
        reg_op("add  x3, x1, x2",   enc_r(7'h00, 2, 1, 3'b000, 3),  3,  32'd2);
        reg_op("sub  x4, x1, x2",   enc_r(7'h20, 2, 1, 3'b000, 4),  4,  32'd8);
        reg_op("sub  x5, x2, x1",   enc_r(7'h20, 1, 2, 3'b000, 5),  5,  32'hFFFF_FFF8);
        reg_op("sll  x6, x1, x1",   enc_r(7'h00, 1, 1, 3'b001, 6),  6,  32'h0000_00A0);
        reg_op("slt  x7, x2, x1",   enc_r(7'h00, 1, 2, 3'b010, 7),  7,  32'd1);
        reg_op("slt  x8, x1, x2",   enc_r(7'h00, 2, 1, 3'b010, 8),  8,  32'd0);
        reg_op("sltu x9, x1, x2",   enc_r(7'h00, 2, 1, 3'b011, 9),  9,  32'd1);
        reg_op("sltu x10, x2, x1",  enc_r(7'h00, 1, 2, 3'b011, 10), 10, 32'd0);
        reg_op("xor  x11, x1, x2",  enc_r(7'h00, 2, 1, 3'b100, 11), 11, 32'hFFFF_FFF8);
        reg_op("srl  x12, x2, x1",  enc_r(7'h00, 1, 2, 3'b101, 12), 12, 32'h07FF_FFFF);
        reg_op("sra  x13, x2, x1",  enc_r(7'h20, 1, 2, 3'b101, 13), 13, 32'hFFFF_FFFF);
        reg_op("or   x14, x1, x2",  enc_r(7'h00, 2, 1, 3'b110, 14), 14, 32'hFFFF_FFFD);
        reg_op("and  x15, x1, x2",  enc_r(7'h00, 2, 1, 3'b111, 15), 15, 32'd5);
        reg_op("sltu x16, x0, x1",  enc_r(7'h00, 1, 0, 3'b011, 16), 16, 32'd1);
        reg_op("sll  x17, x1, x2 (shamt=rs2[4:0]=29)",
                                    enc_r(7'h00, 2, 1, 3'b001, 17), 17, 32'hA000_0000);

        // ---------------- Tipo I aritmeticas ----------------
        reg_op("addi  x18, x1, -10", enc_i(OPI, -10,  1, 3'b000, 18), 18, 32'hFFFF_FFFB);
        reg_op("slti  x19, x2, -2",  enc_i(OPI, -2,   2, 3'b010, 19), 19, 32'd1);
        reg_op("slti  x20, x1, -2",  enc_i(OPI, -2,   1, 3'b010, 20), 20, 32'd0);
        reg_op("sltiu x21, x1, -1",  enc_i(OPI, -1,   1, 3'b011, 21), 21, 32'd1);
        reg_op("sltiu x22, x2, 3",   enc_i(OPI, 3,    2, 3'b011, 22), 22, 32'd0);
        reg_op("xori  x23, x2, -1",  enc_i(OPI, -1,   2, 3'b100, 23), 23, 32'd2);
        reg_op("ori   x24, x1, 0xF0",enc_i(OPI, 'hF0, 1, 3'b110, 24), 24, 32'h0000_00F5);
        reg_op("andi  x25, x2, 0xFF",enc_i(OPI, 'hFF, 2, 3'b111, 25), 25, 32'h0000_00FD);
        reg_op("slli  x26, x1, 31",  enc_sh(7'h00, 31, 1, 3'b001, 26), 26, 32'h8000_0000);
        reg_op("srli  x27, x2, 28",  enc_sh(7'h00, 28, 2, 3'b101, 27), 27, 32'h0000_000F);
        reg_op("srai  x28, x2, 1",   enc_sh(7'h20, 1,  2, 3'b101, 28), 28, 32'hFFFF_FFFE);
        reg_op("addi  x0, x1, 1 (x0 fixo)", enc_i(OPI, 1, 1, 3'b000, 0), 0, 32'd0);

        // ---------------- Tipo U ----------------
        reg_op("lui   x29, 0x12345",    enc_u(LUI, 20'h12345, 29), 29, 32'h1234_5000);
        reg_op("addi  x29, x29, 0x678", enc_i(OPI, 'h678, 29, 3'b000, 29), 29, 32'h1234_5678);
        reg_op("auipc x30, 0x1",        enc_u(AUIPC, 20'h00001, 30), 30, here() + 32'h1000);
        reg_op("lui   x31, 0xFFFFF",    enc_u(LUI, 20'hFFFFF, 31), 31, 32'hFFFF_F000);

        // ---------------- Stores (RAM, base 0x100) ----------------
        reg_op("addi x10, x0, 0x100", enc_i(OPI, 'h100, 0, 3'b000, 10), 10, 32'h100);
        add("sw x29, 0(x10)",  enc_s(0,  29, 10, 3'b010), K_MEM, 0, 32'h1234_5678, 32'h100);
        add("sw x2, 4(x10)",   enc_s(4,  2,  10, 3'b010), K_MEM, 0, 32'hFFFF_FFFD, 32'h104);
        add("sw x0, 8(x10)",   enc_s(8,  0,  10, 3'b010), K_MEM, 0, 32'h0000_0000, 32'h108);
        add("sb x24, 8(x10)",  enc_s(8,  24, 10, 3'b000), K_MEM, 0, 32'h0000_00F5, 32'h108);
        add("sb x1, 11(x10)",  enc_s(11, 1,  10, 3'b000), K_MEM, 0, 32'h0500_00F5, 32'h108);
        add("sw x0, 12(x10)",  enc_s(12, 0,  10, 3'b010), K_MEM, 0, 32'h0000_0000, 32'h10C);
        add("sh x29, 12(x10)", enc_s(12, 29, 10, 3'b001), K_MEM, 0, 32'h0000_5678, 32'h10C);
        add("sh x31, 14(x10)", enc_s(14, 31, 10, 3'b001), K_MEM, 0, 32'hF000_5678, 32'h10C);

        // ---------------- Loads ----------------
        reg_op("lw  x11, 0(x10)",   enc_i(LD, 0,   10, 3'b010, 11), 11, 32'h1234_5678);
        reg_op("lb  x12, 3(x10)",   enc_i(LD, 3,   10, 3'b000, 12), 12, 32'h0000_0012);
        reg_op("lb  x13, 8(x10)",   enc_i(LD, 8,   10, 3'b000, 13), 13, 32'hFFFF_FFF5);
        reg_op("lbu x14, 8(x10)",   enc_i(LD, 8,   10, 3'b100, 14), 14, 32'h0000_00F5);
        reg_op("lh  x15, 14(x10)",  enc_i(LD, 14,  10, 3'b001, 15), 15, 32'hFFFF_F000);
        reg_op("lhu x16, 14(x10)",  enc_i(LD, 14,  10, 3'b101, 16), 16, 32'h0000_F000);
        reg_op("lh  x17, 0(x10)",   enc_i(LD, 0,   10, 3'b001, 17), 17, 32'h0000_5678);
        reg_op("lw  x18, 4(x10)",   enc_i(LD, 4,   10, 3'b010, 18), 18, 32'hFFFF_FFFD);
        reg_op("addi x19, x10, 16", enc_i(OPI, 16, 10, 3'b000, 19), 19, 32'h110);
        reg_op("lw  x20, -16(x19)", enc_i(LD, -16, 19, 3'b010, 20), 20, 32'h1234_5678);
        reg_op("lbu x21, 1(x10)",   enc_i(LD, 1,   10, 3'b100, 21), 21, 32'h0000_0056);

        // ---------------- Branches (x1 = 5, x2 = -3) ----------------
        branch("beq  x1, x1 (tomado)",        enc_b(8, 1, 1, 3'b000), 1);
        branch("beq  x1, x2 (nao tomado)",    enc_b(8, 2, 1, 3'b000), 0);
        branch("bne  x1, x2 (tomado)",        enc_b(8, 2, 1, 3'b001), 1);
        branch("bne  x1, x1 (nao tomado)",    enc_b(8, 1, 1, 3'b001), 0);
        branch("blt  x2, x1 (tomado)",        enc_b(8, 1, 2, 3'b100), 1);
        branch("blt  x1, x2 (nao tomado)",    enc_b(8, 2, 1, 3'b100), 0);
        branch("bge  x1, x2 (tomado)",        enc_b(8, 2, 1, 3'b101), 1);
        branch("bge  x1, x1 (tomado, igual)", enc_b(8, 1, 1, 3'b101), 1);
        branch("bge  x2, x1 (nao tomado)",    enc_b(8, 1, 2, 3'b101), 0);
        branch("bltu x1, x2 (tomado)",        enc_b(8, 2, 1, 3'b110), 1);
        branch("bltu x2, x1 (nao tomado)",    enc_b(8, 1, 2, 3'b110), 0);
        branch("bgeu x2, x1 (tomado)",        enc_b(8, 1, 2, 3'b111), 1);
        branch("bgeu x1, x2 (nao tomado)",    enc_b(8, 2, 1, 3'b111), 0);

        // Laco com branch para tras: x22 = 3 -> 0.
        reg_op("addi x22, x0, 3", enc_i(OPI, 3, 0, 3'b000, 22), 22, 32'd3);
        add("addi x22, x22, -1 (laco)", enc_i(OPI, -1, 22, 3'b000, 22), K_NONE);
        add("bne  x22, x0, -4 (laco)",  enc_b(-4, 0, 22, 3'b001), K_NONE, 0, 0, 0, 0);
        reg_op("addi x23, x22, 7 (laco executou 3x)", enc_i(OPI, 7, 22, 3'b000, 23), 23, 32'd7);

        // ---------------- JAL / JALR ----------------
        x1_jal = here() + 4;
        add("jal  x1, +8", enc_j(8, 1), K_REG, 1, x1_jal, 0, 1, 8);
        trap("trap apos jal");

        a = prog.size();   // indice do auipc base
        reg_op("auipc x5, 0", enc_u(AUIPC, 20'h0, 5), 5, a * 4);
        add("jalr x6, 16(x5)", enc_i(JALR, 16, 5, 3'b000, 6), K_REG, 6, (a + 2) * 4, 0, 1, 12);
        trap("trap apos jalr 1");
        trap("trap apos jalr 1");
        reg_op("addi x7, x5, 29 (endereco impar)", enc_i(OPI, 29, 5, 3'b000, 7), 7, a * 4 + 29);
        // (x5 + 29 + 4) = a*4 + 33 -> bit 0 zerado -> a*4 + 32 = entrada a+8
        add("jalr x8, 4(x7) (zera bit 0)", enc_i(JALR, 4, 7, 3'b000, 8), K_REG, 8, (a + 6) * 4, 0, 1, 12);
        trap("trap apos jalr 2");
        trap("trap apos jalr 2");
        add("jal  x0, +8 (rd = x0)", enc_j(8, 0), K_NONE, 0, 0, 0, 1, 8);
        trap("trap apos jal x0");
        // Salto para tras: A -> C (pula B), C volta para B, B segue para D.
        add("jal  x0, +12",           enc_j(12, 0), K_NONE, 0, 0, 0, 1, 12);  // A
        reg_op("addi x10, x0, 42 (alvo do salto para tras)",
                                      enc_i(OPI, 42, 0, 3'b000, 10), 10, 32'd42); // B
        add("jal  x0, +8",            enc_j(8, 0), K_NONE, 0, 0, 0, 1, 8);    // B+1
        add("jal  x11, -8 (para tras)", enc_j(-8, 11), K_REG, 11, here() + 4, 0, 1, -8); // C
        // D: continua aqui

        // ---------------- MMIO ----------------
        reg_op("lui  x12, 0x40000",      enc_u(LUI, 20'h40000, 12), 12, IO);
        reg_op("addi x13, x0, 0x5A5",    enc_i(OPI, 'h5A5, 0, 3'b000, 13), 13, 32'h5A5);
        // Saidas out0..out3 em 0x00..0x0C (somente escrita, leem 0); entradas in0..in3 em 0x10..0x1C (L)
        add("sw   x13, 0(x12) -> out0",  enc_s(0, 13, 12, 3'b010), K_OUT0, 0, 32'h05A5);
        reg_op("lw   x14, 0(x12) (out0 le 0)", enc_i(LD, 0, 12, 3'b010, 14), 14, 32'h0);
        add("sb   x1, 1(x12) -> out0[15:8]", enc_s(1, 1, 12, 3'b000), K_OUT0, 0,
            {16'h0, x1_jal[7:0], 8'hA5});
        reg_op("lw   x15, 16(x12) (in0)",  enc_i(LD, 16, 12, 3'b010, 15), 15, IN0);
        reg_op("lbu  x16, 16(x12) (in0)",  enc_i(LD, 16, 12, 3'b100, 16), 16, {24'h0, IN0[7:0]});
        reg_op("lb   x17, 16(x12) (in0)",  enc_i(LD, 16, 12, 3'b000, 17), 17, {{24{IN0[7]}}, IN0[7:0]});
        reg_op("lbu  x18, 17(x12) (in0)",  enc_i(LD, 17, 12, 3'b100, 18), 18, {24'h0, IN0[15:8]});
        reg_op("lh   x19, 16(x12) (in0)",  enc_i(LD, 16, 12, 3'b001, 19), 19, {{16{IN0[15]}}, IN0[15:0]});
        reg_op("lhu  x20, 16(x12) (in0)",  enc_i(LD, 16, 12, 3'b101, 20), 20, {16'h0, IN0[15:0]});
        add("sh   x2, 4(x12) -> out1",    enc_s(4, 2, 12, 3'b001), K_OUT1, 0, 32'hFFFD);
        add("sw   x1, 8(x12) -> out2",    enc_s(8, 1, 12, 3'b010), K_OUT2, 0, x1_jal);
        // Saida e entrada com os 32 bits
        add("sw   x12, 12(x12) -> out3",  enc_s(12, 12, 12, 3'b010), K_OUT3, 0, IO);
        reg_op("lw   x24, 12(x12) (out3 le 0)", enc_i(LD, 12, 12, 3'b010, 24), 24, 32'h0);
        reg_op("lb   x25, 31(x12) (in3[31:24])", enc_i(LD, 31, 12, 3'b000, 25), 25,
               {{24{IN3[31]}}, IN3[31:24]});

        // ---------------- Instrucoes nao suportadas / invalidas ----------------
        add("ecall (NOP)", ECALL, K_NONE);
        add("fence (NOP)", FENCE, K_NONE);
        reg_op("mul x21, x1, x1 (funct7=0000001, nao escreve)",
               enc_r(7'h01, 1, 1, 3'b000, 21), 21, 32'h0000_0056);
        reg_op("slli x22, x1, 1 com imm[11:5]=0100000 (invalida)",
               enc_sh(7'h20, 1, 1, 3'b001, 22), 22, 32'd0);
        reg_op("jalr x23, 0(x5) com funct3=001 (invalida)",
               enc_i(JALR, 0, 5, 3'b001, 23), 23, 32'd7);

        // ---------------- Fim ----------------
        add("halt: jal x0, 0", enc_j(0, 0), K_HALT, 0, 0, 0, 1, 0);
    endtask

    // Confere os codificadores contra palavras geradas por um montador GNU.
    task automatic check_encoders();
        logic [31:0] got [6];
        logic [31:0] exp [6];
        got[0] = enc_i(OPI, 5, 0, 3'b000, 1);   exp[0] = 32'h0050_0093; // addi x1, x0, 5
        got[1] = enc_b(8, 0, 0, 3'b000);        exp[1] = 32'h0000_0463; // beq  x0, x0, 8
        got[2] = enc_j(8, 1);                   exp[2] = 32'h0080_00EF; // jal  x1, 8
        got[3] = enc_s(8, 7, 0, 3'b010);        exp[3] = 32'h0070_2423; // sw   x7, 8(x0)
        got[4] = enc_b(-4, 2, 1, 3'b001);       exp[4] = 32'hFE20_9EE3; // bne  x1, x2, -4
        got[5] = enc_j(-8, 0);                  exp[5] = 32'hFF9F_F06F; // j    -8
        for (int i = 0; i < 6; i++)
            if (got[i] !== exp[i])
                fail($sformatf("codificador %0d: obtido %h, esperado %h", i, got[i], exp[i]));
    endtask

    // ------------------------------------------------------------------
    // Execucao
    // ------------------------------------------------------------------
    initial begin
        int          hits[];
        logic [31:0] pc, idx;
        step_t       s;
        int          executed = 0;
        bit          halted = 0;
        logic [31:0] got;

        $display("==================================================");
        $display("   tb_core: programa RV32I completo no core");
        $display("==================================================");

        check_encoders();
        build_program();
        hits = new[prog.size()];

        // Espera o $readmemh inicial e sobrescreve as memorias.
        #1;
        for (int i = 0; i < 1024; i++) dut.search_inst.instr_mem.mem[i] = NOP;
        foreach (prog[i]) dut.search_inst.instr_mem.mem[i] = prog[i].instr;
        for (int w = 0; w < 1024; w++)
            dut.data_memory_inst.mem[w] = 32'h0;

        // Reset sincrono por dois ciclos.
        repeat (2) @(posedge clk);
        @(negedge clk) reset = 1'b0;

        for (int cycle = 0; cycle < 1000 && !halted; cycle++) begin
            pc  = dut.pc;
            idx = pc >> 2;
            if (pc[1:0] != 2'b00 || idx >= prog.size()) begin
                fail($sformatf("PC fora do programa: %h", pc));
                break;
            end
            s = prog[idx];
            hits[idx]++;
            if (s.kind == K_TRAP) begin
                fail($sformatf("PC %h: executou instrucao que deveria ter sido saltada (%s)", pc, s.name));
                break;
            end

            @(posedge clk);
            #1;
            executed++;

            if (s.chk_npc && dut.pc !== s.npc)
                fail($sformatf("PC %h %-40s: proximo PC %h, esperado %h", pc, s.name, dut.pc, s.npc));

            case (s.kind)
                K_REG:  got = reg_val(s.rd);
                K_MEM:  got = ram_word(s.addr);
                K_OUT0: got = io_out0;
                K_OUT1: got = io_out1;
                K_OUT2: got = io_out2;
                K_OUT3: got = io_out3;
                default: got = s.val;
            endcase
            if (got !== s.val)
                fail($sformatf("PC %h %-40s: obtido %h, esperado %h", pc, s.name, got, s.val));
            else if (s.kind inside {K_REG, K_MEM, K_OUT0, K_OUT1, K_OUT2, K_OUT3})
                $display("[PASS] PC %h %-40s = %h", pc, s.name, got);

            if (s.kind == K_HALT) halted = 1;
            @(negedge clk);
        end

        if (!halted) fail("programa nao chegou ao halt");

        // Toda instrucao (exceto traps) precisa ter sido executada.
        foreach (prog[i])
            if (prog[i].kind != K_TRAP && hits[i] == 0)
                fail($sformatf("instrucao nunca executada: PC %h %s", i * 4, prog[i].name));

        $display("==================================================");
        $display("   Instrucoes executadas: %0d", executed);
        if (error_count == 0)
            $display("   STATUS: SUCCESS! Todos os testes passaram.");
        else
            $display("   STATUS: FAILED! Total de erros: %0d", error_count);
        $display("==================================================");
        $finish;
    end

endmodule
