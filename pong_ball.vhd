library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pong_ball is
    port (
    clk : in STD_LOGIC; 
    rst : in STD_LOGIC;
    paddle_x : in integer; -- fixed position for x-axis
    paddle_y : in integer range 0 to 900; -- move up and down for paddle
    ball_x : out integer range 0 to 1600;
    ball_y : out integer range 0 to 900 
    );
end pong_ball;

architecture Behavioral of pong_ball is
    
    signal clk_60Hz : STD_LOGIC := '0';
    signal ball_x_reg : integer range 0 to 1600 := 780;
    signal ball_y_reg : integer range 0 to 900 := 430;
    signal dx, dy : integer range -12 to 12 := 12; -- define ball velocity

begin
    -- Clock divider for 60 Hz update frequency
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

    -- ball control process for movement
    ball_control : process(clk_60Hz) is
begin
    if rising_edge(clk_60Hz) then
        if rst = '1' then
            -- reset ball position and velocity
            ball_x_reg <= 800;
            ball_y_reg <= 450;
            dx <= 12;
            dy <= 8;
        else
            -- check for collisions before updating position
            -- ball bouncing off top wall (y-axis)
            if (ball_y_reg + dy) <= 10 then
                dy <= -dy;
            end if;
            
            -- ball bouncing off bottom wall (y-axis)
            if (ball_y_reg + dy) >= 850 then
                dy <= -dy;
            end if;
            
            -- paddle collision detection
            if ((ball_x_reg + dx) <= (paddle_x + 10) and (ball_x_reg + dx) >= paddle_x)
            and (ball_y_reg >= paddle_y and ball_y_reg <= paddle_y + 150) then
                dx <= -dx;
            end if;
            
            -- ball bouncing off right wall (x-axis)
            if (ball_x_reg + dx) >= 1550 then
                dx <= -dx;
            end if;
            
            -- ball bouncing off left wall (x-axis)
            if (ball_x_reg + dx) <= 0 then
                dx <= -dx;
            end if;
            
            -- update ball position after checking collisions
            ball_x_reg <= ball_x_reg + dx;
            ball_y_reg <= ball_y_reg + dy;
        end if;
    end if;
end process ball_control;

    ball_x <= ball_x_reg;
    ball_y <= ball_y_reg;
    
end Behavioral;
