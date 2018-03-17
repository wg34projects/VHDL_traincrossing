-------------------------------------------------------------------------------
-- train_crossing state machine simulation model
-- one file for package / entity / architecture
--
-- Author: Helmut Resch el16b005 BEL4
-- Date:   March 2018
-- File:   train_crossing_new_sim.vhd
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- package for FSM state types - later used also in testbench
-------------------------------------------------------------------------------

package gate_FSM_types is

  -- states that are shown on output, only the main states are important
  type t_gate_external is (CLOSED, OPENED, INTERMEDIATE);
  -- internal possible states
  type t_gate_internal is (CLOSED, OPENING, OPENING_BREAK, OPENED, CLOSING, CLOSING_BREAK);

end gate_FSM_types;

-------------------------------------------------------------------------------
-- entity
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use work.gate_FSM_types.all;				-- package as defined above

entity gate_simulation is

  -- generic for the initial state of simulation
  generic (initial_state_gate : t_gate_internal := OPENED);

  -- port declaration
  port 
  (
    gate_open_i  : in  std_logic;
    gate_close_i : in  std_logic;
    gate_state_o : out t_gate_external		-- state output
  );

end gate_simulation;

-------------------------------------------------------------------------------
-- architecture SIM
-------------------------------------------------------------------------------

architecture sim of gate_simulation is 

    -- signal for gate state with start value from generic
    signal gate_state_s : t_gate_internal := initial_state_gate;
	-- signal if timer is on or off with initial value
	signal timer_run_s : std_logic := '0';

-- FSM 6 states closed-opening-opening break-opened-closing-closing break
begin

  p_gate_check : process (gate_close_i, gate_open_i)

  -- variables to save time stamps
  variable timer_start_1_v : time := 0 sec;
  variable timer_start_2_v : time := 0 sec;
  variable timer_break_1_v : time := 0 sec;
  variable timer_break_2_v : time := 0 sec;
  
  begin

    case gate_state_s is

      when CLOSED =>
		
	    -- start OPENING
		if (gate_close_i = '0' and gate_open_i = '1') then

		  gate_state_s <= OPENING;
		  report "OPENING";
          -- time OPENDED = 4 sec
		  timer_run_s <= '1' after 4 sec;
		  -- safe start_1 time
		  timer_start_1_v := now;

        end if;

      when OPENING =>

        -- OPENED
		if (timer_run_s = '1') then

          gate_state_s <= OPENED;
          timer_run_s <= '0';						

		-- stop OPENING and start CLOSING
        elsif (gate_close_i = '1' and gate_open_i = '0') then
 
          gate_state_s <= CLOSING;
		  report "CLOSING";
		  -- time CLOSED = before OPENING
          timer_run_s <= '1' after (now - timer_start_1_v);

		-- OPENING_BREAK
		else

		  gate_state_s <= OPENING_BREAK;
		  timer_run_s <= '0';
		  -- safe break_1 time
		  timer_break_1_v := now;

		end if;

      when OPENING_BREAK =>

    	report "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! gate break";

		-- start OPENING
		if (gate_close_i = '0' and gate_open_i = '1') then

	  	  gate_state_s <= OPENING;
		  -- time OPENED = 4 sec - before OPENING
		  timer_run_s <= '1' after (4 sec - (timer_break_1_v - timer_start_1_v));

		-- start CLOSING
		elsif (gate_close_i = '1' and gate_open_i = '0') then

 		  gate_state_s <= CLOSING;
		  -- time CLOSED = before OPENING
		  timer_run_s <= '1' after (timer_break_1_v - timer_start_1_v);

 		end if;

	  when OPENED =>

		-- start CLOSING
		if (gate_close_i = '1' and gate_open_i = '0') then

		  gate_state_s <= CLOSING;
		  report "CLOSING";
		  -- time closed = 4 sec
		  timer_run_s <= '1' after 4 sec;
		  -- safe start_2 time
		  timer_start_2_v := now;

		end if;

      when CLOSING =>

        -- CLOSED
		if (timer_run_s = '1') then

		  gate_state_s <= CLOSED;
		  timer_run_s <= '0';

		-- stop CLOSING and start OPENING
		elsif (gate_close_i = '0' and gate_open_i = '1') then

		  gate_state_s <= OPENING;
		  report "OPENING";
		  -- time OPENED = before CLOSING
		  timer_run_s <= '1' after (now - timer_start_2_v);

		-- CLOSING_BREAK
		else

		  gate_state_s <= CLOSING_BREAK;
		  timer_run_s <= '0';
		  -- safe break_2 time
		  timer_break_2_v := now;

		end if;

      when CLOSING_BREAK =>

   	    report "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! gate break";

		-- start CLOSING
		if (gate_close_i = '1' and gate_open_i = '0') then

		  gate_state_s <= CLOSING;
		  -- time CLOSED = 4 sec - before CLOSING
		  timer_run_s <= '1' after (4 sec - (timer_break_2_v - timer_start_2_v));

		-- start OPENING
		elsif (gate_close_i = '0' and gate_open_i = '1') then

		  gate_state_s <= OPENING;
		  -- time OPENED = before CLOSING
		  timer_run_s <= '1' after (timer_break_2_v - timer_start_2_v);

		end if;

	end case;

  end process p_gate_check;

  p_output : process (gate_state_s)

	begin

	  if (gate_state_s = CLOSED) then

		gate_state_o <= CLOSED;				-- output to "outside" CLOSED state
		report "CLOSED";

	  elsif (gate_state_s = OPENED) then

		gate_state_o <= OPENED;				-- output to "outside" OPENED state
		report "OPENED";

	  else

		gate_state_o <= INTERMEDIATE;		-- rest INTERMEDIATE state

	  end if;

  end process p_output;

end sim;
