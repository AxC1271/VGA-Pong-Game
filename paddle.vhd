library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity paddle is
    port ( 
    clk    : in  STD_LOGIC;  
    rst    : in  STD_LOGIC;  
    up       : in  STD_LOGIC;  -- debounced button input
    down     : in  STD_LOGIC;  -- debounced button input
    paddle_y : out INTEGER range 0 to 900); -- paddle Y position
end paddle;

architecture Behavioral of paddle is
    signal clk_60Hz : STD_LOGIC := '0';
    signal paddle_y_reg : INTEGER range 0 to 900 := 390;  -- start at middle
begin
    -- we need a clock divider so that the position of the paddle doesn't
    -- update hundreds of millions of times a second
    -- We'll do a frequency of 60 Hz
    clock_divider : process(clk) is
        variable clock_count : integer range 0 to (100_000_000 / 60) := 0;
    begin
        if rising_edge(clk) then
            if clock_count = (100_000_000 / 60) then
                clk_60Hz <= not clk_60Hz;
                clock_count := 0;
            else
                clock_count := clock_count + 1;
            end if;
        end if;
    end process clock_divider;

    paddle_control : process(clk_60Hz) is
    begin
        if rising_edge(clk_60Hz) then
            if rst = '1' then
                paddle_y_reg <= 390;
            else
                -- move up if not at top edge
                if up = '1' and paddle_y_reg > 10 then
                    paddle_y_reg <= paddle_y_reg - 20;
                end if;

                -- move down if not at bottom edge
                if down = '1' and paddle_y_reg < 750 then
                    paddle_y_reg <= paddle_y_reg + 20;
                end if;
            end if;
        end if;
    end process paddle_control;

    paddle_y <= paddle_y_reg;

end Behavioral;
