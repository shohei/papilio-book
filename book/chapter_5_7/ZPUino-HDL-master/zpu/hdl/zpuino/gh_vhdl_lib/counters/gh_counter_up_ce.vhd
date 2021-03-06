-----------------------------------------------------------------------------
--	Filename:	gh_Counter_up_ce.vhd
--
--	Description:
--		Binary up counter with count enable
--
--	Copyright (c) 2005 by George Huber 
--		an OpenCores.org Project
--		free to use, but see documentation for conditions 
--
--	Revision 	History:
--	Revision 	Date       	Author   	Comment
--	-------- 	---------- 	---------	-----------
--	1.0      	09/03/05  	S A Dodd	Initial revision
--	2.0     	09/17/05  	h lefevre	name change to avoid conflict
--	        	          	         	  with other libraries
--	2.1      	05/21/06  	S A Dodd 	fix typo's
--
-----------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.std_logic_arith.all;

ENTITY gh_counter_up_ce IS
	GENERIC (size: INTEGER :=8);
	PORT
	(
		CLK   : IN	STD_LOGIC;
		rst   : IN	STD_LOGIC;
		CE    : IN	STD_LOGIC;
		Q     : OUT STD_LOGIC_VECTOR(size-1 DOWNTO 0)
	);
END gh_counter_up_ce;

ARCHITECTURE a OF gh_counter_up_ce IS 

	signal iQ : STD_LOGIC_VECTOR (size-1 DOWNTO 0);
	
BEGIN

--
-- outputs

	Q <= iQ;

----------------------------------
----------------------------------

PROCESS (CLK,rst)
BEGIN
	if (rst = '1') then 
		iQ <= (others => '0');
	elsif (rising_edge(CLK)) then
		if (CE = '1') then
			iQ <= (iQ + "01");
		end if;			
	end if;
END PROCESS;

END a;
