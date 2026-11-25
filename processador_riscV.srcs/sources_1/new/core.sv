`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: UTFPR-CP
// Engineer: Vinicius Souza Dias
//
// Create Date: 26.10.2026
// Design Name: Processador RV32I
// Module Name: core
// Project Name: processador_riscV
// Target Device: Artix-7 Nexys A7-100T
// Tool Version: Vivado 2025.2
// Description: Datapath monociclo RV32I inteiro em um único módulo.
//
// Dependencies: opcode_pkg, func3_pkg, func7_pkg, alu_pkg, branch_pkg, mem_pkg
//
// Revision:
// Revision 0.02 - Integracao dos modulos do processador
// Revision 0.03 - Experimento (branch core_plano): o corpo de cada submódulo
//                 (search, instruction_memory, decoder, register_file,
//                 imm_gen, control_unit, execution, alu, data_memory,
//                 write_back) copiado sem alterações para dentro do core,
//                 num único escopo (sem blocos nomeados)
// Additional Comments:
//   Os parâmetros dos submódulos foram trocados pelos do core (MEM_DEPTH ->
//   INSTR_MEM_DEPTH / DATA_MEM_DEPTH, MEM_FILE -> INSTR_MEM_FILE /
//   DATA_MEM_FILE) e as portas viraram sinais ligados por assign, como no
//   port map das instâncias. Só foram renomeados os nomes que colidiriam no
//   escopo único: instruction_memory -> imem_mem, imem_word_addr,
//   IMEM_ADDR_WIDTH, imem_addr_i, imem_instr_o; imm_gen -> imm_gen_imm_o;
//   execution -> exec_alu_result, exec_branch_taken.
//////////////////////////////////////////////////////////////////////////////////

/**
 * @file core.sv
 * @brief Processador monociclo RV32I em um único módulo (sem submódulos).
 *
 * Mesmo comportamento e mesma interface do core com submódulos: busca,
 * decodificação, execução, memória de dados e write-back, agora como
 * seções deste módulo. O código de cada seção é cópia literal do módulo
 * correspondente; as portas viraram sinais e as ligações seguem o port map do
 * core original.
 *
 * @param XLEN Largura dos dados e enderecos. Padrao: 32 bits.
 * @param INSTR_MEM_DEPTH Número de palavras da memória de instruções. Padrão:
 *                        1024 (4 KiB).
 * @param DATA_MEM_DEPTH Número de palavras da RAM de dados. Padrão: 256 (1 KiB,
 *                       endereços 0x000..0x3FF).
 * @param INSTR_MEM_FILE Arquivo hexadecimal de inicializacao da memoria de
 *                       instrucoes. Padrao: `program_bytes.mem`.
 * @param DATA_MEM_FILE Arquivo hexadecimal de inicializacao da memoria de
 *                      dados. Padrao: `data.mem`.
 * @param clk Clock do processador; PC, instrução registrada, escritas no banco
 *            de registradores e escritas na memória de dados são atualizados
 *            na borda de subida.
 * @param reset_i Reset sincrono ativo em nivel alto para zerar o PC.
 * @param io_in0_i..io_in3_i Entradas genericas, lidas em 0x4000_0010 + 4k.
 * @retval io_out0_o..io_out3_o Saidas genericas, somente escrita, em
 *                              0x4000_0000 + 4k (a leitura devolve 0).
 */
module core #(
    parameter int XLEN = 32,
    parameter int INSTR_MEM_DEPTH = 1024,
    parameter int DATA_MEM_DEPTH = 256,
    parameter string INSTR_MEM_FILE = "program_bytes.mem",
    parameter string DATA_MEM_FILE = "data.mem"
)(
    input logic clk,
    input logic reset_i,
    input logic [31:0] io_in0_i,
    input logic [31:0] io_in1_i,
    input logic [31:0] io_in2_i,
    input logic [31:0] io_in3_i,
    output logic [31:0] io_out0_o,
    output logic [31:0] io_out1_o,
    output logic [31:0] io_out2_o,
    output logic [31:0] io_out3_o
);


    import opcode_pkg::*;
    import func3_pkg::*;
    import func7_pkg::*;
    import alu_pkg::*;
    import branch_pkg::*;
    import mem_pkg::*;

    logic [XLEN-1:0] pc;
    logic [XLEN-1:0] pc_next;
    logic [XLEN-1:0] pc_branch;
    logic [31:0]     instruction;
    logic [XLEN-1:0] rs1_data;
    logic [XLEN-1:0] rs2_data;
    logic [XLEN-1:0] immediate;
    logic [XLEN-1:0] data_memory_data;
    logic [XLEN-1:0] alu_result;
    logic [XLEN-1:0] data_memory_addr;
    logic            data_memory_addr_io;     // endereco no MMIO (sem esperar o somador)
    logic            data_memory_addr_page0;  // endereco nos primeiros 4 KiB (idem)
    logic [XLEN-1:0] write_back_data;
    logic            pc_write_enable;
    logic            branch_taken;
    logic            branch_enable;
    logic            alu_a_select;
    logic [1:0]      alu_b_select;
    logic            data_memory_write_enable;
    logic            register_write_enable;
    logic            mem_to_reg;
    alu_op_t         alu_control;
    branch_op_t      branch_control;
    mem_width_t      data_memory_width;
    mem_signed_t     data_memory_signed;

    // =========================================================================
    // search (com instruction_memory dentro)
    // =========================================================================
    // Parâmetros e portas (clk, reset_i e pc_next vêm do core).

    logic              pc_write_i;
    logic              pc_branch_i;
    logic [XLEN-1:0]   new_pc_i;
    logic [XLEN-1:0]   instr_o;
    logic [XLEN-1:0]   pc_o;

    assign pc_write_i  = pc_write_enable;
    assign pc_branch_i = branch_taken;
    assign new_pc_i    = pc_branch;

    // ---- corpo copiado de search.sv ----
    logic [XLEN-1:0] pc_reg;
    logic [XLEN-1:0] pc_sel;      // próximo PC: vai para o PC e para o endereço da ROM
    logic [XLEN-1:0] rom_data;    // palavra de pc_sel lida da memória de instruções
    logic [XLEN-1:0] instr_reg;   // instrução do PC atual, registrada junto com o PC

    // Valor inicial da instrução: a palavra 0 do programa (o PC nasce 0). O
    // arquivo é lido aqui só para esse valor; a ROM fica na instruction_memory.
    // O xsim avisa (VRFC 10-2921) por instr_reg ter initial e always_ff: é o
    // mesmo padrão das saídas MMIO e vira o INIT dos FFs na síntese.
    logic [XLEN-1:0] rom_init [0:INSTR_MEM_DEPTH-1];
    initial begin
        $readmemh(INSTR_MEM_FILE, rom_init);
        instr_reg = rom_init[0];
    end

    // Atribuições combinacionais de saída
    assign pc_o    = pc_reg;
    assign pc_next = pc_reg + 32'd4;
    assign instr_o = instr_reg;

    // Próximo PC. O reset entra aqui, e não só no registrador, para a instrução
    // registrada também voltar à palavra do endereço 0.
    always_comb begin
        if (reset_i)
            pc_sel = '0;
        else if (pc_write_i)
            pc_sel = pc_branch_i ? new_pc_i : pc_next;
        else
            pc_sel = pc_reg;
    end

    // Atualização sequencial do Contador de Programa (PC) e da instrução, na
    // mesma borda.
    always_ff @(posedge clk) begin
        pc_reg    <= pc_sel;
        instr_reg <= rom_data;
    end

    // ---------------------------------------------------------------------
    // instruction_memory
    // ---------------------------------------------------------------------
    // Portas (MEM_DEPTH e MEM_FILE vêm do search).
    logic [XLEN-1:0] imem_addr_i;
    logic [XLEN-1:0] imem_instr_o;

    assign imem_addr_i = pc_sel;

    // ---- corpo copiado de instruction_memory.sv ----
    logic [XLEN-1:0] imem_mem [0:INSTR_MEM_DEPTH-1];

    initial begin
        $readmemh(INSTR_MEM_FILE, imem_mem);
    end

    localparam int IMEM_ADDR_WIDTH = $clog2(INSTR_MEM_DEPTH);
    logic [IMEM_ADDR_WIDTH-1:0] imem_word_addr;

    assign imem_word_addr = imem_addr_i[IMEM_ADDR_WIDTH+1:2];

    assign imem_instr_o = imem_mem[imem_word_addr];

    assign rom_data = imem_instr_o;

    assign instruction = instr_o;
    assign pc          = pc_o;

    // =========================================================================
    // decoder (com register_file, imm_gen e control_unit dentro)
    // =========================================================================
    // Parâmetros e portas (clk vem do core).
    localparam int REG_XLEN = 5;

    logic [31:0]          instruction_i;
    logic [XLEN-1:0]      written_data_i;

    logic [XLEN-1:0]      rs1_o;
    logic [XLEN-1:0]      rs2_o;
    logic [XLEN-1:0]      imm_o;

    alu_op_t              execution_alu_control_o;
    branch_op_t           execution_branch_control_o;
    logic                 execution_branch_enable_o;
    logic                 execution_control_alu_a_o;
    logic [1:0]           execution_control_alu_b_o;
    logic                 search_pc_write_o;
    logic                 data_memory_mem_write_o;
    mem_width_t           data_memory_mem_width_o;
    mem_signed_t          data_memory_mem_signed_o;
    logic                 register_file_written_enable_o;
    logic                 write_back_mem_to_reg_o;

    assign instruction_i  = instruction;
    assign written_data_i = write_back_data;

    // ---- corpo copiado de decoder.sv ----
    logic [REG_XLEN-1:0] rd;
    logic [REG_XLEN-1:0] rs1_add;
    logic [REG_XLEN-1:0] rs2_add;
    logic [31:0]         imm_rv32;

    // Campos de registrador da instrucao usados pelo banco de registradores.
    assign rd      = instruction_i[11:7];
    assign rs1_add = instruction_i[19:15];
    assign rs2_add = instruction_i[24:20];
    assign imm_o   = imm_rv32;

    // ---------------------------------------------------------------------
    // register_file
    // ---------------------------------------------------------------------
    // Portas (clk, written_data_i, rs1_o e rs2_o vêm do decoder;
    // XLEN e REG_XLEN também).
    logic                 written_enable_i;
    logic [REG_XLEN-1:0]  written_add_i;
    logic [REG_XLEN-1:0]  rs1_add_i;
    logic [REG_XLEN-1:0]  rs2_add_i;

    assign written_enable_i = register_file_written_enable_o;
    assign written_add_i    = rd;
    assign rs1_add_i        = rs1_add;
    assign rs2_add_i        = rs2_add;

    // ---- corpo copiado de register_file.sv ----
    logic [XLEN-1:0] register_file [0:31];

    // Valor inicial zero: evita leituras 'X' na simulacao e vira valor de
    // inicializacao da LUTRAM na FPGA. Não é um reset (o reset só reinicia o
    // PC e a instrução registrada). Para x0 é o que garante a leitura em zero.
    initial begin
        for (int i = 0; i < 32; i++) register_file[i] = '0;
    end

    // x0 nunca é escrito: continua com o zero do initial.
    always_ff @(posedge clk) begin
        if (written_enable_i && (written_add_i != 5'd0)) begin
            register_file[written_add_i] <= written_data_i;
        end
    end

    assign rs1_o = register_file[rs1_add_i];
    assign rs2_o = register_file[rs2_add_i];

    // ---------------------------------------------------------------------
    // imm_gen
    // ---------------------------------------------------------------------
    // Portas (instruction_i vem do decoder).
    logic [31:0] imm_gen_imm_o;

    // ---- corpo copiado de imm_gen.sv ----
    always_comb begin
        case (instruction_i[6:0])
            OPCODE_LOAD,
            OPCODE_OP_IMM,
            OPCODE_JALR:
                imm_gen_imm_o = {{20{instruction_i[31]}}, instruction_i[31:20]};

            OPCODE_STORE:
                imm_gen_imm_o = {{20{instruction_i[31]}},
                         instruction_i[31:25],
                         instruction_i[11:7]};

            OPCODE_BRANCH:
                imm_gen_imm_o = {{19{instruction_i[31]}},
                         instruction_i[31],
                         instruction_i[7],
                         instruction_i[30:25],
                         instruction_i[11:8],
                         1'b0};

            OPCODE_LUI,
            OPCODE_AUIPC:
                imm_gen_imm_o = {instruction_i[31:12], 12'b0};

            OPCODE_JAL:
                imm_gen_imm_o = {{11{instruction_i[31]}},
                         instruction_i[31],
                         instruction_i[19:12],
                         instruction_i[20],
                         instruction_i[30:21],
                         1'b0};

            default:
                imm_gen_imm_o = {{20{instruction_i[31]}}, instruction_i[31:20]};
        endcase
    end

    assign imm_rv32 = imm_gen_imm_o;

    // ---------------------------------------------------------------------
    // control_unit
    // ---------------------------------------------------------------------
    // Portas: todas têm o mesmo nome no decoder (instruction_i e as
    // saídas *_o), então o corpo dirige direto os sinais do decoder.

    // ---- corpo copiado de control_unit.sv ----
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;

    assign opcode = instruction_i[6:0];
    assign funct3 = instruction_i[14:12];
    assign funct7 = instruction_i[31:25];

    always_comb begin
        // Estado seguro/default: PC avanca, sem efeitos colaterais.
        execution_alu_control_o   = OP_ADD;
        execution_branch_control_o = OP_BCT;
        execution_branch_enable_o = 1'b0;
        execution_control_alu_a_o = 1'b0;       // rs1
        execution_control_alu_b_o = 2'b00;      // rs2
        search_pc_write_o      = 1'b1;
        data_memory_mem_write_o     = 1'b0;
        data_memory_mem_width_o     = MEM_WIDTH_WORD;
        // Default sem extensao de sinal; apenas loads sobrescrevem este controle.
        data_memory_mem_signed_o    = MEM_UNSIGNED;
        register_file_written_enable_o = 1'b0;
        write_back_mem_to_reg_o    = 1'b0;       // resultado da ALU

        case (opcode)
            OPCODE_OP: begin
                // Decodificacao estrita: apenas funct7 = 0000000 (todas as
                // operacoes) ou 0100000 (SUB/SRA) sao validos no RV32I. Outros
                // valores (ex.: extensao M, funct7 = 0000001) viram NOP.
                register_file_written_enable_o = 1'b1;
                if (funct7 == F7_ZERO) begin
                    case (funct3)
                        F3_ADD:  execution_alu_control_o = OP_ADD;
                        F3_SLL:  execution_alu_control_o = OP_SLL;
                        F3_SLT:  execution_alu_control_o = OP_SLT;
                        F3_SLTU: execution_alu_control_o = OP_SLTU;
                        F3_XOR:  execution_alu_control_o = OP_XOR;
                        F3_SRL:  execution_alu_control_o = OP_SRL;
                        F3_OR:   execution_alu_control_o = OP_OR;
                        F3_AND:  execution_alu_control_o = OP_AND;
                        default: register_file_written_enable_o = 1'b0;
                    endcase
                end else if (funct7 == F7_ALT) begin
                    case (funct3)
                        F3_SUB:  execution_alu_control_o = OP_SUB;
                        F3_SRA:  execution_alu_control_o = OP_SRA;
                        default: register_file_written_enable_o = 1'b0;
                    endcase
                end else begin
                    register_file_written_enable_o = 1'b0;
                end
            end

            OPCODE_OP_IMM: begin
                register_file_written_enable_o = 1'b1;
                execution_control_alu_b_o = 2'b01; // imediato
                case (funct3)
                    F3_ADDI: execution_alu_control_o = OP_ADD;
                    F3_SLTI: execution_alu_control_o = OP_SLT;
                    F3_SLTIU: execution_alu_control_o = OP_SLTU;
                    F3_XORI: execution_alu_control_o = OP_XOR;
                    F3_ORI: execution_alu_control_o = OP_OR;
                    F3_ANDI: execution_alu_control_o = OP_AND;
                    // Shifts com imediato: imm[11:5] precisa ser 0000000
                    // (SLLI/SRLI) ou 0100000 (SRAI); outros valores viram NOP.
                    F3_SLLI: begin
                        if (funct7 == F7_SLLI) execution_alu_control_o = OP_SLL;
                        else                   register_file_written_enable_o = 1'b0;
                    end
                    F3_SRLI: begin
                        if      (funct7 == F7_SRLI) execution_alu_control_o = OP_SRL;
                        else if (funct7 == F7_SRAI) execution_alu_control_o = OP_SRA;
                        else                        register_file_written_enable_o = 1'b0;
                    end
                    default: register_file_written_enable_o = 1'b0;
                endcase
            end

            OPCODE_LOAD: begin
                execution_alu_control_o = OP_ADD;
                execution_control_alu_b_o = 2'b01; // rs1 + imediato
                register_file_written_enable_o = 1'b1;
                write_back_mem_to_reg_o = 1'b1;
                case (funct3)
                    F3_LB:  begin data_memory_mem_width_o = MEM_WIDTH_BYTE; data_memory_mem_signed_o = MEM_SIGNED; end
                    F3_LH:  begin data_memory_mem_width_o = MEM_WIDTH_HALF; data_memory_mem_signed_o = MEM_SIGNED; end
                    F3_LW:  begin data_memory_mem_width_o = MEM_WIDTH_WORD; data_memory_mem_signed_o = MEM_SIGNED; end
                    F3_LBU: begin data_memory_mem_width_o = MEM_WIDTH_BYTE; data_memory_mem_signed_o = MEM_UNSIGNED; end
                    F3_LHU: begin data_memory_mem_width_o = MEM_WIDTH_HALF; data_memory_mem_signed_o = MEM_UNSIGNED; end
                    default: begin register_file_written_enable_o = 1'b0; end
                endcase
            end

            OPCODE_STORE: begin
                execution_alu_control_o = OP_ADD;
                execution_control_alu_b_o = 2'b01; // rs1 + imediato
                data_memory_mem_write_o = 1'b1;
                case (funct3)
                    F3_SB: data_memory_mem_width_o = MEM_WIDTH_BYTE;
                    F3_SH: data_memory_mem_width_o = MEM_WIDTH_HALF;
                    F3_SW: data_memory_mem_width_o = MEM_WIDTH_WORD;
                    default: data_memory_mem_write_o = 1'b0;
                endcase
            end

            OPCODE_BRANCH: begin
                execution_branch_enable_o = 1'b1;
                case (funct3)
                    F3_BEQ: begin execution_alu_control_o = OP_CMP;  execution_branch_control_o = OP_BCT; end
                    F3_BNE: begin execution_alu_control_o = OP_CMP;  execution_branch_control_o = OP_BCF; end
                    F3_BLT: begin execution_alu_control_o = OP_SLT;  execution_branch_control_o = OP_BCT; end
                    F3_BGE: begin execution_alu_control_o = OP_SLT;  execution_branch_control_o = OP_BCF; end
                    F3_BLTU: begin execution_alu_control_o = OP_SLTU; execution_branch_control_o = OP_BCT; end
                    F3_BGEU: begin execution_alu_control_o = OP_SLTU; execution_branch_control_o = OP_BCF; end
                    default: execution_branch_enable_o = 1'b0;
                endcase
            end

            OPCODE_LUI: begin
                execution_alu_control_o = OP_PASS_B;
                execution_control_alu_b_o = 2'b01; // imediato U
                register_file_written_enable_o = 1'b1;
            end

            OPCODE_AUIPC: begin
                execution_alu_control_o = OP_ADD;
                execution_control_alu_a_o = 1'b1; // PC
                execution_control_alu_b_o = 2'b01; // imediato U
                register_file_written_enable_o = 1'b1;
            end

            OPCODE_JAL: begin
                execution_alu_control_o = OP_PASS_B;
                execution_control_alu_b_o = 2'b10; // PC + 4 para write-back
                execution_branch_enable_o = 1'b1;
                execution_branch_control_o = OP_BIP;
                register_file_written_enable_o = 1'b1;
            end

            OPCODE_JALR: begin
                // JALR so e valido com funct3 = 000; caso contrario vira NOP.
                // OP_BIR (base rs1 do alvo) nao olha o funct3: com funct3
                // invalido o enable fica 0 e o desvio nao acontece. Medido em
                // 21/11/2026: assim o core fecha 100 MHz nos dois fluxos.
                execution_branch_control_o = OP_BIR;
                if (funct3 == F3_JALR) begin
                    execution_alu_control_o = OP_PASS_B;
                    execution_control_alu_b_o = 2'b10; // PC + 4 para write-back
                    execution_branch_enable_o = 1'b1;
                    register_file_written_enable_o = 1'b1;
                end
            end

            default: begin
                // OPCODEs nao suportados mantem os controles default.
            end
        endcase
    end

    assign rs1_data                 = rs1_o;
    assign rs2_data                 = rs2_o;
    assign immediate                = imm_o;
    assign alu_control              = execution_alu_control_o;
    assign branch_control           = execution_branch_control_o;
    assign branch_enable            = execution_branch_enable_o;
    assign alu_a_select             = execution_control_alu_a_o;
    assign alu_b_select             = execution_control_alu_b_o;
    assign pc_write_enable          = search_pc_write_o;
    assign data_memory_write_enable = data_memory_mem_write_o;
    assign data_memory_width        = data_memory_mem_width_o;
    assign data_memory_signed       = data_memory_mem_signed_o;
    assign register_write_enable    = register_file_written_enable_o;
    assign mem_to_reg               = write_back_mem_to_reg_o;

    // =========================================================================
    // execution (com alu dentro)
    // =========================================================================
    // Portas (XLEN vem do core).
    logic [XLEN-1:0] pc_next_i;
    logic [XLEN-1:0] pc_i;
    logic [XLEN-1:0] imm_i;
    logic [XLEN-1:0] reg_data1_i;
    logic [XLEN-1:0] reg_data2_i;

    alu_op_t         alu_control_i;
    branch_op_t      branch_control_i;
    logic            branch_enable_i;
    logic            control_alu_a;
    logic [1:0]      control_alu_b;
    logic [2:0]      funct3_i;

    logic [XLEN-1:0] pc_branch_o;
    logic [XLEN-1:0] alu_result_o;
    logic            branch_taken_o;
    logic [XLEN-1:0] mem_addr_o;
    logic            mem_io_o;
    logic            mem_page0_o;

    assign pc_next_i        = pc_next;
    assign pc_i             = pc;
    assign imm_i            = immediate;
    assign reg_data1_i      = rs1_data;
    assign reg_data2_i      = rs2_data;
    assign alu_control_i    = alu_control;
    assign branch_control_i = branch_control;
    assign branch_enable_i  = branch_enable;
    assign control_alu_a    = alu_a_select;
    assign control_alu_b    = alu_b_select;
    assign funct3_i         = instruction[14:12];   // escolhe a comparação dos desvios

    // ---- corpo copiado de execution.sv ----
    logic [XLEN-1:0] alu_a;
    logic [XLEN-1:0] alu_b;
    logic [XLEN-1:0] exec_alu_result;

    logic [XLEN-1:0] branch_address;
    logic            branch_cond;
    logic            exec_branch_taken;
    logic [XLEN-1:0] branch_a;
    logic [XLEN-1:0] branch_b;

    assign alu_result_o  = exec_alu_result;
    assign pc_branch_o   = branch_address;
    assign branch_taken_o = exec_branch_taken;

    // Selecao dos operandos enviados a ALU.
    always_comb begin
        case (control_alu_a)
            1'b0: alu_a = reg_data1_i;
            1'b1: alu_a = pc_i;
        endcase

        case (control_alu_b)
            2'b00: alu_b = reg_data2_i;
            2'b01: alu_b = imm_i;
            2'b10: alu_b = pc_next_i;
            default: alu_b = reg_data2_i;
        endcase
    end

    // ---------------------------------------------------------------------
    // alu
    // ---------------------------------------------------------------------
    // Portas (XLEN vem da execution).
    logic [XLEN-1:0] a_i;
    logic [XLEN-1:0] b_i;
    alu_op_t         alu_op_i;
    logic [XLEN-1:0] alu_o;

    assign a_i      = alu_a;
    assign b_i      = alu_b;
    assign alu_op_i = alu_control_i;

    // ---- corpo copiado de alu.sv ----
    // --------------------------------------------------------
    // 1. Bloco Aritmético e Comparações (Compartilhamento CARRY4)
    // --------------------------------------------------------
    logic            is_sub;
    logic [XLEN-1:0] b_mux;
    logic [XLEN:0]   add_sub_res;

    assign is_sub = (alu_op_i == OP_SUB)  |
                    (alu_op_i == OP_SLT)  |
                    (alu_op_i == OP_SLTU);

    assign b_mux  = is_sub ? ~b_i : b_i;
    assign add_sub_res = a_i + b_mux + is_sub;

    logic cmp_slt, cmp_sltu;

    assign cmp_sltu = ~add_sub_res[XLEN];
    assign cmp_slt  = (a_i[XLEN-1] != b_i[XLEN-1]) ? a_i[XLEN-1] : add_sub_res[XLEN-1];

    logic [XLEN-1:0] res_arith;
    assign res_arith = (alu_op_i == OP_SLT)  ? {{(XLEN-1){1'b0}}, cmp_slt}  :
                       (alu_op_i == OP_SLTU) ? {{(XLEN-1){1'b0}}, cmp_sltu} :
                       add_sub_res[XLEN-1:0];

    // --------------------------------------------------------
    // 2. Bloco Lógico
    // --------------------------------------------------------
    logic [XLEN-1:0] res_logic;
    always_comb begin
        case (alu_op_i)
            OP_AND:  res_logic = a_i & b_i;
            OP_OR:   res_logic = a_i | b_i;
            OP_XOR:  res_logic = a_i ^ b_i;
            default: res_logic = b_i;
        endcase
    end

    // --------------------------------------------------------
    // 3. Bloco de Deslocamento (Barrel Shifter)
    // --------------------------------------------------------
    logic [XLEN-1:0] res_shift;
    always_comb begin
        case (alu_op_i)
            OP_SLL:  res_shift = a_i << b_i[4:0];
            OP_SRL:  res_shift = a_i >> b_i[4:0];
            OP_SRA:  res_shift = $signed(a_i) >>> b_i[4:0];
            default: res_shift = '0;
        endcase
    end

    // --------------------------------------------------------
    // 4. Multiplexador Final
    // --------------------------------------------------------
    always_comb begin
        case (alu_op_i)
            OP_ADD, OP_SUB, OP_SLT, OP_SLTU:   alu_o = res_arith;
            OP_AND, OP_OR, OP_XOR, OP_PASS_B:  alu_o = res_logic;
            OP_SLL, OP_SRL, OP_SRA:            alu_o = res_shift;
            default:                           alu_o = '0;   // inclui OP_CMP
        endcase
    end

    assign exec_alu_result = alu_o;

    // Comparador dedicado dos desvios: rs1 x rs2 direto, sem os muxes de
    // operando nem a ALU. É uma cadeia de carry só, configurada pelo funct3
    // (fio da instrução, pronto junto com a leitura do banco): funct3[2] = 0
    // compara igualdade e 1 compara "menor"; funct3[1] = 1 é sem sinal. Com
    // sinal = sem sinal com o bit 31 dos dois operandos invertido.
    // A cadeia anda em dígitos de 2 bits: cmp_eq = dígitos iguais (propaga) e
    // cmp_lt = dígito de rs1 menor (gera; só no modo "menor"). O carry de
    // cmp_lt + (cmp_lt ^ cmp_eq) + cin, com cin = 1 no modo igualdade, é o
    // resultado da comparação; escrito assim, a síntese monta um único
    // somador de 16 dígitos (4 CARRY4) em vez de três comparadores e um mux.
    logic              cmp_less;     // 1: "menor"; 0: igualdade
    logic              cmp_signed;
    logic [XLEN-1:0]   cmp_a;
    logic [XLEN-1:0]   cmp_b;
    logic [XLEN/2-1:0] cmp_eq;
    logic [XLEN/2-1:0] cmp_lt;
    logic [XLEN/2:0]   cmp_chain;

    assign cmp_less   = funct3_i[2];
    assign cmp_signed = ~funct3_i[1];
    assign cmp_a      = {reg_data1_i[XLEN-1] ^ cmp_signed, reg_data1_i[XLEN-2:0]};
    assign cmp_b      = {reg_data2_i[XLEN-1] ^ cmp_signed, reg_data2_i[XLEN-2:0]};

    always_comb begin
        for (int j = 0; j < XLEN/2; j++) begin
            cmp_eq[j] = (cmp_a[2*j +: 2] == cmp_b[2*j +: 2]);
            cmp_lt[j] = cmp_less & (cmp_a[2*j +: 2] < cmp_b[2*j +: 2]);
        end
    end

    assign cmp_chain   = {1'b0, cmp_lt} + {1'b0, cmp_lt ^ cmp_eq} + {{(XLEN/2){1'b0}}, ~cmp_less};
    assign branch_cond = cmp_chain[XLEN/2];

    // Decisão: o controle diz antes o que fazer com a comparação verdadeira e
    // com a falsa; a comparação, que chega por último, só escolhe entre as duas.
    logic take_if_true;
    logic take_if_false;

    always_comb begin
        take_if_true  = 1'b0;
        take_if_false = 1'b0;
        if (branch_enable_i) begin
            case (branch_control_i)
                OP_BCT:  take_if_true  = 1'b1;
                OP_BCF:  take_if_false = 1'b1;
                default: begin                 // OP_BIP, OP_BIR: sempre
                    take_if_true  = 1'b1;
                    take_if_false = 1'b1;
                end
            endcase
        end
    end

    assign exec_branch_taken = branch_cond ? take_if_true : take_if_false;

    // Base do endereço de destino: rs1 no JALR, PC nos demais. Não depende do
    // enable: o destino só é usado quando o desvio é tomado.
    assign branch_b = (branch_control_i == OP_BIR) ? reg_data1_i : pc_i;

    assign branch_a       = imm_i;
    // Zera o bit 0: exigido pelo JALR; inofensivo para branches/JAL, cujo
    // imediato ja tem bit 0 = 0.
    assign branch_address = (branch_a + branch_b) & ~XLEN'(1);

    // Endereco da memoria de dados: nao passa pelos muxes de operando nem pelo
    // mux de saida da ALU.
    assign mem_addr_o = reg_data1_i + imm_i;

    // Regiao da memoria de dados sem esperar o carry ate o bit 31. Com imediato
    // de 12 bits, mem_addr_o[31:12] so pode ser rs1[31:12] - 1, + 0 ou + 1,
    // conforme imm[11] e o carry do bit 11. As flags dos tres candidatos
    // dependem so de rs1; o carry atravessa apenas 12 bits.
    logic [12:0] addr_low;
    logic [19:0] rs1_hi;
    logic        io_dec, io_mid, io_inc;
    logic        page0_dec, page0_mid, page0_inc;

    assign addr_low = {1'b0, reg_data1_i[11:0]} + {1'b0, imm_i[11:0]};
    assign rs1_hi   = reg_data1_i[31:12];

    assign io_mid    = (rs1_hi[19:16] == 4'h4);
    // rs1_hi + 1: o nibble alto so muda se rs1_hi[15:0] for todo 1.
    assign io_inc    = (rs1_hi[15:0] == 16'hFFFF) ? (rs1_hi[19:16] == 4'h3) : io_mid;
    // rs1_hi - 1: o nibble alto so muda se rs1_hi[15:0] for todo 0.
    assign io_dec    = (rs1_hi[15:0] == 16'h0000) ? (rs1_hi[19:16] == 4'h5) : io_mid;

    assign page0_mid = (rs1_hi == 20'h00000);
    assign page0_inc = (rs1_hi == 20'hFFFFF);   // rs1_hi + 1 == 0
    assign page0_dec = (rs1_hi == 20'h00001);   // rs1_hi - 1 == 0

    always_comb begin
        case ({imm_i[11], addr_low[12]})
            2'b01:   begin mem_io_o = io_inc; mem_page0_o = page0_inc; end // imm >= 0, carry
            2'b10:   begin mem_io_o = io_dec; mem_page0_o = page0_dec; end // imm < 0, sem carry
            default: begin mem_io_o = io_mid; mem_page0_o = page0_mid; end
        endcase
    end

    assign pc_branch              = pc_branch_o;
    assign alu_result             = alu_result_o;
    assign branch_taken           = branch_taken_o;
    assign data_memory_addr       = mem_addr_o;
    assign data_memory_addr_io    = mem_io_o;
    assign data_memory_addr_page0 = mem_page0_o;

    // =========================================================================
    // data_memory
    // =========================================================================
    // Parâmetros e portas (clk, io_in*_i e io_out*_o vêm do core).

    logic             mem_write_i;
    mem_width_t       mem_width_i;
    mem_signed_t      mem_signed_i;
    logic [XLEN-1:0]  addr_i;
    logic             addr_io_i;
    logic             addr_page0_i;
    logic [XLEN-1:0]  data_i;
    logic [XLEN-1:0]  data_o;

    assign mem_write_i  = data_memory_write_enable;
    assign mem_width_i  = data_memory_width;
    assign mem_signed_i = data_memory_signed;
    assign addr_i       = data_memory_addr;
    assign addr_io_i    = data_memory_addr_io;
    assign addr_page0_i = data_memory_addr_page0;
    assign data_i       = rs2_data;

    // ---- corpo copiado de data_memory.sv ----
    // RAM interna: array 1-D de words com escrita por faixa de byte (forma que
    // o Vivado infere como RAM distribuida; o array 2-D de bytes virava FFs).
    logic [31:0] mem [0:DATA_MEM_DEPTH-1];

    // data.mem tem um byte por token em ordem de endereco; monta as words
    // little-endian a partir de um array temporario.
    logic [7:0] mem_init_bytes [0:DATA_MEM_DEPTH*4-1];

    initial begin
        $readmemh(DATA_MEM_FILE, mem_init_bytes);
        for (int w = 0; w < DATA_MEM_DEPTH; w++)
            mem[w] = {mem_init_bytes[4*w+3], mem_init_bytes[4*w+2],
                      mem_init_bytes[4*w+1], mem_init_bytes[4*w]};
    end

    localparam int ADDR_WIDTH = $clog2(DATA_MEM_DEPTH);

    // addr_page0_i so cobre os primeiros 4 KiB.
    if (DATA_MEM_DEPTH * 4 > 4096) begin : g_mem_depth_check
        $error("data_memory: DATA_MEM_DEPTH*4 (%0d) passa de 4096, limite de addr_page0_i", DATA_MEM_DEPTH * 4);
    end

    // =========================================================================
    // DECODIFICAÇÃO DE ENDEREÇOS
    // Mapeamento:
    //   - 0x0000_0000 até MEM_DEPTH*4-1 (0x0000_03FF com MEM_DEPTH = 256, o valor do core) -> RAM Interna
    //   - 0x4xxx_xxxx                -> Espaço de I/O (MMIO)
    // As comparações dos bits altos vêm prontas da execution (addr_io_i,
    // addr_page0_i), sem esperar o carry do somador de endereço.
    // =========================================================================
    logic                  is_io_space;
    logic                  ram_addr_valid;
    logic [3:0]            io_offset;
    logic [ADDR_WIDTH-1:0] word_addr;
    logic [1:0]            byte_offset;

    assign is_io_space    = addr_io_i;
    assign ram_addr_valid = addr_page0_i && (addr_i[11:0] < (DATA_MEM_DEPTH * 4));
    assign io_offset   = addr_i[5:2]; // Offset do registrador no bloco de I/O
    assign word_addr   = addr_i[ADDR_WIDTH+1:2];
    assign byte_offset = addr_i[1:0];

    // =========================================================================
    // LÓGICA DE LEITURA DA RAM INTERNA (Assíncrona)
    // =========================================================================
    logic [31:0] ram_word_data;
    logic [31:0] io_data_out;   // palavra lida dos periféricos (definida abaixo)
    logic [31:0] word_data;     // palavra selecionada: RAM ou MMIO
    logic [7:0]  byte_sel;
    logic [15:0] half_sel;
    logic        sign_b;
    logic        sign_h;
    logic [31:0] load_data;

    always_comb begin
        if (ram_addr_valid)
            ram_word_data = mem[word_addr];
        else
            ram_word_data = '0;
    end

    // A selecao de byte/halfword e a extensao de sinal valem tanto para a RAM
    // quanto para o MMIO (ex.: LBU em 0x4000_0011 retorna io_in0_i[15:8]).
    assign word_data = is_io_space ? io_data_out : ram_word_data;

    always_comb begin
        case (byte_offset)
            2'b00:  byte_sel = word_data[7:0];
            2'b01:  byte_sel = word_data[15:8];
            2'b10:  byte_sel = word_data[23:16];
            2'b11:  byte_sel = word_data[31:24];
        endcase
    end

    assign half_sel = byte_offset[1] ? word_data[31:16] : word_data[15:0];

    assign sign_b = (mem_signed_i == MEM_SIGNED) & byte_sel[7];
    assign sign_h = (mem_signed_i == MEM_SIGNED) & half_sel[15];

    always_comb begin
        case (mem_width_i)
            MEM_WIDTH_BYTE: load_data = {{24{sign_b}}, byte_sel};
            MEM_WIDTH_HALF: load_data = {{16{sign_h}}, half_sel};
            MEM_WIDTH_WORD: load_data = word_data;
            default:        load_data = word_data;
        endcase
    end

    // =========================================================================
    // LÓGICA DE ESCRITA (Síncrona)
    // =========================================================================
    logic [3:0]  we_byte;
    logic [31:0] wdata;
    logic        ram_write_en;

    always_comb begin
        case (mem_width_i)
            MEM_WIDTH_BYTE: we_byte = 4'b0001 << byte_offset;
            MEM_WIDTH_HALF: we_byte = byte_offset[1] ? 4'b1100 : 4'b0011;
            MEM_WIDTH_WORD: we_byte = 4'b1111;
            default:        we_byte = 4'b1111;
        endcase
    end

    always_comb begin
        case (mem_width_i)
            MEM_WIDTH_BYTE: wdata = {4{data_i[7:0]}};
            MEM_WIDTH_HALF: wdata = {2{data_i[15:0]}};
            MEM_WIDTH_WORD: wdata = data_i;
            default:        wdata = data_i;
        endcase
    end

    // Impede escrita na RAM se o endereço pertencer ao espaço de I/O
    assign ram_write_en = mem_write_i & ~is_io_space & ram_addr_valid;

    always_ff @(posedge clk) begin
        if (ram_write_en) begin
            for (int b = 0; b < 4; b++)
                if (we_byte[b]) mem[word_addr][8*b +: 8] <= wdata[8*b +: 8];
        end
    end

    // Habilitação de escrita das saídas (offsets 0..3); entradas não são graváveis
    logic io_write_out0;
    logic io_write_out1;
    logic io_write_out2;
    logic io_write_out3;

    assign io_write_out0 = mem_write_i && is_io_space && (io_offset == 4'h0);
    assign io_write_out1 = mem_write_i && is_io_space && (io_offset == 4'h1);
    assign io_write_out2 = mem_write_i && is_io_space && (io_offset == 4'h2);
    assign io_write_out3 = mem_write_i && is_io_space && (io_offset == 4'h3);

    // Registradores síncronos das saídas
    initial begin
        io_out0_o = '0;
        io_out1_o = '0;
        io_out2_o = '0;
        io_out3_o = '0;
    end

    // Escrita por faixa de bytes (mesmos we_byte/wdata da RAM): SB/SH alteram
    // apenas os bytes enderecados.
    always_ff @(posedge clk) begin
        for (int b = 0; b < 4; b++) begin
            if (io_write_out0 && we_byte[b]) io_out0_o[8*b +: 8] <= wdata[8*b +: 8];
            if (io_write_out1 && we_byte[b]) io_out1_o[8*b +: 8] <= wdata[8*b +: 8];
            if (io_write_out2 && we_byte[b]) io_out2_o[8*b +: 8] <= wdata[8*b +: 8];
            if (io_write_out3 && we_byte[b]) io_out3_o[8*b +: 8] <= wdata[8*b +: 8];
        end
    end

    // =========================================================================
    // LEITURA DO MMIO: entradas em 0x10..0x1C; saídas (0x00..0x0C) leem 0
    // =========================================================================
    always_comb begin
        case (io_offset)
            4'h4:    io_data_out = io_in0_i;
            4'h5:    io_data_out = io_in1_i;
            4'h6:    io_data_out = io_in2_i;
            4'h7:    io_data_out = io_in3_i;
            default: io_data_out = 32'h0;
        endcase
    end

    // =========================================================================
    // MULTIPLEXADOR DE SAÍDA FINAL (Caminho Crítico Otimizado)
    // =========================================================================
    assign data_o = load_data;

    assign data_memory_data = data_o;

    // =========================================================================
    // write_back
    // =========================================================================
    // Portas (XLEN vem do core).
    logic [XLEN-1:0] alu_result_i;
    logic [XLEN-1:0] mem_data_i;
    logic            mem_to_reg_i;
    logic [XLEN-1:0] wb_data_o;

    assign alu_result_i = alu_result;
    assign mem_data_i   = data_memory_data;
    assign mem_to_reg_i = mem_to_reg;

    // ---- corpo copiado de write_back.sv ----
    always_comb begin
        case (mem_to_reg_i)
            1'b0:    wb_data_o = alu_result_i;
            1'b1:    wb_data_o = mem_data_i;
            default: wb_data_o = alu_result_i;
        endcase
    end

    assign write_back_data = wb_data_o;

endmodule
