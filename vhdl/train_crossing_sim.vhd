package gate_FSM_types is

  type t_gate_external is (CLOSED, OPENED, INTERMEDIATE);
  type t_gate_internal is (CLOSED, OPENING, OPENING_BREAK, OPENED, CLOSING, CLOSING_BREAK);

end gate_FSM_types;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use work.gate_FSM_types.all;

entity gate_simulation is

  generic (
           initial_state_gate : t_gate_internal := OPENED
          );

  port 
  (
    gate_open_i  : in  std_logic;
    gate_close_i : in  std_logic;
    gate_state_o : out t_gate_external	
  );

end gate_simulation;

architecture sim of gate_simulation is 

    signal gate_state_s : t_gate_internal := initial_state_gate;
	signal timer_run_s : std_logic := '0';
	signal timer_measure_s : time := 0 sec;

begin

  p_gate_check : process (gate_close_i, gate_open_i)
  
  begin

    case gate_state_s is

      when CLOSED =>

		if (gate_close_i = '0' and gate_open_i = '1') then

		  gate_state_s <= OPENING;
		  timer_run_s <= '1' after 4 sec;
		  timer_measure_s <= now;

        end if;

	  when OPENING =>

		if (timer_run_s = '1') then

          gate_state_s <= OPENED;
          timer_run_s <= '0';						

        elsif (gate_close_i = '1' and gate_open_i = '0') then
 
          gate_state_s <= CLOSING;
          timer_run_s <= '1' after (now - timer_measure_s);
          timer_measure_s <= now - (4 sec - (now - timer_measure_s));

		else
	
		  gate_state_s <= OPENING_BREAK;
		  timer_run_s <= '0';
		  timer_measure_s <= now - timer_measure_s;

		end if;

      when OPENING_BREAK =>

		if (gate_close_i = '0' and gate_open_i = '1') then

	  	  gate_state_s <= OPENING;
		  timer_run_s <= '1' after (4 sec - timer_measure_s);
		  timer_measure_s <= now - timer_measure_s;

		elsif (gate_close_i = '1' and gate_open_i = '0') then

 		  gate_state_s <= CLOSING;
		  timer_run_s <= '1' after timer_measure_s;
		  timer_measure_s <= now - (4 sec -timer_measure_s);

 		end if;

	  when OPENED =>

		if (gate_close_i = '1' and gate_open_i = '0') then

		  gate_state_s <= CLOSING;
		  timer_run_s <= '1' after 4 sec;
		  timer_measure_s <= now;

		end if;

      when CLOSING =>

		if (timer_run_s = '1') then

		  gate_state_s <= CLOSED;
		  timer_run_s <= '0';

		elsif (gate_close_i = '0' and gate_open_i = '1') then

		  gate_state_s <= OPENING;
		  timer_run_s <= '1' after (now - timer_measure_s);
		  timer_measure_s <= now - (4 sec - (now - timer_measure_s));

		else

		  gate_state_s <= CLOSING_BREAK;
		  timer_run_s <= '0';
		  timer_measure_s <= now - timer_measure_s;

		end if;

      when CLOSING_BREAK =>

		if (gate_close_i = '1' and gate_open_i = '0') then

		  gate_state_s <= CLOSING;
		  timer_run_s <= '1' after (4 sec - timer_measure_s);
		  timer_measure_s <= now - timer_measure_s;

		elsif (gate_close_i = '0' and gate_open_i = '1') then

		  gate_state_s <= OPENING;
		  timer_run_s <= '1' after timer_measure_s;
		  timer_measure_s <= now;

		end if;

	end case;

  end process p_gate_check;

  p_output : process (gate_state_s)

	begin

	  if (gate_state_s = CLOSED) then

		gate_state_o <= CLOSED;

	  elsif (gate_state_s = OPENED) then

		gate_state_o <= OPENED;

	  else

		gate_state_o <= INTERMEDIATE;

	  end if;

  end process p_output;

end sim;
