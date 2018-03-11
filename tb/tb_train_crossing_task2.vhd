-------------------------------------------------------------------------------
-- train_crossing state machine simulation model testbench task 1
-- one file for package / entity / architecture
--
-- Author: Helmut Resch el16b005 BEL4
-- Date:   March 2018
-- File:   train_crossing_new_sim.vhd
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- package with the procedure
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

package train_simulation is

  procedure train_simulation (
                              constant timevalue : in time;
                              signal train_in : out std_logic;
                              signal train_out : out std_logic;
                              signal track_blocked : inout std_logic
                             );

  end train_simulation;

  package body train_simulation is

    procedure train_simulation (
                                constant timevalue : in time;
                                signal train_in : out std_logic;
                                signal train_out : out std_logic;
                                signal track_blocked : inout std_logic
                               ) is

  begin
  
    if (timevalue < 6 sec) then assert false report

      "minimum time to pass track is 6 sec"
      severity warning;

    elsif (track_blocked = '1') then assert false report

      "another train is already crossing"
      severity warning;

    else

      train_in <= '1', '0' after 1 sec;
      train_out <= '1' after (timevalue - 1 sec), '0' after timevalue;
      track_blocked <= '1', '0' after (timevalue + 6 sec);

    end if;

  end train_simulation;

end package body train_simulation;

-------------------------------------------------------------------------------
-- entity
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.gate_FSM_types.all;
use work.train_simulation.all;

entity tb_train_crossing is 
end tb_train_crossing;

-------------------------------------------------------------------------------
-- architecture SIM
-------------------------------------------------------------------------------

architecture sim of tb_train_crossing is

component train_crossing

  port 
  (
	clk_i     	   : in   std_logic;
	reset_i   	   : in   std_logic;
	train_in_i 	   : in   std_logic;
	train_out_i	   : in   std_logic;
	engine_open_o  : out  std_logic;
	engine_close_o : out  std_logic;
	light_o        : out  std_logic
  );

end component;

component gate_simulation

  generic 
  (
    initial_state_gate : t_gate_internal
  );

  port 
  (
    gate_open_i  : in  std_logic;
    gate_close_i : in  std_logic;
    gate_state_o : out t_gate_external
  );

end component;

signal clk_i     	  : std_logic;
signal reset_i   	  : std_logic;
signal train_in_i     : std_logic;
signal train_out_i    : std_logic;
signal engine_open_o  : std_logic;
signal engine_close_o : std_logic;
signal light_o        : std_logic;
signal track_blocked_o : std_logic;
signal gate_state_o	  : t_gate_external;

begin

  i_train_crossing : train_crossing

  port map 
    (
      clk_i => clk_i,
      reset_i => reset_i,
      train_in_i => train_in_i,
      train_out_i => train_out_i,
      engine_open_o => engine_open_o,
      engine_close_o => engine_close_o,
      light_o => light_o
    );

  i_gate_simulation : gate_simulation

  generic map
  (
    initial_state_gate => OPENED
  )

  port map 
    (
      gate_open_i => engine_open_o,
      gate_close_i => engine_close_o,
      gate_state_o => gate_state_o
    );

  p_clk : process

	begin

	  clk_i <= '0';
	  wait for 0.5 sec;
	  clk_i <= '1';
	  wait for 0.5 sec;

	end process p_clk;

  -- test pattern like in solved example

  run : process

	begin

	  reset_i <= '1';
	  train_in_i <= '0';
	  train_out_i <= '0';
	  track_blocked_o <= '0';
      wait for 2 sec;

	  reset_i <= '0';
      wait for 10 sec;

	  train_simulation(6 sec, train_in_i, train_out_i, track_blocked_o);
      wait for 15 sec;

	  train_simulation(10 sec, train_in_i, train_out_i, track_blocked_o);
      wait for 20 sec;

	  train_simulation(8 sec, train_in_i, train_out_i, track_blocked_o);
      wait for 1 sec;

	  train_simulation(5.5 sec, train_in_i, train_out_i, track_blocked_o);
      wait for 1 sec;

	  train_simulation(6 sec, train_in_i, train_out_i, track_blocked_o);
      wait for 10 sec;

      assert false report "END OF THIS SIMULATION" severity failure;

	end process run;

end sim;
