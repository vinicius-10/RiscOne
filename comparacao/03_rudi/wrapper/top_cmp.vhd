-- top_cmp.vhd - top de medicao da comparacao do TCC (Rudi-RV32I, hamsternz)
--
-- Copia de src/systems/top_level_expanded.vhd do autor SEM bus_expander, UART, GPIO e
-- contador de ms: CPU + bus_bridge + program_memory (BRAM 4 KiB) + ram_memory (BRAM 4 KiB),
-- clock direto de 100 MHz. Mudancas de mapa de memoria (so as constantes de janela do
-- bus_bridge, para o programa do TCC enderecar dados em 0x0 e MMIO em 0x4000_0000):
--   m0 RAM     0x0000_0000 / 0xFFFF_F000   (autor: 0x1000_0000)
--   m1 ROM     0xF000_0000 / 0xFFFF_F000   (igual ao autor; reset vector = 0xF000_0000)
--   m2 MMIO    0x4000_0000 / 0xFFFF_FFE0   (autor: bus_expander em 0xE000_0000)
-- MMIO: escrita em m2 carrega led (registrador); leitura devolve as chaves.
-- Reset: CPU_RESETN invertido (no autor, shift register de power-on).
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_cmp is
  generic ( bus_bridge_use_clk : std_logic := '0';   -- '0' = sem ponte registrada (CPI 1, exceto loads)
            cpu_minimize_size  : std_logic := '0');  -- '0' = configuracao rapida do autor
  port ( clk        : in  STD_LOGIC;
         CPU_RESETN : in  STD_LOGIC;
         switch     : in  STD_LOGIC_VECTOR(15 downto 0);
         led        : out STD_LOGIC_VECTOR(15 downto 0) := (others => '0'));
end entity;

architecture Behavioral of top_cmp is

    component riscv_cpu is
          port ( clk           : in  STD_LOGIC;
                 pc_next       : out STD_LOGIC_VECTOR(31 downto 0);
                 reset         : in  STD_LOGIC;
                 minimize_size : in  STD_LOGIC;
                 bus_busy      : in  STD_LOGIC;
                 bus_addr      : out STD_LOGIC_VECTOR(31 downto 0);
                 bus_width     : out STD_LOGIC_VECTOR(1 downto 0);
                 bus_write     : out STD_LOGIC;
                 bus_enable    : out STD_LOGIC;
                 bus_dout      : out STD_LOGIC_VECTOR(31 downto 0);
                 bus_din       : in  STD_LOGIC_VECTOR(31 downto 0);
                 instr_reg     : in  STD_LOGIC_VECTOR(31 downto 0);
                 debug_pc      : out STD_LOGIC_VECTOR(31 downto 0);
                 debug_sel     : in  STD_LOGIC_VECTOR(4 downto 0);
                 debug_data    : out STD_LOGIC_VECTOR(31 downto 0));
    end component;

    component program_memory is
    port ( clk            : in  STD_LOGIC;
           pc_next        : in  STD_LOGIC_VECTOR(31 downto 0);
           instr_reg      : out STD_LOGIC_VECTOR(31 downto 0);
           bus_busy       : out STD_LOGIC;
           bus_addr       : in  STD_LOGIC_VECTOR(11 downto 2);
           bus_enable     : in  STD_LOGIC;
           bus_write_mask : in  STD_LOGIC_VECTOR(3 downto 0);
           bus_write_data : in  STD_LOGIC_VECTOR(31 downto 0);
           bus_read_data  : out STD_LOGIC_VECTOR(31 downto 0));
    end component;

    component ram_memory is
    port ( clk            : in  STD_LOGIC;
           bus_enable     : in  STD_LOGIC;
           bus_addr       : in  STD_LOGIC_VECTOR(11 downto 2);
           bus_write_mask : in  STD_LOGIC_VECTOR(3 downto 0);
           bus_write_data : in  STD_LOGIC_VECTOR(31 downto 0);
           bus_busy       : out STD_LOGIC;
           bus_read_data  : out STD_LOGIC_VECTOR(31 downto 0));
    end component;

    component bus_bridge is
    generic ( use_clk           : in  STD_LOGIC);
    port ( clk               : in  STD_LOGIC;
           cpu_bus_busy      : out STD_LOGIC;
           cpu_bus_addr      : in  STD_LOGIC_VECTOR(31 downto 0);
           cpu_bus_width     : in  STD_LOGIC_VECTOR( 1 downto 0);
           cpu_bus_dout      : in  STD_LOGIC_VECTOR(31 downto 0);
           cpu_bus_write     : in  STD_LOGIC;
           cpu_bus_enable    : in  STD_LOGIC;
           cpu_bus_din       : out STD_LOGIC_VECTOR(31 downto 0);
           m0_window_base    : in  STD_LOGIC_VECTOR(31 downto 0);
           m0_window_mask    : in  STD_LOGIC_VECTOR(31 downto 0);
           m0_bus_busy       : in  STD_LOGIC;
           m0_bus_addr       : out STD_LOGIC_VECTOR(31 downto 2);
           m0_bus_enable     : out STD_LOGIC;
           m0_bus_write_mask : out STD_LOGIC_VECTOR( 3 downto 0);
           m0_bus_write_data : out STD_LOGIC_VECTOR(31 downto 0);
           m0_bus_read_data  : in  STD_LOGIC_VECTOR(31 downto 0);
           m1_window_base    : in  STD_LOGIC_VECTOR(31 downto 0);
           m1_window_mask    : in  STD_LOGIC_VECTOR(31 downto 0);
           m1_bus_busy       : in  STD_LOGIC;
           m1_bus_addr       : out STD_LOGIC_VECTOR(31 downto 2);
           m1_bus_enable     : out STD_LOGIC;
           m1_bus_write_mask : out STD_LOGIC_VECTOR( 3 downto 0);
           m1_bus_write_data : out STD_LOGIC_VECTOR(31 downto 0);
           m1_bus_read_data  : in  STD_LOGIC_VECTOR(31 downto 0);
           m2_window_base    : in  STD_LOGIC_VECTOR(31 downto 0);
           m2_window_mask    : in  STD_LOGIC_VECTOR(31 downto 0);
           m2_bus_busy       : in  STD_LOGIC;
           m2_bus_addr       : out STD_LOGIC_VECTOR(31 downto 2);
           m2_bus_enable     : out STD_LOGIC;
           m2_bus_write_mask : out STD_LOGIC_VECTOR( 3 downto 0);
           m2_bus_write_data : out STD_LOGIC_VECTOR(31 downto 0);
           m2_bus_read_data  : in  STD_LOGIC_VECTOR(31 downto 0));
    end component;

    signal reset     : STD_LOGIC;
    signal pc_next   : STD_LOGIC_VECTOR(31 downto 0);
    signal instr_reg : STD_LOGIC_VECTOR(31 downto 0);

    signal cpu_bus_busy   : STD_LOGIC;
    signal cpu_bus_addr   : STD_LOGIC_VECTOR(31 downto 0);
    signal cpu_bus_width  : STD_LOGIC_VECTOR(1 downto 0);
    signal cpu_bus_write  : STD_LOGIC;
    signal cpu_bus_enable : STD_LOGIC;
    signal cpu_bus_dout   : STD_LOGIC_VECTOR(31 downto 0);
    signal cpu_bus_din    : STD_LOGIC_VECTOR(31 downto 0);

    signal m0_bus_busy, m1_bus_busy, m2_bus_busy       : STD_LOGIC;
    signal m0_bus_enable, m1_bus_enable, m2_bus_enable : STD_LOGIC;
    signal m0_bus_addr, m1_bus_addr, m2_bus_addr       : STD_LOGIC_VECTOR(31 downto 2);
    signal m0_bus_write_mask, m1_bus_write_mask, m2_bus_write_mask : STD_LOGIC_VECTOR(3 downto 0);
    signal m0_bus_write_data, m1_bus_write_data, m2_bus_write_data : STD_LOGIC_VECTOR(31 downto 0);
    signal m0_bus_read_data, m1_bus_read_data, m2_bus_read_data    : STD_LOGIC_VECTOR(31 downto 0);
begin

    reset <= not CPU_RESETN;

i_riscv_cpu: riscv_cpu port map (
       clk           => clk,
       instr_reg     => instr_reg,
       reset         => reset,
       minimize_size => cpu_minimize_size,
       bus_busy      => cpu_bus_busy,
       bus_addr      => cpu_bus_addr,
       bus_width     => cpu_bus_width,
       bus_write     => cpu_bus_write,
       bus_enable    => cpu_bus_enable,
       bus_dout      => cpu_bus_dout,
       bus_din       => cpu_bus_din,
       pc_next       => pc_next,
       debug_pc      => open,
       debug_sel     => "00000",
       debug_data    => open);

i_bus_bridge: bus_bridge generic map (use_clk => bus_bridge_use_clk) port map (
       clk               => clk,
       cpu_bus_busy      => cpu_bus_busy,
       cpu_bus_addr      => cpu_bus_addr,
       cpu_bus_width     => cpu_bus_width,
       cpu_bus_dout      => cpu_bus_dout,
       cpu_bus_write     => cpu_bus_write,
       cpu_bus_enable    => cpu_bus_enable,
       cpu_bus_din       => cpu_bus_din,
       -- RAM de dados
       m0_window_base    => x"00000000",
       m0_window_mask    => x"FFFFF000",
       m0_bus_busy       => m0_bus_busy,
       m0_bus_addr       => m0_bus_addr,
       m0_bus_enable     => m0_bus_enable,
       m0_bus_write_mask => m0_bus_write_mask,
       m0_bus_write_data => m0_bus_write_data,
       m0_bus_read_data  => m0_bus_read_data,
       -- Memoria de programa
       m1_window_base    => x"F0000000",
       m1_window_mask    => x"FFFFF000",
       m1_bus_busy       => m1_bus_busy,
       m1_bus_addr       => m1_bus_addr,
       m1_bus_enable     => m1_bus_enable,
       m1_bus_write_mask => m1_bus_write_mask,
       m1_bus_write_data => m1_bus_write_data,
       m1_bus_read_data  => m1_bus_read_data,
       -- MMIO minimo (LEDs / chaves)
       m2_window_base    => x"40000000",
       m2_window_mask    => x"FFFFFFE0",
       m2_bus_busy       => m2_bus_busy,
       m2_bus_addr       => m2_bus_addr,
       m2_bus_enable     => m2_bus_enable,
       m2_bus_write_mask => m2_bus_write_mask,
       m2_bus_write_data => m2_bus_write_data,
       m2_bus_read_data  => m2_bus_read_data);

i_ram_memory: ram_memory port map (
       clk            => clk,
       bus_enable     => m0_bus_enable,
       bus_addr       => m0_bus_addr(11 downto 2),
       bus_busy       => m0_bus_busy,
       bus_write_mask => m0_bus_write_mask,
       bus_write_data => m0_bus_write_data,
       bus_read_data  => m0_bus_read_data);

i_program_memory: program_memory port map (
       clk            => clk,
       pc_next        => pc_next,
       instr_reg      => instr_reg,
       bus_enable     => m1_bus_enable,
       bus_addr       => m1_bus_addr(11 downto 2),
       bus_busy       => m1_bus_busy,
       bus_write_mask => m1_bus_write_mask,
       bus_write_data => m1_bus_write_data,
       bus_read_data  => m1_bus_read_data);

    -- MMIO minimo: sem espera, escrita registra os LEDs, leitura devolve as chaves
    m2_bus_busy      <= '0';
    m2_bus_read_data <= x"0000" & switch;

process(clk)
   begin
      if rising_edge(clk) then
         if m2_bus_enable = '1' and m2_bus_write_mask /= "0000" then
            led <= m2_bus_write_data(15 downto 0);
         end if;
      end if;
   end process;

end Behavioral;
