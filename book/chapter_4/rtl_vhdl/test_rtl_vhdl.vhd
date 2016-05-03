--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:48:19 05/16/2014
-- Design Name:   
-- Module Name:   E:/cq/papilio/ise/rtl_vhdl/test_rtl_vhdl.vhd
-- Project Name:  rtl_vhdl
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: rtl_vhdl
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY test_rtl_vhdl IS
END test_rtl_vhdl;
 
ARCHITECTURE behavior OF test_rtl_vhdl IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT rtl_vhdl
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         d : IN  std_logic;
         q : OUT  std_logic;
         a : IN  std_logic;
         b : IN  std_logic;
         s : IN  std_logic;
         sel_o : OUT  std_logic;
         x : OUT  std_logic;
         y : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal d : std_logic := '0';
   signal a : std_logic := '0';
   signal b : std_logic := '0';
   signal s : std_logic := '0';

 	--Outputs
   signal q : std_logic;
   signal sel_o : std_logic;
   signal x : std_logic;
   signal y : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: rtl_vhdl PORT MAP (
          clk => clk,
          reset => reset,
          d => d,
          q => q,
          a => a,
          b => b,
          s => s,
          sel_o => sel_o,
          x => x,
          y => y
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns      wait for 100 ns;	
		reset <= '1';
		d <= '0';
		a <= '0';
		b <= '0';
		s <= '0';
      wait for clk_period*10;
		reset <= '0';
      wait for clk_period*10;
		d <= '1';
      wait for clk_period*10;
		d <= '0';
      wait for clk_period*10;
		a <= '1';
		b <= '0';
      wait for clk_period*10;
		a <= '0';
		b <= '1';
      wait for clk_period*10;
		a <= '1';
		b <= '1';
      wait for clk_period*10;
		a <= '1';
		b <= '0';
      wait for clk_period*10;
		s <= '1';
      wait for clk_period*10;
		a <= '0';
		b <= '0';
      wait for clk_period*10;
		a <= '1';
		b <= '0';
      wait for clk_period*10;
		a <= '0';
		b <= '1';
      wait for clk_period*10;
		a <= '1';
		b <= '1';
      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
