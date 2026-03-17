--+----------------------------------------------------------------------------
--| 
--| COPYRIGHT 2017 United States Air Force Academy All rights reserved.
--| 
--| United States Air Force Academy     __  _______ ___    _________ 
--| Dept of Electrical &               / / / / ___//   |  / ____/   |
--| Computer Engineering              / / / /\__ \/ /| | / /_  / /| |
--| 2354 Fairchild Drive Ste 2F6     / /_/ /___/ / ___ |/ __/ / ___ |
--| USAF Academy, CO 80840           \____//____/_/  |_/_/   /_/  |_|
--| 
--| ---------------------------------------------------------------------------
--|
--| FILENAME      : thunderbird_fsm.vhd
--| AUTHOR(S)     : Capt Phillip Warner, Capt Dan Johnson
--| CREATED       : 03/2017 Last modified 06/25/2020
--| DESCRIPTION   : This file implements the ECE 281 Lab 2 Thunderbird tail lights
--|					FSM using enumerated types.  This was used to create the
--|					erroneous sim for GR1
--|
--|					Inputs:  i_clk 	 --> 100 MHz clock from FPGA
--|                          i_left  --> left turn signal
--|                          i_right --> right turn signal
--|                          i_reset --> FSM reset
--|
--|					Outputs:  o_lights_L (2:0) --> 3-bit left turn signal lights
--|					          o_lights_R (2:0) --> 3-bit right turn signal lights
--|
--|					Upon reset, the FSM by defaults has all lights off.
--|					Left ON - pattern of increasing lights to left
--|						(OFF, LA, LA/LB, LA/LB/LC, repeat)
--|					Right ON - pattern of increasing lights to right
--|						(OFF, RA, RA/RB, RA/RB/RC, repeat)
--|					L and R ON - hazard lights (OFF, ALL ON, repeat)
--|					A is LSB of lights output and C is MSB.
--|					Once a pattern starts, it finishes back at OFF before it 
--|					can be changed by the inputs
--|					
--|
--|                 xxx State Encoding key
--|                 --------------------
--|                  State | Encoding
--|                 --------------------
--|                  OFF   | 
--|                  ON    | 
--|                  R1    | 
--|                  R2    | 
--|                  R3    | 
--|                  L1    | 
--|                  L2    | 
--|                  L3    | 
--|                 --------------------
--|
--|
--+----------------------------------------------------------------------------
--|
--| REQUIRED FILES :
--|
--|    Libraries : ieee
--|    Packages  : std_logic_1164, numeric_std
--|    Files     : None
--|
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
 
entity thunderbird_fsm is
    port (
        i_clk, i_reset  : in    std_logic;
        i_left, i_right : in    std_logic;
        o_lights_L      : out   std_logic_vector(2 downto 0);
        o_lights_R      : out   std_logic_vector(2 downto 0)
    );
end thunderbird_fsm;

architecture thunderbird_fsm_arch of thunderbird_fsm is 
-- CONSTANTS ------------------------------------------------------------------ 
    signal S2, S1, S0 : std_logic;
    signal S2_next, S1_next, S0_next : std_logic;
  
begin

	-- CONCURRENT STATEMENTS --------------------------------------------------------	
    S2_next <= ((not S2) and (not S1) and (not S0) and i_left) or
               (S2 and (not S1) and (not S0)) or
               (S2 and (not S1) and S0);
    S1_next <= ((not S2) and (not S1) and (not S0) and i_left and i_right) or
               ((not S2) and (not S1) and S0) or
               ((not S2) and S1 and (not S0)) or
               (S2 and (not S1) and S0);
    S0_next <= ((not S2) and (not S1) and (not S0) and i_right) or
               ((not S2) and S1 and (not S0)) or
               (S2 and (not S1) and (not S0));
               

    o_lights_L(0) <= S2 or (S2 and S1 and S0);
    o_lights_L(1) <= (S2 and (S1 or S0)) or (S2 and S1 and S0);
    o_lights_L(2) <= (S2 and S1) or (S2 and S1 and S0);
    

    o_lights_R(0) <= ((not S2) and (S1 or S0)) or (S2 and S1 and S0); 
    o_lights_R(1) <= ((not S2) and S1) or (S2 and S1 and S0);
    o_lights_R(2) <= ((not S2) and S1 and S0) or (S2 and S1 and S0); 
    ---------------------------------------------------------------------------------
	
	-- PROCESSES --------------------------------------------------------------------
    register_proc : process(i_clk, i_reset)
    begin
    if i_reset = '1' then
        S2 <= '0';
        S1 <= '0';
        S0 <= '0';
    elsif rising_edge(i_clk) then  
        S2 <= S2_next;
        S1 <= S1_next;
        S0 <= S0_next;
    end if;
end process register_proc;
	-----------------------------------------------------					   
				  
end thunderbird_fsm_arch;