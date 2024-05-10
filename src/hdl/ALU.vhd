--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
--|
--| ALU OPCODES:
--|
--|   ADD          000
--|   SUBTRACT      001
--|   
--|
--|
--+----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


entity ALU is
    port(
        i_op : in std_logic_vector(2 downto 0);
        i_B : in signed(7 downto 0);
        i_A : in signed(7 downto 0);
        o_flags : out std_logic_vector(2 downto 0);
        o_result : out signed(7 downto 0)
    );
    
end ALU;

architecture behavioral of ALU is 
  
	 signal res: signed(8 downto 0);
	 
begin
	res <=
	       
	       to_signed(to_integer(i_A) + to_integer(i_B),9) when (i_op = "000") else
	       to_signed(to_integer(i_A) - to_integer(i_B),9) when (i_op = "001") else
            resize(i_A or i_B, 9) when (i_op = "010") else
	        resize(i_A and i_B, 9) when (i_op = "011") else
	       resize(signed(shift_left(unsigned(i_A), to_integer(i_B))),9) when (i_op = "100") else 
            resize(signed(shift_right(unsigned(i_A), to_integer(i_B))),9) when (i_op = "101") else 
            "000000000";
            
    
    
    o_result <= signed(res(7 downto 0));
    o_flags(0) <= res(8);
    o_flags(1) <= '1' when (res(7 downto 0) = "00000000") else '0';
    o_flags(2) <= not res(7);
    
    
	
	
end behavioral;

