
--*****************************************************************************
-- File Name            : zpuino_userreg.v
-------------------------------------------------------------------------------
-- Function             : USER REG for ZPUINO
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

entity zpuino_userreg is
  generic (
    user_data_width: integer := 32
  );
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
    user_data_o : out std_logic_vector( user_data_width-1 downto 0);
    user_data_o_en :out std_logic;
    user_data_i: in std_logic_vector( user_data_width-1 downto 0);
    user_data_i_en: in std_logic
  );
end entity zpuino_userreg ;


architecture behave of zpuino_userreg is

signal user_data_o_ff : std_logic_vector( user_data_width-1 downto 0);
signal user_data_o_en_ff : std_logic;
signal user_data_i_ff : std_logic_vector( user_data_width-1 downto 0);
signal wb_ack_o_ff : std_logic;

begin

wb_ack_o <= wb_ack_o_ff;
wb_inta_o <= '0';
--ACK生成
process(wb_clk_i)
begin
  if rising_edge(wb_clk_i) then
    if(( wb_cyc_i = '1')and(wb_stb_i='1')and(wb_ack_o_ff='0')) then
	  wb_ack_o_ff <= '1';
	else
	  wb_ack_o_ff <= '0';
    end if;
 end if;
end process;

-- output.

tgen: for i in 0 to user_data_width-1 generate
   user_data_o(i) <= user_data_o_ff(i);
end generate;

   user_data_o_en <= user_data_o_en_ff;
--読み出しデータの選択   
process(wb_adr_i,user_data_o_ff,user_data_i_ff)
begin
  case wb_adr_i(5 downto 2) is
    when "0000" =>
       wb_dat_o <= user_data_o_ff(31 downto 0);  
    when "0001" =>
       wb_dat_o <= user_data_i_ff(31 downto 0);
    when others =>
      wb_dat_o <= (others => '0');
  end case;
end process;

--書き込みデータの保存
process(wb_clk_i)
begin
  if rising_edge(wb_clk_i) then
    if wb_rst_i='1' then
       user_data_o_ff <= (others => '0');
    elsif wb_stb_i='1' and wb_cyc_i='1' and wb_we_i='1' then
       case wb_adr_i(5 downto 2) is
          when "0000" =>
             user_data_o_ff(31 downto 0) <= wb_dat_i;	  
          when others =>
		     user_data_o_ff <= user_data_o_ff;
       end case;
    end if;
   end if;
end process;

--出力データのイネーブル生成
process(wb_clk_i)
begin
  if rising_edge(wb_clk_i) then
    if wb_rst_i='1' then
       user_data_o_en_ff <= '0';
    elsif wb_stb_i='1' and wb_cyc_i='1' and wb_we_i='1' then
       case wb_adr_i(5 downto 2) is
          when "0000" =>
             user_data_o_en_ff <= '1';
   		  when others =>
             user_data_o_en_ff <= '0';
       end case;
	else
      user_data_o_en_ff <= '0';
    end if;
   end if;
end process;

--入力データの保持
process(wb_clk_i)
begin
  if rising_edge(wb_clk_i) then
    if wb_rst_i='1' then
       user_data_i_ff <= (others => '0');
    elsif  user_data_i_en ='1'  then
       user_data_i_ff(31 downto 0) <=  user_data_i;	 
    else	   
       user_data_i_ff <=  user_data_i_ff;	 
   end if;
 end if;
end process;


end behave;

