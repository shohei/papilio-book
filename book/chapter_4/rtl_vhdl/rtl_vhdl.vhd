----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:09:05 05/16/2014 
-- Design Name: 
-- Module Name:    rtl_vhdl - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity rtl_vhdl is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           d : in  STD_LOGIC;
           q : out  STD_LOGIC;
           a : in  STD_LOGIC;
           b : in  STD_LOGIC;
           s : in  STD_LOGIC;
           sel_o : out  STD_LOGIC;
           x : out  STD_LOGIC;
           y : out  STD_LOGIC);
end rtl_vhdl;

architecture Behavioral of rtl_vhdl is

 component dff is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           d : in  STD_LOGIC;
           q : out  STD_LOGIC);
  end component dff;
  
 component sel_dff is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           a : in  STD_LOGIC;
           b : in  STD_LOGIC;
           s : in  STD_LOGIC;
           sel_o : out  STD_LOGIC);
  end component sel_dff;
  
  
 component and_gate is
    Port (
           a : in  STD_LOGIC;
           b : in  STD_LOGIC;
           x : out  STD_LOGIC);
  end component and_gate;
  
begin


  block_1: dff
  port map (
    clk     => clk,
    reset     => reset,
    d     => d,
    q  => q
  );


  block_2: sel_dff
  port map (
    clk     => clk,
    reset     => reset,
    a     => a,
    b     => b,
    s     => s,
    sel_o  => sel_o
  );
  

  block_3: and_gate
  port map (
    a     => a,
    b     => b,
    x  => x
  );
  
  y <= '1' when ((a='1')and(b='1')) else '0';
  
end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity dff is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           d : in  STD_LOGIC;
           q : out  STD_LOGIC);
end dff ;

architecture rtl of dff is

begin

process(clk,reset)
begin
  if(reset ='1') then
    q <= '0';
  else
    if (clk='1' and clk'event) then
    q <= d;
	end if;
  end if;
end process;

end rtl;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity sel_dff is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           a : in  STD_LOGIC;
           b : in  STD_LOGIC;
           s : in  STD_LOGIC;
           sel_o : out  STD_LOGIC);
end sel_dff;

architecture rtl of sel_dff is

begin

process(clk,reset)
begin
  if(reset ='1') then
    sel_o <= '0';
  else
    if (clk='1' and clk'event) then
	  if(s='0') then
        sel_o <= a;
	  else
        sel_o <= b;	    
	  end if;  
	end if;
  end if;
end process;

end rtl;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity and_gate is
    Port (
           a : in  STD_LOGIC;
           b : in  STD_LOGIC;
           x : out  STD_LOGIC);
end and_gate;

architecture rtl of and_gate is

begin

process(a,b)
begin
  if((a='1')and(b='1')) then
    x <= '1';
  else
    x <= '0';
  end if;
end process;

end rtl;
