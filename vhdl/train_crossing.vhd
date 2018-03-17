-------------------------------------------------------------------------------
-- train_crossing state machine
-------------------------------------------------------------------------------

-- entity

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity train_crossing is

	port 
	(
		clk_i			: in   std_logic;
		reset_i			: in   std_logic;
		train_in_i		: in   std_logic;
		train_out_i		: in   std_logic;
		engine_open_o	: out  std_logic;
		engine_close_o	: out  std_logic;
		light_o			: out  std_logic
	);

end train_crossing;

--	architecture

architecture rtl of train_crossing is

	type states is (opened, closing1, closing2, closed1, closed2, opening1, opening2);
	signal presentstate_s : states;
	signal nextstate_s : states;
	signal blink : natural;

begin

--	first process sequential

	p_train_crossing_seq_p : process (clk_i, reset_i)

	begin

		if reset_i = '1' then

			presentstate_s <= closing1;

		elsif clk_i'event and clk_i = '1' then

			presentstate_s <= nextstate_s;

		end if;

	end process p_train_crossing_seq_p;

--	second process combinatorial

	p_train_crossing_com_p : process (presentstate_s, train_in_i, train_out_i)

	begin

		case presentstate_s is

		when opened =>

			engine_open_o <= '0';
			engine_close_o <= '0';
			light_o <= '0';
			blink <= 0;

			if train_in_i = '1' then

				nextstate_s <= closing1;

			else

				nextstate_s <= opened;

			end if;

		when closing1 =>

			engine_open_o <= '0';
			engine_close_o <= '1';
			light_o <= '1';

			if blink = 2 then

				nextstate_s <= closed1;
				blink <= 0;

			else

				nextstate_s <= closing2;

			end if;

		when closing2 =>

			engine_open_o <= '0';
			engine_close_o <= '1';
			light_o <= '0';
			blink <= blink + 1;
			nextstate_s <= closing1;

		when closed1 =>

			engine_open_o <= '0';
			engine_close_o <= '0';
			light_o <= '0';

			if train_out_i = '1' then

				nextstate_s <= opening2;

			else

				nextstate_s <= closed2;

			end if;

		when closed2 =>

			engine_open_o <= '0';
			engine_close_o <= '0';
			light_o <= '1';

			if train_out_i = '1' then

				nextstate_s <= opening1;

			else

				nextstate_s <= closed1;

			end if;

		when opening1 =>


			engine_open_o <= '1';
			engine_close_o <= '0';
			light_o <= '0';
			nextstate_s <= opening2;
			blink <= blink + 1;

		when opening2 =>

			engine_open_o <= '1';
			engine_close_o <= '0';
			light_o <= '1';

			if blink = 2 then

				nextstate_s <= opened;
				blink <= 0;

			else

				nextstate_s <= opening1;

			end if;

		when others =>

			nextstate_s <= closing1;

		end case;

  end process p_train_crossing_com_p;

end rtl;
