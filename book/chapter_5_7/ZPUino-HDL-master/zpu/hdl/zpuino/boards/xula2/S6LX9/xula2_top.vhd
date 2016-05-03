--
--
--  ZPUINO implementation on XESS 'XuLa2' Board
-- 
--  Copyright 2014 Alvaro Lopes <alvieboy@alvie.com>
-- 
--  Version: 1.0
-- 
--  The FreeBSD license
--  
--  Redistribution and use in source and binary forms, with or without
--  modification, are permitted provided that the following conditions
--  are met:
--  
--  1. Redistributions of source code must retain the above copyright
--     notice, this list of conditions and the following disclaimer.
--  2. Redistributions in binary form must reproduce the above
--     copyright notice, this list of conditions and the following
--     disclaimer in the documentation and/or other materials
--     provided with the distribution.
--  
--  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY
--  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
--  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
--  PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
--  ZPU PROJECT OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
--  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
--  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
--  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
--  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
--  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
--  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--  
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.zpupkg.all;
use work.zpuinopkg.all;
use work.zpuino_config.all;
use work.zpu_config.all;
use work.pad.all;
use work.wishbonepkg.all;

entity xula2_top is
  port (
    fpgaClk_i:      in std_logic;

    -- Connection to the main SPI flash and SD card
    sclk_o:         out std_logic;
    miso_i:         in std_logic;
    mosi_o:         out std_logic;
    flashCs_bo:     out std_logic;
    usdflashCs_bo:  out std_logic;

    -- Prototype header connections
    chanClk_io:     inout std_logic;
    chan_io:        inout std_logic_vector(31 downto 0);

    -- SDRAM connections
    sdaddr_o:       out   std_logic_vector (12 downto 0);
    sdbs_o:         out   std_logic_vector (1 downto 0);
    sdcas_bo:       out   std_logic;
    sdcke_o:        out   std_logic;
    sdclk_o:        out   std_logic;
    sdce_bo:        out   std_logic;
    sddata_io:      inout std_logic_vector(15 downto 0);
    sddqml_o:       out std_logic;
    sddqmh_o:       out std_logic;
    sdras_bo:       out   std_logic;
    sdclkfb_i:      in std_logic;
    sdwe_bo:        out   std_logic
  );
end entity xula2_top;

architecture behave of xula2_top is

  component clkgen is
  port (
    clkin:  in std_logic;
    rstin:  in std_logic;
    clkout: out std_logic;
    clkout1: out std_logic;
    clkout2: out std_logic;
	  clk_1Mhz_out: out std_logic;
    rstout: out std_logic
  );
  end component;

  component zpuino_serialreset is
  generic (
    SYSTEM_CLOCK_MHZ: integer := 96
  );
  port (
    clk:      in std_logic;
    rx:       in std_logic;
    rstin:    in std_logic;
    rstout:   out std_logic
  );
  end component zpuino_serialreset;

  component wb_bootloader is
  port (
    wb_clk_i:   in std_logic;
    wb_rst_i:   in std_logic;

    wb_dat_o:   out std_logic_vector(31 downto 0);
    wb_adr_i:   in std_logic_vector(11 downto 2);
    wb_cyc_i:   in std_logic;
    wb_stb_i:   in std_logic;
    wb_ack_o:   out std_logic;
    wb_stall_o: out std_logic;

    wb2_dat_o:   out std_logic_vector(31 downto 0);
    wb2_adr_i:   in std_logic_vector(11 downto 2);
    wb2_cyc_i:   in std_logic;
    wb2_stb_i:   in std_logic;
    wb2_ack_o:   out std_logic;
    wb2_stall_o: out std_logic
  );
  end component;

  signal sysrst:      std_logic;
  signal sysclk:      std_logic;
  signal clkgen_rst:  std_logic;
  signal wb_clk_i:    std_logic;
  signal wb_rst_i:    std_logic;

  signal gpio_o:      std_logic_vector(zpuino_gpio_count-1 downto 0);
  signal gpio_t:      std_logic_vector(zpuino_gpio_count-1 downto 0);
  signal gpio_i:      std_logic_vector(zpuino_gpio_count-1 downto 0);

  constant spp_cap_in: std_logic_vector(zpuino_gpio_count-1 downto 0) :=
    "00" &
    "1111111111111111" &
    "1111111111111100";

  constant spp_cap_out: std_logic_vector(zpuino_gpio_count-1 downto 0) :=
    "00" &
    "1111111111111111" &
    "1111111111111100";

  -- I/O Signals
  signal slot_cyc:    slot_std_logic_type;
  signal slot_we:     slot_std_logic_type;
  signal slot_stb:    slot_std_logic_type;
  signal slot_read:   slot_cpuword_type;
  signal slot_write:  slot_cpuword_type;
  signal slot_address:slot_address_type;
  signal slot_ack:    slot_std_logic_type;
  signal slot_interrupt: slot_std_logic_type;

  -- 2nd SPI signals
  signal spi2_mosi:   std_logic;
  signal spi2_miso:   std_logic;
  signal spi2_sck:    std_logic;

  -- GPIO Periperal Pin Select
  signal gpio_spp_data: std_logic_vector(zpuino_gpio_count-1 downto 0);
  signal gpio_spp_read: std_logic_vector(zpuino_gpio_count-1 downto 0);

  -- Timer connections
  signal timers_interrupt:  std_logic_vector(1 downto 0);
  signal timers_pwm:        std_logic_vector(1 downto 0);

  -- Sigmadelta output
  signal sigmadelta_spp_data: std_logic_vector(1 downto 0);

  -- main SPI signals
  signal spi_pf_miso: std_logic;
  signal spi_pf_mosi: std_logic;
  signal spi_pf_sck:  std_logic;

  -- UART signals
  signal rx: std_logic;
  signal tx: std_logic;
  signal sysclk_sram_we, sysclk_sram_wen: std_ulogic;

  signal ram_wb_ack_o:       std_logic;
  signal ram_wb_dat_i:       std_logic_vector(wordSize-1 downto 0);
  signal ram_wb_dat_o:       std_logic_vector(wordSize-1 downto 0);
  signal ram_wb_adr_i:       std_logic_vector(maxAddrBitIncIO downto 0);
  signal ram_wb_cyc_i:       std_logic;
  signal ram_wb_stb_i:       std_logic;
  signal ram_wb_sel_i:       std_logic_vector(3 downto 0);
  signal ram_wb_we_i:        std_logic;
  signal ram_wb_stall_o:     std_logic;

  signal np_ram_wb_ack_o:       std_logic;
  signal np_ram_wb_dat_i:       std_logic_vector(wordSize-1 downto 0);
  signal np_ram_wb_dat_o:       std_logic_vector(wordSize-1 downto 0);
  signal np_ram_wb_adr_i:       std_logic_vector(maxAddrBitIncIO downto 0);
  signal np_ram_wb_cyc_i:       std_logic;
  signal np_ram_wb_stb_i:       std_logic;
  signal np_ram_wb_sel_i:       std_logic_vector(3 downto 0);
  signal np_ram_wb_we_i:        std_logic;

  signal sram_wb_ack_o:       std_logic;
  signal sram_wb_dat_i:       std_logic_vector(wordSize-1 downto 0);
  signal sram_wb_dat_o:       std_logic_vector(wordSize-1 downto 0);
  signal sram_wb_adr_i:       std_logic_vector(maxAddrBitIncIO downto 0);
  signal sram_wb_cyc_i:       std_logic;
  signal sram_wb_stb_i:       std_logic;
  signal sram_wb_we_i:        std_logic;
  signal sram_wb_sel_i:       std_logic_vector(3 downto 0);
  signal sram_wb_stall_o:     std_logic;

  signal rom_wb_ack_o:       std_logic;
  signal rom_wb_dat_o:       std_logic_vector(wordSize-1 downto 0);
  signal rom_wb_adr_i:       std_logic_vector(maxAddrBitIncIO downto 0);
  signal rom_wb_cyc_i:       std_logic;
  signal rom_wb_stb_i:       std_logic;
  signal rom_wb_cti_i:       std_logic_vector(2 downto 0);
  signal rom_wb_stall_o:     std_logic;

  signal sram_rom_wb_ack_o:       std_logic;
  signal sram_rom_wb_dat_o:       std_logic_vector(wordSize-1 downto 0);
  signal sram_rom_wb_adr_i:       std_logic_vector(maxAddrBit downto 2);
  signal sram_rom_wb_cyc_i:       std_logic;
  signal sram_rom_wb_stb_i:       std_logic;
  signal sram_rom_wb_cti_i:       std_logic_vector(2 downto 0);
  signal sram_rom_wb_stall_o:     std_logic;

  signal prom_rom_wb_ack_o:       std_logic;
  signal prom_rom_wb_dat_o:       std_logic_vector(wordSize-1 downto 0);
  signal prom_rom_wb_adr_i:       std_logic_vector(maxAddrBit downto 2);
  signal prom_rom_wb_cyc_i:       std_logic;
  signal prom_rom_wb_stb_i:       std_logic;
  signal prom_rom_wb_cti_i:       std_logic_vector(2 downto 0);
  signal prom_rom_wb_stall_o:     std_logic;

  signal memory_enable: std_logic;

  component sdram_ctrl is
  port (
    wb_clk_i: in std_logic;
	 	wb_rst_i: in std_logic;

    wb_dat_o: out std_logic_vector(31 downto 0);
    wb_dat_i: in std_logic_vector(31 downto 0);
    wb_adr_i: in std_logic_vector(maxIOBit downto minIOBit);
    wb_we_i:  in std_logic;
    wb_cyc_i: in std_logic;
    wb_stb_i: in std_logic;
    wb_sel_i: in std_logic_vector(3 downto 0);
    wb_ack_o: out std_logic;
    wb_stall_o: out std_logic;

    -- extra clocking
    clk_off_3ns: in std_logic;

    -- SDRAM signals
     DRAM_ADDR   : OUT   STD_LOGIC_VECTOR (11 downto 0);
     DRAM_BA      : OUT   STD_LOGIC_VECTOR (1 downto 0);
     DRAM_CAS_N   : OUT   STD_LOGIC;
     DRAM_CKE      : OUT   STD_LOGIC;
     DRAM_CLK      : OUT   STD_LOGIC;
     DRAM_CS_N   : OUT   STD_LOGIC;
     DRAM_DQ      : INOUT STD_LOGIC_VECTOR(15 downto 0);
     DRAM_DQM      : OUT   STD_LOGIC_VECTOR(1 downto 0);
     DRAM_RAS_N   : OUT   STD_LOGIC;
     DRAM_WE_N    : OUT   STD_LOGIC
  
  );
  end component sdram_ctrl;

  component wb_master_np_to_slave_p is
  generic (
    ADDRESS_HIGH: integer := maxIObit;
    ADDRESS_LOW: integer := maxIObit
  );
  port (
    wb_clk_i: in std_logic;
	 	wb_rst_i: in std_logic;

    -- Master signals

    m_wb_dat_o: out std_logic_vector(31 downto 0);
    m_wb_dat_i: in std_logic_vector(31 downto 0);
    m_wb_adr_i: in std_logic_vector(ADDRESS_HIGH downto ADDRESS_LOW);
    m_wb_sel_i: in std_logic_vector(3 downto 0);
    m_wb_cti_i: in std_logic_vector(2 downto 0);
    m_wb_we_i:  in std_logic;
    m_wb_cyc_i: in std_logic;
    m_wb_stb_i: in std_logic;
    m_wb_ack_o: out std_logic;

    -- Slave signals

    s_wb_dat_i: in std_logic_vector(31 downto 0);
    s_wb_dat_o: out std_logic_vector(31 downto 0);
    s_wb_adr_o: out std_logic_vector(ADDRESS_HIGH downto ADDRESS_LOW);
    s_wb_sel_o: out std_logic_vector(3 downto 0);
    s_wb_cti_o: out std_logic_vector(2 downto 0);
    s_wb_we_o:  out std_logic;
    s_wb_cyc_o: out std_logic;
    s_wb_stb_o: out std_logic;
    s_wb_ack_i: in std_logic;
    s_wb_stall_i: in std_logic
  );
  end component;

  component wb_sid6581 is
  port (
    wb_clk_i: in std_logic;
    wb_rst_i: in std_logic;
    wb_dat_o: out std_logic_vector(wordSize-1 downto 0);
    wb_dat_i: in std_logic_vector(wordSize-1 downto 0);
    wb_adr_i: in std_logic_vector(maxIObit downto minIObit);
    wb_we_i:  in std_logic;
    wb_cyc_i: in std_logic;
    wb_stb_i: in std_logic;
    wb_ack_o: out std_logic;
    wb_inta_o:out std_logic;

    clk_1MHZ: in std_logic;
    audio_data: out std_logic_vector(17 downto 0)

  );
  end component wb_sid6581;
  
	COMPONENT zpuino_io_YM2149
	PORT(
		wb_clk_i : IN std_logic;
		wb_rst_i : IN std_logic;
		wb_dat_i : IN std_logic_vector(31 downto 0);
		wb_adr_i : IN std_logic_vector(26 downto 2);
		wb_we_i : IN std_logic;
		wb_cyc_i : IN std_logic;
		wb_stb_i : IN std_logic;          
		wb_dat_o : OUT std_logic_vector(31 downto 0);
		wb_ack_o : OUT std_logic;
		wb_inta_o : OUT std_logic;
		data_out : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;

	COMPONENT zpuino_io_audiomixer
	PORT(
		clk : IN std_logic;
		rst : IN std_logic;
		ena : IN std_logic;
		data_in1 : IN std_logic_vector(17 downto 0);
		data_in2 : IN std_logic_vector(17 downto 0);
		data_in3 : IN std_logic_vector(17 downto 0);          
		audio_out : OUT std_logic
		);
	END COMPONENT;	
	
  component clkgen_sid is
  port (
    clkin:  in std_logic;
    rstin:  in std_logic;
    clkout: out std_logic;
    clkout_1mhz: out std_logic;
    rstout: out std_logic
  );
  end component clkgen_sid;	

  signal sid_audio_data, ym2149_audio_dac: std_logic_vector(17 downto 0);
  signal sid_audio: std_logic;
  
  signal ym2149_audio_data, pokey_audio_data: std_logic_vector(7 downto 0);
  signal platform_audio_sd: std_logic; 
  signal sigmadelta_raw: std_logic_vector(17 downto 0);  
  
  signal uart2_tx, uart2_rx: std_logic;  
  
  signal sigmadelta_spp_en:  std_logic_vector(1 downto 0);
  signal sysclk_1mhz: std_logic;  

begin


  wb_clk_i <= sysclk;
  wb_rst_i <= sysrst;

  rstgen: zpuino_serialreset
    generic map (
      SYSTEM_CLOCK_MHZ  => 96
    )
    port map (
      clk       => sysclk,
      rx        => rx,
      rstin     => clkgen_rst,
      rstout    => sysrst
    );

  clkgen_inst: clkgen
  port map (
    clkin   => fpgaClk_i,
    rstin   => '0'  ,
    clkout  => sysclk,
    clkout1  => sysclk_sram_we,
    clkout2  => sysclk_sram_wen,
	  --clk_1Mhz_out => sysclk_1mhz,
    rstout  => clkgen_rst
  );

  ibufrx:   IPAD port map ( PAD => chan_io(0),        O => rx,           C => sysclk );
  obuftx:   OPAD port map ( I => tx,           PAD => chan_io(1) );

  pin00: IOPAD port map(I => gpio_o(0),O => gpio_i(0),T => gpio_t(0),C => sysclk,PAD => chanClk_io );
  --pin01: IOPAD port map(I => gpio_o(1),O => gpio_i(1),T => gpio_t(1),C => sysclk,PAD => chan_io(1) );
  pin02: IOPAD port map(I => gpio_o(2),O => gpio_i(2),T => gpio_t(2),C => sysclk,PAD => chan_io(2) );
  pin03: IOPAD port map(I => gpio_o(3),O => gpio_i(3),T => gpio_t(3),C => sysclk,PAD => chan_io(3) );
  pin04: IOPAD port map(I => gpio_o(4),O => gpio_i(4),T => gpio_t(4),C => sysclk,PAD => chan_io(4) );
  pin05: IOPAD port map(I => gpio_o(5),O => gpio_i(5),T => gpio_t(5),C => sysclk,PAD => chan_io(5) );
  pin06: IOPAD port map(I => gpio_o(6),O => gpio_i(6),T => gpio_t(6),C => sysclk,PAD => chan_io(6) );
  pin07: IOPAD port map(I => gpio_o(7),O => gpio_i(7),T => gpio_t(7),C => sysclk,PAD => chan_io(7) );
  pin08: IOPAD port map(I => gpio_o(8),O => gpio_i(8),T => gpio_t(8),C => sysclk,PAD => chan_io(8) );
  pin09: IOPAD port map(I => gpio_o(9),O => gpio_i(9),T => gpio_t(9),C => sysclk,PAD => chan_io(9) );
  pin10: IOPAD port map(I => gpio_o(10),O => gpio_i(10),T => gpio_t(10),C => sysclk,PAD => chan_io(10) );
  pin11: IOPAD port map(I => gpio_o(11),O => gpio_i(11),T => gpio_t(11),C => sysclk,PAD => chan_io(11) );
  pin12: IOPAD port map(I => gpio_o(12),O => gpio_i(12),T => gpio_t(12),C => sysclk,PAD => chan_io(12) );
  pin13: IOPAD port map(I => gpio_o(13),O => gpio_i(13),T => gpio_t(13),C => sysclk,PAD => chan_io(13) );
  pin14: IOPAD port map(I => gpio_o(14),O => gpio_i(14),T => gpio_t(14),C => sysclk,PAD => chan_io(14) );
  pin15: IOPAD port map(I => gpio_o(15),O => gpio_i(15),T => gpio_t(15),C => sysclk,PAD => chan_io(15) );
  pin16: IOPAD port map(I => gpio_o(16),O => gpio_i(16),T => gpio_t(16),C => sysclk,PAD => chan_io(16) );
  pin17: IOPAD port map(I => gpio_o(17),O => gpio_i(17),T => gpio_t(17),C => sysclk,PAD => chan_io(17) );
  pin18: IOPAD port map(I => gpio_o(18),O => gpio_i(18),T => gpio_t(18),C => sysclk,PAD => chan_io(18) );
  pin19: IOPAD port map(I => gpio_o(19),O => gpio_i(19),T => gpio_t(19),C => sysclk,PAD => chan_io(19) );
  pin20: IOPAD port map(I => gpio_o(20),O => gpio_i(20),T => gpio_t(20),C => sysclk,PAD => chan_io(20) );
  pin21: IOPAD port map(I => gpio_o(21),O => gpio_i(21),T => gpio_t(21),C => sysclk,PAD => chan_io(21) );
  pin22: IOPAD port map(I => gpio_o(22),O => gpio_i(22),T => gpio_t(22),C => sysclk,PAD => chan_io(22) );
  pin23: IOPAD port map(I => gpio_o(23),O => gpio_i(23),T => gpio_t(23),C => sysclk,PAD => chan_io(23) );
  pin24: IOPAD port map(I => gpio_o(24),O => gpio_i(24),T => gpio_t(24),C => sysclk,PAD => chan_io(24) );
  pin25: IOPAD port map(I => gpio_o(25),O => gpio_i(25),T => gpio_t(25),C => sysclk,PAD => chan_io(25) );
  pin26: IOPAD port map(I => gpio_o(26),O => gpio_i(26),T => gpio_t(26),C => sysclk,PAD => chan_io(26) );
  pin27: IOPAD port map(I => gpio_o(27),O => gpio_i(27),T => gpio_t(27),C => sysclk,PAD => chan_io(27) );
  pin28: IOPAD port map(I => gpio_o(28),O => gpio_i(28),T => gpio_t(28),C => sysclk,PAD => chan_io(28) );
  pin29: IOPAD port map(I => gpio_o(29),O => gpio_i(29),T => gpio_t(29),C => sysclk,PAD => chan_io(29) );
  pin30: IOPAD port map(I => gpio_o(30),O => gpio_i(30),T => gpio_t(30),C => sysclk,PAD => chan_io(30) );
  pin31: IOPAD port map(I => gpio_o(31),O => gpio_i(31),T => gpio_t(31),C => sysclk,PAD => chan_io(31) );


  ibufmiso: IPAD port map ( PAD => miso_i,   O => spi_pf_miso,  C => sysclk );

  ospiclk:  OPAD port map ( I => spi_pf_sck,   PAD => sclk_o );
  ospics:   OPAD port map ( I => gpio_o(32),   PAD => flashCs_bo );
  osdpics:  OPAD port map ( I => gpio_o(33),   PAD => usdflashCs_bo );
  ospimosi: OPAD port map ( I => spi_pf_mosi,  PAD => mosi_o );

  zpuino:zpuino_top_icache
    port map (
      clk           => sysclk,
	 	  rst           => sysrst,

      slot_cyc      => slot_cyc,
      slot_we       => slot_we,
      slot_stb      => slot_stb,
      slot_read     => slot_read,
      slot_write    => slot_write,
      slot_address  => slot_address,
      slot_ack      => slot_ack,
      slot_interrupt=> slot_interrupt,

      m_wb_dat_o    => open,
      m_wb_dat_i    => (others => 'X'),
      m_wb_adr_i    => (others => 'X'),
      m_wb_we_i     => '0',
      m_wb_cyc_i    => '0',
      m_wb_stb_i    => '0',
      m_wb_ack_o    => open,

      memory_enable => memory_enable,

      ram_wb_ack_i      => np_ram_wb_ack_o,
      ram_wb_stall_i    => '0',--np_ram_wb_stall_o,
      ram_wb_dat_o      => np_ram_wb_dat_i,
      ram_wb_dat_i      => np_ram_wb_dat_o,
      ram_wb_adr_o      => np_ram_wb_adr_i(maxAddrBit downto 0),
      ram_wb_cyc_o      => np_ram_wb_cyc_i,
      ram_wb_stb_o      => np_ram_wb_stb_i,
      ram_wb_sel_o      => np_ram_wb_sel_i,
      ram_wb_we_o       => np_ram_wb_we_i,

      rom_wb_ack_i      => rom_wb_ack_o,
      rom_wb_stall_i      => rom_wb_stall_o,
      rom_wb_dat_i      => rom_wb_dat_o,
      rom_wb_adr_o      => rom_wb_adr_i(maxAddrBit downto 0),
      rom_wb_cyc_o      => rom_wb_cyc_i,
      rom_wb_stb_o      => rom_wb_stb_i,


      -- No debug unit connected
      dbg_reset     => open,
      jtag_data_chain_out => open,            --jtag_data_chain_in,
      jtag_ctrl_chain_in  => (others => '0') --jtag_ctrl_chain_out
      );

  memarb: wbarb2_1
  generic map (
    ADDRESS_HIGH => maxAddrBit,
    ADDRESS_LOW => 2
  )
  port map (
    wb_clk_i      => wb_clk_i,
    wb_rst_i      => wb_rst_i,

    m0_wb_dat_o   => ram_wb_dat_o,
    m0_wb_dat_i   => ram_wb_dat_i,
    m0_wb_adr_i   => ram_wb_adr_i(maxAddrBit downto 2),
    m0_wb_sel_i   => ram_wb_sel_i,
    m0_wb_cti_i   => CTI_CYCLE_CLASSIC,
    m0_wb_we_i    => ram_wb_we_i,
    m0_wb_cyc_i   => ram_wb_cyc_i,
    m0_wb_stb_i   => ram_wb_stb_i,
    m0_wb_ack_o   => ram_wb_ack_o,
    m0_wb_stall_o => ram_wb_stall_o,

    m1_wb_dat_o   => sram_rom_wb_dat_o,
    m1_wb_dat_i   => (others => DontCareValue),
    m1_wb_adr_i   => sram_rom_wb_adr_i(maxAddrBit downto 2),
    m1_wb_sel_i   => (others => '1'),
    m1_wb_cti_i   => CTI_CYCLE_CLASSIC,
    m1_wb_we_i    => '0',--rom_wb_we_i,
    m1_wb_cyc_i   => sram_rom_wb_cyc_i,
    m1_wb_stb_i   => sram_rom_wb_stb_i,
    m1_wb_ack_o   => sram_rom_wb_ack_o,
    m1_wb_stall_o => sram_rom_wb_stall_o,

    s0_wb_dat_i   => sram_wb_dat_o,
    s0_wb_dat_o   => sram_wb_dat_i,
    s0_wb_adr_o   => sram_wb_adr_i(maxAddrBit downto 2),
    s0_wb_sel_o   => sram_wb_sel_i,
    s0_wb_cti_o   => open,
    s0_wb_we_o    => sram_wb_we_i,
    s0_wb_cyc_o   => sram_wb_cyc_i,
    s0_wb_stb_o   => sram_wb_stb_i,
    s0_wb_ack_i   => sram_wb_ack_o,
    s0_wb_stall_i => sram_wb_stall_o
  );

  bootmux: wbbootloadermux
  generic map (
    address_high  => maxAddrBit
  )
  port map (
    wb_clk_i      => wb_clk_i,
	 	wb_rst_i      => wb_rst_i,

    sel           => memory_enable,

    -- Master 

    m_wb_dat_o    => rom_wb_dat_o,
    m_wb_dat_i    => (others => DontCareValue),
    m_wb_adr_i    => rom_wb_adr_i(maxAddrBit downto 2),
    m_wb_sel_i    => (others => '1'),
    m_wb_cti_i    => CTI_CYCLE_CLASSIC,
    m_wb_we_i     => '0',
    m_wb_cyc_i    => rom_wb_cyc_i,
    m_wb_stb_i    => rom_wb_stb_i,
    m_wb_ack_o    => rom_wb_ack_o,
    m_wb_stall_o  => rom_wb_stall_o,

    -- Slave 0 signals

    s0_wb_dat_i   => sram_rom_wb_dat_o,
    s0_wb_dat_o   => open,
    s0_wb_adr_o   => sram_rom_wb_adr_i,
    s0_wb_sel_o   => open,
    s0_wb_cti_o   => open,
    s0_wb_we_o    => open,
    s0_wb_cyc_o   => sram_rom_wb_cyc_i,
    s0_wb_stb_o   => sram_rom_wb_stb_i,
    s0_wb_ack_i   => sram_rom_wb_ack_o,
    s0_wb_stall_i => sram_rom_wb_stall_o,

    -- Slave 1 signals

    s1_wb_dat_i   => prom_rom_wb_dat_o,
    s1_wb_dat_o   => open,
    s1_wb_adr_o   => prom_rom_wb_adr_i(11 downto 2),
    s1_wb_sel_o   => open,
    s1_wb_cti_o   => open,
    s1_wb_we_o    => open,
    s1_wb_cyc_o   => prom_rom_wb_cyc_i,
    s1_wb_stb_o   => prom_rom_wb_stb_i,
    s1_wb_ack_i   => prom_rom_wb_ack_o,
    s1_wb_stall_i => prom_rom_wb_stall_o

  );

  npnadapt: wb_master_np_to_slave_p
  generic map (
    ADDRESS_HIGH  => maxAddrBitIncIO,
    ADDRESS_LOW   => 0
  )
  port map (
    wb_clk_i    => wb_clk_i,
	 	wb_rst_i    => wb_rst_i,

    -- Master signals

    m_wb_dat_o  => np_ram_wb_dat_o,
    m_wb_dat_i  => np_ram_wb_dat_i,
    m_wb_adr_i  => np_ram_wb_adr_i,
    m_wb_sel_i  => np_ram_wb_sel_i,
    m_wb_cti_i  => CTI_CYCLE_CLASSIC,
    m_wb_we_i   => np_ram_wb_we_i,
    m_wb_cyc_i  => np_ram_wb_cyc_i,
    m_wb_stb_i  => np_ram_wb_stb_i,
    m_wb_ack_o  => np_ram_wb_ack_o,

    -- Slave signals

    s_wb_dat_i  => ram_wb_dat_o,
    s_wb_dat_o  => ram_wb_dat_i,
    s_wb_adr_o  => ram_wb_adr_i,
    s_wb_sel_o  => ram_wb_sel_i,
    s_wb_cti_o  => open,
    s_wb_we_o   => ram_wb_we_i,
    s_wb_cyc_o  => ram_wb_cyc_i,
    s_wb_stb_o  => ram_wb_stb_i,
    s_wb_ack_i  => ram_wb_ack_o,
    s_wb_stall_i => ram_wb_stall_o
  );


  -- PROM

  prom: wb_bootloader
    port map (
      wb_clk_i    => wb_clk_i,
      wb_rst_i    => wb_rst_i,

      wb_dat_o    => prom_rom_wb_dat_o,
      wb_adr_i    => prom_rom_wb_adr_i(11 downto 2),
      wb_cyc_i    => prom_rom_wb_cyc_i,
      wb_stb_i    => prom_rom_wb_stb_i,
      wb_ack_o    => prom_rom_wb_ack_o,
      wb_stall_o  => prom_rom_wb_stall_o,

      wb2_dat_o    => slot_read(15),
      wb2_adr_i    => slot_address(15)(11 downto 2),
      wb2_cyc_i    => slot_cyc(15),
      wb2_stb_i    => slot_stb(15),
      wb2_ack_o    => slot_ack(15),
      wb2_stall_o  => open
    );



  --
  -- IO SLOT 0
  --

  slot0: zpuino_spi
  port map (
    wb_clk_i      => wb_clk_i,
	 	wb_rst_i      => wb_rst_i,
    wb_dat_o      => slot_read(0),
    wb_dat_i      => slot_write(0),
    wb_adr_i      => slot_address(0),
    wb_we_i       => slot_we(0),
    wb_cyc_i      => slot_cyc(0),
    wb_stb_i      => slot_stb(0),
    wb_ack_o      => slot_ack(0),
    wb_inta_o     => slot_interrupt(0),

    mosi          => spi_pf_mosi,
    miso          => spi_pf_miso,
    sck           => spi_pf_sck,
    enabled       => open
  );

  --
  -- IO SLOT 1
  --

  uart_inst: zpuino_uart
  port map (
    wb_clk_i      => wb_clk_i,
	 	wb_rst_i      => wb_rst_i,
    wb_dat_o      => slot_read(1),
    wb_dat_i      => slot_write(1),
    wb_adr_i      => slot_address(1),
    wb_we_i       => slot_we(1),
    wb_cyc_i      => slot_cyc(1),
    wb_stb_i      => slot_stb(1),
    wb_ack_o      => slot_ack(1),
    wb_inta_o     => slot_interrupt(1),

    enabled       => open,
    tx            => tx,
    rx            => rx
  );

  --
  -- IO SLOT 2
  --

  gpio_inst: zpuino_gpio
  generic map (
    gpio_count => zpuino_gpio_count
  )
  port map (
    wb_clk_i      => wb_clk_i,
	 	wb_rst_i      => wb_rst_i,
    wb_dat_o      => slot_read(2),
    wb_dat_i      => slot_write(2),
    wb_adr_i      => slot_address(2),
    wb_we_i       => slot_we(2),
    wb_cyc_i      => slot_cyc(2),
    wb_stb_i      => slot_stb(2),
    wb_ack_o      => slot_ack(2),
    wb_inta_o     => slot_interrupt(2),

    spp_data      => gpio_spp_data,
    spp_read      => gpio_spp_read,

    gpio_i        => gpio_i,
    gpio_t        => gpio_t,
    gpio_o        => gpio_o,
    spp_cap_in    => spp_cap_in,
    spp_cap_out   => spp_cap_out
  );

  --
  -- IO SLOT 3
  --

  timers_inst: zpuino_timers
  generic map (
    A_TSCENABLED        => true,
    A_PWMCOUNT          => 1,
    A_WIDTH             => 16,
    A_PRESCALER_ENABLED => true,
    A_BUFFERS           => true,
    B_TSCENABLED        => false,
    B_PWMCOUNT          => 1,
    B_WIDTH             => 8,--24,
    B_PRESCALER_ENABLED => false,
    B_BUFFERS           => false
  )
  port map (
    wb_clk_i      => wb_clk_i,
	 	wb_rst_i      => wb_rst_i,
    wb_dat_o      => slot_read(3),
    wb_dat_i      => slot_write(3),
    wb_adr_i      => slot_address(3),
    wb_we_i       => slot_we(3),
    wb_cyc_i      => slot_cyc(3),
    wb_stb_i      => slot_stb(3),
    wb_ack_o      => slot_ack(3),

    wb_inta_o     => slot_interrupt(3), -- We use two interrupt lines
    wb_intb_o     => slot_interrupt(4), -- so we borrow intr line from slot 4

    pwm_a_out   => timers_pwm(0 downto 0),
    pwm_b_out   => timers_pwm(1 downto 1)
  );

  --
  -- IO SLOT 4  - DO NOT USE (it's already mapped to Interrupt Controller)
  --

  --
  -- IO SLOT 5
  --

  -- sigmadelta_inst: zpuino_sigmadelta
  -- port map (
    -- wb_clk_i      => wb_clk_i,
	 	-- wb_rst_i      => wb_rst_i,
    -- wb_dat_o      => slot_read(5),
    -- wb_dat_i      => slot_write(5),
    -- wb_adr_i      => slot_address(5),
    -- wb_we_i       => slot_we(5),
    -- wb_cyc_i      => slot_cyc(5),
    -- wb_stb_i      => slot_stb(5),
    -- wb_ack_o      => slot_ack(5),
    -- wb_inta_o     => slot_interrupt(5),

    -- spp_data      => sigmadelta_spp_data,
    -- spp_en        => open,
    -- sync_in       => '1'
  -- );
  
  sigmadelta_inst: zpuino_sigmadelta
  port map (
    wb_clk_i       => wb_clk_i,
	 	wb_rst_i    => wb_rst_i,
    wb_dat_o      => slot_read(5),
    wb_dat_i     => slot_write(5),
    wb_adr_i   => slot_address(5),
    wb_we_i        => slot_we(5),
    wb_cyc_i        => slot_cyc(5),
    wb_stb_i        => slot_stb(5),
    wb_ack_o      => slot_ack(5),
    wb_inta_o => slot_interrupt(5),

	 raw_out => sigmadelta_raw,
    spp_data  => sigmadelta_spp_data,
    spp_en    => sigmadelta_spp_en,
    sync_in   => '1'
  );  
  
    -- slot5: zpuino_empty_device
  -- port map (
    -- wb_clk_i      => wb_clk_i,
	 	-- wb_rst_i      => wb_rst_i,
    -- wb_dat_o      => slot_read(5),
    -- wb_dat_i      => slot_write(5),
    -- wb_adr_i      => slot_address(5),
    -- wb_we_i       => slot_we(5),
    -- wb_cyc_i      => slot_cyc(5),
    -- wb_stb_i      => slot_stb(5),
    -- wb_ack_o      => slot_ack(5),
    -- wb_inta_o     => slot_interrupt(5)
  -- );

  --
  -- IO SLOT 6
  --

  slot1: zpuino_spi
  port map (
    wb_clk_i      => wb_clk_i,
	 	wb_rst_i      => wb_rst_i,
    wb_dat_o      => slot_read(6),
    wb_dat_i      => slot_write(6),
    wb_adr_i      => slot_address(6),
    wb_we_i       => slot_we(6),
    wb_cyc_i      => slot_cyc(6),
    wb_stb_i      => slot_stb(6),
    wb_ack_o      => slot_ack(6),
    wb_inta_o     => slot_interrupt(6),

    mosi          => spi2_mosi,
    miso          => spi2_miso,
    sck           => spi2_sck,
    enabled       => open
  );



  --
  -- IO SLOT 7
  --

  crc16_inst: zpuino_crc16
  port map (
    wb_clk_i      => wb_clk_i,
	 	wb_rst_i      => wb_rst_i,
    wb_dat_o      => slot_read(7),
    wb_dat_i      => slot_write(7),
    wb_adr_i      => slot_address(7),
    wb_we_i       => slot_we(7),
    wb_cyc_i      => slot_cyc(7),
    wb_stb_i      => slot_stb(7),
    wb_ack_o      => slot_ack(7),
    wb_inta_o     => slot_interrupt(7)
  );

  --
  -- IO SLOT 8
  --

  slot8: zpuino_empty_device
  port map (
    wb_clk_i      => wb_clk_i,
	 	wb_rst_i      => wb_rst_i,
    wb_dat_o      => slot_read(8),
    wb_dat_i      => slot_write(8),
    wb_adr_i      => slot_address(8),
    wb_we_i       => slot_we(8),
    wb_cyc_i      => slot_cyc(8),
    wb_stb_i      => slot_stb(8),
    wb_ack_o      => slot_ack(8),
    wb_inta_o     => slot_interrupt(8)
  );

  sram_inst: sdram_ctrl
    port map (
      wb_clk_i    => wb_clk_i,
  	 	wb_rst_i    => wb_rst_i,
      wb_dat_o    => sram_wb_dat_o,
      wb_dat_i    => sram_wb_dat_i,
      wb_adr_i    => sram_wb_adr_i(maxIObit downto minIObit),
      wb_we_i     => sram_wb_we_i,
      wb_cyc_i    => sram_wb_cyc_i,
      wb_stb_i    => sram_wb_stb_i,
      wb_sel_i    => sram_wb_sel_i,
      wb_ack_o    => sram_wb_ack_o,
      wb_stall_o  => sram_wb_stall_o,

      clk_off_3ns => sysclk_sram_we,

      DRAM_ADDR   => sdaddr_o(11 downto 0), -- FIX ME FIX ME
      DRAM_BA     => sdbs_o,
      DRAM_CAS_N  => sdcas_bo,
      DRAM_CKE    => sdcke_o,
      DRAM_CLK    => sdclk_o,
      DRAM_CS_N   => sdce_bo,
      DRAM_DQ     => sddata_io,
      DRAM_DQM(0) => sddqml_o,
      DRAM_DQM(1) => sddqmh_o,
      DRAM_RAS_N  => sdras_bo,
      DRAM_WE_N   => sdwe_bo

    );
  sdaddr_o(12) <= '0';
  --
  -- IO SLOT 9
  --

slot9: zpuino_empty_device
  port map (
    wb_clk_i      => wb_clk_i,
	 	wb_rst_i      => wb_rst_i,
    wb_dat_o      => slot_read(9),
    wb_dat_i      => slot_write(9),
    wb_adr_i      => slot_address(9),
    wb_we_i       => slot_we(9),
    wb_cyc_i      => slot_cyc(9),
    wb_stb_i      => slot_stb(9),
    wb_ack_o      => slot_ack(9),
    wb_inta_o     => slot_interrupt(9)
  );


  --
  -- IO SLOT 10
  --

  slot10: zpuino_empty_device
  port map (
    wb_clk_i      => wb_clk_i,
	 	wb_rst_i      => wb_rst_i,
    wb_dat_o      => slot_read(10),
    wb_dat_i      => slot_write(10),
    wb_adr_i      => slot_address(10),
    wb_we_i       => slot_we(10),
    wb_cyc_i      => slot_cyc(10),
    wb_stb_i      => slot_stb(10),
    wb_ack_o      => slot_ack(10),
    wb_inta_o     => slot_interrupt(10)
  );

  --
  -- IO SLOT 11
  --

  slot11: zpuino_uart
  generic map (
    bits => 4
  )
  port map (
    wb_clk_i       => wb_clk_i,
	 	wb_rst_i    => wb_rst_i,
    wb_dat_o      => slot_read(11),
    wb_dat_i     => slot_write(11),
    wb_adr_i   => slot_address(11),
    wb_we_i      => slot_we(11),
    wb_cyc_i       => slot_cyc(11),
    wb_stb_i       => slot_stb(11),
    wb_ack_o      => slot_ack(11),

    wb_inta_o => slot_interrupt(11),

    tx        => uart2_tx,
    rx        => uart2_rx
  );

  --
  -- IO SLOT 12
  --

  slot12: zpuino_empty_device
  port map (
    wb_clk_i      => wb_clk_i,
	 	wb_rst_i      => wb_rst_i,
    wb_dat_o      => slot_read(12),
    wb_dat_i      => slot_write(12),
    wb_adr_i      => slot_address(12),
    wb_we_i       => slot_we(12),
    wb_cyc_i      => slot_cyc(12),
    wb_stb_i      => slot_stb(12),
    wb_ack_o      => slot_ack(12),
    wb_inta_o     => slot_interrupt(12)
  );

  --
  -- IO SLOT 13
  --

  --
  -- IO SLOT 14
  --
  
  --
  -- IO SLOT 15 - do not use
  --
  
 -- Audio output for devices

	ym2149_audio_dac <= ym2149_audio_data & "0000000000";

   mixer: zpuino_io_audiomixer
         port map (
     clk     => wb_clk_i,
     rst     => wb_rst_i,
     ena     => '1',
     
     data_in1  => sid_audio_data,
     data_in2  => ym2149_audio_dac,
     data_in3  => sigmadelta_raw,
     
     audio_out => platform_audio_sd
     );  

  process(gpio_spp_read, spi_pf_mosi, spi_pf_sck,
          sigmadelta_spp_data,timers_pwm,
          spi2_mosi,spi2_sck)
  begin

    gpio_spp_data <= (others => DontCareValue);

    -- PPS Outputs
    gpio_spp_data(0)  <= sigmadelta_spp_data(0);   -- PPS0 : SIGMADELTA DATA
    gpio_spp_data(1)  <= timers_pwm(0);            -- PPS1 : TIMER0
    gpio_spp_data(2)  <= timers_pwm(1);            -- PPS2 : TIMER1
    gpio_spp_data(3)  <= spi2_mosi;                -- PPS3 : USPI MOSI
    gpio_spp_data(4)  <= spi2_sck;                 -- PPS4 : USPI SCK
    gpio_spp_data(5)  <= platform_audio_sd;        -- PPS5 : SIGMADELTA1 DATA
    gpio_spp_data(6) <= uart2_tx;                  -- PPS6 : UART2 DATA
    gpio_spp_data(8) <= platform_audio_sd;

    -- PPS inputs
    spi2_miso         <= gpio_spp_read(0);         -- PPS0 : USPI MISO
    uart2_rx <= gpio_spp_read(1);              -- PPS0 : USPI MISO	

  end process;


end behave;
