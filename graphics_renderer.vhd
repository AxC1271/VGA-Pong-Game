library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity graphics_renderer is
    port ( 
    clk : in  STD_LOGIC; 
    pixel_x   : in integer range 0 to 1600;  -- x value of pixel
    pixel_y   : in integer range 0 to 900;   -- y value of pixel
    ball_x    : in integer range 0 to 1600;  -- ball x position
    ball_y    : in integer range 0 to 900;   -- ball y position
    paddle_y  : in integer range 0 to 900;   -- paddle y position
    color     : out STD_LOGIC_VECTOR(11 downto 0)
    );  
end graphics_renderer;

architecture Behavioral of graphics_renderer is
    constant PADDLE_X : integer := 20;   
    constant PADDLE_W : integer := 20;
    constant PADDLE_H : integer := 120;  
    constant BALL_SIZE: integer := 40; 
    
begin

    graphics : process(clk) is
begin
    if rising_edge(clk) then
        -- background color (black)
        color <= "000000000000";  

        -- draw paddle first
        if (pixel_x >= PADDLE_X and pixel_x < PADDLE_X + PADDLE_W) and
        (pixel_y >= paddle_y and pixel_y < paddle_y + PADDLE_H) then
            color <= "111111111111";  -- white paddle
        -- draw ball next (ensures ball does not interfere with paddle rendering)
        elsif (pixel_x >= ball_x and pixel_x < ball_x + BALL_SIZE) and
              (pixel_y >= ball_y and pixel_y < ball_y + BALL_SIZE) then
            color <= "111100000000";  -- red ball
        end if;
    end if;
end process graphics;


end Behavioral;
