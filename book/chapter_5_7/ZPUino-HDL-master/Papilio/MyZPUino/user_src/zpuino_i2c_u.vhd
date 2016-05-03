--
--  USER REG for ZPUINO
-- 
--  
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all; 

library work;
use work.zpu_config.all;
use work.zpupkg.all;
use work.zpuinopkg.all;
use work.zpuino_config.all;

entity zpuino_i2c_u is
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
    -- i2c lines
    scl_pad_i     : in  std_logic;                    -- i2c clock line input
    scl_pad_o     : out std_logic;                    -- i2c clock line output
    scl_padoen_o  : out std_logic;                    -- i2c clock line output enable, active low
    sda_pad_i     : in  std_logic;                    -- i2c data line input
    sda_pad_o     : out std_logic;                    -- i2c data line output
    sda_padoen_o  : out std_logic                     -- i2c data line output enable, active low
  );
end entity zpuino_i2c_u ;


architecture behave of zpuino_i2c_u is

signal  i2c_wb_adr_i      : std_logic_vector(2 downto 0); -- lower address bits
signal  i2c_wb_dat_i      : std_logic_vector(7 downto 0); -- Databus input
signal  i2c_wb_dat_o      : std_logic_vector(7 downto 0); -- Databus output
signal  arst_i        :  std_logic;
  component i2c_master_top is
    generic(
            ARST_LVL : std_logic := '0'                   -- asynchronous reset level
    );
    port   (
            -- wishbone signals
            wb_clk_i      : in  std_logic;                    -- master clock input
            wb_rst_i      : in  std_logic := '0';             -- synchronous active high reset
            arst_i        : in  std_logic := not ARST_LVL;    -- asynchronous reset
            wb_adr_i      : in  std_logic_vector(2 downto 0); -- lower address bits
            wb_dat_i      : in  std_logic_vector(7 downto 0); -- Databus input
            wb_dat_o      : out std_logic_vector(7 downto 0); -- Databus output
            wb_we_i       : in  std_logic;                    -- Write enable input
            wb_stb_i      : in  std_logic;                    -- Strobe signals / core select signal
            wb_cyc_i      : in  std_logic;                    -- Valid bus cycle input
            wb_ack_o      : out std_logic;                    -- Bus cycle acknowledge output
            wb_inta_o     : out std_logic;                    -- interrupt request output signal
            -- i2c lines
            scl_pad_i     : in  std_logic;                    -- i2c clock line input
            scl_pad_o     : out std_logic;                    -- i2c clock line output
            scl_padoen_o  : out std_logic;                    -- i2c clock line output enable, active low
            sda_pad_i     : in  std_logic;                    -- i2c data line input
            sda_pad_o     : out std_logic;                    -- i2c data line output
            sda_padoen_o  : out std_logic                     -- i2c data line output enable, active low
    );
 end component i2c_master_top;

begin

i2c_wb_adr_i <=  wb_adr_i(4 downto 2);
i2c_wb_dat_i <=  wb_dat_i(7 downto 0);
wb_dat_o <= "000000000000000000000000"&i2c_wb_dat_o;

  arst_i <= '1';
  
  i2c_u: i2c_master_top
  port map (
    wb_clk_i      => wb_clk_i,
	wb_rst_i      => wb_rst_i,
	arst_i        =>  arst_i   ,
    wb_dat_o      => i2c_wb_dat_o,
    wb_dat_i      => i2c_wb_dat_i,
    wb_adr_i      => i2c_wb_adr_i,
    wb_we_i       => wb_we_i,
    wb_cyc_i      => wb_cyc_i ,
    wb_stb_i      => wb_stb_i   ,
    wb_ack_o      => wb_ack_o,
    wb_inta_o     => wb_inta_o,
	scl_pad_i     => scl_pad_i,    
	scl_pad_o     => scl_pad_o,    
	scl_padoen_o  => scl_padoen_o, 
	sda_pad_i     => sda_pad_i,    
	sda_pad_o     => sda_pad_o,    
	sda_padoen_o  => sda_padoen_o 
	
  );


end behave;

