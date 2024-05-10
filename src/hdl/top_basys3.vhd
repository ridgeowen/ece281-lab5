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
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


entity top_basys3 is
    port(
        clk     :       in std_logic;
        sw      :       in std_logic_vector(15 downto 0);
        led     :       out std_logic_vector(15 downto 0);
        
  
        btnU	:	in	std_logic;                    
        btnC    :   in    std_logic;   
        seg     :   out std_logic_vector(6 downto 0);
        an      :   out std_logic_vector(3 downto 0)
    
    );
end top_basys3;

architecture top_basys3_arch of top_basys3 is 
  
	-- declare components and signals
 component clock_divider is
           generic ( constant k_DIV : natural := 2    );
           port (     i_clk    : in std_logic;
                   i_reset  : in std_logic;           
                   o_clk    : out std_logic           
           );
       end component clock_divider;
      
  component sevenSegDecoder is
            port ( i_D : in STD_LOGIC_VECTOR (3 downto 0);
            o_S : out STD_LOGIC_VECTOR (6 downto 0));
           
       end component sevenSegDecoder;
       
  component TDM4 is
               generic ( constant k_WIDTH : natural  := 4); -- bits in input and output
               port ( i_clk        : in  STD_LOGIC;
                      i_reset      : in  STD_LOGIC;
                      i_D3         : in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
                      i_D2         : in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
                      i_D1         : in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
                      i_D0         : in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
                      o_data        : out STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
                      o_sel         : out STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0)
                      
               );
          
           end component TDM4;
  
   component controller_FSM is
          port (     i_reset    : in std_logic;
                    i_clk : in std_logic;
                      i_adv  : in std_logic;           
                      o_cycle    : out std_logic_vector(3 downto 0)           
              );          
                    
     end component controller_FSM;
     
      component twoscomp_decimal is
         port (
             i_binary: in std_logic_vector(7 downto 0);
             o_negative: out std_logic;
             o_hundreds: out std_logic_vector(3 downto 0);
             o_tens: out std_logic_vector(3 downto 0);
             o_ones: out std_logic_vector(3 downto 0)
         );
         end component twoscomp_decimal;

     component ALU is 
            port (      i_A      : in std_logic_vector (7 downto 0);
                        i_B      : in std_logic_vector (7 downto 0);
                        i_op      : in std_logic_vector (2 downto 0);
                        o_result : out std_logic_vector (7 downto 0);
                        o_flags : out std_logic_vector (2 downto 0)
                        
                     );
                end component ALU;   
        
    



       
       --signals 
       signal w_QA : std_logic_vector (7 downto 0);
       signal w_QB : std_logic_vector (7 downto 0);
       signal w_cycle : std_logic_vector (3 downto 0);
       signal w_result : std_logic_vector (7 downto 0);
       signal w_Y : std_logic_vector (7 downto 0);
       signal w_sign : std_logic_vector (3 downto 0);
       signal w_neg : std_logic;
       signal w_hund : std_logic_vector (3 downto 0);
       signal w_tens : std_logic_vector (3 downto 0);
       signal w_ones : std_logic_vector (3 downto 0);
       signal w_data : std_logic_vector (3 downto 0);
       signal w_sel : std_logic_vector (3 downto 0);
       signal w_clk : std_logic;
       signal w_controller_reset : std_logic;
       
       
  
begin
	-- PORT MAPS ----------------------------------------
    clkdivTDM_inst : clock_divider
          generic map ( k_DIV => 250000 ) -- same divider as your elevator tdm
          port map (
          i_clk => clk,
          i_reset => btnU,
          o_clk => w_clk
          );
	
	controller_fsm_inst : controller_FSM
        port map(
             i_clk => clk,
             i_reset => btnU,
             i_adv => btnC,
             o_cycle => w_cycle
          );
 
    ALU_inst : ALU
        port map(
           i_A => w_QA,
           i_B => w_QB,
           i_op => sw(2 downto 0),
           o_result => w_result(7 downto 0),
           o_flags => led(15 downto 13)
          );         
          
    sevenSegDecoder_inst : sevenSegDecoder
         port map(
             i_D => w_data,
             o_S => seg
                );
                
    TDM4_inst : TDM4
        generic map (k_WIDTH => 4)
           port map(
               i_D3 => w_sign,
               i_D2 => w_hund,
               i_D1 => w_Y(7 downto 4),
               i_D0 => w_Y(3 downto 0),
               o_data => w_data,
               o_sel => w_sel,
               i_clk => w_clk,
               i_reset => btnU                         
           );   
           
     twoscomp_decimal_inst : twoscomp_decimal
        port map (
            i_binary => w_Y,
            o_negative => w_neg,
            o_hundreds => w_hund,
            o_tens => w_tens,
            o_ones => w_ones
        );
     
	
	-- CONCURRENT STATEMENTS ----------------------------
	
	w_Y <= w_QA when w_cycle = "1000" else
	       w_QB when w_cycle = "0100" else
	       w_result when w_cycle = "0010" else
	       "00000000";
	       
	 w_sign <= x"A" when w_neg = '0' else 
	           x"B";
	       
	 an <= "1111" when w_cycle = "0001" else 
            w_sel;        
	  
	 led(3 downto 0) <= w_cycle;
	       
	 register_proc : process (clk)
        begin
             if w_cycle = "0001" then 
                w_QA <= sw(7 downto 0);
             elsif w_cycle = "1000" then 
                w_QB <= sw(7 downto 0);
             end if;                                             
        end process register_proc;    
        
	
	
end top_basys3_arch;
	
