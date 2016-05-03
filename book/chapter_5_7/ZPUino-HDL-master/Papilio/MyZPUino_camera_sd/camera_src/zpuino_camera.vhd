
--*****************************************************************************
-- File Name            : zpuino_camera.vhd
-------------------------------------------------------------------------------
-- Function             : Camera_if for ZPUINO
--                        
-------------------------------------------------------------------------------
-- Designer             : yokomizo 
-------------------------------------------------------------------------------
-- History
-- -.-- 2014/05/24
--*****************************************************************************
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all; 

library work;
use work.zpu_config.all;
use work.zpupkg.all;
use work.zpuinopkg.all;
use work.zpuino_config.all;

entity zpuino_camera is
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
    -- camera 
	pclk : in  std_logic;    
    c_vsync : in  std_logic;  
    href: in  std_logic; 
    in_data : in std_logic_vector(7 downto 0);
    dmy_camera_mode : in std_logic -- 0:camera 1:dmy    
  );
end entity zpuino_camera ;


architecture behave of zpuino_camera is


  component camera_mem_if is
    port   (
            -- wishbone signals
            wb_clk_i      : in  std_logic;                    -- master clock input
            wb_rst_i      : in  std_logic := '0';             -- synchronous active high reset
            wb_adr_i      : in  std_logic_vector(15 downto 2); -- lower address bits
            wb_dat_i      : in  std_logic_vector(31 downto 0); -- Databus input
            wb_dat_o      : out std_logic_vector(31 downto 0); -- Databus output
            wb_we_i       : in  std_logic;                    -- Write enable input
            wb_stb_i      : in  std_logic;                    -- Strobe signals / core select signal
            wb_cyc_i      : in  std_logic;                    -- Valid bus cycle input
            wb_ack_o      : out std_logic;                    -- Bus cycle acknowledge output
            wb_inta_o     : out std_logic;                    -- interrupt request output signal
            -- camera l
	        pclk : in  std_logic;    
            c_vsync : in  std_logic;  
            href: in  std_logic; 
           in_data : in std_logic_vector(7 downto 0);
           dmy_camera_mode : in std_logic -- 0:camera 1:dmy    
    );
 end component camera_mem_if;

begin
  
  u_camera_mem_if: camera_mem_if
  port map (
    wb_clk_i      => wb_clk_i,
	wb_rst_i      => wb_rst_i,
    wb_dat_o      => wb_dat_o,
    wb_dat_i      => wb_dat_i,
    wb_adr_i      => wb_adr_i(15 downto 2) ,
    wb_we_i       => wb_we_i,
    wb_cyc_i      => wb_cyc_i ,
    wb_stb_i      => wb_stb_i   ,
    wb_ack_o      => wb_ack_o,
    wb_inta_o     => wb_inta_o,
	pclk  => pclk,
	c_vsync  => c_vsync,
	href  => href,
	in_data  => in_data,
	dmy_camera_mode => dmy_camera_mode
	
  );


end behave;

