--Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2018.3 (lin64) Build 2405991 Thu Dec  6 23:36:41 MST 2018
--Date        : Wed May  8 14:16:44 2019
--Host        : L-CHROTZ1NB107H63 running 64-bit Ubuntu 18.04.2 LTS
--Command     : generate_target system_wrapper.bd
--Design      : system_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity system_top is
  port (
    ddr3_sdram_addr : out STD_LOGIC_VECTOR ( 13 downto 0 );
    ddr3_sdram_ba : out STD_LOGIC_VECTOR ( 2 downto 0 );
    ddr3_sdram_cas_n : out STD_LOGIC;
    ddr3_sdram_ck_n : out STD_LOGIC_VECTOR ( 0 to 0 );
    ddr3_sdram_ck_p : out STD_LOGIC_VECTOR ( 0 to 0 );
    ddr3_sdram_cke : out STD_LOGIC_VECTOR ( 0 to 0 );
    ddr3_sdram_cs_n : out STD_LOGIC_VECTOR ( 0 to 0 );
    ddr3_sdram_dm : out STD_LOGIC_VECTOR ( 1 downto 0 );
    ddr3_sdram_dq : inout STD_LOGIC_VECTOR ( 15 downto 0 );
    ddr3_sdram_dqs_n : inout STD_LOGIC_VECTOR ( 1 downto 0 );
    ddr3_sdram_dqs_p : inout STD_LOGIC_VECTOR ( 1 downto 0 );
    ddr3_sdram_odt : out STD_LOGIC_VECTOR ( 0 to 0 );
    ddr3_sdram_ras_n : out STD_LOGIC;
    ddr3_sdram_reset_n : out STD_LOGIC;
    ddr3_sdram_we_n : out STD_LOGIC;
    eth0_mdio_mdc : out STD_LOGIC;
    eth0_mdio_mdio_io : inout STD_LOGIC;
    eth0_mii_col : in STD_LOGIC;
    eth0_mii_crs : in STD_LOGIC;
    eth0_mii_rst_n : out STD_LOGIC;
    eth0_mii_rx_clk : in STD_LOGIC;
    eth0_mii_rx_dv : in STD_LOGIC;
    eth0_mii_rx_er : in STD_LOGIC;
    eth0_mii_rxd : in STD_LOGIC_VECTOR ( 3 downto 0 );
    eth0_mii_tx_clk : in STD_LOGIC;
    eth0_mii_tx_en : out STD_LOGIC;
    eth0_mii_txd : out STD_LOGIC_VECTOR ( 3 downto 0 );
    eth0_ref_clk : out STD_LOGIC;
    gpio_0_leds : out STD_LOGIC_VECTOR ( 3 downto 0 );
    qspi_flash_io : inout STD_LOGIC_VECTOR ( 1 downto 0 );
    qspi_flash_ss : inout STD_LOGIC_VECTOR ( 0 downto 0 );
    i_clk : in STD_LOGIC;
    usb_uart_rxd : in STD_LOGIC;
    usb_uart_txd : out STD_LOGIC;
    i_switch : in STD_LOGIC_VECTOR ( 3 downto 0 )
  );
end system_top;

architecture STRUCTURE of system_top is
  component system is
  port (
    i_clk : in STD_LOGIC;
    eth0_ref_clk : out STD_LOGIC;
    gpio_0_leds : out STD_LOGIC_VECTOR ( 3 downto 0 );
    ddr3_sdram_dq : inout STD_LOGIC_VECTOR ( 15 downto 0 );
    ddr3_sdram_dqs_p : inout STD_LOGIC_VECTOR ( 1 downto 0 );
    ddr3_sdram_dqs_n : inout STD_LOGIC_VECTOR ( 1 downto 0 );
    ddr3_sdram_addr : out STD_LOGIC_VECTOR ( 13 downto 0 );
    ddr3_sdram_ba : out STD_LOGIC_VECTOR ( 2 downto 0 );
    ddr3_sdram_ras_n : out STD_LOGIC;
    ddr3_sdram_cas_n : out STD_LOGIC;
    ddr3_sdram_we_n : out STD_LOGIC;
    ddr3_sdram_reset_n : out STD_LOGIC;
    ddr3_sdram_ck_p : out STD_LOGIC_VECTOR ( 0 to 0 );
    ddr3_sdram_ck_n : out STD_LOGIC_VECTOR ( 0 to 0 );
    ddr3_sdram_cke : out STD_LOGIC_VECTOR ( 0 to 0 );
    ddr3_sdram_cs_n : out STD_LOGIC_VECTOR ( 0 to 0 );
    ddr3_sdram_dm : out STD_LOGIC_VECTOR ( 1 downto 0 );
    ddr3_sdram_odt : out STD_LOGIC_VECTOR ( 0 to 0 );
    eth0_mdio_mdc : out STD_LOGIC;
    eth0_mdio_mdio_i : in STD_LOGIC;
    eth0_mdio_mdio_o : out STD_LOGIC;
    eth0_mdio_mdio_t : out STD_LOGIC;
    eth0_mii_col : in STD_LOGIC;
    eth0_mii_crs : in STD_LOGIC;
    eth0_mii_rst_n : out STD_LOGIC;
    eth0_mii_rx_clk : in STD_LOGIC;
    eth0_mii_rx_dv : in STD_LOGIC;
    eth0_mii_rx_er : in STD_LOGIC;
    eth0_mii_rxd : in STD_LOGIC_VECTOR ( 3 downto 0 );
    eth0_mii_tx_clk : in STD_LOGIC;
    eth0_mii_tx_en : out STD_LOGIC;
    eth0_mii_txd : out STD_LOGIC_VECTOR ( 3 downto 0 );
    usb_uart_rxd : in STD_LOGIC;
    usb_uart_txd : out STD_LOGIC;
    qspi_flash_io0_i : in STD_LOGIC;
    qspi_flash_io0_o : out STD_LOGIC;
    qspi_flash_io0_t : out STD_LOGIC;
    qspi_flash_io1_i : in STD_LOGIC;
    qspi_flash_io1_o : out STD_LOGIC;
    qspi_flash_io1_t : out STD_LOGIC;
    qspi_flash_sck_i : in STD_LOGIC;
    qspi_flash_sck_o : out STD_LOGIC;
    qspi_flash_sck_t : out STD_LOGIC;
    qspi_flash_ss_i : in STD_LOGIC_VECTOR ( 0 to 0 );
    qspi_flash_ss_o : out STD_LOGIC_VECTOR ( 0 to 0 );
    qspi_flash_ss_t : out STD_LOGIC;
    o_clk_main : out STD_LOGIC;
    i_switch : in STD_LOGIC_VECTOR ( 3 downto 0 )
  );
  end component system;
  component IOBUF is
  port (
    I : in STD_LOGIC;
    O : out STD_LOGIC;
    T : in STD_LOGIC;
    IO : inout STD_LOGIC
  );
  end component IOBUF;
  signal eth0_mdio_mdio_i : STD_LOGIC;
  signal eth0_mdio_mdio_o : STD_LOGIC;
  signal eth0_mdio_mdio_t : STD_LOGIC;

  signal qspi_flash_io_i : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal qspi_flash_io_o : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal qspi_flash_io_t : STD_LOGIC_VECTOR ( 1 downto 0 );

  signal qspi_flash_sck: STD_LOGIC;
  signal qspi_flash_ss_i : STD_LOGIC_VECTOR ( 0 to 0 );
  signal qspi_flash_ss_o : STD_LOGIC_VECTOR ( 0 to 0 );
  signal qspi_flash_ss_t : STD_LOGIC;

  signal clk : std_logic;
  signal startup_eos : std_logic;

  component STARTUPE2
  generic
  (
     PROG_USR      : string;
     SIM_CCLK_FREQ : real
  );
  port
  (
     USRCCLKO  : in std_logic;
     ----------
     CFGCLK    : out std_logic;
     CFGMCLK   : out std_logic;
     EOS       : out std_logic;
     PREQ      : out std_logic;
     ----------
     CLK       : in std_logic;
     GSR       : in std_logic;
     GTS       : in std_logic;
     KEYCLEARB : in std_logic;
     PACK      : in std_logic;
     USRCCLKTS : in std_logic;
     USRDONEO  : in std_logic;
     USRDONETS : in std_logic
  );
  end component;


begin

system_i: component system
     port map (
      ddr3_sdram_addr(13 downto 0) => ddr3_sdram_addr(13 downto 0),
      ddr3_sdram_ba(2 downto 0) => ddr3_sdram_ba(2 downto 0),
      ddr3_sdram_cas_n => ddr3_sdram_cas_n,
      ddr3_sdram_ck_n(0) => ddr3_sdram_ck_n(0),
      ddr3_sdram_ck_p(0) => ddr3_sdram_ck_p(0),
      ddr3_sdram_cke(0) => ddr3_sdram_cke(0),
      ddr3_sdram_cs_n(0) => ddr3_sdram_cs_n(0),
      ddr3_sdram_dm(1 downto 0) => ddr3_sdram_dm(1 downto 0),
      ddr3_sdram_dq(15 downto 0) => ddr3_sdram_dq(15 downto 0),
      ddr3_sdram_dqs_n(1 downto 0) => ddr3_sdram_dqs_n(1 downto 0),
      ddr3_sdram_dqs_p(1 downto 0) => ddr3_sdram_dqs_p(1 downto 0),
      ddr3_sdram_odt(0) => ddr3_sdram_odt(0),
      ddr3_sdram_ras_n => ddr3_sdram_ras_n,
      ddr3_sdram_reset_n => ddr3_sdram_reset_n,
      ddr3_sdram_we_n => ddr3_sdram_we_n,
      eth0_mdio_mdc => eth0_mdio_mdc,
      eth0_mdio_mdio_i => eth0_mdio_mdio_i,
      eth0_mdio_mdio_o => eth0_mdio_mdio_o,
      eth0_mdio_mdio_t => eth0_mdio_mdio_t,
      eth0_mii_col => eth0_mii_col,
      eth0_mii_crs => eth0_mii_crs,
      eth0_mii_rst_n => eth0_mii_rst_n,
      eth0_mii_rx_clk => eth0_mii_rx_clk,
      eth0_mii_rx_dv => eth0_mii_rx_dv,
      eth0_mii_rx_er => eth0_mii_rx_er,
      eth0_mii_rxd(3 downto 0) => eth0_mii_rxd(3 downto 0),
      eth0_mii_tx_clk => eth0_mii_tx_clk,
      eth0_mii_tx_en => eth0_mii_tx_en,
      eth0_mii_txd(3 downto 0) => eth0_mii_txd(3 downto 0),
      eth0_ref_clk => eth0_ref_clk,
      gpio_0_leds(3 downto 0) => gpio_0_leds(3 downto 0),
      qspi_flash_io0_i => qspi_flash_io_i(0),
      qspi_flash_io0_o => qspi_flash_io_o(0),
      qspi_flash_io0_t => qspi_flash_io_t(0),
      qspi_flash_io1_i => qspi_flash_io_i(1),
      qspi_flash_io1_o => qspi_flash_io_o(1),
      qspi_flash_io1_t => qspi_flash_io_t(1),
      qspi_flash_sck_i => qspi_flash_sck,
      qspi_flash_sck_o => qspi_flash_sck,
      qspi_flash_sck_t => open,
      qspi_flash_ss_i(0) => qspi_flash_ss_i(0),
      qspi_flash_ss_o(0) => qspi_flash_ss_o(0),
      qspi_flash_ss_t => qspi_flash_ss_t,
      i_clk => i_clk,
      usb_uart_rxd => usb_uart_rxd,
      usb_uart_txd => usb_uart_txd,
      o_clk_main => clk,
      i_switch => i_switch
    );


eth0_mdio_mdio_iobuf: component IOBUF
     port map (
      I => eth0_mdio_mdio_o,
      IO => eth0_mdio_mdio_io,
      O => eth0_mdio_mdio_i,
      T => eth0_mdio_mdio_t
    );


-------------------------------- FLASH ----------------------------------------

  I_FLASH_IOBUF_IO_GEN: for I in 0 to 1 generate
  begin
      INST: component IOBUF
      port map (
        I => qspi_flash_io_o(I),
        IO => qspi_flash_io(I),
        O => qspi_flash_io_i(I),
        T => qspi_flash_io_t(I)
      );
  end generate;

  I_FLASH_IOBUF_SS: component IOBUF
  port map (
    I => qspi_flash_ss_o(0),
    IO => qspi_flash_ss(0),
    O => qspi_flash_ss_i(0),
    T => qspi_flash_ss_t
  );

  I_STARTUPE2 : component STARTUPE2
  generic map
  (
    PROG_USR      => "FALSE", -- Activate program event security feature.
    SIM_CCLK_FREQ => 0.0      -- Set the Configuration Clock Frequency(ns) for simulation.
  )
  port map
  (
    USRCCLKO  => qspi_flash_sck,      -- SRCCLKO      , -- 1-bit input: User CCLK input
    ----------
    CFGCLK    => open, --CFGCLK,       -- FGCLK        , -- 1-bit output: Configuration main clock output
    CFGMCLK   => open, --CFGMCLK,       -- FGMCLK       , -- 1-bit output: Configuration internal oscillator clock output
    EOS       => startup_eos, -- OS           , -- 1-bit output: Active high output signal indicating the End Of Startup.
    PREQ      => open, --PREQ_int,       -- REQ          , -- 1-bit output: PROGRAM request to fabric output
    ----------
    CLK       => '0',        -- LK           , -- 1-bit input: User start-up clock input
    GSR       => '0',        -- SR           , -- 1-bit input: Global Set/Reset input (GSR cannot be used for the port name)
    GTS       => '0',        -- TS           , -- 1-bit input: Global 3-state input (GTS cannot be used for the port name)
    KEYCLEARB => '0',        -- EYCLEARB     , -- 1-bit input: Clear AES Decrypter Key input from Battery-Backed RAM (BBRAM)
    PACK      => '1',        -- ACK          , -- 1-bit input: PROGRAM acknowledge input
    USRCCLKTS => '0',        -- SRCCLKTS     , -- 1-bit input: User CCLK 3-state enable input
    USRDONEO  => '1',        -- SRDONEO      , -- 1-bit input: User DONE pin output control
    USRDONETS => '1'         -- SRDONETS       -- 1-bit input: User DONE 3-state enable output
  );


--   inst_debug: if (false) generate
--      component ila_0
--      port (
--         clk : in std_logic;
--         probe0 : in std_logic_vector(4 downto 0)
--      );
--      end component  ;

--      signal probe0 : std_logic_vector(4 downto 0) := (others => '0');
--      signal trig_gen : std_logic;

--   begin
--      proc_triggen : process(clk)
--        subtype T_COUNT is natural range 0 to 100;
--        variable count : T_COUNT := 0;
--      begin
--         if rising_edge(clk) then
--            if(count < T_COUNT'high) then
--               count := count + 1;
--               trig_gen <= '0';
--            else
--               count := 0;
--               trig_gen <= '1';
--            end if;
--         end if;
--      end process;

--      probe0(0) <= trig_gen; 
--      probe0(1) <= qspi_flash_ss_i(0);
--      probe0(2) <= qspi_flash_sck;
--      probe0(3) <= qspi_flash_io_i(0);
--      probe0(4) <= qspi_flash_io_i(1);

--      inst_ila : ila_0
--      port map (
--         clk => clk,
--         probe0 => probe0
--      );
--   end generate;


end STRUCTURE;
