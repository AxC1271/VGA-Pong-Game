library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vga_controller is
    port ( 
    clk : in STD_LOGIC;  
    rst : in STD_LOGIC; 
    btn_up : in  STD_LOGIC; 
    btn_down : in  STD_LOGIC;  
    hsync : out STD_LOGIC;  
    vsync : out STD_LOGIC;  
    vga_r : out STD_LOGIC_VECTOR(3 downto 0); 
    vga_g : out STD_LOGIC_VECTOR(3 downto 0); 
    vga_b : out STD_LOGIC_VECTOR(3 downto 0)  
         );
end vga_controller;

architecture Behavioral of vga_controller is

    -- VGA Timing Constants for 1600x900 @ 60Hz (pixel clock = 86.4 MHz)
    constant H_PIXELS  : INTEGER := 1600; 
    constant H_FP      : INTEGER := 40;   
    constant H_PULSE   : INTEGER := 80;   
    constant H_BP      : INTEGER := 80;  
    constant H_TOTAL   : INTEGER := 1800; 

    constant V_PIXELS  : INTEGER := 900; 
    constant V_FP      : INTEGER := 3;    
    constant V_PULSE   : INTEGER := 6;    
    constant V_BP      : INTEGER := 17;   
    constant V_TOTAL   : INTEGER := 926; 

    signal pixel_x : INTEGER range 0 to H_TOTAL - 1 := 0;
    signal pixel_y : INTEGER range 0 to V_TOTAL - 1 := 0;

    -- game-related signals
    signal ball_x   : INTEGER range 0 to 1600 := 780; -- start in the middle
    signal ball_y   : INTEGER range 0 to 900 := 430;
    signal paddle_y : INTEGER range 0 to 900 := 400;
    signal color    : STD_LOGIC_VECTOR(11 downto 0);  -- 12-bit color output
    
    signal pixel_clk : STD_LOGIC := '0';
    
    signal db_btn_up : STD_LOGIC;
    signal db_btn_down : STD_LOGIC;

begin

    -- VGA horizontal and vertical sync generation
    vga_sync : process(clk) is
    begin
        if rising_edge(clk) then
            if pixel_x < H_TOTAL - 1 then
                pixel_x <= pixel_x + 1;
            else
                pixel_x <= 0;
                if pixel_y < V_TOTAL - 1 then
                    pixel_y <= pixel_y + 1;
                else
                    pixel_y <= 0;
                end if;
            end if;
        end if;
    end process vga_sync;

    -- generate sync pulses (active low)
    hsync <= '0' when (pixel_x >= H_PIXELS + H_FP and pixel_x < H_PIXELS + H_FP + H_PULSE) else '1';
    vsync <= '0' when (pixel_y >= V_PIXELS + V_FP and pixel_y < V_PIXELS + V_FP + V_PULSE) else '1';

    -- instantiate all modules
    
    debounced_btn_up : entity work.button_debounce 
        port map (
            clk => clk,
            btn_in => btn_up,
            btn_out => db_btn_up
        );
        
    debounced_btn_down : entity work.button_debounce 
        port map (
            clk => clk,
            btn_in => btn_down,
            btn_out => db_btn_down
        );
    
    
    paddle_ctrl: entity work.paddle
        port map (
            clk => clk,
            rst => rst,
            up => db_btn_up,
            down => db_btn_down,
            paddle_y  => paddle_y
        );

    ball_ctrl: entity work.pong_ball
        port map (
            clk => clk,
            rst => rst,
            paddle_x => 20,
            paddle_y => paddle_y,
            ball_x    => ball_x,
            ball_y    => ball_y
        );

    renderer: entity work.graphics_renderer
        port map (
            clk => clk,
            pixel_x   => pixel_x,
            pixel_y   => pixel_y,
            ball_x    => ball_x,
            ball_y    => ball_y,
            paddle_y  => paddle_y,
            color     => color
        );

    vga_r <= color(11 downto 8); -- red
    vga_g <= color(7 downto 4);  -- green
    vga_b <= color(3 downto 0);  -- blue

end Behavioral;
