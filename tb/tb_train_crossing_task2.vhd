-------------------------------------------------------------------------------
-- train_crossing state machine simulation model testbench task s
-- one file for entity / architecture
--
-- Author: Helmut Resch el16b005 BEL4
-- Date:   March 2018
-- File:   train_crossing_task2.vhd
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- entity
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.gate_FSM_types.all;		-- package for FSM types from train_crossing_new_sim

entity tb_train_crossing is 
end tb_train_crossing;

-------------------------------------------------------------------------------
-- architecture SIM
-------------------------------------------------------------------------------

architecture sim of tb_train_crossing is

  -- procedure for train
  procedure train_sim_model (constant time_value : in time;
                             signal train_in_s : out std_logic;
                             signal train_out_s : out std_logic;
						     -- track_blocked_s must be inout because it is
							 -- read and written in procedure
                             signal track_blocked_s : inout std_logic) is

  begin
  
    -- warning too short train pass time 6 sec and track blocked
    if (time_value < 6 sec) and (track_blocked_s = '1') then assert false report

      "track blocked and train crossing under 6 sec! - STOP!"
      severity error;

	-- warning too short time train pass and track is free
    elsif (time_value < 6 sec) and (track_blocked_s = '0') then assert false report

      "train crossing under 6 sec! - STOP!"
      severity warning;

	    -- warning too short train pass time 6 sec
    elsif (time_value >= 6 sec) and (track_blocked_s = '1') then assert false report

      "track blocked - STOP!"
      severity error;

    else

      -- 1 second train in on  = train approaches
      train_in_s <= '1', '0' after 1 sec;
	  -- train needs given time to pass the track
      train_out_s <= '1' after (time_value), '0' after time_value + 1 sec;
	  -- track is blocked for additional 6 seconds after leaving
      track_blocked_s <= '1', '0' after (time_value + 6 sec);
	  report "______________________________________________________________________________[ABC]-[DEF]-[GHI]-[JKL]-/RAILJET\__________";


    end if;

  end train_sim_model;

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
  (initial_state_gate : t_gate_internal);

  port 
  (
    gate_open_i  : in  std_logic;
    gate_close_i : in  std_logic;
    gate_state_o : out t_gate_external
  );

end component;

signal clk_i     	   : std_logic;
signal reset_i   	   : std_logic;
signal train_in_i      : std_logic;
signal train_out_i     : std_logic;
signal engine_open_o   : std_logic;
signal engine_close_o  : std_logic;
signal light_o         : std_logic;
signal track_blocked_o : std_logic;
signal gate_state_o	   : t_gate_external;		-- output for the 3 main states

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
    initial_state_gate => CLOSED
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

  -- misc. test pattern
  run : process

	begin

	  reset_i <= '1';
	  train_in_i <= '0';
	  train_out_i <= '0';
	  track_blocked_o <= '0';
      wait for 2 sec;

	  reset_i <= '0';
      wait for 15 sec;


--# ** Note: CLOSED
--#    Time: 0 ns  Iteration: 0  Instance: /tb_train_crossing/i_gate_simulation
--# ** Note: ______________________________________________________________________________[ABC]-[DEF]-[GHI]-[JKL]-/RAILJET\__________
--#    Time: 17 sec  Iteration: 0  Instance: /tb_train_crossing
--# ** Note: OPENING
--#    Time: 23500 ms  Iteration: 3  Instance: /tb_train_crossing/i_gate_simulation
--# ** Note: OPENED
--#    Time: 28500 ms  Iteration: 4  Instance: /tb_train_crossing/i_gate_simulation

	  -- 17 sec train in - 23 sec train out - 29 sec next safe in
	  train_sim_model(6 sec, train_in_i, train_out_i, track_blocked_o);
      wait for 15 sec;

--# ** Note: ______________________________________________________________________________[ABC]-[DEF]-[GHI]-[JKL]-/RAILJET\__________
--#    Time: 32 sec  Iteration: 0  Instance: /tb_train_crossing
--# ** Note: CLOSING
--#    Time: 32500 ms  Iteration: 3  Instance: /tb_train_crossing/i_gate_simulation
--# ** Note: CLOSED
--#    Time: 37500 ms  Iteration: 4  Instance: /tb_train_crossing/i_gate_simulation
--# ** Note: OPENING
--#    Time: 42500 ms  Iteration: 3  Instance: /tb_train_crossing/i_gate_simulation
--# ** Note: OPENED
--#    Time: 47500 ms  Iteration: 4  Instance: /tb_train_crossing/i_gate_simulation

      -- 32 sec next train in - 42 sec train out - 48 sec next safe in
	  train_sim_model(10 sec, train_in_i, train_out_i, track_blocked_o);
      wait for 20 sec;

--# ** Note: ______________________________________________________________________________[ABC]-[DEF]-[GHI]-[JKL]-/RAILJET\__________
--#    Time: 52 sec  Iteration: 0  Instance: /tb_train_crossing
--# ** Note: CLOSING
--#    Time: 52500 ms  Iteration: 3  Instance: /tb_train_crossing/i_gate_simulation
--# ** Error: track blocked and train crossing under 6 sec! - STOP!
--#    Time: 53 sec  Iteration: 0  Instance: /tb_train_crossing
--# ** Error: track blocked - STOP!
--#    Time: 54 sec  Iteration: 0  Instance: /tb_train_crossing
--# ** Note: CLOSED
--#    Time: 57500 ms  Iteration: 4  Instance: /tb_train_crossing/i_gate_simulation
--# ** Note: OPENING
--#    Time: 60500 ms  Iteration: 3  Instance: /tb_train_crossing/i_gate_simulation
--# ** Error: track blocked and train crossing under 6 sec! - STOP!
--#    Time: 64 sec  Iteration: 0  Instance: /tb_train_crossing
--# ** Note: OPENED
--#    Time: 65500 ms  Iteration: 4  Instance: /tb_train_crossing/i_gate_simulation

      -- 52 sec train in - 60 sec train out - 66 sec next safe in
	  train_sim_model(8 sec, train_in_i, train_out_i, track_blocked_o);
      wait for 1 sec;

      -- 53 sec track blocked and time for passing too short - STOP
	  train_sim_model(5.5 sec, train_in_i, train_out_i, track_blocked_o);
      wait for 1 sec;

      -- 54 sec track blocked - STOP
	  train_sim_model(6 sec, train_in_i, train_out_i, track_blocked_o);
      wait for 10 sec;

      -- 64 sec gate blocked - STOP
	  train_sim_model(2 sec, train_in_i, train_out_i, track_blocked_o);
      wait for 5 sec;

--# ** Note: ______________________________________________________________________________[ABC]-[DEF]-[GHI]-[JKL]-/RAILJET\__________
--#    Time: 69 sec  Iteration: 0  Instance: /tb_train_crossing
--# ** Note: CLOSING
--#    Time: 69500 ms  Iteration: 3  Instance: /tb_train_crossing/i_gate_simulation
--# ** Note: CLOSED
--#    Time: 74500 ms  Iteration: 4  Instance: /tb_train_crossing/i_gate_simulation
--# ** Note: OPENING
--#    Time: 75500 ms  Iteration: 3  Instance: /tb_train_crossing/i_gate_simulation
--# ** Error: track blocked - STOP!
--#    Time: 79 sec  Iteration: 0  Instance: /tb_train_crossing
--# ** Note: OPENED
--#    Time: 80500 ms  Iteration: 4  Instance: /tb_train_crossing/i_gate_simulation
--# ** Warning: train crossing under 6 sec! - STOP!
--#    Time: 82 sec  Iteration: 0  Instance: /tb_train_crossing

      -- 69 sec train in - 75 sec train out - 81 sec next safe in
	  train_sim_model(6 sec, train_in_i, train_out_i, track_blocked_o);
      wait for 10 sec;

	  -- 79 sec track blocked - STOP
	  train_sim_model(7 sec, train_in_i, train_out_i, track_blocked_o);
      wait for 3 sec;

	  -- 82 sec time for passing too short - STOP
	  train_sim_model(4 sec, train_in_i, train_out_i, track_blocked_o);
      wait for 15 sec;

	  -- 97 sec train in - 117 sec train out - 122 sec next safe in
	  train_sim_model(20 sec, train_in_i, train_out_i, track_blocked_o);
      wait for 10 sec;

--# ** Note: ______________________________________________________________________________[ABC]-[DEF]-[GHI]-[JKL]-/RAILJET\__________
--#    Time: 97 sec  Iteration: 0  Instance: /tb_train_crossing
--# ** Note: CLOSING
--#    Time: 97500 ms  Iteration: 3  Instance: /tb_train_crossing/i_gate_simulation
--# ** Note: CLOSED
--#    Time: 102500 ms  Iteration: 4  Instance: /tb_train_crossing/i_gate_simulation
--# ** Error: track blocked - STOP!
--#    Time: 107 sec  Iteration: 0  Instance: /tb_train_crossing

	  -- 97 track blocked - stop
	  train_sim_model(20 sec, train_in_i, train_out_i, track_blocked_o);
      wait for 13 sec;

	  -- 110 sec

	end process run;

end sim;
